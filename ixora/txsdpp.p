/* txsdpp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Информация по налоговым платежам для НК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
	Список процедур, вызывающих эту процедуру
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        rkoall.p
 * MENU
        Филиал г. Алматы - 3.2.10.10.13
 * AUTHOR
        19/12/03 kanat
 * CHANGES
*/

{get-dep.i}
{gl-utils.i}

def var v-dep as integer.
def var v-arp as char.
def var v-sum as decimal init 0.
def var v-comsum as decimal init 0.
def var v-sqn as char.
def var v-date_begin as date init ?.
def var v-date_end as date init ?.
def var v-kbk as integer format "999999" init 0.
def var v-choice as log.
def var v-depart as char.
def var v-tax-depart as integer.

if not connected ("comm") then run comm-con. /*:))*/

update v-date_begin   label "Введите дату начала периода" with side-label.
update v-date_end     label "Введите дату конца периода" with side-label.
update v-kbk          label "Код бюдж. классификации: " with side-label.

if v-date_begin = ? then do:
message "Не введена дата начала периода" view-as alert-box title "".
return.
end.

if v-date_end = ? then do:
message "Не введена дата конца периода" view-as alert-box title "".
return.
end.

if v-kbk = 0 then do:
message "Не введен код бюджетной классификации" view-as alert-box title "".
return.
end.
else do:
find first budcodes where budcodes.code = v-kbk no-lock no-error.
if not avail budcodes then do:
message "Данный КБК отсутствует в справочнике банка" view-as alert-box title "".
return.
end.
end.

run rkoall.
v-depart = string(return-value).


if v-depart = "" then do:
message "Не выбрано структурное подразделение" view-as alert-box title "".
return.
end.


output to report.csv.

for each tax where tax.txb = 0 and tax.date >= v-date_begin and
                   tax.date <= v-date_end and 
                   tax.kb = v-kbk and 
                   tax.senddoc <> ? and 
                   tax.duid = ? no-lock break by date by senddoc.

v-tax-depart = get-dep(tax.uid, tax.date).

if v-tax-depart = integer(v-depart) then do:

if first-of(tax.senddoc) then do:
put unformatted "Номер квитанции;Референс;Дата;РНН плательщика;Сумма;Номер пачки;КБК;РНН налогового комитета;" skip.
find first remtrz where remtrz.remtrz = tax.senddoc no-lock no-error.
if avail remtrz then
v-sqn = trim(substring(remtrz.sqn,19,8)).
v-sum = 0.
end.

v-sum = v-sum + tax.sum.

put unformatted tax.dnum format ">>>>>9" ";" 
                tax.senddoc format "x(10)" ";"  
                string(tax.date) ";" 
                "`"tax.rnn ";" 
                XLS-NUMBER (tax.sum) ";" 
                v-sqn format "x(7)" ";" 
                tax.kb ";" 
                "`"tax.rnn_nk ";" skip.

if last-of(tax.senddoc) then do:
put unformatted "Итого по пачке N " v-sqn format "x(7)" ": " XLS-NUMBER (v-sum) skip(2).
end.
end.
end.

output close.
unix silent cptwin report.csv excel.
