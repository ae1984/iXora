/* pkrefrep.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Отчет по рефинансированию
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
        22/05/2006 madiyar
 * CHANGES
        23/05/2006 madiyar - добавил колонку "Первонач. сумма кредитов"
*/

{mainhead.i}

def new shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field dpt as integer
  field dptname as char
  field num as integer
  field sum as decimal
  field sumod as decimal
  field sumold as decimal
  index idx is primary bank dpt.

def var usrnm as char no-undo.
def stream rep.
def var dt1 as date no-undo.
def var dt2 as date no-undo.

dt2 = date(month(g-today),1,year(g-today)) - 1.
dt1 = date(month(dt2),1,year(dt2)).

update dt1 label ' Укажите дату с ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' skip
       with side-label /* row 5 */ centered frame dat .

{r-brfilial.i &proc = "pkrefrep2 (dt1,dt2)"}

output stream rep to pkrefrep.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Отчет по рефинансированию за период с " dt1 format "99/99/9999" " по " dt2 format "99/99/9999" "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip
    "<td>Филиал/РКО</td>" skip
    "<td>Кол-во реф.<br>кредитов</td>" skip
    "<td>Сумма реф.<br>кредитов</td>" skip
    "<td>Первонач. сумма<br>кредитов</td>" skip
    "<td>Сумма<br>погаш. ОД</td>" skip
    "<td>Увелич. суммы<br>кредита в %</td>" skip
    "</tr>" skip.

for each wrk no-lock break by wrk.bank:
  
  if first-of(wrk.bank) then put stream rep unformatted "<tr><td colspan=6 bgcolor=""#9BCDFF""><b>" wrk.bankn "</b></td></tr>" skip.
    
  put stream rep unformatted
    "<tr>" skip
    "<td>" wrk.dptname "</td>" skip
    "<td>" wrk.num "</td>" skip
    "<td>" replace(string(wrk.sum, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrk.sumold, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrk.sumod, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string((wrk.sum - wrk.sumold) / wrk.sumold * 100, ">>9.99"),'.',',') "</td>" skip
    "</tr>" skip.
  
end. /* for each wrk */

put stream rep unformatted "</table></body></html>".
output stream rep close.

unix silent cptwin pkrefrep.htm excel.

