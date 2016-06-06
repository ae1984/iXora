/* kzrepscrc.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по опорным курсам валют
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
        BANK COMM
 * CHANGES
*/
{global.i}
def new shared var s-vcourbank as char.
def new shared var p-bank as char.
def new shared var dtb as date.
def new shared var dte as date.

def var i as integer.
i = 0.

def new shared temp-table wrk
    field dt as date
    field tm as char
    field rasp as int
    field crc as char
    field buy1 as decimal
    field sell1 as decimal
    field spred1 as decimal
    field buy2 as decimal
    field sell2 as decimal
    field spred2 as decimal
    field buy3 as decimal
    field sell3 as decimal
    field spred3 as decimal
    field buy4 as decimal
    field sell4 as decimal
    field spred4 as decimal.
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

run kzrepscrc1(dtb, dte).

def stream vcrpt.
output stream vcrpt to kzrepscrc.htm.

{html-title.i
 &stream = " stream vcrpt "
 &title = "Опорные курсы"
 &size-add = "xx-"
}

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Опорные курсы<BR> за период с " + string(dtb, "99/99/9999") + " по " + string(dte, "99/99/9999") "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted
"<TR align=""center"" style=""font:bold;background:gainsboro "">" skip
"<TD><font size=1>№</TD>" skip
"<TD colspan = 3><font size=1>Доллар США </TD>" skip
"<TD colspan = 3><font size=1>Евро </TD>" skip
"<TD colspan = 3><font size=1>Российские рубли</TD>" skip
"<TD colspan = 3><font size=1></TD>" skip
"<TD><font size=1>Дата</TD>" skip
"<TD><font size=1>Время</TD>" skip
"<TD><font size=1>№  распоряжения</TD>" skip
"</TR>" skip.
put stream vcrpt unformatted
     "<TR align=""center"" style=""font:bold"">" skip
     "<TD></TD>" skip
     "<TD>'Опорный курс' покупки</TD>" skip
     "<TD>'Опорный курс' продажи</TD>" skip
     "<TD>'Мин спрэд'</TD>" skip
     "<TD>'Опорный курс' покупки</TD>" skip
     "<TD>'Опорный курс' продажи</TD>" skip
     "<TD>'Мин спрэд'</TD>" skip
     "<TD>'Опорный курс' покупки</TD>" skip
     "<TD>'Опорный курс' продажи</TD>" skip
     "<TD>'Мин спрэд'</TD>" skip
     "<TD>'Опорный курс' покупки</TD>" skip
     "<TD>'Опорный курс' продажи</TD>" skip
     "<TD>'Мин спрэд'</TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
      "</TR>" skip.
for each wrk no-lock break by wrk.rasp.
    if first-of(wrk.rasp) then do:
        i = i + 1.
        put stream vcrpt unformatted
        "<tr>"
        "<td><font size=1>" i "</td>".
        put stream vcrpt unformatted
        "<td><font size=1>" replace(trim(string(wrk.buy1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.sell1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.spred1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.buy2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.sell2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.spred2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.buy3,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.sell3,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td><font size=1>" replace(trim(string(wrk.spred3,'>>>>>>>>>>>9.99')),'.',',') "</td>".
        if wrk.buy4 <> 0 then put stream vcrpt unformatted "<td><font size=1>" wrk.crc " - " replace(trim(string(wrk.buy4,'>>>>>>>>>>>9.99')),'.',',') "</td>".
        else put stream vcrpt unformatted "<td><font size=1>"  "</td>".
        if wrk.sell4 <> 0 then put stream vcrpt unformatted "<td><font size=1>" wrk.crc " - " replace(trim(string(wrk.sell4,'>>>>>>>>>>>9.99')),'.',',') "</td>".
        else put stream vcrpt unformatted "<td><font size=1>"  "</td>".
        if wrk.spred4 <> 0 then put stream vcrpt unformatted "<td><font size=1>" wrk.crc " - " replace(trim(string(wrk.spred4,'>>>>>>>>>>>9.99')),'.',',') "</td>".
        else put stream vcrpt unformatted "<td><font size=1>"  "</td>".
        put stream vcrpt unformatted
        "<td><font size=1>" wrk.dt "</td>"
        "<td><font size=1>" wrk.tm "</td>"
        "<TD><font size=1>" wrk.rasp "</TD>"
        "</tr>" skip.
    end.
end.

put stream vcrpt unformatted
  "</B></FONT></P>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin kzrepscrc.htm excel").

pause 0.