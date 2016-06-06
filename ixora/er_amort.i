/* er_amort.i
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Функция расчета эффективной ставки для амортизации комиссий
 * RUN

        Функция вида
                                      Sj                       Pi
        v-d - v-k - v-l + SUM(------------------) - SUM(------------------) = 0
                              (1 + APR)^(Tj/12)        (1 + APR)^(Ti/12)

        где v-d - сумма первого займа
            v-k - единовременные комиссии при выдаче кредита
            v-l - сумма депозита, внесенного на дату получения займа
            Sj  - сумма j-ой выплаты клиенту (очередной займ, вознаграждение по депозиту и тп)
            Tj  - период в месяцах со дня предоставления первого займа до j-ой выплаты клиенту
            Pi  - сумма i-ого платежа клиента (внесение депозита, доп.взнос по депозиту, вознаграждение по займам и тп)
            Ti  - период в месяцах со дня предоставления первого займа до i-ого платежа клиента

        Пары значений Sj,Tj и Pi,Ti передаются во временные таблицы b2cl и cl2b соответственно

        v-x0 - первое приближение

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        29/09/2011 madiyar - скопировал из er.i с изменениями
 * BASES
        -
 * CHANGES
        22/12/2011 madiyar - графики для займов исходя из дат, не периодов
        26/12/2011 madiyar - корректировка периодов
        26/07/2013 Sayat(id01143) - ТЗ 1982 от 26/07/2013 "Доработка рассчета эффективной ставки" добавлено ограничение количества итераций
*/

define temp-table b2cl no-undo
  field nn as deci
  field dt as date
  field days as integer
  field sum as decimal
  index idx is primary dt.

define temp-table cl2b no-undo
  field nn as deci
  field dt as date
  field days as integer
  field sum as decimal
  index idx is primary dt.

/* значение функции */
function f returns decimal (
                           v-d as decimal,
                           v-k as decimal,
                           v-l as decimal,
                           v-x as decimal
                           ).
    def var v-f as decimal no-undo.
    def var i as integer no-undo.

    v-f = v-d - v-k - v-l.

    /*
    message "v-d - v-k = " v-f view-as alert-box.
    */

    for each b2cl no-lock:
      v-f = v-f + b2cl.sum / exp(1 + v-x,b2cl.nn / 12).
      /*
      message "b2cl(" b2cl.nn "); b2cl.sum=" b2cl.sum " f=" b2cl.sum / exp(1 + v-x,b2cl.nn / 12) view-as alert-box.
      message "b2cl(" b2cl.nn ") = " b2cl.sum / exp(1 + v-x,b2cl.nn / 12) view-as alert-box.
      */
    end.

    for each cl2b no-lock:
      v-f = v-f - cl2b.sum / exp(1 + v-x,cl2b.nn / 12).
      /*
      message "cl2b(" cl2b.nn "); cl2b.sum=" cl2b.sum " f=" cl2b.sum / exp(1 + v-x,cl2b.nn / 12) view-as alert-box.
      */
    end.

    return v-f.
end.

/* значение производной функции */
function df returns decimal (v-x as decimal).
    def var v-df as decimal no-undo.

    v-df = 0.
    for each b2cl no-lock:
      v-df = v-df - b2cl.nn * b2cl.sum / 12 / exp(1 + v-x,b2cl.nn / 12 + 1).
    end.

    for each cl2b no-lock:
      v-df = v-df + cl2b.nn * cl2b.sum / 12 / exp(1 + v-x,cl2b.nn / 12 + 1).
    end.

    return v-df.
end.

function get_er returns decimal (
                                v-d as decimal,
                                v-k as decimal,
                                v-l as decimal,
                                v-x0 as decimal
                                ).
    def var v-x as decimal no-undo.
    def var v-coun as integer no-undo.
    def var v-toch as decimal no-undo.

    v-coun = 0.
    v-toch = 0.000001.
    repeat:
        v-x = v-x0 - f(v-d,v-k,v-l,v-x0) / df(v-x0).
        if abs(v-x - v-x0) < v-toch then leave.
        else v-x0 = v-x.
        v-coun = v-coun + 1.
        /*Sayat*/
        if v-coun > 10000 then do:
            v-coun = 0.
            v-toch = v-toch * 10.
            if v-toch >= 0.01 then leave.
        end.
        /*******/
    end.

    v-x = round(v-x * 100,2).
    return v-x.
end.

function get_er2 returns decimal (
                                 v-d as decimal,
                                 v-k as decimal,
                                 v-l as decimal,
                                 v-x0 as decimal
                                 ).
    def var v-x as decimal no-undo.
    def var v-coun as integer no-undo.
    def var v-toch as decimal no-undo.

    v-coun = 0.
    v-toch = 0.000001.
    repeat:
        v-x = v-x0 - f(v-d,v-k,v-l,v-x0) / df(v-x0).
        if abs(v-x - v-x0) < v-toch then leave.
        else v-x0 = v-x.
        v-coun = v-coun + 1.
        /*Sayat*/
        if v-coun > 10000 then do:
            v-coun = 0.
            v-toch = v-toch * 10.
            if v-toch >= 0.01 then leave.
        end.
        /*******/
    end.

    return v-x.
end.


