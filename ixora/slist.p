/* slist.p
 * MODULE
        Клиентские операции
 * DESCRIPTION
        Реестр проведенных з/п платежей Salary
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        15.1.4.1.3
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        19.07.2013 damir - Внедрено Т.З. № 1931.
*/
{mainhead.i}

def new shared var v-dtb as date.
def new shared var v-dte as date.

def var v-file as char init "slist.htm".

def new shared temp-table t-wrk no-undo
    field cif as char
    field name as char
    field iik as char
    field sum as deci
    field sumcom as deci
    field sts as char
    field dt as date
    field jou as char
    field paynum as char.

form
    v-dtb format "99/99/9999" label "С"
    v-dte format "99/99/9999" label "ПО"
with centered side-labels title "ПЕРИОД" frame slis.

set v-dtb with frame slis.
set v-dte with frame slis.

empty temp-table t-wrk.
{r-brfilial.i &proc = "slist_txb"}

output to value(v-file).
{html-title.i}

put unformatted
    "<P align=center style='font:bold;font-size:14pt'>Реестр проведенных з/п платежей Salary</P>" skip.
put unformatted
    "<TABLE width=100% border=1 cellpadding=0 cellspacing=0>" skip.

put unformatted
    "<TR align=center style='font:bold;font-size:10pt'>"
    "<TD>Дата</TD>" skip
    "<TD>Отправитель - CIF код</TD>" skip
    "<TD>Наименование отправителя</TD>" skip
    "<TD>ИИК отправителя</TD>" skip
    "<TD>Номер платежного<br>поручения</TD>" skip
    "<TD>JOU-документ</TD>" skip
    "<TD>Общая сумма к зачислению</TD>" skip
    "<TD>Сумма комиссии</TD>" skip
    "<TD>Отметка о контроле</TD>" skip
    "</TR>" skip.

for each t-wrk no-lock:
    put unformatted
        "<TR align=center style='font-size:10pt'>"
        "<TD>" string(t-wrk.dt,"99/99/9999") "</TD>" skip
        "<TD>" t-wrk.cif "</TD>" skip
        "<TD>" t-wrk.name "</TD>" skip
        "<TD>" t-wrk.iik "</TD>" skip
        "<TD>" t-wrk.paynum "</TD>" skip
        "<TD>" t-wrk.jou "</TD>" skip
        "<TD>" replace(string(t-wrk.sum,"->>>>>>>>>>>>>>>>>>>>>9.99"),".",",") "</TD>" skip
        "<TD>" replace(string(t-wrk.sumcom,"->>>>>>>>>>>>>>>>>>>>>9.99"),".",",") "</TD>" skip
        "<TD>" t-wrk.sts "</TD>" skip
        "</TR>" skip.
end.

put unformatted
    "</TABLE>" skip.

{html-end.i}
output close.

unix silent cptwin value(v-file) excel.
