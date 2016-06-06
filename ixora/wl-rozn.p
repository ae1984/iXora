/* wl-rozn.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Watch list – по рознице
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
        25.09.2013 dmitriy. ТЗ 1975
 * BASES
        BANK COMM
 * CHANGES

*/

{mainhead.i}

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

def var v-path1 as char no-undo.

run sel2 ("Отчеты:", " 1. Действующие  | 2. Погашенные ", output vsel).

def var dt as date no-undo.

dt = g-today.
update dt label ' На дату' format '99/99/9999' validate (dt <= g-today, " Дата должна быть не позже текущей!") with side-label row 10 centered frame dat.

def new shared var rates as deci no-undo extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < dt no-lock no-error.
  if avail crchis then rates[crc.crc] = crchis.rate[1].
end.

{r-brfilial.i &proc = "wl-rozn1(dt)"}

def var coun as integer no-undo.

define stream m-out.

output stream m-out to wl-rozn1.htm.

{wl-rozn.i}

put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

unix silent cptwin wl-rozn1.htm excel.
