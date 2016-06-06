/* delbxrep.p
 * MODULE
        Название модуля - Клиенты и счета
 * DESCRIPTION
        Описание - Отчет по списанным комиссиям по филиалу
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 1.4.1.20.3
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def new shared var v-dtb as date.
def new shared var v-dte as date.

def new shared temp-table t-temp
    field filname as char
    field dtspis  as date
    field crc     as char
    field cif     as char
    field name    as char
    field rem     as char
    field dtcreat as date
    field acc     as char
    field amount  as deci
    field sumkz   as deci
    field idmen   as char
    field idcon   as char
    index idx is primary dtspis ascending
                         cif ascending
                         acc ascending
                         amount ascending.

def var repname as char init "bxcif.htm".
def stream rep.
output stream rep to value(repname).

v-dtb = g-today.
v-dte = g-today.

form
    v-dtb label "С" format "99/99/9999" validate(v-dtb <= g-today, "Дата не должна быть больше текущей !!!") skip
    v-dte label "ПО" format "99/99/9999" validate(v-dte <= g-today, "Дата не должна быть больше текущей !!!") skip
with side-labels row 5 centered title "УКАЖИТЕ ПЕРИОД" frame delbxcif.

update v-dtb v-dte with frame delbxcif.
displ v-dtb v-dte with frame delbxcif.

{r-brfilial.i &proc = " delbxrepdat(input txb.info) "}

{html-title.i
 &stream = " stream rep "
 &size-add = "xx-"
 &title = " "
}


put stream rep unformatted
    "<B>" skip
    "<P align = ""center""><FONT size=5>Отчет по списанным комиссиям</FONT></P></B>" skip.

put stream rep unformatted
    "<TABLE  width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream rep unformatted
    "<TR align=""center"">" skip
    "<td><FONT size=3><B>Наименование <br> филиала</B></FONT></td>" skip
    "<td><FONT size=3><B>Дата <br> списания</B></FONT></td>" skip
    "<td><FONT size=3><B>Валюта <br> задолженности</B></FONT></td>" skip
    "<td><FONT size=3><B>CIF-код <br> клиента</B></FONT></td>" skip
    "<td><FONT size=3><B>Наименование <br> клиента</B></FONT></td>" skip
    "<td><FONT size=3><B>Примечание</B></FONT></td>" skip
    "<td><FONT size=3><B>Дата <br> образования <br> задолженности</B></FONT></td>" skip
	"<td><FONT size=3><B>№ счета <br> клиента</B></FONT></td>" skip
    "<td><FONT size=3><B>Сумма в <br> валюте</B></FONT></td>" skip
	"<td><FONT size=3><B>Сумма в <br> тенге</B></FONT></td>" skip
	"<td><FONT size=3><B>id менеджера</B></FONT></td>" skip
    "<td><FONT size=3><B>id контролера</B></FONT></td>" skip
	"</TR>" skip.

for each t-temp no-lock use-index idx:
    put stream rep unformatted
        "<TR align=""center"">" skip
        "<td><FONT size=2>" t-temp.filname                      "</FONT></td>" skip
        "<td><FONT size=2>" string(t-temp.dtspis, "99/99/9999") "</FONT></td>" skip
        "<td><FONT size=2>" t-temp.crc                          "</FONT></td>" skip
        "<td><FONT size=2>" t-temp.cif                          "</FONT></td>" skip
        "<td><FONT size=2>" t-temp.name                         "</FONT></td>" skip
        "<td><FONT size=2>" t-temp.rem                          "</FONT></td>" skip
        "<td><FONT size=2>" t-temp.dtcreat                      "</FONT></td>" skip
        "<td><FONT size=2>" t-temp.acc                          "</FONT></td>" skip
        "<td><FONT size=2>" string(t-temp.amount, ">>>,>>>,>>>,>>9.99") "</FONT></td>" skip
        "<td><FONT size=2>" string(t-temp.sumkz, ">>>,>>>,>>>,>>9.99")  "</FONT></td>" skip
        "<td><FONT size=2>" t-temp.idmen                        "</FONT></td>" skip
        "<td><FONT size=2>" t-temp.idcon                        "</FONT></td>" skip
        "</TR>" skip.
end.

{html-end.i " stream rep "}

put stream rep unformatted
    "</TABLE>".

output stream rep close.
unix silent cptwin value(repname) excel.