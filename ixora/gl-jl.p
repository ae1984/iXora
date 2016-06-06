/* gl-jl.p
 * MODULE
        Вал контроль
 * DESCRIPTION
        Сверка текущего счета клиента и платежей ВК
 * RUN
        vccomp.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        24.02.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        27.02.2012 aigul - добавила индексы
*/
{global.i}
def new shared var v-dt1 as date no-undo.
def new shared var v-dt2 as date no-undo.
def new shared temp-table wrk
    field fil as char
    field dgl as int
    field dtype as char
    field cgl as int
    field ctype as char
    field ln as int
    field jh as int
    field dt as date
    field des as char
    field fio as char
    field uid as char
    field usr as char
    field amt as decimal
    field amt_kzt as decimal
    index main is primary ln.
def buffer b-wrk for wrk.
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

{r-branch.i &proc = "gl-jl-dat"}

/*{r-brfilial.i &proc = "gl-jl-dat"}*/
def stream gl-jl.
output stream gl-jl to gl-jl.html.
{html-title.i
 &title = "Сверка корр.счетов и п.9.3.4 Реестр платежей" &stream = "stream gl-jl" &size-add = "x-"}


put stream gl-jl unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет по проведенным проводкам<BR>за дату c " + string(v-dt1, "99/99/9999") + " по " + string(v-dt2, "99/99/9999") +
   "</FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Исходящие платежи, которых нет в Прагме. */
put stream gl-jl unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Filial</B></FONT></TD>" skip
     /*"<TD><FONT size=""2""><B>Line</B></FONT></TD>" skip*/
     "<TD><FONT size=""2""><B>GLDB</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>DB_TYPE</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>GLCR</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>CR_TYPE</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>TRX_ID</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>TRX_DATE</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>TRX_DESC</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>TRX_FIO</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>TRX_UID</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>TRX_AUTO</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>TRX_AMOUNT_NOMINAL</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>TRX_AMOUNT_KZT</B></FONT></TD>" skip
   "</TR>" skip.

for each wrk no-lock:
    put stream gl-jl unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2"">" + wrk.fil   + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + string(wrk.dgl)   + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.dtype   + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + string(wrk.cgl)   + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.ctype + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + string(wrk.jh) + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + string(wrk.dt, "99/99/99") + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.des + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.fio + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.uid + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + wrk.usr + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + replace(trim(string(wrk.amt, "->>>>>>>>>>>>>>9.99")),".",",") + "</FONT></TD>" skip
    "<TD><FONT size=""2"">" + replace(trim(string(wrk.amt_kzt, "->>>>>>>>>>>>>>9.99")),".",",") + "</FONT></TD>" skip
    "</TR>" skip.
end.



put stream gl-jl unformatted
"</TABLE>" skip.

{html-end.i "stream gl-jl" }

output stream gl-jl close.
unix silent cptwin gl-jl.html excel.exe.
pause 0.
