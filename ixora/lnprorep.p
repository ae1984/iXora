/* lnprorep.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Отчет по реструктуризации/пролонгации
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
        22/05/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def new shared var dat1 as date no-undo.
def new shared var dat2 as date no-undo.

def new shared temp-table wrk no-undo
  field bank as char
  field cif as char
  field cifn as char
  field lon as char
  field crc as integer
  field bankn as char
  field odRestr as deci
  field opType as char
  field dtRestr as date
  field who as char
  field dtPog as date
  field dtOd as date
  field dtPrc as date
  field sumPen as deci
  index idx is primary bank cifn.

if day(g-today) > 1 then dat2 = g-today.
else dat2 = g-today - 1.
dat1 = date(month(dat2),1,year(dat2)).
update dat1 label "C " format "99/99/9999" skip
       dat2 label "По" format "99/99/9999" skip
with side-label row 13 centered frame dat.

hide frame dat.
message "Формируется отчет...".

{r-brfilial.i &proc = "lnprorep2"}

def stream rep.
def var i as integer no-undo.

output stream rep to rep.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

put stream rep unformatted
    "<center><b>Отчет по реструктуризации/пролонгации за период с " dat1 format "99/99/9999" " по " dat2 format "99/99/9999" "</b><br>" skip
    v-bankname "</center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>nn</td>" skip
    "<td>Код кл</td>" skip
    "<td>ФИО</td>" skip
    "<td>Сс. счет</td>" skip
    "<td>Филиал</td>" skip
    "<td>Валюта</td>" skip
    "<td>ОД на дату<br>реструктуризации</td>" skip
    "<td>Тип<br>операции</td>" skip
    "<td>Дата</td>" skip
    "<td>Менеджер</td>" skip
    "<td>Дата погашения<br>кредита</td>" skip
    "<td>Отсрочка<br>ОД</td>" skip
    "<td>Отсрочка<br>%%</td>" skip
    "<td>Сумма<br>отсроч. пени</td>" skip
    "</tr>" skip.

i = 0.
for each wrk no-lock:
    i = i + 1.
    find first crc where crc.crc = wrk.crc no-lock no-error.
    put stream rep unformatted
        "<tr>" skip
        "<td>" i "</td>" skip
        "<td>" wrk.cif "</td>" skip
        "<td>" wrk.cifn "</td>" skip
        "<td>&nbsp;" wrk.lon "</td>" skip
        "<td>" wrk.bankn "</td>" skip
        "<td>" crc.code "</td>" skip
        "<td>" replace(trim(string(wrk.odRestr, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" wrk.opType "</td>" skip
        "<td>" string(wrk.dtRestr,"99/99/9999") "</td>" skip
        "<td>" wrk.who "</td>" skip
        "<td>" string(wrk.dtPog,"99/99/9999") "</td>" skip
        "<td>" string(wrk.dtOd,"99/99/9999") "</td>" skip
        "<td>" string(wrk.dtPrc,"99/99/9999") "</td>" skip
        "<td>" replace(trim(string(wrk.sumPen, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "</tr>" skip.
end.

put stream rep unformatted "</table></body></html>" skip.
output stream rep close.

hide message no-pause.

unix silent cptwin rep.htm excel.


