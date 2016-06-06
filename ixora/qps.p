/* qps.p
 * MODULE
        Процессы для работы с Sonic
 * DESCRIPTION
        Sonic 4-gl process caller
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
        05/03/2009 madiyar - скопировал из ps.p с изменениями
 * BASES
        BANK
 * CHANGES
        11/03/2009 madiyar - убрал мусор
        05/11/2009 madiyar - перекомпиляция
*/

{global.i "NEW GLOBAL"}.

run setglob.
if g-ofc eq "" then do:
    input through whoami.
    import g-ofc.
    g-ofc = trim(g-ofc).
end.

{qps.i "new"}.

input through echo $pid.
import m_pid.
if m_pid = "" then do:
    put unformatted "Нет кода процесса!" skip. pause 0.
    quit.
end.
input through echo $hst.
import m_hst.
if m_hst = "" then do:
    put unformatted "Нет кода HOSTа!" skip. pause 0.
    quit.
end.
input through echo $copy.
import m_copy.
if m_copy = "" then do:
    put unformatted "Нет номера копии процесса!" skip. pause 0.
    quit.
end.

input through
value("echo $UPID") .
import u_pid .
input close.
put unformatted " u_pid !!!! " + trim(u_pid) skip. pause 0.

if u_pid = "" then do:
    put unformatted "Не могу считать UNIX_ID для процесса!" skip. pause 0.
    quit.
end.

put unformatted "Процесс запущен" skip. pause 0.

find first qproc where qproc.pid = m_pid no-lock no-error.
if not avail qproc then do:
    put unformatted "Нет описания процесса в qproc файле! " + m_pid + " " + m_copy skip. pause 0.
    quit.
end.

do transaction:
    find first qproca where qproca.pid = m_pid and qproca.copy = integer(m_copy) exclusive-lock no-error.
    if avail qproca then delete qproca.
    create qproca.
    assign qproca.pid = m_pid
           qproca.copy = integer(m_copy)
           qproca.u_pid = integer(u_pid).
end. /* transaction */

release qproca.

run value(qproc.proc).

