/* r-riskline.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Расчет операционного риска по направлениям деятельности
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
        02.04.2013 dmitriy. ТЗ 1690
 * BASES
        BANK COMM
 * CHANGES
*/

def var sum1 as deci.
def var sum2 as deci.
def var sum3 as deci.
def var sum4 as deci.

def buffer b-wrk2 for wrk2.



message "Обработка данных...".
for each wrk1 where wrk1.nom <> 2 no-lock:
    for each wrk2 where wrk2.nom = wrk1.nom no-lock:
        run CalcSum.
    end.
end.

for each wrk2 where wrk2.nom = 1 no-lock:
    case wrk2.id:
        when 1 then do:
            find first b-wrk2 where b-wrk2.id = 10 no-lock no-error.
            if avail b-wrk2 then do:
                do transaction:
                    wrk2.income = wrk2.income - b-wrk2.income.
                    wrk2.expense = wrk2.expense - b-wrk2.expense.
                    wrk2.bal = wrk2.bal - b-wrk2.bal.
                    wrk2.risksum = wrk2.bal * 0.18 .
                end.
            end.
        end.
        when 2 then do:
            find first b-wrk2 where b-wrk2.id = 11 no-lock no-error.
            if avail b-wrk2 then do:
                do transaction:
                    wrk2.income = wrk2.income - b-wrk2.income.
                    wrk2.expense = wrk2.expense - b-wrk2.expense.
                    wrk2.bal = wrk2.bal - b-wrk2.bal.
                    wrk2.risksum = wrk2.bal * 0.18 .
                end.
            end.
        end.
        when 7 then do:
            find first b-wrk2 where b-wrk2.id = 14 no-lock no-error.
            if avail b-wrk2 then do:
                do transaction:
                    wrk2.income = wrk2.income - b-wrk2.income.
                    wrk2.expense = wrk2.expense - b-wrk2.expense.
                    wrk2.bal = wrk2.bal - b-wrk2.bal.
                    wrk2.risksum = wrk2.bal * 0.18 .
                end.
            end.
        end.
        when 8 then do:
            find first b-wrk2 where b-wrk2.id = 13 no-lock no-error.
            if avail b-wrk2 then do:
                do transaction:
                    wrk2.income = wrk2.income - b-wrk2.income.
                    wrk2.expense = wrk2.expense - b-wrk2.expense.
                    wrk2.bal = wrk2.bal - b-wrk2.bal.
                    wrk2.risksum = wrk2.bal * 0.18 .
                end.
            end.
        end.
        when 9 then do:
            find first b-wrk2 where b-wrk2.id = 15 no-lock no-error.
            if avail b-wrk2 then do:
                do transaction:
                    wrk2.income = wrk2.income - b-wrk2.income.
                    wrk2.expense = wrk2.expense - b-wrk2.expense.
                    wrk2.bal = wrk2.bal - b-wrk2.bal.
                    wrk2.risksum = wrk2.bal * 0.18 .
                end.
            end.
        end.

        otherwise next.
    end case.
end.


sum1 = 0. sum2 = 0. sum3 = 0. sum4 = 0.
for each wrk-gl where wrk-gl.include = no no-lock:
    if substr(wrk-gl.gl4, 1, 1) = "4" then  sum1 = sum1 + wrk-gl.bal.
    if substr(wrk-gl.gl4, 1, 1) = "5" then  sum2 = sum2 + wrk-gl.bal.
end.

sum3 = sum1 - sum2.
sum4 = sum3 * 0.12.

find first wrk2 where wrk2.id = 34 exclusive-lock no-error.
if avail wrk2 then
do transaction:
    wrk2.income = sum1.
    wrk2.expense = sum2.
    wrk2.bal = sum3.
    wrk2.risksum = sum4.
end.




procedure CalcSum:
    sum1 = 0. sum2 = 0. sum3 = 0. sum4 = 0.

    for each wrk-gl where lookup(wrk-gl.gl4, wrk2.inc-gl) > 0 no-lock:
        wrk-gl.include = yes.
        sum1 = sum1 + wrk-gl.bal.
    end.

    for each wrk-gl where lookup(wrk-gl.gl4, wrk2.exp-gl) > 0 no-lock:
        wrk-gl.include = yes.
        sum2 = sum2 + wrk-gl.bal.
    end.

    sum3 = sum1 - sum2.
    sum4 = sum3 * wrk1.beta.

    do transaction:
        wrk2.income = sum1.
        wrk2.expense = sum2.
        wrk2.bal = sum3.
        wrk2.risksum = sum4 / 100.
    end.

end procedure.

message "". pause 0.


