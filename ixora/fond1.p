/* fond1.p
 * MODULE

 * DESCRIPTION
        Фондирование активных операций
 * RUN
        fond.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        17.05.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var v-dt as date no-undo.

def shared temp-table wrk-act
    field gr as int
    field id as int
    field sum as deci
    field typ as char
    field crc as int.
def shared temp-table wrk-pas
    field gr as int
    field id as int
    field sum as deci
    field typ as char
    field crc as int.
def var v-act as deci.
def var v-act-t as deci.
def var v-act-u as deci.
def var v-act-e as deci.
def var v-act-r as deci.
def var v-act-o as deci.
def var v-pas as deci.
def var v-pas-t as deci.
def var v-pas-u as deci.
def var v-pas-e as deci.
def var v-pas-r as deci.
def var v-pas-o as deci.
def var v-act-perc as deci.
def var v-pas-perc as deci.

v-act-perc = 0.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 0 no-lock:
    v-act = v-act + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 1 no-lock:
    v-act-t = v-act-t + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 2 no-lock:
    v-act-u = v-act-u + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 3 no-lock:
    v-act-e = v-act-e + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 4 no-lock:
    v-act-r = v-act-r + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 5 no-lock:
    v-act-o = v-act-o + wrk-act.sum.
end.

v-pas-perc = 0.
for each wrk-pas where wrk-pas.typ = "total" and wrk-pas.crc = 0 no-lock:
    v-pas = v-pas + wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.typ = "total" and wrk-pas.crc = 1 no-lock:
    v-pas-t = v-pas-t + wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.typ = "total" and wrk-pas.crc = 2 no-lock:
    v-pas-u = v-pas-u + wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.typ = "total" and wrk-pas.crc = 3 no-lock:
    v-pas-e = v-pas-e + wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.typ = "total" and wrk-pas.crc = 4 no-lock:
    v-pas-r = v-pas-r + wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.typ = "total" and wrk-pas.crc = 5 no-lock:
    v-pas-o = v-pas-o + wrk-pas.sum.
end.

def stream fond1.
output stream fond1 to fond1.html.
{html-title.i
 &title = "Цена базисного пункта (BPV)" &stream = "stream fond1" &size-add = "x-"}


put stream fond1 unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman"">"
   "<B>Фондирование активных операций АО 'ForteBank' на  " + string(v-dt, "99/99/9999") + "</FONT></P>" skip
   "<br><B><FONT size=""2"" face=""Times New Roman"">тыс.тенге" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.



/*1. Показатели структуры активов*/
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD colspan = 3><FONT size=""3"" face=""Times New Roman""><B>Активы</B></FONT></TD>" skip
    "<TD colspan = 3><FONT size=""3"" face=""Times New Roman""><B>Пассивы</B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Наименование</B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Сальдо </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Доля в валюте баланса </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Наименование</B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Сальдо </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Доля в валюте баланса </B></FONT></TD>" skip
    "</TR>" skip.
/*1-group*/
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD  style=""background-color: #D8BFD8"" colspan = 6><FONT size=""2"" face=""Times New Roman""><B>Группа I</B></FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Касса и драг.металлы</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 1 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Счета до востребования клиентов</B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 1 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 1 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 1 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 1 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 1 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 1 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 1 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 1 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 1 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 1 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 1 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Корсчета в НБ РК и БВУ</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 2 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Межбанковские займы и вклады</B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 2 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 2 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 2 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 2 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 2 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 2 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 2 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 2 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 2 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 2 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 8 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Срочные требования  к  НБ РК</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 3 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Срочные вклады    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 3 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 3 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 3 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 3 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 3 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 3 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 3 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 3 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 3 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 3 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 3 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Межбанковские займы и вклады </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 4 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Прямое Репо    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 4 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 4 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 4 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 4 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 4 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 4 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 4 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 4 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 4 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 4 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 4 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 9 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Торговый портфель ценных бумаг  </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 5 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Прочие пассивы    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 5 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 5 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 5 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 5 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 5 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 5 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 5 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 5 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 5 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 5 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 5 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 10 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Обратное Репо</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 6 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 6 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 6 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 6 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 6 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 6 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 11 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + "</FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 7 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    put stream fond1 unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman"">
    <B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF"">
    <FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>"
    skip.
    find first wrk-act where wrk-act.gr = 1 and wrk-act.id = 7 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    v-act-perc = v-act-perc + (round(wrk-act.sum / v-act * 100,2)).
    put stream fond1 unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 6 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas  then
    put stream fond1 unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>
    " + replace(string(wrk-pas.sum / 1000),".",",") + "</B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>
    " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + "</B></FONT></TD>" skip
    "</TR>" skip.
    find first wrk-pas where wrk-pas.gr = 1 and wrk-pas.id = 6 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas  then
    v-pas-perc = v-pas-perc + (round(wrk-pas.sum / v-pas * 100,2)).

