/* opincome.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Операционный доход
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.4.1.16.6.1
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        30.04.2013 damir - Внедрено Т.З. № 1805.
*/
{mainhead.i}

def new shared temp-table tempod no-undo
    field filial as char
    field months as char
    field ciftype1 like cif.type
    field perev-oper1 as deci decimals 2
    field kass-oper1 as deci decimals 2
    field konvert-oper1 as deci decimals 2
    field cursdoh1 as deci decimals 2
    field garants1 as deci decimals 2
    field docum-oper1 as deci decimals 2
    field other-oper1 as deci decimals 2
    field itogtype1 as deci decimals 2
    field ciftype2 like cif.type
    field perev-quick2 as deci decimals 2
    field perev-bank2 as deci decimals 2
    field kass-oper2 as deci decimals 2
    field curs-convert2 as deci decimals 2
    field other-oper2 as deci decimals 2
    field itogtype2 as deci decimals 2
    field allsumm as deci decimals 2
    index main is primary ciftype1 ciftype2 months.

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

def var repname as char init "opincome.htm".
def var namebank as char.

def stream rep.

v-dte = g-today.
v-dtb = g-today.

form
    v-dte label "С " skip
    v-dtb label "ПО " skip
with centered side-label title "Введите период отчета(помесячно)" frame aaa.

update v-dte v-dtb with frame aaa.
displ  v-dte v-dtb with frame aaa.

if connected ("txb") then disconnect "txb".
for each txb where txb.consolid no-lock:
    if connected ("txb") then  disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
    run opincomedat2(input txb.bank, v-dte, v-dtb).
    disconnect "txb".
end.

{r-brfilial.i &proc = "opincomedat"}

output stream rep to value(repname).
{html-title.i &stream = "stream rep"}

find first cmp no-lock no-error.
if avail cmp then namebank = trim(cmp.name).

put stream rep unformatted
    "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

put stream rep unformatted
    "<P align=center style='font-size:14pt;font:bold' colspan=10>Операционный доход. " namebank "  С " v-dte " ПО " v-dtb "</P>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<TD rowspan=2>Период, Филиал</TD>" skip
    "<TD colspan=7>Юридические лица</TD>" skip
    "<TD rowspan=2>Итого ЮЛ</TD>" skip
    "<TD colspan=5>Физические лица</TD>" skip
    "<TD rowspan=2>Итого ФЛ</TD>" skip
    "<TD rowspan=2>Итого</TD>" skip
    "</TR>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<TD>Переводные операции</TD>" skip
    "<TD>Кассовые операции</TD>" skip
    "<TD>Конвертация</TD>" skip
    "<TD>Курсовой доход</TD>" skip
    "<TD>Гарантии</TD>" skip
    "<TD>Документарные операции</TD>" skip
    "<TD>Прочие</TD>" skip
    "<TD>Переводные(Быстрые)</TD>" skip
    "<TD>Переводные(Банковские)</TD>" skip
    "<TD>Кассовые операции</TD>" skip
    "<TD>Курсовой доход, <br> конвертация</TD>" skip
    "<TD>Прочие</TD>" skip
    "</TR>" skip.

for each tempod no-lock:
    put stream rep unformatted
        "<TR align=center style='font-size:10pt'>" skip
        "<TD>" tempod.filial "</TD>" skip
        "<TD>" replace(string(tempod.perev-oper1),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.kass-oper1),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.konvert-oper1),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.cursdoh1),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.garants1),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.docum-oper1),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.other-oper1),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.itogtype1),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.perev-quick2),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.perev-bank2),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.kass-oper2),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.curs-convert2),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.other-oper2),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.itogtype2),".",".") "</TD>" skip
        "<TD>" replace(string(tempod.allsumm),".",".") "</TD>" skip
        "</TR>" skip.
end.
put stream rep unformatted
    "</TABLE>" skip.

{html-end.i "stream rep"}
output stream rep close.

unix silent cptwin value(repname) excel.

