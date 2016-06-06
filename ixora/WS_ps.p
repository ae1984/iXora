/* WS_ps.p
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
def var v-sub as char init "".


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
   
   if remtrz.bi = "our" then do :
    find first bankt where bankt.cbank = remtrz.scbank and
     bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .
    if avail bankt then v-sub =  bankt.subl. 
   end.

   /*  End of program body */
 
   que.dp = today.
   que.tp = time.
   que.con = "F".
   if v-sub = "cif" then do :
     if remtrz.jh1 = ? or remtrz.jh1 = 0 then
      que.rcod = "10".
     else que.rcod = "20".
   end.
   else do :
     if remtrz.jh1 = ? or remtrz.jh1 = 0 then
      que.rcod = "0".
     else que.rcod = "1".
   end.

   if remtrz.fcrc ne 1 then do :
      if remtrz.jh1 = ? then  que.rcod = "40".
      else que.rcod = "50".
   end.
     
   v-text = remtrz.remtrz + 
     " обработан код завершения = " + que.rcod .
   run lgps.
  end.
 end.
