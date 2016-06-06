/* .p
 * MODULE
        Название модуля
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

def new shared temp-table t-acc
    field filial  as char
    field cif     like cif.cif
    field crc     like crc.crc
    field summ    as deci decimals 2
    field rdt     as date
    field duedt   as date
    field monthdt as deci decimals 2
    field stavka% as deci decimals 2
    field nbrksum as deci decimals 2
    field type    as char.

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

{r-brfilial.i   &proc = " depurfizdat(input txb.bank, '1', v-dte, v-dtb, v-type) "}

{html-title.i}
def var caption as char init "Депозиты юридических и физических лиц.".
def var namebank as char.
def buffer b-cmp for cmp.
find first b-cmp no-lock no-error.
if avail b-cmp then do:
    namebank = trim(b-cmp.name).
end.

put stream rep unformatted
    "<html><head>
     <META content=""text/html; charset=windows-1251"" http-equiv=Content-Type>
     <META content=ru http-equiv=Content-Language>
    </head>
    <TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

put stream rep unformatted
    "<P align=center colspan=10><font size=""4""><b><a name="" ""></a>" caption "  " namebank "  С " v-dte
    " ПО " v-dtb "</b></font></P>" skip.

put stream rep unformatted
    "<TR>" skip
    "<TD align=center>" "Филиал"           "</TD>" skip
    "<TD align=center>" "Клиент"           "</TD>" skip
    "<TD align=center>" "Валюта"           "</TD>" skip
    "<TD align=center>" "Сумма"            "</TD>" skip
    "<TD align=center>" "Дата открытия"    "</TD>" skip
    "<TD align=center>" "Дата закрытия"    "</TD>" skip
    "<TD align=center>" "Срок в месяцах"   "</TD>" skip
    "<TD align=center>" "Ставка (%)"       "</TD>" skip
    "<TD align=center>" "Сумма в тенге(по курсу НБ РК на дату формирования отчета)" "</TD>" skip
    "<TD align=center>" "Вид депозита"     "</TD>" skip
    "</TR>" skip.
def var v-sum  as deci decimals 2 init 0.
def var v-summ as deci decimals 2 init 0.
def buffer b-t-acc for t-acc.
for each t-acc no-lock break by t-acc.filial:
    if first-of(t-acc.filial) then do:
        v-summ = 0.
        for each b-t-acc where b-t-acc.filial = t-acc.filial no-lock:
            v-summ = v-summ + t-acc.nbrksum.
            put stream rep unformatted
               "<TR>" skip
               "<TD align=center>"   t-acc.filial          "</TD>" skip
               "<TD align=center>"   t-acc.cif             "</TD>" skip
               "<TD align=center>"   string(t-acc.crc)     "</TD>" skip
               "<TD align=center>"   string(t-acc.summ)    "</TD>" skip
               "<TD align=center>"   string(t-acc.rdt)     "</TD>" skip
               "<TD align=center>"   string(t-acc.duedt)   "</TD>" skip
               "<TD align=center>' " string(t-acc.monthdt) "</TD>" skip
               "<TD align=center>"   string(t-acc.stavka%) "</TD>" skip
               "<TD align=center>"   string(t-acc.nbrksum) "</TD>" skip
               "<TD align=center>"   t-acc.type            "</TD>" skip
               "</TR>" skip.
        end.
        put stream rep unformatted
        "<TR>" skip
        "<TD align=center colspan=8>" "Итого по Филиалу" "</TD>" skip
        "<TD align=center>" string(v-summ) "</TD>" skip
        "</TR>" skip.
        v-sum = v-sum + v-summ.
        message v-sum view-as alert-box.
    end.
end.
put stream rep unformatted
    "<TR>" skip
    "<TD align=center colspan=8>" "Итого по Банку" "</TD>" skip
    "<TD align=center>" string(v-sum) "</TD>" skip
    "</TR>" skip.

put stream rep unformatted
    "</TABLE>" skip.

output stream rep close.
{html-end.i }
unix silent cptwin value(repname) excel.