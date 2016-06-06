/* ps.p
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

{global.i "NEW GLOBAL"}.

run setglob.
if g-ofc eq "" then do:
 input through whoami.
 import g-ofc.
 g-ofc = trim(g-ofc) . 
end.
def var i as int.
def var tmp as cha.
def var olddate as date .
def var v-tout like dproc.tout .
def var v-oldtout like dproc.tout .
def new shared var n-list as int initial 1 .
{lgps.i "new global"}
input through echo $pid .
import m_pid.
if m_pid = "" then
 do:
  v-text = " Нет кода  процесса ! " .
  put unformatted v-text skip.  pause 0 .
  run lgps.
  quit.
 end.
input through echo $hst .
import m_hst.
if m_hst = "" then
 do:
  v-text = " Нет кода HOSTа ! " .
  put unformatted v-text skip.  pause 0 .
  run lgps.
  quit.
 end.
input through echo $copy .
import m_copy.
if m_copy = "" then
 do:
  v-text = " Нет номера копии процесса ! " .
  put unformatted v-text skip.  pause 0 .
  run lgps.
  quit.
 end.


input through value("ps_pid " + trim(m_hst) + " " +  trim(m_pid) + " " + string(m_copy,"99") ) .

tmp = "" .
i = 0.
repeat:
 import tmp .
 i = i + 1 .
end.
 input close.
if i > 1   then
  do:
   v-text = " Процесс уже работает ! " .
   put unformatted v-text skip.  pause 0 .
   run lgps.
   return .
  end.


/*if u_pid eq "0" then do:*/

input through
 value("echo $UPID") .
 import u_pid .
 input close.
/*end  .*/

   v-text = " u_pid !!!! " + trim(u_pid) .
   put unformatted v-text skip.  pause 0 .
   run lgps.

if u_pid = "" then
  do:
   v-text = " Не могу считать UNIX_ID для процесса ! " .
   put unformatted v-text skip.  pause 0 .
   quit.
  end.

v-text = " Процесс запущен. ".
  put unformatted v-text skip.  pause 0 .
run lgps.

  if search(m_pid + "_ps.r") eq ? then
  do:
   put unformatted m_pid + "_ps.r не найден " skip . pause 0 .
   v-text = m_pid + "_ps.r не найден " .
   run lgps.
   quit .
   end .

find first fproc where fproc.pid = m_pid no-lock no-error .
 if not avail fproc then
  do:
    v-text = " Нет описания процесса в fproc файле ! " .
    put unformatted v-text " " m_pid " " m_copy skip.  pause 0 .
    run lgps.
    quit.
  end.

do transaction :
 find first dproc where dproc.pid = m_pid and dproc.copy = integer(m_copy)
   exclusive-lock no-error .
 if avail dproc then delete dproc .
 create dproc.
 dproc.pid = m_pid .
 dproc.copy = integer(m_copy).
 dproc.tout = fproc.tout.
 dproc.u_pid = integer(u_pid).
end.

 v-tout = time + dproc.tout .
 v-oldtout = dproc.tout .
 release dproc.


repeat on error undo , leave  :
 
   
find first dproc where dproc.u_pid = integer(u_pid) no-lock no-error .
if not avail dproc then do:
 v-text = "Ошибка : Неожиданный останов процесса UNIX_ID = " + u_pid .
 run lgps .
 quit .  
end. 
if dproc.tout = 1000 then
do transaction :
  find first dproc where dproc.u_pid = integer(u_pid) exclusive-lock .
  delete dproc.
  v-text = string(today) + " " + string(time,"hh:mm:ss") + 
    " Процесс остановлен ! " .
  put unformatted v-text skip.  pause 0 .
  run lgps.
  output close .
  quit.
end.

 if v-oldtout = 0 or dproc.tout = 77777 then pause 0 .
  else
 pause 1.
 if v-oldtout ne dproc.tout or olddate ne today then do:
  v-tout    = time + dproc.tout .
  olddate = today .
  v-oldtout = dproc.tout .
 end.
if dproc.tout = 77777 then 
do :
 find first que where que.pid = m_pid and que.con = "W"
  use-index fprc no-lock no-error.
 if not avail que then do:
     do transaction :
      find first dproc where dproc.u_pid = integer(u_pid) exclusive-lock .
      dproc.hst = "wait".
     end.
   release dproc.
   pause 999999999.
    do transaction :
     find first dproc where dproc.u_pid = integer(u_pid) exclusive-lock .
     dproc.hst = "".
    end.
   find first dproc where dproc.u_pid = integer(u_pid) no-lock .
   find first que where que.pid = m_pid and que.con = "W"
   use-index fprc  no-lock no-error.
 end.
end.
if (dproc.tout = 77777 and avail que) 
 or (dproc.tout ne 77777 and time >= v-tout) 
 then do:
  v-tout = time + dproc.tout .
  v-text = "" .
  /*
  if avail que then   run value(m_pid + trim(que.ptype) + "_ps.r"). 
  else 
  */
  run value(m_pid + "_ps.r").
  do transaction :
   find first dproc where dproc.u_pid = integer(u_pid) 
    exclusive-lock no-error.
   if not avail dproc then do:
    v-text = "Ошибка : Неожиданный останов процесса UNIX_ID = " + u_pid .
    run lgps .
    for each dproc no-lock . 
     display dproc . pause 0 . 
    end. 
    quit .
   end.
   dproc.l_time = time.
  end.
 end.
 release que. 
 release dproc.
end.
