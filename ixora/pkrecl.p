/* pkanlzd.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Отчет по рекламе БД
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
        29/06/2006 madiyar
 * CHANGES
        03/08/2006 madiyar - отчет работал некорректно на филиалах, исправил
*/

{mainhead.i}

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def temp-table wrk no-undo
  field code as char
  field name as char
  field num as integer
  index idx is primary code.

def var v-bal as deci no-undo.
def var coun as integer no-undo.
def var usrnm as char no-undo.
def var dat1 as date no-undo.
def var dat2 as date no-undo.
dat1 = date(month(g-today),1,year(g-today)).
dat2 = g-today.

update dat1 label ' Укажите дату с ' format '99/99/9999' dat2 label ' по ' format '99/99/9999' ' ' skip
       with side-label row 5 centered frame dat.

for each bookcod where bookcod.bookcod = "pkankrec" no-lock:

  create wrk.
  wrk.code = bookcod.code.
  wrk.name = bookcod.name.
  
end.

for each lon where lon.rdt >= dat1 and lon.rdt <= dat2 and (lon.grp = 90 or lon.grp = 92) no-lock:
  
  if lon.opnamt <= 0 then next.
  
  find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = lon.lon no-lock no-error.
  if not avail pkanketa or pkanketa.credtype <> '6' or pkanketa.id_org <> '' then next.
  
  run lonbalcrc('lon',lon.lon,today,"1,7",yes,lon.crc,output v-bal).
  if v-bal <= 0 then next.
  
  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'reclama' no-lock no-error.
  if not avail pkanketh or trim(pkanketh.value1) = '' then next.
  
  find first wrk where wrk.code = pkanketh.value1 no-error.
  if avail wrk then wrk.num = wrk.num + 1.
    
end.


define stream rep.
output stream rep to pkrecl.htm.

put stream rep unformatted
                 "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Отчет по рекламе БД, " dat1 format "99/99/9999" " - " dat2 format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>пп</td>" skip
    "<td>Источник информации</td>" skip
    "<td>Количество</td>" skip
    "</tr>" skip.

coun = 1.
for each wrk no-lock:
  
  put stream rep unformatted
    "<tr>" skip
    "<td>" coun "</td>" skip
    "<td>" wrk.name "</td>" skip
    "<td>" wrk.num "</td>" skip
    "</tr>" skip.
  coun = coun + 1.
  
end.

put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.
unix silent cptwin pkrecl.htm excel.
