/* kzrepfcur.p
 * MODULE
        7.4.3.7.1 Операции с нал. ин. вал. в разрезе каждой операции
 * DESCRIPTION
        Описание
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
        05.12.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
def new shared var v-dt1 as date no-undo.
def new shared var v-dt2 as date no-undo.
def new shared var v-reptype as int no-undo.
def new shared temp-table wrk
    field dt as date
    field fil as char
    field crc as int
    field sdelka as char
    field sum as decimal
    field kurs as decimal
    field tim as int
    field typ as char
    field order as char
    field ofc as char
    field rem as char
    field chk as char.

def frame fparam
   v-dt1 label "Период с" format "99/99/9999" validate(v-dt1 <= g-today,'Дата не может быть больше операционной')
   v-dt2 label "по" format "99/99/9999" validate(v-dt1 <= v-dt2 and v-dt2 <= g-today,'Дата начала не может быть меньше даты окончания и больше текущей даты') skip
   v-reptype label ' Тип курса' format "9"
   validate ( v-reptype > 0 and v-reptype < 4, " Тип курса - 1, 2, или 3") help "1 - все, 2 - стандартные, 3 - льготные"
with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

v-dt1 = g-today.
v-dt2 = g-today.
v-reptype = 1.
update v-dt1 with frame fparam.
update v-dt2 with frame fparam.
update v-reptype with frame fparam.

{r-brfilial.i &proc = "kzrepfcur-dat"}


def stream vcrpt.
output stream vcrpt to kzrepfcur.xls.
{html-title.i
 &title = "Приложение 1" &stream = "stream vcrpt" &size-add = "x-"}
 find first cmp no-lock no-error.

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman""></P>" skip
   "<P align = ""left""><FONT size=""2"" face=""Times New Roman"">"
   "<B>Приложение 2</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Исходящие платежи, которых нет в Прагме. */
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Дата</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Филиал</B></FONT></TD>" skip
     "<TD ><FONT size=""2"" ><B>Валюта</B></FONT></TD>" skip
     "<TD ><FONT size=""2"" ><B>Вид сделки</B></FONT></TD>" skip
     "<TD ><FONT size=""2"" ><B>Сумма</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Курс</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Время операции (время Астаны)</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Вид курса</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>№ распоряжения</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Кассир/ менеджер</B></FONT></TD>" skip
   "</TR>" skip.
if v-reptype = 1 or v-reptype = 2 then do:
    for each wrk where wrk.typ = "стандартный" no-lock break by wrk.dt /*by wrk.tim*/ by wrk.fil by wrk.crc by wrk.sdelka by wrk.sum:
            put stream vcrpt unformatted
            "<TD><FONT size=""2"">" + string(wrk.dt, "99/99/99") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + wrk.fil   + "</FONT></TD>" skip.
            find first crc where crc.crc = wrk.crc no-lock no-error.
            if avail crc then put stream vcrpt unformatted
            "<TD><FONT size=""2"">" + crc.des + "</FONT></TD>" skip.
            put stream vcrpt unformatted
            "<TD><FONT size=""2"">" + wrk.sdelka + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk.sum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip.
            put stream vcrpt unformatted
            "<TD><FONT size=""2"">" + replace(trim(string(wrk.kurs, "->>>>>>>>>>>>>>9.999")),".",",")   + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + string(wrk.tim,"HH:MM:SS") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + wrk.typ + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + wrk.order + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + wrk.ofc + "</FONT></TD>" skip
            /*"<TD><FONT size=""2"">" + wrk.rem + "</FONT></TD>" skip*/.
            put stream vcrpt unformatted "</TR>" skip.
    end.
end.
if v-reptype = 1 or v-reptype = 3 then do:
    for each wrk where wrk.typ = "льготный" no-lock break by wrk.dt /*by wrk.tim*/ by wrk.fil by wrk.crc by wrk.sdelka by wrk.sum:
            put stream vcrpt unformatted
            "<TD><FONT size=""2"">" + string(wrk.dt, "99/99/99") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + wrk.fil   + "</FONT></TD>" skip.
            find first crc where crc.crc = wrk.crc no-lock no-error.
            if avail crc then put stream vcrpt unformatted
            "<TD><FONT size=""2"">" + crc.des + "</FONT></TD>" skip.
            put stream vcrpt unformatted
            "<TD><FONT size=""2"">" + wrk.sdelka + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk.sum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip.
            put stream vcrpt unformatted
            "<TD><FONT size=""2"">" + replace(trim(string(wrk.kurs, "->>>>>>>>>>>>>>9.999")),".",",")   + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + string(wrk.tim,"HH:MM:SS") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + wrk.typ + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + wrk.order + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + wrk.ofc + "</FONT></TD>" skip
            /*"<TD><FONT size=""2"">" + wrk.rem + "</FONT></TD>" skip*/.
            put stream vcrpt unformatted "</TR>" skip.
    end.
end.
put stream vcrpt unformatted "</TABLE>" skip.
{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin kzrepfcur.xls excel").

pause 0.
