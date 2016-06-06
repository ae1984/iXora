/* SNS_ps.p
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
 {lgps.i }
def var exitcod as cha .
def var v-sqn as cha .


 do transaction :
 find first que where que.pid = m_pid and que.con = "W"
   use-index fprc  exclusive-lock no-error.
 if avail que then
  do:
   que.dw = today.
   que.tw = time.
   que.con = "P".

   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
   /*  Beginning of main program body */


   /*  End of program body */
   que.dp = today.
   que.tp = time.
   que.con = "F".
   if remtrz.info[3] begins "11B" then que.rcod = "1".
   else que.rcod = "0" .

   v-text =  remtrz.remtrz + 
     " обработан код завершения = " + que.rcod .
   run lgps.
  end.
 end.
