/* lnriskrep.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет для рисковиков
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
        20/01/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        03/03/2011 madiyar - изменения по ТЗ 924
        19/05/2011 madiyar - добавил дни текущей просрочки, количество просрочек
        26/05/2011 madiyar - добавил ухудшение фин. состояния (wrk.fsDecline)
        14/10/2011 kapar - изменения по ТЗ 1175
        11/03/2012 dmitriy - добавил столбцы: Пул МСФО, Провизии МСФО, Штраф, Общая сумма залога недвиж.имущ., Общая сумма залога движ.имущ
                           - добавил wrk.grp, не отражалась группа кредита
        25/02/2013 sayat(id01143) - ТЗ 1696 от 04/02/2013 вывод в отчет отвественного по обеспечению
        07.11.2013 dmitriy - ТЗ 1725. Добавил столбцы «Количество баллов» и «Финансовое состояние»
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
    /*
    field zalog as deci
    */
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
    field mark as int
    field fins as char
    index ind is primary bank cifn.

def new shared var vsel as decimal.

run sel2 ("Отчеты:", " 1. Действующие  | 2. Погашенные ", output vsel).

def var dt as date no-undo.
def var v-fins as char.


dt = g-today.
update dt label ' На дату' format '99/99/9999' validate (dt <= g-today, " Дата должна быть не позже текущей!") with side-label row 10 centered frame dat.

def new shared var rates as deci no-undo extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < dt no-lock no-error.
  if avail crchis then rates[crc.crc] = crchis.rate[1].
end.


{r-brfilial.i &proc = "lnriskrep1(dt)"}

def var coun as integer no-undo.

define stream m-out.
output stream m-out to rep.htm.

{lnriskrep.i}

put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

unix silent cptwin rep.htm excel.

