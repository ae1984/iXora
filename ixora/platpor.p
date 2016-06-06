/* platpor.p
 * MODULE
     Коммунальные платежи 
 * DESCRIPTION
     Процедура - Реестр отправленных налоговых п/п за период  
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.10.10.6
 * AUTHOR
        31/12/99 pragma
 * CHANGES
     07.07.03 kanat добавил разбивку по филиалам
     01.10.03 sasco проверка на tax.duid <> ?
*/

{global.i}
{comm-txb.i}

def var seltxb as int.
seltxb = comm-cod().

define variable return_choice as logical.
define variable d_date_begin as date.
define variable d_date_end as date.
define variable d_sum as decimal.


define variable d_whole_sum as decimal.
define variable d_whole_count as integer init 0.


update d_date_begin   label "Введите дату начала периода" with centered side-label.
update d_date_end     label "Введите дату конца периода" with centered side-label.


    MESSAGE "Сформировать отчет за период?" 
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
    TITLE "Отчет по СПФ" UPDATE return_choice.

      if return_choice then do:

output to madina.img.

put fill("-",78) format "x(78)" skip.
put unformatted "Реестр отправленных в НК пачек п.п. за период " skip.
put unformatted "Данные с " d_date_begin " по " d_date_end skip.

for each tax where tax.date >= d_date_begin and tax.date <= d_date_end and tax.duid = ? and
tax.txb = seltxb no-lock break by tax.date by tax.grp.

if first-of (tax.date) then do:
put fill("-",78) format "x(78)" skip.
put unformatted "               Данные за " tax.date skip. 
put fill("-",78) format "x(78)" skip.
put unformatted "Пачка    " 
                "Дата     "  
                "RMZ...                  "  
                "Сумма           " skip.
put fill("-",78) format "x(78)" skip.
end.


accumulate tax.sum (sub-total by tax.grp by tax.date).


find first remtrz where remtrz.remtrz = tax.senddoc no-lock no-error.


if avail remtrz then do:
if last-of (tax.grp) then do:
put unformatted tax.grp format ">>>>>>9" " " 
                tax.date " " 
                remtrz.remtrz format "x(10)" " " 
                (accum sub-total by tax.grp tax.sum) format ">>,>>>,>>>,>>>,>>9.99" skip.
d_sum = d_sum + (accum sub-total by tax.grp tax.sum).

d_whole_count = d_whole_count + 1.
d_whole_sum = d_whole_sum + (accum sub-total by tax.grp tax.sum).

end.
end.


if last-of (tax.date) then do:
put fill("-",78) format "x(78)" skip.
put unformatted "ИТОГО за " tax.date " - " d_sum format ">>,>>>,>>>,>>>,>>9.99" skip.
d_sum = 0.
end.

end.


put unformatted "Итого за период с " d_date_begin " по " d_date_end " было отправлено " d_whole_count " пачек на сумму : " d_whole_sum format ">>,>>>,>>>,>>>,>>9.99" skip.


output close.
run menu-prt ("madina.img").

        end.


