/* gbstars.p
 * MODULE
        Бухгалтерия
 * DESCRIPTION
        Обнаружение звезд
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
        15/12/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def new shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field gl as integer
  field crc as integer
  field sub as char
  field level as integer
  field sum_gl as deci
  field sum_gl_kzt as deci
  field sum_lon as deci
  index idx is primary bank gl crc.

def var dat as date no-undo.

dat = g-today.
update dat label ' На дату' format '99/99/9999' validate (dat <= g-today, " Дата должна быть не позже текущей!") skip
       skip with side-label row 5 centered frame dat.

def new shared var rates as deci extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < dat no-lock no-error.
  rates[crc.crc] = crchis.rate[1].
end.

{r-brfilial.i &proc = "gbstars2(dat)"}

def stream rep.
output stream rep to rep.htm.

put stream rep unformatted
     "<html><head>" skip
     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip
     "Date:&nbsp;&nbsp;" dat format "99/99/9999" "<br>" skip
     "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
     "<tr bgcolor=""#C0C0C0"" style=""font:bold"" align=""center"">" skip
     "<td>Филиал</td>" skip
     "<td>Счет ГК</td>" skip
     "<td>Валюта</td>" skip
     "<td>Сабледжер</td>" skip
     "<td>Уровень</td>" skip
     "<td>Баланс</td>" skip
     "<td>Модуль</td>" skip
     "<td>Расхождение</td>" skip
     "<td></td>" skip
     "<td>Баланс KZT</td>" skip
     "</tr>" skip.

for each wrk no-lock:
    
    if wrk.sum_gl - wrk.sum_lon <> 0 then do:
        find first crc where crc.crc = wrk.crc no-lock no-error.
        put stream rep unformatted
               "<tr>" skip
               "<td>" wrk.bankn "</td>" skip
               "<td>" wrk.gl "</td>" skip
               "<td>" crc.code "</td>" skip
               "<td>" wrk.sub "</td>" skip
               "<td>" wrk.level "</td>" skip
               "<td>" replace(trim(string(wrk.sum_gl)),'.',',') "</td>" skip
               "<td>" replace(trim(string(wrk.sum_lon)),'.',',') "</td>" skip
               "<td>" if wrk.sum_gl <> wrk.sum_lon then replace(trim(string(wrk.sum_gl - wrk.sum_lon)),'.',',') else "" "</td>" skip
               "<td></td>" skip
               "<td>" replace(trim(string(wrk.sum_gl_kzt)),'.',',') "</td>" skip
               "</tr>" skip.
    end.
end. /* for each wrk */

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin rep.htm excel.

