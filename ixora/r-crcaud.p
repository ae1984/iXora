
/* r-crcaud.p
 * MODULE
        Обменные операции
 * DESCRIPTION
       Печать истории валюты
 * RUN
       Вызов из п меню без параметров
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK
 * AUTHOR
        17/12/08 marinav
 * CHANGES
     29/05/09 marinav - перевод в excel
     25/04/2012 evseev  - rebranding. Название банка из sysc.
*/
{nbankBik.i}
def new shared var v-dtb as date.
def new shared var v-dte as date.

update
    v-dtb label " Начальная дата " format "99/99/9999" skip
    v-dte label "  Конечная дата " format "99/99/9999"
    with centered row 5 side-label frame f-dt.



find first cmp.
define stream rep.
output stream rep to cas.htm.

put stream rep unformatted "<html><head><title>" + v-nbank1 + "</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


       put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

       put stream rep unformatted "<tr><td align=""center"" colspan=7><h3>История изменения курса <BR>".
       put stream rep unformatted "</h3></td></tr>" skip.
       put stream rep unformatted "<tr style=""font:bold"" >"
                                  "<td align=""center"" colspan=7><h3> с " string(v-dtb) " по " string(v-dte) "</td></tr>"  skip.
       put stream rep "</table>" skip.

       put stream rep unformatted "<br><table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" >"
                  "<td align=""left"" colspan=7>" cmp.name    format 'x(79)' "</td></tr>"
                  "<tr style=""font:bold"" >"
                  "<td align=""left"" colspan=7>" cmp.addr[1] format 'x(79)' "</td></tr>"
                   skip.
       put stream rep "</table>" skip.

       put stream rep unformatted "<br><br><br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td >Дата</td>"
                  "<td >Время</td>"
                  "<td >Валюта</td>"
                  "<td >Учетный курс</td>"
                  "<td >Покупки</td>"
                  "<td >Продажи</td>"
                  "<td >Менеджер</td>"
                  "</tr>"
                   skip.

    for each crchis where rdt >= v-dtb and rdt <= v-dte no-lock by crchis.rdt by crchis.crc by crchis.tim.
      find crc where crc.crc = crchis.crc no-lock.

         put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:x-small""><b>"
                   "<td>" string(crchis.rdt) "</td></b>"
                   "<td>" string(crchis.tim,"HH:MM") "</td>"
                   "<td>" crc.code "</td>" skip
                   "<td>" crchis.rate[1] "</td>"
                   "<td>" crchis.rate[2] "</td>" skip
                   "<td>" crchis.rate[3] "</td>"
                   "<td>" string(crchis.who) "</td>" skip
                   "</tr>".

    end.

    put stream rep "</table>" skip.


put stream rep "</body></html>" skip.
output stream rep close.

unix silent cptwin cas.htm excel.



