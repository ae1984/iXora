/* p_rates.p
 * MODULE
        PUSH-отчеты - Кредиты
 * DESCRIPTION
        Средние ставки по кредитному портфелю
        (КОНСОЛИДИРОВАННО)
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        lonrates-txb.p
 * MENU
        
 * AUTHOR
        28/03/05 sasco
 * CHANGES
 	03/07/06 u00121 - вызывалась p_rates-txb.p теперь p_rates-txb.r
 			- добавил опцию no-undo  в таблицы tmp и tots
 			- добавил индекс (idx-tots1) в таблицу tots
 			- добавил индекс (idx-tmp2) в tmp
*/

{global.i}
{push.i}

vres = no.

def var russ as char extent 12 no-undo
                     init ["января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"].

{gl-utils.i}

define new shared temp-table tmp no-undo
     field rate as decimal
     field ost as decimal
     field crc as int 
     field ostk as decimal
     field cnt as integer 
     field perc as decimal
     index itmp is primary rate
     index idx-tmp2 rate crc.

define temp-table tots no-undo
     field crc as int
     field totc as decimal
     field tot as decimal
     field perc as decimal
     field rate as decimal
     index idx-tots1 crc.

function EMPTY returns character (tdp as character, mess as character).
    return "<TD " + tdp + " style=""border-style : none none none none;"">" + mess + "</TD>".
end.

function BOX returns character (tdp as character, mess as character).
    return "<TD " + tdp + " style=""border-style : solid solid solid solid;"">" + mess + "</TD>".
end.

function FILLBOX returns character (tdp as character, mess as char).
    return "<TD " + tdp + " bgcolor=""#C0C0C0"" style=""border-style : solid solid solid solid;"">" + mess + "</TD>".
end.


define new shared variable rats as decimal extent 12.
define new shared variable ratc as char extent 12.

define variable verytot as decimal.

for each crc no-lock:
    rats[crc.crc] = crc.rate[1].
    ratc[crc.crc] = CAPS (crc.code).
end.

define new shared variable v-dt as date initial today.
v-dt = vd1.

if v-dt = ? or v-dt > today then do:
   vrdes = "Неправильная дата отчета!".
   vres = no.
   return.
end.


/* ----------------------------------------- */



{r-branch.i &proc="p_rates-txb"}

for each tmp where tmp.ost > 0 or tmp.ostk > 0:
    tmp.perc = tmp.ostk / 100 * tmp.rate.
    find last tots where tots.crc = tmp.crc no-error.
    if not avail tots then create tots.
    tots.crc = tmp.crc.
    tots.totc = tots.totc + tmp.ost. /* валюта */
    tots.tot = tots.tot + tmp.ostk. /* тенге */
    tots.perc = tots.perc + tmp.perc.
end.

for each tots:
    tots.rate  = tots.perc / tots.tot * 100.
end.


output to value (vfname).
{html-start.i}

put unformatted "<table width=""640"" border=""0"">" skip.
put unformatted "<tr>"
                 EMPTY ("colspan=""4""", "<b>Портфель юридических лиц по ставке и валюте</b>")
                 FILLBOX ("align=""center""", string(day(v-dt)) + " " + russ[month(v-dt)] + " " + string(year (v-dt))) 
                 "</tr></table>" skip.
put unformatted "<BR>" skip.


put unformatted "<table width=""640"" border=""1"">" skip.
put unformatted "<tr>"
                FILLBOX ("", "Ставка")
                FILLBOX ("", "Валюта")
                FILLBOX ("", "Сумма (ВАЛ)")
                FILLBOX ("", "Сумма (ТЕНГЕ)")
                FILLBOX ("", "Количество кредитов")
                FILLBOX ("", "ИТОГ")
                "</tr>" skip.

for each tmp where tmp.ost > 0 and tmp.ostk > 0 and tmp.rate <= 12 by tmp.rate by tmp.crc:
    put unformatted "<tr>"
                    "<td>" XLS-NUMBER (tmp.rate) "</td>"
                    "<td align=""center"">" ratc[tmp.crc] "</td>"
                    "<td>" XLS-NUMBER (tmp.ost) "</td>"
                    "<td>" XLS-NUMBER (tmp.ostk) "</td>"
                    "<td>" tmp.cnt "</td>"
                    EMPTY ("", "&nbsp;")
                    "</tr>" skip.
   accumulate tmp.ostk (total).