/*2-group*/
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #D8BFD8"" colspan = 6><FONT size=""2"" face=""Times New Roman""><B>Группа II</B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Банковские займы - брутто</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 1 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Счета до востребования клиентов</B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 1 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 1 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 1 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 1 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 1 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> "+ replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в т.ч. займы по кредитн. карточкам и овердрафт</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 6 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 7 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Межбанковские займы и вклады </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 2 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Срочные вклады     </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 2 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 2 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 2 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 2 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 2 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 8 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Дебиторы по документарным расчетам</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 3 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + "
    </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> Межбанковские займы и вклады </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + "
    </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 3 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 3 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 3 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 3 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 3 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Портфель ценных бумаг до погашения </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Обязательства п/д Правительством и проч. фин. и нефин. орган-ми
    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc > 4  no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 9 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Заимствования путем выпуска ценных бумаг    </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">   </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">   </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">  </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Субординированный долг  </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">  </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">  </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">  </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Собственный капитал   </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">   </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">  </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">  </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Кредиторы по документарным расчетам  </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">  </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">  </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">  </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 5 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    put stream fond1 unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman"">
    <B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF"">
    <FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.

    find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 5 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    v-act-perc = v-act-perc + (round(wrk-act.sum / v-act * 100,2)).
    put stream fond1 unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 9 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas  then
    put stream fond1 unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>
    " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>
    " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + "</B></FONT></TD>" skip
    "</TR>" skip.
    find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 9 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas  then
    v-pas-perc = v-pas-perc + (round(wrk-pas.sum / v-pas * 100,2)).


/*3-group*/
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #D8BFD8"" colspan = 6><FONT size=""2"" face=""Times New Roman""><B>Группа III</B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Инвестицонный портфель</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Собственный капитал </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 5 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Осн. сред-ва и нематер-ные активы  </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Прочие пассивы     </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Прочие активы</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 3 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>Счета до востребования клиентов   </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 3 and wrk-act.crc = 1 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 1 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 3 and wrk-act.crc = 2 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 2 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 3 and wrk-act.crc = 3 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 3 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 3 and wrk-act.crc = 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 4 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 3 and wrk-act.crc > 4 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 5 no-lock no-error.
    if avail wrk-pas then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-pas.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">провизии</FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 6 no-lock no-error.
    if avail wrk-act then
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(wrk-act.sum / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </FONT></TD>" skip.
    put stream fond1 unformatted
    "<TD><FONT size=""2"" face=""Times New Roman""><B></B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""><B>  </B></FONT></TD>" skip
    "</TR>" skip.

put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе</B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 4 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    put stream fond1 unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman"">
    <B> " + replace(string(wrk-act.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF"">
    <FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-act.sum / v-act * 100,2)),".",",") + " </B></FONT></TD>" skip.
    find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 4 and wrk-act.crc = 0 no-lock no-error.
    if avail wrk-act  then
    v-act-perc = v-act-perc + (round(wrk-act.sum / v-act * 100,2)).

    put stream fond1 unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman""><B>Итого по группе </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 4 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas  then
    put stream fond1 unformatted
    "<TD style=""background-color: #F98DAF""><FONT size=""2"" face=""Times New Roman"">
    <B> " + replace(string(wrk-pas.sum / 1000),".",",") + " </B></FONT></TD>" skip
    "<TD style=""background-color: #F98DAF"">
    <FONT size=""2"" face=""Times New Roman""><B> " + replace(string(round(wrk-pas.sum / v-pas * 100,2)),".",",") + " </B></FONT></TD>" skip.
    find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 4 and wrk-pas.crc = 0 no-lock no-error.
    if avail wrk-pas  then
    v-pas-perc = v-pas-perc + (round(wrk-pas.sum / v-pas * 100,2)).
    put stream fond1 unformatted
    "</TR>" skip.

/*total*/
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>Итого активы - нетто</B></FONT></TD>" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>" + replace(string(v-act / 1000),".",",") +  "</B></FONT></TD>" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>"  + replace(string(v-act-perc),".",",") +  "</B></FONT></TD>" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>Итого пассивы </B></FONT></TD>" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B>" + replace(string(v-pas / 1000),".",",") +  "</B></FONT></TD>" skip
    "<TD style=""background-color: #D8BFD8""><FONT size=""2"" face=""Times New Roman""><B> "  + replace(string(v-pas-perc),".",",") +  " </B></FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string( v-act-t / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(v-act-t / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в том числе: в тенге</FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string( v-pas-t / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">" + replace(string(round(v-pas-t / v-pas * 100,2)),".",",") + "  </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">в USD</FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(v-act-u / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">" + replace(string(round(v-act-u / v-act * 100,2)),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в USD </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string( v-pas-u / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">" + replace(string(round(v-pas-u / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(v-act-e / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(v-act-e / v-act * 100,2)),".",",") + "</FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в EUR </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string( v-pas-e / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(v-pas-e / v-pas * 100,2)),".",",") + "</FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(v-act-r / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(v-act-r / v-act * 100,2)),".",",") + "</FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в RUB </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string( v-pas-r / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">" + replace(string(round(v-pas-r / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.
put stream fond1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(v-act-o / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string(round(v-act-o / v-act * 100,2)),".",",") + "</FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> в других валютах </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman""> " + replace(string( v-pas-o / 1000),".",",") + " </FONT></TD>" skip
    "<TD><FONT size=""2"" face=""Times New Roman"">" + replace(string(round(v-pas-o / v-pas * 100,2)),".",",") + " </FONT></TD>" skip
    "</TR>" skip.


put stream fond1 unformatted
"</TABLE> <br><br>" skip.

{html-end.i "stream fond1" }

output stream fond1 close.
unix silent cptwin fond1.html excel.exe.
pause 0.