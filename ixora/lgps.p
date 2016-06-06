/* lgps.p
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

{lgps.i }
def shared var g-ofc like ofc.ofc.
if m_hst = "" then do:

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message " Нет записи OURBNK в sysc файле !".
 pause .
end.

m_hst = trim(sysc.chval).

end.
if m_pid = ""  then m_pid = "XXX" . 
if m_copy = "" then m_copy = "XX" .
if u_pid = "" then u_pid = "XXXXX" . 
if m_hst = "" then m_hst = "XXXXX" .
do transaction:
 create logfile .
 dattim = string(today) + " " + string(time,"hh:mm:ss") .
 mess  = m_hst + " " + m_pid + " " +
 m_copy + " " + u_pid + " " + g-ofc + " " + v-text .
end.
