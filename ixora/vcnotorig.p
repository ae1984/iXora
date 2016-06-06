/* vcnotorig.p
 * MODULE
        Название модуля - Карточка по нарушению
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
        24.04.2012 damir - перекомпиляция.
*/

{mainhead.i}

def new shared temp-table t-temp
    field cifname as char
    field contr   as char
    field ps      as char
    field daypros as inte.

def new shared var v-date as date.

def var file    as char init "doc.htm".
def var v-month as char.
def var v-god   as char.
def stream rep.
output stream rep to value(file).

v-date = g-today.
v-month = substr(string(g-today),4,2).
v-god = substr(string(g-today),7,4).
form
    v-date label "Ввод даты" validate(v-date <= g-today,"Дата не должна быть больше текущей !!!")
with centered side-label row 5 width 80 title "Укажите дату отчета" frame f-oper.

displ v-date with frame f-oper.
update v-date with frame f-oper.

{r-brfilial.i &proc = "vcnotorigdat(input txb.bank)"}

find first cmp no-lock no-error.

{html-title.i &stream = "stream rep"}

put stream rep unformatted
    "<P align = ""center""><FONT size=""4""><B>" skip
    "Отчет по нарушениям предоставления оригиналов контрактов.</FONT></P>" skip
    "<FONT size=""4"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""left"">" skip
    "Наименование банка: <U>"  cmp.name "</U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" skip
    "за " + string(g-today) "</P></FONT></B>" skip.

put stream rep unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
    "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
    "<TD>Наименование клиента</TD>" skip
    "<TD>№ и дата контракта</TD>" skip
    "<TD>Номер ПС</TD>" skip
    "<TD>Кол-во дней просрочки</TD>" skip.

for each t-temp no-lock:
    put stream rep unformatted
         "<TR align=""center"">" skip
         "<TD>" t-temp.cifname         "</TD>" skip
         "<TD>" t-temp.contr           "</TD>" skip
         "<TD>" t-temp.ps              "</TD>" skip
         "<TD>" string(t-temp.daypros) "</TD>" skip
         "</TR>" skip.
end.

put stream rep unformatted
    "</TABLE>".

{html-end.i "stream rep"}


output stream rep close.

unix silent value("cptwin " + file + " winword").
pause 0.

