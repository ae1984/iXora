/* cifincome.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Отчет по операционным доходам за период
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.4.1.16.6.3
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        cli-inc - усовершенствованная версия cli-inc.p.
        31.08.2011 damir - добавил счет ГК 460130,461210 заменил на 461211.
        02.09.2011 aigul - добавила 2 столбца Наличие ссудного счета и Категория
        11.10.2012 damir - на основании С.З. от 11.10.2012 г., добавил счета ГК 460112,460715,460828,460829,461500.
        01.04.2013 damir - Исправлена техническая ошибка.
        30.04.2013 damir - Внедрено Т.З. № 1805.
        14.05.2013 damir - Внедрено Т.З. № 1739.
*/
{mainhead.i}

def new shared temp-table tempcif1 no-undo
    field filial as char
    field cifname as char
    field gl1 as deci
    field gl2 as deci
    field gl3 as deci
    field gl4 as deci
    field gl5 as deci
    field gl6 as deci
    field gl7 as deci
    field gl8 as deci
    field itog as deci
    field lon as char
    field categ as char
    field fAccdt as date
    field CrSum as deci
    field bal as deci
    field balCL as deci.

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

def var repname as char init "cifincome.htm".

v-dte = g-today.
v-dtb = g-today.

update
    v-dte   label "        ПЕРИОД ОТЧЕТА С" skip
    v-dtb   label "                     ПО" skip
    with side-label row 5 centered title " Введите период отчета " frame dat.

display "Ждите..." with row 5 frame ww centered .

if connected ("txb") then disconnect "txb".
for each txb where txb.consolid no-lock:
    if connected ("txb") then  disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
    run cifincomedat2(input txb.bank, v-dte, v-dtb).
    disconnect "txb".
end.

{r-brfilial.i &proc = "cifincomedat"}

output stream rep to value(repname).
{html-title.i &stream = "stream rep"}

def var namebank as char.
def buffer b-cmp for cmp.
find first b-cmp no-lock no-error.
if avail b-cmp then namebank = trim(b-cmp.name).

put stream rep unformatted
    "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

put stream rep unformatted
    "<P align=center style='font-size:14pt;font:bold' colspan=10>Клиенты, принесшие доход свыше 100 000 тенге. " namebank "  С " v-dte
    " ПО " v-dtb "</b></font></P>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<TD rowspan=2>Филиал</TD>" skip
    "<TD rowspan=2>Наименование/ ФИО клиента</TD>" skip
    "<TD rowspan=2>Дата открытия первого расчетного счета</TD>" skip
    "<TD rowspan=2>Кредитовые обороты по расчетным счетам (в тенге)</TD>" skip
    "<TD colspan=8>Сумма дохода / Счета ГК по доходам</TD>" skip
    "<TD rowspan=2>Итого</TD>" skip
    "<TD rowspan=2>Наличие ссудного счета (Да/Нет)</TD>" skip
    "<TD rowspan=2>Остаток основного долга</TD>" skip
    "<TD rowspan=2>Категория</TD>" skip
    "</TR>" skip.

put stream rep unformatted
    "<TR align=left style='font-size:10pt;font:bold'>" skip
    "<TD>460111-Комиссионные доходы за услуги по перевод.операциям ЮЛ без НДС, <br> 460122-Комиссион.доходы за услуги по прочим переводным операциям ФЛ, <br> 460130-Комиссионный доход по сервису Cash pooling,<br>460112-Комиссионные доходы за услуги по перевод.операциям ЮЛ c НДС</TD>" skip
    "<TD>461110-Комиссионные доходы за услуги по кассовым операциям ЮЛ, <br> 461120-Комиссионные доходы за услуги по кассовым операциям ФЛ,<br>461500-Комиссионные доходы за услуги по инкассации с НДС</TD>" skip
    "<TD>460410-Комис.доходы за услуги по купле-продаже инвалюты без НДС, <br> 460430-Комис.доходы за отмену заявки по купле-продаже инвалюты с НДС, <br> 460411-Комисс-е доходы за услуги по купле-продаже инвалюты без НДС ФЛ</TD>" skip
    "<TD>453010-Доходы по купле-продаже безналичной  инвалюты без НДС, <br> 453020-Доходы по купле-продаже наличной  инвалюты без НДС, <br> 453080-Доход по курсовой разнице WU</TD>" skip
    "<TD>460610-Комис.доходы ОД за услуги по операциям с гарантиями без НДС" "</TD>" skip
    "<TD>461211-Комиссионные доходы по документарным расчетам с НДС,<br> 461220-Комиссии без учета НДС</TD>" skip
    "<TD>460713-Доходы за открытие счетов ЮЛ,<br> 460721-Доход от прочих услуг по ведению счетов без НДС,<br> 460725-Комиссионный доход за закрытие счета с НДС</TD>" skip
    "<TD>460824-Прочие комиссии с НДС,<br> 492130-Прочий доход от банковской деятельности с НДС,<br> 460819-Прочий комиссионный доход за услуги по выплате пенсий,<br> 492120-Прочий доход от банковской деятельности,<br>460715-Доход за открытие счетов физических лиц,<br>460828-Комис. доход за выпуск Электр.цифр.подписи с НДС,<br>460829-Комис. доход от операций по валютному контролю c НДС</TD>" skip
    "</TR>" skip.

for each tempcif1 no-lock:
    put stream rep unformatted
        "<TR style='font-size:10pt'>" skip
        "<TD>" tempcif1.filial "</TD>" skip
        "<TD>" tempcif1.cifname "</TD>" skip
        "<TD>" string(tempcif1.fAccdt,"99/99/9999") "</TD>" skip
        "<TD>" replace(string(tempcif1.CrSum,"-zzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
        "<TD>" replace(string(tempcif1.gl1),".",",") "</TD>" skip
        "<TD>" replace(string(tempcif1.gl2),".",",") "</TD>" skip
        "<TD>" replace(string(tempcif1.gl3),".",",") "</TD>" skip
        "<TD>" replace(string(tempcif1.gl4),".",",") "</TD>" skip
        "<TD>" replace(string(tempcif1.gl5),".",",") "</TD>" skip
        "<TD>" replace(string(tempcif1.gl6),".",",") "</TD>" skip
        "<TD>" replace(string(tempcif1.gl7),".",",") "</TD>" skip
        "<TD>" replace(string(tempcif1.gl8),".",",") "</TD>" skip
        "<TD>" replace(string(tempcif1.itog),".",",") "</TD>" skip
        "<TD>" tempcif1.lon "</TD>" skip
        "<TD>" replace(string(tempcif1.bal,"-zzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
        "<TD>" tempcif1.categ "</TD>" skip
        "</TR>" skip.
end.

put stream rep unformatted
    "</TABLE>" skip.

{html-end.i "stream rep"}
output stream rep close.

unix silent cptwin value(repname) excel.







