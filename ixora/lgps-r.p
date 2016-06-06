/* lgps-r.p
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
def shared var g-ofc like bank.ofc.ofc.
find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error .
if avail bank.sysc  then   m_hst = trim(bank.sysc.chval).
do transaction:
 create shtbnk.logfile .
 dattim = string(today) + " " + string(time,"hh:mm:ss") .
 mess  = m_hst + " " + m_pid + " " +
 m_copy + " " + u_pid + " " + g-ofc + " REMOTE " + v-text .
end.