end.
verytot = verytot + accum total (tmp.ostk).

put unformatted "<tr>"
                "<td colspan=""5"" align=""right""><b>Сумма кредитов со ставкой до 12 % </b></td>"
                FILLBOX ("", XLS-NUMBER (accum total (tmp.ostk)))
                "</tr>" skip.

for each tmp where tmp.ost > 0 and tmp.ostk > 0 and tmp.rate > 12 and tmp.rate <= 16 by tmp.rate by tmp.crc:
    put unformatted "<tr>"
                    "<td>" XLS-NUMBER (tmp.rate) "</td>"
                    "<td align=""center"">" ratc[tmp.crc] "</td>"
                    "<td>" XLS-NUMBER (tmp.ost) "</td>"
                    "<td>" XLS-NUMBER (tmp.ostk) "</td>"
                    "<td>" tmp.cnt "</td>"
                    EMPTY ("", "&nbsp;")
                    "</tr>" skip.
   accumulate tmp.ostk (total).
end.
verytot = verytot + accum total (tmp.ostk).

put unformatted "<tr>"
                "<td colspan=""5"" align=""right""><b>Сумма кредитов со ставкой до 16 % </b></td>"
                FILLBOX ("", XLS-NUMBER (accum total (tmp.ostk)))
                "</tr>" skip.


for each tmp where tmp.ost > 0 and tmp.ostk > 0 and tmp.rate > 16 by tmp.rate by tmp.crc:
    put unformatted "<tr>"
                    "<td>" XLS-NUMBER (tmp.rate) "</td>"
                    "<td align=""center"">" ratc[tmp.crc] "</td>"
                    "<td>" XLS-NUMBER (tmp.ost) "</td>"
                    "<td>" XLS-NUMBER (tmp.ostk) "</td>"
                    "<td>" tmp.cnt "</td>"
                    EMPTY ("", "&nbsp;")
                    "</tr>" skip.
   accumulate tmp.ostk (total).
end.
verytot = verytot + accum total (tmp.ostk).

put unformatted "<tr>"
                "<td colspan=""5"" align=""right""><b>Сумма кредитов со ставкой свыше 16 % </b></td>"
                FILLBOX ("", XLS-NUMBER (accum total (tmp.ostk)))
                "</tr>" skip.

put unformatted "</table>" skip.

put unformatted "<P>&nbsp;</P>" skip.

put unformatted "<table width=""640"" border=""0"">" skip.
put unformatted "<tr>"
                 EMPTY ("colspan=""3""", "<b>Всего портфель юридических лиц</b>")
                 FILLBOX ("", XLS-NUMBER (verytot)) 
                 EMPTY ("", "&nbsp")
                 "</tr></table>" skip.

put unformatted "<P>&nbsp;</P>" skip.

put unformatted "<table width=""640"" border=""0"">" skip.
put unformatted "<tr>"
                 EMPTY ("colspan=""4""", "&nbsp;")
                 EMPTY ("align=""center""", "Средняя % ставка") 
                 "</tr>" skip.
verytot = 0.
for each tots by tots.crc:
    put unformatted "<tr>" .

    if verytot = 0 then put unformatted EMPTY ("align=""left""", "<b>ИТОГО</b>"). 
                   else put unformatted EMPTY ("", "&nbsp;").
    verytot = 1.
    
    put unformatted EMPTY ("align=""left""", "в " + ratc[tots.crc]) 
                    EMPTY ("align=""right""", XLS-NUMBER (tots.totc))
                    EMPTY ("align=""right""", XLS-NUMBER (tots.tot))
                    EMPTY ("align=""center""", XLS-NUMBER (tots.rate))
                    skip.

end.

put unformatted "</table>" skip.
put unformatted "<BR>" skip.


{html-end.i}
output close.

vres = yes.

