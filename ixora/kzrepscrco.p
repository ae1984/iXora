/* kzrepscrco.p
 * MODULE
        7.4.3.6.3 Опорные и курсы филиала для о/п
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
        05.04.2012 aigul - добавила прогу kzrepscrco-opor для подсчета опорников
        16.04.2012 aigul - исправила вывод данных
*/

{global.i}

def new shared var v-dt1 as date no-undo.
def new shared var v-dt2 as date no-undo.
def new shared var v-reptype as int no-undo.
def new shared temp-table wrk
    field dt as date
    field fil as char
    field usell as decimal
    field ubuy as decimal
    field uspred as decimal
    field esell as decimal
    field ebuy as decimal
    field espred as decimal
    field rsell as decimal
    field rbuy as decimal
    field rspred as decimal
    field tim as int
    field typ as char
    field rasp as char.
def new shared temp-table wrk-op
    field dt as date
    field fil as char
    field usell as decimal
    field ubuy as decimal
    field uspred as decimal
    field esell as decimal
    field ebuy as decimal
    field espred as decimal
    field rsell as decimal
    field rbuy as decimal
    field rspred as decimal
    field tim as int
    field typ as char
    field rasp as char.
def new shared temp-table wrk1
    field dt as date
    field fil as char
    field usell as decimal
    field ubuy as decimal
    field uspred as decimal
    field esell as decimal
    field ebuy as decimal
    field espred as decimal
    field rsell as decimal
    field rbuy as decimal
    field rspred as decimal
    field tim as int
    field typ as char
    field rasp as char.
def var v-bank as char initial "ЦО".
def buffer b-wrk for wrk.
def frame fparam
   v-dt1 label "Период с" format "99/99/9999" validate(v-dt1 <= g-today,'Дата не может быть больше операционной')
   v-dt2 label "по" format "99/99/9999" validate(v-dt1 <= v-dt2 and v-dt2 <= g-today,'Дата начала не может быть меньше даты окончания и больше текущей даты') skip
   v-reptype label ' Тип курса' format "9"
   validate ( v-reptype > 0 and v-reptype < 5, " Тип курса - 1, 2, 3 или 4") help "1 - все, 2 - опорные, 3 - стандартные, 4 - льготные"
with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

v-dt1 = g-today.
v-dt2 = g-today.
v-reptype = 1.
update v-dt1 with frame fparam.
update v-dt2 with frame fparam.
update v-reptype with frame fparam.

if v-reptype = 1 or v-reptype = 2 then do:
    run kzrepscrco-opor.
end.

{r-brfilial.i &proc = "kzrepscrco-dat"}
for each wrk no-lock break by wrk.fil by wrk.rasp:
    if first-of(wrk.rasp) then do:
        create wrk1.
        wrk1.dt = wrk.dt.
        wrk1.fil = wrk.fil.
        wrk1.usell = wrk.usell.
        wrk1.ubuy = wrk.ubuy.
        wrk1.uspred = wrk.uspred.
        wrk1.esell = wrk.esell.
        wrk1.ebuy = wrk.ebuy.
        wrk1.espred = wrk.espred.
        wrk1.rsell = wrk.rsell.
        wrk1.rbuy = wrk.rbuy.
        wrk1.rspred = wrk.rspred.
        wrk1.typ = wrk.typ .
        wrk1.rasp = wrk.rasp.
        wrk1.tim = wrk.tim.
   end.
   else do:
        for each wrk1 where wrk1.rasp = wrk.rasp and wrk1.fil = wrk.fil and wrk1.dt = wrk.dt
        and wrk1.typ = wrk.typ exclusive-lock:
            if wrk1.usell = 0 then do:
            wrk1.usell = wrk.usell.
            wrk1.ubuy = wrk.ubuy.
            wrk1.uspred = wrk.uspred.
            end.
            if wrk1.esell = 0 then do:
            wrk1.esell = wrk.esell.
            wrk1.ebuy = wrk.ebuy.
            wrk1.espred = wrk.espred.
            end.
            if wrk1.rsell = 0 then do:
            wrk1.rsell = wrk.rsell.
            wrk1.rbuy = wrk.rbuy.
            wrk1.rspred = wrk.rspred.
            end.
        end.
    end.
end.

def stream vcrpt.
output stream vcrpt to kzrepscrco.htm.
{html-title.i
 &title = "Приложение 1" &stream = "stream vcrpt" &size-add = "x-"}
 find first cmp no-lock no-error.

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman""></P>" skip
   "<P align = ""left""><FONT size=""2"" face=""Times New Roman"">"
   "<B>Приложение 1</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Исходящие платежи, которых нет в Прагме. */
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Дата</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Подразделение</B></FONT></TD>" skip
     "<TD colspan = 3><FONT size=""2"" ><B>Доллар США</B></FONT></TD>" skip
     "<TD colspan = 3><FONT size=""2"" ><B>Евро</B></FONT></TD>" skip
     "<TD colspan = 3><FONT size=""2"" ><B>Российские рубли</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Время Астаны</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Вид курсов</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>№  распоряжения</B></FONT></TD>" skip
   "</TR>" skip.
   put stream vcrpt unformatted "<tr style=""font:bold"">"
   "<td bgcolor=""#C0C0C0"" align=""center""> </td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> </td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> курс покупки</td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> курс продажи</td>"
   "<td bgcolor=""#C0C0C0"" align=""center"">«Мин спрэд»*</td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> курс покупки</td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> курс продажи</td>"
   "<td bgcolor=""#C0C0C0"" align=""center"">«Мин спрэд»*</td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> курс покупки</td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> курс продажи</td>"
   "<td bgcolor=""#C0C0C0"" align=""center"">«Мин спрэд»*</td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> </td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> </td>"
   "<td bgcolor=""#C0C0C0"" align=""center""> </td></tr>" skip.


for each wrk1 no-lock break by wrk1.dt by wrk1.tim by wrk1.fil:
        put stream vcrpt unformatted
        "<TD><FONT size=""2"">" + string(wrk1.dt, "99/99/99") + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + wrk1.fil   + "</FONT></TD>" skip.
        put stream vcrpt unformatted
        "<TD><FONT size=""2"">" + replace(trim(string(wrk1.ubuy, "->>>>>>>>>>>>>>9.999")),".",",")   + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + replace(trim(string(wrk1.usell, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + replace(trim(string(wrk1.uspred, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip.
        put stream vcrpt unformatted
        "<TD><FONT size=""2"">" + replace(trim(string(wrk1.ebuy, "->>>>>>>>>>>>>>9.999")),".",",")   + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + replace(trim(string(wrk1.esell, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + replace(trim(string(wrk1.espred, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + replace(trim(string(wrk1.rbuy, "->>>>>>>>>>>>>>9.999")),".",",")   + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + replace(trim(string(wrk1.rsell, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + replace(trim(string(wrk1.rspred, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip.
        put stream vcrpt unformatted
        "<TD><FONT size=""2"">" + string(wrk1.tim,"HH:MM:SS") + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + wrk1.typ + "</FONT></TD>" skip
        "<TD><FONT size=""2"">" + wrk1.rasp + "</FONT></TD>" skip.
        put stream vcrpt unformatted "</TR>" skip.
end.


put stream vcrpt unformatted "</TABLE>" skip.
put stream vcrpt unformatted " * только для 'опорных' курсов" skip.
{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin kzrepscrco.htm excel").

pause 0.
