/* r-cods2.p
 * MODULE
        Push Отчет по доходам-расходам
 * DESCRIPTION
        Push Отчет по доходам-расходам
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
        02/11/2005 nataly
 * CHANGES
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/

{mainhead.i}

def var fname as char.
def var quar as inte.
def var v-date as date .


update v-date label 'Введите дату начала месяца, на которую надо сформировать отчет' with frame ddd .

if month(v-date) <= 12 then quar = 4.
if month(v-date) <= 9 then quar = 3.
if month(v-date) <= 6 then quar = 2.
if month(v-date) <= 3 then quar = 1.

fname = "-" + string(year(v-date)) + "-" + string(month(v-date)) + "-" + string(quar) + "-" + string(day(v-date)) + ".html".


  unix silent value("cptwin /data/reports/push/cods" + fname + " excel").

pause 0.
