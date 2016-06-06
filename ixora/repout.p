/* repout.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Отчет по исходящим платежам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 1.4.1.16.6.8
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        11.11.2011 damir - небольшие корректировки.
        03.07.2012 Lyubov - добавила валюту ZAR
        10.08.2012 Lyubov - добавила валюту CAD
*/

{mainhead.i}

def var v-dtb   as date init ?.
def var v-dte   as date init ?.
def var v-file  as char init "clientplat.html".
def var IntType as int init 1.
def var v-case  as char view-as combo-box list-items "Интернет платежи", "Обычные платежи".
def new shared var v-nametitle as char.

def new shared var v-type as char.

def new shared temp-table t-platcif
    field bank    as char
    field cifname as char
    field sumkzt  as deci
    field kolkzt  as inte
    field sumusd  as deci
    field kolusd  as inte
    field sumeur  as deci
    field koleur  as inte
    field sumrub  as deci
    field kolrub  as inte
    field sumgbp  as deci
    field kolgbp  as inte
    field sumchf  as deci
    field kolchf  as inte
    field sumaud  as deci
    field kolaud  as inte
    field sumsek  as deci
    field kolsek  as inte
    field sumzar  as deci
    field kolzar  as inte
    field sumcad  as deci
    field kolcad  as inte.

def buffer b-t-platcif for t-platcif.

def stream rep.
output stream rep to value(v-file).

form
    v-dtb  label "С" format "99/99/9999" validate(v-dtb <= g-today, "Дата должна быть не больше текущей !!!") skip
    v-dte  label "ПО" format "99/99/9999" validate(v-dte <= g-today, "Дата должна быть не больше текущей !!!") skip
    v-case label "Выберите тип платежа" skip
with side-labels row 15 width 50 centered title "Укажите период отчета" frame cifplat.

on return,value-changed of v-case do:
    v-case = "".
    IntType = self:lookup(self:screen-value).
    if IntType = 1 then v-type = "IBH".
    else v-type = "EXCEPTIBH".
    apply "go" to frame cifplat.
end.

update v-dtb  with frame cifplat.
update v-dte  with frame cifplat.
update v-case with frame cifplat.

enable all with frame cifplat.

{r-brfilial.i  &proc = "repoutdat(input txb.info, v-dtb, v-dte)" }

if v-type = "IBH"       then v-nametitle = "Интернет платежи".
if v-type = "EXCEPTIBH" then v-nametitle = "Обычные платежи".

{html-title.i
 &stream = " stream rep "
 &title = " "
 &size-add = " xx- "
}

put stream rep unformatted
    "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
    "<B>Отчет по клиентским платежам<BR>за период с " + string(v-dtb, "99/99/9999") +
    " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream rep unformatted
    "<TR align=""center"">" skip
    "<TD rowspan=""3"">Наименование <br> организации <br> / ФИО клиента</TD>" skip
    "<TD colspan=""20"">" v-nametitle "</TD>" skip
    "</TR>" skip
    "<TR align=""center"">" skip
    "<TD colspan=""2"">KZT</TD>" skip
    "<TD colspan=""2"">USD</TD>" skip
    "<TD colspan=""2"">EUR</TD>" skip
    "<TD colspan=""2"">RUB</TD>" skip
    "<TD colspan=""2"">GBP</TD>" skip
    "<TD colspan=""2"">CHF</TD>" skip
    "<TD colspan=""2"">AUD</TD>" skip
    "<TD colspan=""2"">SEK</TD>" skip
    "<TD colspan=""2"">ZAR</TD>" skip
    "<TD colspan=""2"">CAD</TD>" skip
    "</TR>" skip
    "<TR align=""center"">" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>количество</TD>" skip
    "</TR>" skip.

for each t-platcif break by t-platcif.bank:
    if first-of(t-platcif.bank) then do:
        put stream rep unformatted
        "<TR align=""center"">"
        "<TD colspan=21 bgcolor='#9BCDFF'><FONT size=""6"">" t-platcif.bank "</FONT></TD>" skip
        "</TR>" skip.
        for each b-t-platcif where b-t-platcif.bank = t-platcif.bank no-lock:
            put stream rep unformatted
                "<TR>" skip
                "<TD>" b-t-platcif.cifname "</TD>" skip
                "<TD>" string(b-t-platcif.sumkzt, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.kolkzt "</TD>" skip
                "<TD>" string(b-t-platcif.sumusd, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.kolusd "</TD>" skip
                "<TD>" string(b-t-platcif.sumeur, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.koleur "</TD>" skip
                "<TD>" string(b-t-platcif.sumrub, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.kolrub "</TD>" skip
                "<TD>" string(b-t-platcif.sumgbp, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.kolgbp "</TD>" skip
                "<TD>" string(b-t-platcif.sumchf, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.kolchf "</TD>" skip
                "<TD>" string(b-t-platcif.sumaud, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.kolaud "</TD>" skip
                "<TD>" string(b-t-platcif.sumsek, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.kolsek "</TD>" skip
                "<TD>" string(b-t-platcif.sumzar, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.kolzar "</TD>" skip
                "<TD>" string(b-t-platcif.sumcad, ">>>>>>>>>>>>>>>>>>>>>>>9.99") "</TD>" skip
                "<TD>" b-t-platcif.kolcad "</TD>" skip
                "</TR>" skip.
        end.
    end.
end.

{html-end.i " stream rep " }

put stream rep unformatted
    "<TABLE>" skip.

output stream rep close.

unix silent cptwin value(v-file) excel.