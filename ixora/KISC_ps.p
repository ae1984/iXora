/* KISC_ps.p
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

/* 
   KOVAL
   Писанина в лог
*/

 {global.i}
 {lgps.i}

 def input parameter kod as char.
 def input parameter vnum like clrdoc.pr .
 def input parameter s-remtrz like remtrz.remtrz.
 def input parameter i-system as char.

 u_pid = kod.
 
 do transaction :
 find first que where que.remtrz=s-remtrz and que.pid=u_pid exclusive-lock no-error.
 if avail que then do:
   que.dw = today.
   que.tw = time.
   if kod="V2" then que.rcod = "1". else que.rcod = "0".
   que.con = "F".
   v-text = s-remtrz + " обработан " + "( que.rcod = " + string(que.rcod) + " ) " + i-system + " N " +  string(vnum).
   run lgps.
 end.
end.
/* Для v2 отправим как LB, LBG */