/* sumincome.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Доходы в разбивке по суммам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.4.1.16.6.2
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        07.10.2011 damir - исправил диапазон от 100000 до 1000000 тенге.
        11.10.2012 damir - на основании С.З. от 11.10.2012 г., добавил счета ГК 460112,460715,460828,460829,461500.
        30.04.2013 damir - Внедрено Т.З. № 1805.
*/
{mainhead.i}

def var repname as char init "sumincome.htm".

def new shared temp-table temptable no-undo
    field filial as char
    field i1 as inte
    field i2 as inte
    field i3 as inte
    field i4 as inte
    field i5 as inte
    field i6 as inte
    field sumamt1 as deci decimals 2
    field sumamt2 as deci decimals 2
    field sumamt3 as deci decimals 2
    field sumamt4 as deci decimals 2
    field sumamt5 as deci decimals 2
    field sumamt6 as deci decimals 2
    field srednee1 as deci decimals 2
    field srednee2 as deci decimals 2
    field srednee3 as deci decimals 2
    field srednee4 as deci decimals 2
    field srednee5 as deci decimals 2
    field srednee6 as deci decimals 2.

def new shared temp-table filpay no-undo
    field filid as char
    field bankfrom as char
    field bankto as char
    field iik as char
    field cif as char
    field jhcom as inte
    field gl as inte
    field jhamt as deci decimals 2
index idx1 iik ascending.

def new shared var v-dte as date.
def new shared var v-dtb as date.

def stream rep.

v-dte = g-today.
v-dtb = g-today.

form
    v-dte label "С " skip
    v-dtb label "ПО " skip
with centered side-label title "Введите период отчета" frame aaa.

update v-dte v-dtb with frame aaa.
displ  v-dte v-dtb with frame aaa.

if connected ("txb") then disconnect "txb".
for each txb where txb.consolid no-lock:
    if connected ("txb") then  disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
    run sumincomedat2(input txb.bank, v-dte, v-dtb).
    disconnect "txb".
end.

{r-brfilial.i &proc = "sumincomedat"}

output stream rep to value(repname).
{html-title.i &stream = "stream rep"}

def var caption as char init "Доходы в разбивке по суммам.".
def var namebank as char.
def buffer b-cmp for cmp.
find first b-cmp no-lock no-error.
if avail b-cmp then namebank = trim(b-cmp.name).

put stream rep unformatted
    "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

put stream rep unformatted
    "<P align=center style='font-size:14pt;font:bold' colspan=10>Доходы в разбивке по суммам. " namebank "  С " v-dte " ПО " v-dtb "</b></font></P>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<TD colspan=2 >Филиал / Доход</TD>" skip
    "<TD colspan=3>до 1 000 тенге</TD>" skip
    "<TD colspan=3>от 1 000   до 10 000 тенге</TD>" skip
    "<TD colspan=3>от 10 000  до 50 000 тенге</TD>" skip
    "<TD colspan=3>от 50 000  до 100 000 тенге</TD>" skip
    "<TD colspan=3>от 100 000 до 1 000 000 тенге</TD>" skip
    "<TD colspan=3>свыше 1 000 000 тенге</TD>" skip
    "</TR>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<TD>№</TD>" skip
    "<TD>Наименование</TD>" skip
    "<TD>количество клиентов</TD>" skip
    "<TD>общая сумма доходов</TD>" skip
    "<TD>средний доход</TD>" skip
    "<TD>количество клиентов</TD>" skip
    "<TD>общая сумма доходов</TD>" skip
    "<TD>средний доход</TD>" skip
    "<TD>количество клиентов</TD>" skip
    "<TD>общая сумма доходов</TD>" skip
    "<TD>средний доход</TD>" skip
    "<TD>количество клиентов</TD>" skip
    "<TD>общая сумма доходов</TD>" skip
    "<TD>средний доход</TD>" skip
    "<TD>количество клиентов</TD>" skip
    "<TD>общая сумма доходов</TD>" skip
    "<TD>средний доход</TD>" skip
    "<TD>количество клиентов</TD>" skip
    "<TD>общая сумма доходов</TD>" skip
    "<TD>средний доход</TD>" skip
    "</TR>" skip.

def var i as inte init 0.
for each temptable no-lock break by temptable.filial:
    i = i + 1.
    put stream rep unformatted
    "<TR align=center style='font-size:10pt'>"
    "<TD>" i "</TD>"  skip
    "<TD>" temptable.filial "</TD>"  skip.
    if temptable.i1 <> 0 and temptable.sumamt1 <> 0 then do:
        put stream rep unformatted
            "<TD>" string(temptable.i1)             "</TD>" skip
            "<TD>" replace(string(temptable.sumamt1),".",",") "</TD>" skip
            "<TD>" replace(string(round(temptable.srednee1,2)),".",",") "</TD>" skip.
    end.
    else do:
        put stream rep unformatted
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip.
    end.
    if temptable.i2 <> 0 and temptable.sumamt2 <> 0 then do:
        put stream rep unformatted
            "<TD>" string(temptable.i2)             "</TD>" skip
            "<TD>" replace(string(temptable.sumamt2),".",",")        "</TD>" skip
            "<TD>" replace(string(round(temptable.srednee2,2)),".",",") "</TD>" skip.
    end.
    else do:
        put stream rep unformatted
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip.
    end.
    if temptable.i3 <> 0 and temptable.sumamt3 <> 0 then do:
        put stream rep unformatted
            "<TD>" string(temptable.i3)             "</TD>" skip
            "<TD>" replace(string(temptable.sumamt3),".",",")        "</TD>" skip
            "<TD>" replace(string(round(temptable.srednee3,2)),".",",") "</TD>" skip.
    end.
    else do:
        put stream rep unformatted
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip.
    end.
    if temptable.i4 <> 0 and temptable.sumamt4 <> 0 then do:
        put stream rep unformatted
            "<TD>" string(temptable.i4)             "</TD>" skip
            "<TD>" replace(string(temptable.sumamt4),".",",")        "</TD>" skip
            "<TD>" replace(string(round(temptable.srednee4,2)),".",",") "</TD>" skip.
    end.
    else do:
        put stream rep unformatted
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip.
    end.
    if temptable.i5 <> 0 and temptable.sumamt5 <> 0 then do:
        put stream rep unformatted
            "<TD>" string(temptable.i5)             "</TD>" skip
            "<TD>" replace(string(temptable.sumamt5),".",",")        "</TD>" skip
            "<TD>" replace(string(round(temptable.srednee5,2)),".",",") "</TD>" skip.
    end.
    else do:
        put stream rep unformatted
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip.
    end.
    if temptable.i6 <> 0 and temptable.sumamt6 <> 0 then do:
        put stream rep unformatted
            "<TD>" string(temptable.i6)             "</TD>" skip
            "<TD>" replace(string(temptable.sumamt6),".",",")        "</TD>" skip
            "<TD>" replace(string(round(temptable.srednee6,2)),".",",") "</TD>" skip.
    end.
    else do:
        put stream rep unformatted
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip
        "<TD>" string(0) "</TD>" skip.
    end.
    put stream rep unformatted
    "</TR>" skip.
end.

put stream rep unformatted
    "</TABLE>" skip.

{html-end.i "stream rep"}
output stream rep close.

unix silent cptwin value(repname) excel.

