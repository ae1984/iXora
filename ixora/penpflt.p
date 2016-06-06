/* penpflt.p
 * MODULE
        Социальные платежи
 * DESCRIPTION
        Реестр социальных отчислений 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        16/03/2005 kanat
 * CHANGES
*/

{global.i}
{comm-txb.i}

def var v-seltxb as integer.
def var v-date-begin as date.
def var v-date-fin as date.
def var v-whole as decimal.
def var v-count as integer.

v-seltxb = comm-cod().
v-date-begin = g-today.
v-date-fin = g-today.

update v-date-begin label "Укажите период с " v-date-fin label " по " with centered side-label frame fdat.
hide frame fdat.

output to report.txt.
put unformatted "Реестр (тенге) пенсионных платежей с номерами телефонов плательщиков" skip.

if v-date-begin = v-date-fin then 
put unformatted " за " v-date-begin skip(1).

if v-date-begin > v-date-fin then do:
message "Неверно задан период обработки для отчета!" view-as alert-box title "Внимание".
return.
end.

if v-date-begin < v-date-fin then 
put unformatted " с " v-date-begin " по " v-date-fin skip(1).

put unformatted fill("=",90) skip.
put unformatted "Дата            "
                "Номер квитанции "
                "Сумма           "
                "Номер телефона  "
                "РНН             "
                "ФИО кассира                   " skip.
put unformatted fill("=",90) skip.
for each p_f_payment where p_f_payment.txb = v-seltxb and p_f_payment.date >= v-date-begin and p_f_payment.date <= v-date-fin and 
                           p_f_payment.cod <> 400 and p_f_payment.deluid = ? no-lock.
find first ofc where ofc.ofc = p_f_payment.uid no-lock no-error.
if avail ofc then do:
put unformatted string(p_f_payment.date) format "x(15)" " " string(p_f_payment.dnum) format "x(15)" " " 
                string(p_f_payment.amt) format "x(15)" " " 
                p_f_payment.chval[2] format "x(15)" " " p_f_payment.rnn format "x(15)" " " 
                ofc.name format "x(30)" skip.
v-whole = v-whole + p_f_payment.amt.
v-count = v-count + 1.
end.
end.
put unformatted fill("=",90) skip.
put unformatted "Итого квитанций " string(v-count) " на сумму: " string(v-whole) skip.
output close.

run menu-prt ("report.txt").
