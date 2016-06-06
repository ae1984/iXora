/* p_wl-rozn.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        03.10.2013 dmitriy
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
{push.i}

def new shared temp-table wrk no-undo
    field bank as char
    field bankn as char
    field grp as int
    field clGroup as integer
    field cif as char
    field cifn as char
    field lon as char
    field manager as char
    field riskManager as char
    field zalogManager as char
    field turnoverDecrease as deci
    field cushion as deci
    field applicationDate as date
    field lastMonitoring as date
    field fsDecline as char
    field approvalDate as date
    field rdt as date
    field duedt as date
    field prem as deci
    field prov as deci
    field opnamt as deci
    field od as deci
    field prc as deci
    field zalog as char
    field overdue as deci
    field daysOverdue as integer
    field maxDaysOverdue as integer
    field overdueCount as integer
    field appropriateUseFundsPrc as deci
    field blocks as char
    field isRestructured as char
    field industryEstimation as char
    field industry as char
    field lnObject as char
    field isAffil as char
    field kkres as char
    field err as char
    field poolmsfo as char
    field provmsfo as deci
    field shtraf as deci
    field nedvij as deci
    field dvij as deci
    index ind is primary bank cifn.

def new shared var vsel as decimal.
def var dt as date no-undo.
def var v-path1 as char no-undo.

vsel = 1.

dt = g-today.

def new shared var rates as deci no-undo extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < dt no-lock no-error.
  if avail crchis then rates[crc.crc] = crchis.rate[1].
end.

v-path1 = '/data/b'.
for each comm.txb where comm.txb.consolid = true no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path1) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run wl-rozn1(dt).
end.
if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".

def var coun as integer no-undo.
define stream m-out.
output stream m-out to value(vfname).

{wl-rozn.i}

put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

vres = yes. /* успешное формирование файла */
