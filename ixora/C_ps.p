/* C_ps.p
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
*/

 {global.i}
 {lgps.i}
 def var nxt like que.rcod .
 do transaction :
 find first que where que.pid = m_pid and que.con = "W"
   use-index fprc  exclusive-lock no-error.
 if avail que then
  do:
   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
   que.dw = today.
   que.tw = time.
   que.con = "P".
   if que.pvar = "" then
    que.pvar = string(que.pri).

       /* Begining of the program body   */

   find first jh where remtrz.jh1 = jh.jh no-lock no-error .
   if not avail jh then
   do:
     v-text = " 1 проводка не найдена в jh файле для " + remtrz.remtrz .
     run lgps.
     nxt = "10".
     que.con = "F".
     que.pri = integer(que.pvar).
     que.pvar = "" .
   end.
  else
  if jh.sts = 6 then do:
    find first jl where jl.jh = jh.jh no-lock.
    v-text = "1 проводка акцептована " + jl.teller + " для " + remtrz.remtrz .
    run lgps.
    que.rcod = "0".
    que.con = "F".
    que.pri = integer(que.pvar).
    que.pvar = "" .
  end.
  else
  if jh.sts ne 6 then do:
    que.pri = que.pri + 1 .
    if que.pri > 29999 then que.pri = 1 .
    que.con = "W".
  end.
   /* end of program body */
   que.dp = today.
   que.tp = time.
 end.
 release que . 
 release remtrz.
 end.
