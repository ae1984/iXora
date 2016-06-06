/* drout_ps.p
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
        18/02/2005 kanat
 * CHANGES
        01.03.2005 kanat - изменил запросы по remtrz
        05.03.2005 kanat - добавил дополнительное условие по филиалам банка получателя для прямых корр. отношениям
        23.03.2005 kanat - добавил условие по счетам ГК DFB
        14.04.2005 kanat - добавил обработку транспорта 2 для ПКО
        21.04.2005 kanat - добавил обработку транспорта 3!? для ПКО
        24/05/2005 kanat - перекомпиляция
        02/08/2005 kanat - добавил обработку LORO - счетов банков
        10/08/2005 kanat - добавил редактирование счетов ГК по кредиту
*/


{global.i}
{lgps.i}

find first que where que.pid = m_pid and que.con = "W" use-index fprc exclusive-lock.
if avail que then do:

        find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock.
        if avail remtrz then do:

                find first clrdir where clrdir.rem = remtrz.remtrz and clrdir.sts = 0 no-lock no-error.
                if avail clrdir then do:

                        find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
                        find first direct_bank where direct_bank.bank1 = bankl.cbank no-lock no-error.
                        if avail direct_bank then do:


        if direct_bank.ext[3] <> "" and direct_bank.ext[3] <> ? then do:
        remtrz.cracc = trim(direct_bank.ext[3]).  /* LORO счет банка получателя */
        find first aaa where aaa.aaa = remtrz.cracc no-lock no-error.
        if avail aaa then do:
        remtrz.crgl = aaa.gl.
        remtrz.rsub = "cif".
        end.
        end.
        else                           
        remtrz.cracc = direct_bank.bank2.  /* NOSTRO счет банка получателя */


/*  kanat - условие по счетам ГК DFB*/

  find first dfb where dfb.dfb = remtrz.cracc no-lock no-error.
  if avail dfb then do:
  remtrz.crgl = dfb.gl.
  end.


   if trim(remtrz.source) = "PRR" and remtrz.cover = 1 then do:
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "1".
   end.

   if trim(remtrz.source) <> "PRR" and remtrz.cover = 1 then do:
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "0".
   end.

   if remtrz.cover = 2 then do:
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "2".
   end.

   if remtrz.cover <> 1 and remtrz.cover <> 2 then do:
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "3".
   end.

   find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
   if avail sub-cod then  do:
      remtrz.cracc = "900161014".
      remtrz.crgl = 105100.
      que.dp = today.
      que.tp = time.
      que.con = "F".
      que.rcod = "4".
   end.

v-text = remtrz.remtrz + " обработан (прямые корр. отношения) ( que.rcod = " + string(que.rcod) + " )".
run lgps.
                        end.
                end.
        end.
end.


