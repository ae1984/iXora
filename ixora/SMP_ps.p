/* SMP_ps.p
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
        19.08.2013 galina ТЗ1871
* BASES
        BANK
 * CHANGES
*/

 def input parameter kod as char.
 {global.i}
 {lgps.i }
 def  shared var vnum like clrdoc.pr .

 def shared var s-remtrz like remtrz.remtrz.
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
   "( que.rcod = " + string(que.rcod) + " )  СМЭП N " +  string(vnum)  .

    run lgps.
  end.
end.
