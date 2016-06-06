/* M_ps.p
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
 def var nxt like route.npc.
 def buffer  b-que for que . 
for each  b-que where b-que.con = "F" use-index fmnt no-lock .
 do transaction :
 find first que where recid(que) = recid(b-que) exclusive-lock no-wait 
  no-error.  
    if not avail que then next .
    find first route where  route.ptype = que.ptype and
    route.pid = que.pid and
    route.rcod = que.rcod no-lock no-error .
    if not available route then do:
       v-text = "Route error for PTYPE " + que.ptype + " PID " +
       que.pid + " " + que.rcod + " " + que.remtrz + " -> E " .
       run lgps.
       nxt = "E" .
      end.
      else nxt = route.npc .
   que.pid = nxt .
   que.df = today.
   que.tf = time.
   que.con = "W".
   if substr(que.npar,1,9)  = " Last PRI" then que.npar = "" .
    que.npar  = " Last PRI = " + string(que.pri,"zzzz9") +
    " Last PID = " + string(que.pid) + que.npar .
   que.pvar = "".
   /*
   v-text = "I'm monitor ... " + que.remtrz + " -> " + string(que.pid).
   run lgps.    */
   release que.
   end.
  end.
