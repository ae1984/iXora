/* LB_ps.p
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

 def input parameter kod as char.
 {global.i}
 {lgps.i }
 def shared var vnum like clrdoc.pr .
 def shared var s-remtrz like remtrz.remtrz.
 /*u_pid = 'LB'. */
 u_pid = kod.
 
 do transaction :
 find first que where que.remtrz = s-remtrz 
 and  que.pid = u_pid  exclusive-lock no-error.
 if avail que then
  do:
   que.dw = today.
   que.tw = time.
   que.con = "F".
   que.rcod = "0".
   v-text = s-remtrz + " обработан " +
   "( que.rcod = " + string(que.rcod) + " ) Клиринг N " +  string(vnum)  .
    run lgps.
  end.
end.
