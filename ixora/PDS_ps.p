/* PDS_ps.p
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

 {global.i }
 {lgps.i }
def new shared var s-remtrz like remtrz.remtrz.
def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha .
def buffer our for sysc .
def new shared stream m-doc.
def var tra as char.
/*
m_pid = "PDS".
u_pid = "SWD".
*/

find first sysc where sysc.sysc = "PR-DIR" no-lock no-error .

 if not avail sysc then do:
  v-text = " Записи PR-DIR нет в sysc файле " .  run lgps.
  return .
 end.

 do transaction :
 find first que where que.pid = m_pid and que.con = "W"
   use-index fprc  exclusive-lock no-error.
 if avail que then
  do:
   que.dw = today.
   que.tw = time.
   que.con = "P".

   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
   s-remtrz = remtrz.remtrz.
   tra = trim(remtrz.t_sqn).

   /*  Beginning of main program body */

   if tra = "" then do :
      que.dp = today.
      que.tp = time.
      que.con = "F".
      que.rcod = "1".
      v-text = "Ссылочный номер SWIFT отсутствует для платежа " + remtrz.remtrz.
      run lgps.
      return.
   end.

 find jh where jh.jh = remtrz.jh1 no-lock no-error.
 if not available jh then do :
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "1".
   v-text = "Нет 1 проводки для платежа " + remtrz.remtrz.
   run lgps.
   return.
 end.

/** KOVAL
  unix silent value("swiarc " + tra + " | swtrans -1 >  tmpsw_ps.img ").
  unix silent value("cat tmpsw_ps.img >> " + sysc.chval + "/SW.log").
  pause 0.                               
  output to value(sysc.chval + "/SW.log") append.
  put skip(10).
  output close.
**/

   /*  End of program body */
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "0".
   v-text = " Платежный документ сформирован для платежа " + remtrz.remtrz.
   run lgps.
   release remtrz.
  end.
 end.
