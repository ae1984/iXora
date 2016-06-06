/* SG_ps.p
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
        02.03.2005 kanat - счет поменял на drout
        05.04.2005 kanat - добавил условие по филиалам банком для прямых корр. отношений и для истории очереди DROUT
        23/03/2005 kanat - раскомментировал условие по суммам платежей
        05/04/2005 kanat - добавил дополнительное условие по дате валютирования
        13/04/2005 kanat - добавил проверку на 2 дату валютирования по платежам ПКО
        24/05/2005 kanat - перекомпиляция
        05/09/2005 kanat - изменил запрос по clrdir.sts = 1 и 0
        06/10/2005 suchkov - раскомментировал и слегка изменил проверку на первую проводку.
        29/03/2006 suchkov - добавил обработку "вечерних" платежей после 18-00 (STIME)
        19.09.2012 Lyubov - добавлены зарплатные платежи
        19/08/2013 galina  - добавла обработку СМЭП

*/

{global.i}
{lgps.i}

def var exitcod as char no-undo.
def var v-sqn as char no-undo.
def var v-depart as char init "" no-undo.

def var v-dirsum1 as decimal init 0 no-undo.
def var v-dirsum2 as decimal init 0 no-undo.

def var u_ms as integer no-undo.
def var u_ys as integer no-undo.

def var v-lbnstr as char no-undo.
def var v-dirprc as decimal no-undo.
define variable v-weekend as integer no-undo .
define variable v-weekbeg as integer no-undo .

 find sysc where sysc.sysc = "LBNSTR" no-lock  no-error.
   if not avail sysc then
    do:
       v-text = " Нет LBNSTR записи в sysc файле ".
       return.
    end.
   else
   v-lbnstr = sysc.chval.


 find sysc where sysc.sysc = "DIRPRC" no-lock  no-error.
   if not avail sysc then
    do:
       v-text = " Нет DIRPRC записи в sysc файле ".
       return.
    end.
   else
   v-dirprc = sysc.deval.

 do transaction :
 find first que where que.pid = m_pid and que.con = "W" and not locked que use-index fprc exclusive-lock no-error no-wait.
/*
 find first que where que.pid = m_pid and que.con = "W" use-index fprc  exclusive-lock no-error.
*/
 if avail que then
  do:
   que.dw = today.
   que.tw = time.
   que.con = "P".

   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock.
   /*  Beginning of main program body */

  find first jl where jl.jh = remtrz.jh1 no-lock no-error.
  if not available jl then do :
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "10".
   v-text = " Ошибка ! 1 проводка не найдена " + remtrz.remtrz.
   run lgps.
   return.
  end.


   /*  End of program body */
   que.dp = today.
   que.tp = time.
   que.con = "F".

   find jh where jh.jh = remtrz.jh2 no-lock no-error.
   if not avail jh then do:

   find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
   find first direct_bank where direct_bank.bank1 = bankl.cbank and
                                direct_bank.limit_sum2 >= remtrz.amt and
                                direct_bank.limit_time1 <= time and
                                direct_bank.limit_time2 >= time no-lock no-error.

   if not avail direct_bank then do:
   run init_rcods.
   end.
   else do:

/* 13/04/2005 kanat - добавил дополнительную проверку на 2 дату валютирования при отправке платежей по ПКО */

   if remtrz.valdt1 = g-today and
      remtrz.valdt2 = remtrz.valdt1 and
      not remtrz.rcvinfo[1] matches "*/TAX/*" and
      not remtrz.rcvinfo[1] matches "*/PSJ/*" and
      not remtrz.rcvinfo[1] matches "*/PNJ/*" and
      not remtrz.rcvinfo[1] matches "*/ZP/*" then do:

   assign u_ms = month(g-today) - 1
          u_ys = year(g-today).

   if u_ms = 0 then assign u_ms = 12
                           u_ys = u_ys - 1.

  v-dirsum1 = 0.
  for each rmzshst where month(rmzshst.regdate) = u_ms and year(rmzshst.regdate) = u_ys and rmzshst.ptype = "I" no-lock.
  v-dirsum1 = v-dirsum1 + rmzshst.sum.
  end.

  v-dirsum2 = 0.
  for each clrdir where clrdir.cmon = month(g-today) and clrdir.ctoy = year(g-today) no-lock.
  v-dirsum2 = v-dirsum2 + clrdir.amt.
  end.

   if ((v-dirsum1 * v-dirprc) / 100) >= (v-dirsum2 + remtrz.amt) then do:

