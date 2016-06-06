/* lnamortgrf.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Просмотр графика амортизация комиссии
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
        22/10/2011 madiyar
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def shared var s-lon like lon.lon.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then return.

find first cif where cif.cif = lon.cif no-lock no-error.

def stream rep.
def var coun as int no-undo.
def var v-itogo as deci no-undo.
output stream rep to rpt.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.


put stream rep unformatted
    "Наименование/имя заемщика (код): " cif.name " (" cif.cif ")<BR>" skip
    "Ссудный счет: " lon.lon "<BR><BR>" skip.

put stream rep unformatted
    "<h2>График амортизации комиссии</h2>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td width=30>N</td>" skip
    "<td width=100>Дата</td>" skip
    "<td width=100>Сумма</td>" skip
    "</tr>" skip.

coun = 1.
v-itogo = 0.
for each lnscc where lnscc.lon = lon.lon and lnscc.sch = yes no-lock:
  put stream rep unformatted
             "<tr>" skip
             "<td align=""center"">" coun "</td>" skip
             "<td align=""center"">" lnscc.stdat "</td>" skip
             "<td align=""right"">" replace(string(lnscc.stval, "->>>>>>>>>>>9.99"),".",",") "</td>" skip
             "</tr>" skip.
  v-itogo = v-itogo + lnscc.stval.
  coun = coun + 1.
end.

put stream rep unformatted
             "<tr style=""font:bold"">" skip
             "<td align=""center""></td>" skip
             "<td align=""center"">ИТОГО:</td>" skip
             "<td align=""right"">" replace(string(v-itogo, "->>>>>>>>>>>9.99"),".",",") "</td>" skip
             "</tr>" skip.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin rpt.htm excel.

