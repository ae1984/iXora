/* newcifcode.p
 * MODULE
        Название модуля - Новые CIF коды с открытыми счетами.
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

def var repname   as char init "1.htm".
def var v-dte     as date no-undo.
def var v-dtb     as date no-undo.
def var v-type    as char no-undo.

def new shared temp-table newtemp
    field filial as char
    field summ   as deci decimals 2.

def stream rep.
output stream rep to value(repname).

v-dte = g-today.
v-dtb = g-today.
v-type = "b".

form
    v-dte  label "С " skip
    v-dtb  label "ПО " skip
    v-type label "Тип клиентов" validate(v-type = "b" or v-type = "p", "Недопустимый тип клиента, введите P или B !") skip

with centered side-label title "Введите период отчета(помесячно)" frame aaa.

update v-dte v-dtb v-type with frame aaa.
displ  v-dte v-dtb v-type with frame aaa.

{r-brfilial.i   &proc = " newcifcodedat(input txb.bank, '1', v-dte, v-dtb, v-type) "}

{html-title.i}
def var caption as char init "Новые CIF коды, с открытыми счетами.".
def var namebank as char.
def buffer b-cmp for cmp.
find first b-cmp no-lock no-error.
if avail b-cmp then do:
    namebank = trim(b-cmp.name).
end.

put stream rep unformatted
    "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

put stream rep unformatted
    "<P align=center colspan=10><font size=""4""><b><a name="" ""></a>" caption "  " namebank "  С " v-dte
    " ПО " v-dtb "</b></font></P>" skip.

put stream rep unformatted
    "<TR style=""font:bold;font-size:11pt"">" skip
    "<TD rowspan=2 colspan=2 align=center>" "ФИЛИАЛ" "</TD>" skip
    "<TD align=center>" "ПЕРИОД"                     "</TD>" skip
    "</TR>" skip
    "<TR>" skip
    "<TD align=center>" "С " + string(v-dte) + " ПО " + string(v-dtb) "</TD>" skip
    "</TR>" skip.

def var j  as inte init 0.
def var sumall as deci init 0.
for each newtemp no-lock:
    j = j + 1.
    sumall = sumall + newtemp.summ.
    put stream rep unformatted
        "<TR>" skip
        "<TD align=center>" string(j)      "</TD>" skip
        "<TD align=center>" newtemp.filial "</TD>" skip
        "<TD align=center>" newtemp.summ   "</TD>" skip
        "</TR>".
end.
put stream rep unformatted
    "<TR>" skip
    "<TD colspan=2 align=center>" "ИТОГО ПО БАНКУ" "</TD>" skip
    "<TD align=center>" sumall "</TD>" skip
    "</TR>" skip.

put stream rep unformatted
    "</TABLE>" skip.

output stream rep close.
{html-end.i }
unix silent cptwin value(repname) excel.