/*
        05/09/2005 kanat - изменил запрос по clrdir.sts = 1 и 0
*/

   find first clrdir where clrdir.rem = remtrz.remtrz and clrdir.sts = 1 no-lock no-error.
   if not avail clrdir then do:
   find first clrdir where clrdir.rem = remtrz.remtrz and clrdir.sts = 0 no-lock no-error.
   if not avail clrdir then do:

/*
        05/09/2005 kanat - изменил запрос по clrdir.sts = 1 и 0
*/

   create clrdir.
   update clrdir.rem = remtrz.remtrz
          clrdir.rdt = g-today
          clrdir.amt = remtrz.amt
          clrdir.tim = time
          clrdir.cmon = month(g-today)
          clrdir.ctoy = year(g-today)
          clrdir.sts = 0.

   que.rcod = "90".

   end.
   end.
   end.
   else do:
   run init_rcods.
   end.
   end.        /*  проверка на source ... */
   else do:
   run init_rcods.
   end.
   end.

   end.
   else do:       /* if 2trx was done */
     if remtrz.cracc eq trim(v-lbnstr) and remtrz.cover ne 4
     then
      que.rcod = "2".
     else  que.rcod = "3".  /*  finish   */
   end.

   v-text = remtrz.remtrz + " обработан  ( que.rcod = " + string(que.rcod) + " )" .
   if lookup(remtrz.source,"PNJ,ZP") > 0 then v-text = v-text + ", дата 2 " + string(remtrz.valdt2, "99/99/99").
   run lgps.
  end.
 end.


procedure init_rcods.
    if remtrz.cracc eq trim(v-lbnstr) and crgl ne 0 then do:
       if remtrz.source = "IBH" then v-depart  = "I".
       else do:
         find last ofchis where ofchis.ofc = remtrz.rwho no-lock no-error.
         if avail ofchis then do:
            if ofchis.depart = 1 then v-depart  = "".
            else v-depart  = trim(string(ofchis.depart - 1,">>>9")).
         end.
       end.
/**/
        if v-depart  = "I" then do:
        find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
        find first bankt where bankt.cbank = bankl.cbank and
            bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .
           if remtrz.valdt2 = g-today and bankt.vtime < time
                then remtrz.cover = 2.
        end.
/**/

       if remtrz.cover = 1  then
          que.rcod = "0" + v-depart.     /* NET  */
       else  if remtrz.cover = 2 then que.rcod = "1" + v-depart. /* GROSS*/
       if remtrz.valdt2 gt g-today
       then que.rcod = "6".     /*  valdt ne today   */
       /****galina обрботка нового типа транспорта СМЭП******/
       if remtrz.cover = 6  then do:
           que.rcod = "7".
       end.
       /*********/

       /*suchkov - 23.03.06 - Обработка времени отправки платежа */
       find first sysc where sysc.sysc = "STIME" no-lock no-error.
       if available sysc and sysc.inval < time then do:

          find sysc "WKEND" no-lock no-error.
          if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

          find sysc "WKSTRT" no-lock no-error.
          if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.


          find first sub-cod where
          sub-cod.d-cod = 'eknp' and
          sub-cod.ccode = 'eknp' and
          sub-cod.sub   = 'rmz'  and
          sub-cod.acc   = remtrz.remtrz
          no-lock no-error.
          if available sub-cod then do:
                if substring(sub-cod.rcode,1,2) = "13" and substring(sub-cod.rcode,4,2) = "14" or
                   substring(sub-cod.rcode,1,2) = "14" and substring(sub-cod.rcode,4,2) = "13" then do:
                   repeat:
                     find hol where hol.hol eq remtrz.valdt2 no-lock no-error.
                     if not available hol and weekday(remtrz.valdt2) ge v-weekbeg and weekday(remtrz.valdt2) le v-weekend then leave.
                     else remtrz.valdt2 = remtrz.valdt2 + 1.
                   end.
                   que.rcod = "6".
                end.
          end.
          else do:
                v-text = " Ошибка ! Не найден EKNP для " + remtrz.remtrz.
                run lgps.
          end.
       end.
    end.
   else do :
      if crgl ne 0 then que.rcod = "4".
      else
      do:
        if remtrz.ptype = "2" then do:
           que.rcod = "3".
        end.
        else
           que.rcod = "5".
      end.
   end.
end.

