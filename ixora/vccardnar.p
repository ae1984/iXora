/* vccardnar.p
 * MODULE
        Название модуля - Отчет по карточкам по нарушению
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def var v-date as date.
def var v-sts  as char.

def var repname as char init "1.htm".
def var i       as inte init 0.

def stream rep.
output stream rep to value(repname).

def new shared temp-table t-temp
    field cif      as char
    field ctnum    as char
    field ctdate   as char
    field ncrc     as char
    field cardnum  as char
    field sumoper  as char
    field dateoper as char
    field codetype as char
    field desnar   as char.

form
    v-date label "На дату" format "99/99/9999" validate(v-date <= g-today, "Дата не должна быть больше текущей!!!") skip
    v-sts  label "Статус карточки" validate(v-sts = "A" or v-sts = "N" or v-sts = "D", "Выберите A,N,D !!!")
    help "Выберите A - все, N - новые, D - действующие." skip
with centered side-labels row 10 overlay title "Укажите дату и статус карточки для отчета:" frame vccardnar.

v-date = g-today.
v-sts  = "A".
displ v-date  with frame vccardnar.
displ v-sts   with frame vccardnar.
update v-date with frame vccardnar.
displ v-date  with frame vccardnar.
update v-sts  with frame vccardnar.
displ v-sts   with frame vccardnar.

{r-brfilial.i   &proc = " vccardnardat (input txb.bank, v-date, v-sts) "}

{html-title.i
 &stream = " stream rep "
 &size-add = "xx-"
 &title = " Отчет о карточках по нарушению "
}

put stream rep unformatted
    "<B>" skip
    "<P align = ""center""><FONT size=5>Контракты, имеющие лицевые карточки</FONT></P>" skip.

put stream rep unformatted
    "<TABLE  width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream rep unformatted
    "<TR align=""center"">" skip
    "<td><FONT size=3>N</FONT></td>" skip
    "<td><FONT size=3>Наименование клиента</FONT></td>" skip
    "<td><FONT size=3>Номер контракта</FONT></td>" skip
    "<td><FONT size=3>Дата контракта</FONT></td>" skip
    "<td><FONT size=3>Валюта <br> контракта</FONT></td>" skip
    "<td><FONT size=3>Номер карточки</FONT></td>" skip
	"<td><FONT size=3>Сумма операции</FONT></td>" skip
    "<td><FONT size=3>Дата операции</FONT></td>" skip
	"<td><FONT size=3>Вид <br> нарушения</FONT></td>" skip
	"<td><FONT size=3>Суть нарушения</FONT></td>" skip
	"</B></TR>" skip.

for each t-temp no-lock:
    i = i + 1.
    put stream rep unformatted
        "<TR align=""center"">" skip
        "<TD><FONT size=2>" string(i)        "</FONT></TD>" skip
        "<TD><FONT size=2>" t-temp.cif       "</FONT></TD>" skip
        "<TD><FONT size=2>" t-temp.ctnum     "</FONT></TD>" skip
        "<TD><FONT size=2>" t-temp.ctdate    "</FONT></TD>" skip
        "<TD><FONT size=2>" t-temp.ncrc      "</FONT></TD>" skip
        "<TD><FONT size=2>." t-temp.cardnum   "</FONT></TD>" skip
        "<TD><FONT size=2>" t-temp.sumoper   "</FONT></TD>" skip
        "<TD><FONT size=2>" t-temp.dateoper  "</FONT></TD>" skip
        "<TD><FONT size=2>" t-temp.codetype  "</FONT></TD>" skip
        "<TD><FONT size=2>" t-temp.desnar    "</FONT></TD>" skip
        "</TR>" skip.
end.

{html-end.i " stream rep "}

put stream rep unformatted
    "</TABLE>".

output stream rep close.
unix silent cptwin value(repname) excel.