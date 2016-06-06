/* comm-esp.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по комиссии за выпуск ЭЦП
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
        28.03.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        04.05.2012 aigul - добавила Bases
*/

{global.i}

def new shared var v-dt1 as date no-undo.
def new shared var v-dt2 as date no-undo.
def new shared temp-table wrk
    field fil as char
    field num as int
    field dt as date
    field client as char
    field usr as char
    field acc as char
    field ofc as char.
def var v-bank as char.

find cmp no-lock no-error.
v-bank = cmp.name.

def frame fparam
   v-dt1 label "Период с" format "99/99/9999" validate(v-dt1 <= g-today,'Дата не может быть больше операционной')
   v-dt2 label "по" format "99/99/9999" validate(v-dt1 <= v-dt2 and v-dt2 <= g-today,'Дата начала не может быть меньше даты окончания и больше текущей даты') skip
with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

v-dt1 = g-today.
v-dt2 = g-today.
update v-dt1 with frame fparam.
update v-dt2 with frame fparam.

{r-brfilial.i &proc = "comm-esp-dat"}
def stream gl-jl.
output stream gl-jl to gl-jl.html.
{html-title.i
 &title = "Отчет по комиссии за выпуск ЭЦП" &stream = "stream gl-jl" &size-add = "x-"}


put stream gl-jl unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет по комиссии за выпуск ЭЦП <BR>за дату c " + string(v-dt1, "99/99/9999") + " по " + string(v-dt2, "99/99/9999") +
   "</FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Исходящие платежи, которых нет в Прагме. */
put stream gl-jl unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Филиал</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер документа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата документа</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Клиент</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Пользователь</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Счет</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сотрудник</B></FONT></TD>" skip
   "</TR>" skip.

for each wrk no-lock:
    put stream gl-jl unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"">" + wrk.fil   + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + string(wrk.num) + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + string(wrk.dt, "99/99/99") + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.client + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.usr + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.acc + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.ofc + "</FONT></TD>" skip
    "</TR>" skip.
end.



put stream gl-jl unformatted
"</TABLE>" skip.

{html-end.i "stream gl-jl" }

output stream gl-jl close.
unix silent cptwin gl-jl.html excel.exe.
pause 0.