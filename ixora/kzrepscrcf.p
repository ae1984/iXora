 /* kzrepscrcf.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Обменные курсы наличных иностранной валюты филиалов
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
        25.03.2011 aigul
 * BASES
        BANK
 * CHANGES
        26.04.2011 aigul - изменила вывод валют
*/
{global.i}
def new shared var dtb as date.
def new shared var dte as date.
def var p-bank as char.
def var i as int.
def new shared temp-table wrk
    field fil as char
    field i as int
    field dt as date
    field tm as char
    field rasp as char
    field crc as char
    field buy1 as decimal
    field sell1 as decimal
    field buy2 as decimal
    field sell2 as decimal
    field buy3 as decimal
    field sell3 as decimal
    field buy4 as decimal
    field sell4 as decimal.
def var v-buy as decimal.
def var v-sell as decimal.
form
  skip(1)
  dtb label " За период с" format "99/99/9999"
  dte label " по" format "99/99/9999"
  skip
with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.
dtb = g-today.
dte = g-today.
displ dtb dte with frame f-dt.
update dtb dte with frame f-dt.

{r-brfilial.i &proc = "kzrepscrcf1"}
def buffer b-wrk for wrk.
def stream vcrpt.
output stream vcrpt to kzrepscrcf.htm.

{html-title.i
 &stream = " stream vcrpt "
 &title = "Опорные курсы"
 &size-add = "xx-"
}

put stream vcrpt unformatted

   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Обменные курсы наличных иностранной валюты филиалов <BR> за период с " + string(dtb, "99/99/9999") + " по " + string(dte, "99/99/9999") "</B></FONT></P>" skip.
put stream vcrpt unformatted
"<TR align=""center"" style=""font:bold;background:gainsboro "">" skip
"<TD><font size=1>№</TD>" skip
"<TD colspan = 2><font size=1>Доллар США </TD>" skip
"<TD colspan = 2><font size=1>Евро </TD>" skip
"<TD colspan = 2><font size=1>Российские рубли</TD>" skip
"<TD colspan = 2><font size=1></TD>" skip
"<TD><font size=1>Дата</TD>" skip
"<TD><font size=1>Время</TD>" skip
"<TD><font size=1>№  распоряжения</TD>" skip
"</TR>" skip.
put stream vcrpt unformatted
     "<TR align=""center"" style=""font:bold"">" skip
     "<TD></TD>" skip
     "<TD> Курс покупки</TD>" skip
     "<TD> Курс продажи</TD>" skip
     "<TD> Курс покупки</TD>" skip
     "<TD> Курс продажи</TD>" skip
     "<TD> Курс покупки</TD>" skip
     "<TD> Курс продажи</TD>" skip
     "<TD> Курс покупки</TD>" skip
     "<TD> Курс продажи</TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
      "</TR>" skip.

for each wrk no-lock break by wrk.fil by wrk.rasp.
if first-of(wrk.fil) then put stream vcrpt unformatted "<tr style=""font:bold""><td colspan=9>" wrk.fil "</td></tr>".
        if first-of(wrk.rasp) then do:
        i = i + 1.
        put stream vcrpt unformatted
        "<tr>"
        "<td><font size=1>" i "</td>".
        put stream vcrpt unformatted
        "<td><font size=1>" replace(trim(string(wrk.buy1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.sell1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.buy2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.sell2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.buy3,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.sell3,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" wrk.crc " - " replace(trim(string(wrk.buy4,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" wrk.crc " - " replace(trim(string(wrk.sell4,'>>>>>>>>>>>9.99')),'.',',') "</td>".
        put stream vcrpt unformatted
        "<td><font size=1>" wrk.dt "</td>"
        "<td><font size=1>" wrk.tm "</td>"
        "<td><font size=1>" wrk.rasp "</td>".
        put stream vcrpt unformatted
        "</tr>" skip.
        end.
end.

put stream vcrpt unformatted
  "</B></FONT></P></table></body></html>" skip.

output stream vcrpt close.

unix silent value("cptwin kzrepscrcf.htm excel").

pause 0.
