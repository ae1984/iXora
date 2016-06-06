/* lnclerr.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Выявление кредитов, по которым не была проставлена или неверная классификация
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
        03/06/2005 madiar
 * CHANGES
*/

{global.i}

define new shared temp-table wrk
  field cif like cif.cif
  field name as char
  field lon like lon.lon
  field bilance1 as deci
  field bilance2 as deci
  field sts as integer
  index idx is primary cif lon.

def var dat as date.
def var dt1 as date.
def var dt2 as date.
dat = date(month(g-today),1,year(g-today)).
dt2 = dat - 1.
dt1 = date(month(dt2),1,year(dt2)).

update skip(1)
       dat label ' Дата отчета ' format '99/99/9999' validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip(1)
       dt1 label ' Период с    ' format '99/99/9999' validate (dt1 < g-today, " Дата должна быть раньше текущей! ")
       dt2 label ' по ' format '99/99/9999' validate (dt2 < g-today, " Дата должна быть раньше текущей! ") " " skip(1)
       with side-label row 5 centered frame dates.

message " Формируется отчет... ".

{r-branch.i &proc = "lnclerr2 (dat,dt1,dt2)"}


def stream rep.
output stream rep to lnclerr.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Код заемщика</td>" skip
    "<td>Наименование заемщика</td>" skip
    "<td>Ссудный счет</td>" skip
    "<td>ОД начало</td>" skip
    "<td>ОД конец</td>" skip
    "<td>Классиф</td>" skip
    "</tr>" skip.

for each wrk no-lock:
  
  put stream rep unformatted
    "<tr>" skip
    "<td>" wrk.cif "</td>" skip
    "<td>" wrk.name "</td>" skip
    "<td>&nbsp;" wrk.lon "</td>" skip
    "<td>" replace(trim(string(wrk.bilance1,">>>>>>>>>>>9.99")),'.',',')"</td>" skip
    "<td>" replace(trim(string(wrk.bilance2,">>>>>>>>>>>9.99")),'.',',')"</td>" skip
    "<td>" wrk.sts "</td>" skip
    "</tr>" skip.
  
end. /* for each wrk */


put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.

unix silent cptwin lnclerr.htm excel.
