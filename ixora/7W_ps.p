/* 7W_ps.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        02.04.2004 nadejda - добавила просмотр остатка на счете получателя по счету ГК
*/


{global.i}
{lgps.i }
def var v-sqn as cha .
def var v-field as char.
def var v-amt like remtrz.payment.
def var v-crc like remtrz.tcrc.
def var num as cha.
def var vbal as dec.
def buffer xaaa for aaa.

for each  que where que.pid = m_pid and que.con = "W" use-index fprc exclusive-lock .

   que.dw = today.
   que.tw = time.
   find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.

 /*  Beginning of main program body */

/* 02.04.2004 nadejda - поиск счета получателя по счету ГК */
   if remtrz.crgl <> 0 then do:
     find first gl where gl.gl = remtrz.crgl no-lock no-error.

     case gl.sub:
       when "cif" then do:
         /* проверка суммы на клиентском счете */

         find first aaa where aaa.aaa = remtrz.cracc no-lock no-error.
         if not avail aaa then do:
            v-text = "Ошибка! " + remtrz.cracc + " не найден...".
            run lgps.
            release que. 
            next. 
         end.

         if aaa.craccnt <> "" then
         find first xaaa where xaaa.aaa = aaa.craccnt exclusive-lock no-error.
         vbal = aaa.cbal - aaa.hbal + ( if available xaaa then xaaa.cbal else 0 ).
       end.

       when "arp" then do:
         /* проверка суммы на ARP-счете */
         find first arp where arp.arp = remtrz.cracc no-lock no-error.
         if not avail arp then do:
            v-text = "Ошибка! " + remtrz.cracc + " не найден...".
            run lgps.
            release que. 
            next. 
         end.

         find trxbal where trxbal.sub = gl.sub and trxbal.acc = remtrz.cracc and 
                           trxbal.crc = arp.crc and trxbal.lev = 1 no-lock no-error.
         vbal = trxbal.cam - trxbal.dam.
         if lookup(gl.type, "a,r") > 0 then vbal = - vbal.
       end.
     end case.
   end.
   else do:
     find first dfb where dfb.dfb = remtrz.cracc no-lock no-error .

     if  not avail dfb then do:
         v-text = "Ошибка ! "  + remtrz.cracc + " не найден ".
         run lgps.
         release que. 
         next.
     end.
     vbal = dfb.dam[1] - dfb.cam[1].
   end.

   vbal = vbal - remtrz.amt.

   if vbal < 0 then do : 
     release que. 
     next. 
   end .

   v-text = "Платеж " + remtrz.remtrz + " отправлен с " + m_pid +
            " на 2 проводку . Остаток  = " + string (vbal) .

   /*  End of program body */
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "0".
   release que .
   run lgps.
end.
