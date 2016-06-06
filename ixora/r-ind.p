/* r-ind.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Формирование списка индексированных кредитов с уровнями 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-2-15 
 * AUTHOR
        06.02.04 nataly
 * CHANGES
        13.02.04 nataly были добавлены итоги
        07/06/2005 madiar - переделал отчет
        05/08/2005 madiar - отбрасывались кредиты с нулевым остатком ОД, исправил
*/

{mainhead.i}

def stream rpt.
output stream rpt to r-ind.htm.

define temp-table wrk
  field cif like cif.cif
  field name as char
  field lon like lon.lon
  field crc like crc.crc
  field opnamt as deci
  field od as deci
  field iod as deci
  field iprc as deci
  field icrc like crc.crc
  field icrcrate as deci
  index idx is primary crc cif lon.

def var usrnm as char.
def var bilance as deci.
def var coun as integer.
def var dat as date.

dat = date(month(g-today),1,year(g-today)) - 1.
update dat label " За дату: " format "99/99/9999"  
                  skip with side-label row 5 centered frame dat .

message " Формируется отчет... ".

for each lon no-lock:
  
  if lon.opnamt <= 0 then next.
  find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and d-cod = 'lnindex' no-lock no-error.
  if not avail sub-cod then next.
  else if sub-cod.ccod <> '1' then next.
  run lonbalcrc('lon',lon.lon,dat,"1,7",yes,lon.crc,output bilance).
  /*
  if bilance <= 0 then next.
  */
  find first lonhar where lonhar.lon = lon.lon and ln = 1 no-lock no-error.
  find cif where cif.cif = lon.cif no-lock no-error.
  create wrk.
  wrk.cif = lon.cif.
  wrk.name = trim(cif.name).
  wrk.lon = lon.lon.
  wrk.crc = lon.crc.
  wrk.opnamt = lon.opnamt.
  wrk.od = bilance.
  run lonbalcrc('lon',lon.lon,dat,"20",yes,lon.crc,output wrk.iod).
  run lonbalcrc('lon',lon.lon,dat,"22",yes,lon.crc,output wrk.iprc).
  wrk.icrc = lonhar.rez-int[1].
  wrk.icrcrate = lonhar.rez-dec[1].
  
end. /* for each lon */


put stream rpt unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rpt unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Индексированные кредиты, за " dat format "99/99/9999" "</b></center><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip
    "<td>пп</td>" skip
    "<td>Код<BR>заемщика</td>" skip
    "<td>Наименование заемщика</td>" skip
    "<td>Сс счет</td>" skip
    "<td>Валюта<BR>займа</td>" skip
    "<td>Сумма<BR>кредита</td>" skip
    "<td>Остаток<BR>кредита</td>" skip
    "<td>Индексация<BR>ОД</td>" skip
    "<td>Индексация<BR>%%</td>" skip
    "<td>Итого<BR>индексация</td>" skip
    "<td>Курс<BR>индексации</td>" skip
    "</tr>" skip.

coun = 1.
for each wrk no-lock:
  
  find crc where crc.crc = wrk.crc no-lock no-error.
  put stream rpt unformatted
    "<tr>" skip
    "<td>" coun "</td>" skip
    "<td>" wrk.cif "</td>" skip
    "<td>" wrk.name "</td>" skip
    "<td>&nbsp;" wrk.lon "</td>" skip
    "<td>" crc.code "</td>" skip
    "<td>" replace(trim(string(wrk.opnamt,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.od,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.iod,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.iprc,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.iod + wrk.iprc,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.icrcrate,">>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.
  
end. 

put stream rpt unformatted "</table></body></html>" skip.
output stream rpt close.
hide message no-pause.

unix silent cptwin r-ind.htm excel.
pause 0.


