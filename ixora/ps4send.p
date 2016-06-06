/* ps4send.p
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
  24.05.2003 nadejda - убраны параметры -H -S из коннекта 
*/
def buffer tgl for gl.
def var acode like crc.code.
def var bcode like crc.code.
def var oldpid like que.pid .
def var prilist as cha.
def var oldpri like que.pri .
def var nparpri as cha .
def var nparpid as cha .
def var yn as log format "да/нет" initial false .
def new shared var v-weekbeg as int.
def new shared var v-weekend as int.

def shared frame remtrz.

{global.i}
{ps-prmt.i}
{lgps.i}
{rmz.f}

 find sysc "WKEND" no-lock no-error.
  if available sysc then v-weekend = sysc.inval. else v-weekend = 6.
 find sysc "WKSTRT" no-lock no-error.
  if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.


def shared var s-remtrz like que.remtrz.

find first que where que.remtrz = s-remtrz no-lock .
find first remtrz where remtrz.remtrz = que.remtrz no-lock .
if not remtrz.rbank begins "RKB" then return .
find first bankl where remtrz.rbank = bankl.bank no-lock no-error .
if not avail bankl then do:
 message " There isn't bankl record ..." + remtrz.rbank . 
 pause . 
 return .
end .
 if bankl.acct ne "" then do:     /*  Progress connect  */
 if que.pid ne "4N" then return .
 m_pid = "4" + substr(remtrz.rbank,4,2) .
 find first dproc where dproc.pid = m_pid no-lock no-error .
 if avail dproc then 
  do:
   message "Остановите  " + m_pid + " процесс сначала !" . 
   pause .
   return .
  end.
   yn = false .
   Message "Вы уверены ? " update yn .
 if not yn then return .
   v-text = "Прямой доступ к базе -> " + remtrz.rbank  . run lgps . 
   message v-text .
 if not connected("shtbnk") then 
   connect value(" -db " +  bankl.chipno + " -ld shtbnk -trig /platon/RXRMT.pl")  no-error .  

if not connected("shtbnk") 
then do:
 v-text = " Ошибка ! . HOST " + bankl.acct + " не отвечает " .  
  run lgps .           
  message v-text . 
  pause .
 return .
end.
message "".
if connected("shtbnk") then run pssend. 
pause 0 . 
if connected("shtbnk") then disconnect shtbnk .
end.
else do:    /*  laska  */ 
if que.pid ne "4" then return .
 m_pid = "4"  .
  find first dproc where dproc.pid = m_pid no-lock no-error .
   if avail dproc then
    do:
     message "Остановите  " + m_pid + " процесс сначала !" .
     pause .
     return .
    end.
    yn = false .
    Message "Вы уверены ? " update yn .
    if not yn then return .
     message " Отправка в транспортную систему ... " . 
    run 4lsk .
end . 

if que.rcod = "0" then do:
 message "Выполнено " . pause . 
end.
else do:
 message v-text . pause . 
end.



