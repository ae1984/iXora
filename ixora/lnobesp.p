/* lnobesp.p
 * MODULE
    Кредитный модуль     
 * DESCRIPTION
        Просмотр залогов по текущему кредиту
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
        20/01/2005 madiar
 * CHANGES
        26/01/2005 madiar - исправил формат вывода сумм
        18/08/2005 madiar - добавил адрес залога
*/

{global.i}

def shared var s-lon like lon.lon.
def stream rep.
def var coun as int.
output stream rep to rpt.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find lon where lon.lon = s-lon no-lock.
find first cif where cif.cif = lon.cif no-lock no-error.
find first crc where crc.crc = lon.crc no-lock no-error.
find first cmp no-lock no-error.

put stream rep unformatted
    "<h2>" cmp.name format "x(40)" "</h2><BR>" skip
    "Наименование/имя заемщика (код): " cif.name " (" cif.cif ")<BR>" skip
    "Ссудный счет: " lon.lon "<BR>" skip
    "Сумма кредита: " lon.opnamt " " crc.code "<BR><BR>" skip.
    
put stream rep unformatted
    "<h3>Обеспечение</h3>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>N</td>" skip
    "<td>Вид</td>" skip
    "<td>Валюта</td>" skip
    "<td>Сумма</td>" skip
    "<td>Сумма KZT</td>" skip
    "<td>Предмет залога</td>" skip
    "<td>Адрес залога</td>" skip
    "<td>Организация/ФИО</td>" skip
    "<td>Адрес организации</td>" skip
    "</tr>" skip.

coun = 1.
for each lonsec1 where lonsec1.lon = lon.lon no-lock:
  find first lonsec where lonsec.lonsec = lonsec1.lonsec no-lock no-error.
  find crc where crc.crc = lonsec1.crc no-lock no-error.
  put stream rep unformatted
    "<tr>" skip
    "<td>" coun "</td>" skip
    "<td>" lonsec.lonsec " (" lonsec.des1 ")</td>" skip
    "<td>" crc.code "</td>" skip
    "<td>" replace(trim(string(lonsec1.secamt,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(lonsec1.secamt * crc.rate[1],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" entry(1,lonsec1.prm,'&') "</td>" skip
    "<td>" entry(1,lonsec1.vieta,'&') "</td>" skip
    "<td>" if num-entries(lonsec1.prm,'&') > 1 then entry(2,lonsec1.prm,'&') else '' "</td>" skip
    "<td>" if num-entries(lonsec1.prm,'&') > 2 then entry(3,lonsec1.prm,'&') else '' "</td>" skip
    "</tr>" skip.
  coun = coun + 1.
end.


put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin rpt.htm excel.


