/* er.i
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Функция расчета эффективной ставки
 * RUN

        Функция вида
                                      Sj                       Pi
        v-d - v-k - v-l + SUM(------------------) - SUM(------------------) = 0
                              (1 + APR)^(Tj/365)        (1 + APR)^(Ti/365)

        где v-d - сумма первого займа
            v-k - единовременные комиссии при выдаче кредита
            v-l - сумма депозита, внесенного на дату получения займа
            Sj  - сумма j-ой выплаты клиенту (очередной займ, вознаграждение по депозиту и тп)
            Tj  - период в днях со дня предоставления первого займа до j-ой выплаты клиенту
            Pi  - сумма i-ого платежа клиента (внесение депозита, доп.взнос по депозиту, вознаграждение по займам и тп)
            Ti  - период в днях со дня предоставления первого займа до i-ого платежа клиента

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
        17/01/2007 madiyar
 * BASES
        -
 * CHANGES
        25/08/2011 madiyar - добавил функцию get_er2, возвращает ставку не округляя и не переводя в проценты
*/

define temp-table b2cl no-undo
  field dt as date
  field days as integer
  field sum as decimal
  index idx is primary dt.

define temp-table cl2b no-undo
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
    for each b2cl no-lock:
      v-f = v-f + b2cl.sum / exp(1 + v-x,b2cl.days / 365).
    end.

    for each cl2b no-lock:
      v-f = v-f - cl2b.sum / exp(1 + v-x,cl2b.days / 365).
    end.

    return v-f.
end.

/* значение производной функции */
function df returns decimal (v-x as decimal).
    def var v-df as decimal no-undo.

    v-df = 0.
    for each b2cl no-lock:
      v-df = v-df - b2cl.days * b2cl.sum / 365 / exp(1 + v-x,b2cl.days / 365 + 1).
    end.

    for each cl2b no-lock:
      v-df = v-df + cl2b.days * cl2b.sum / 365 / exp(1 + v-x,cl2b.days / 365 + 1).
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

    v-coun = 0.
    repeat:
        v-x = v-x0 - f(v-d,v-k,v-l,v-x0) / df(v-x0).
        if abs(v-x - v-x0) < 0.00001 then leave.
        else v-x0 = v-x.
        v-coun = v-coun + 1.
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

    v-coun = 0.
    repeat:
        v-x = v-x0 - f(v-d,v-k,v-l,v-x0) / df(v-x0).
        if abs(v-x - v-x0) < 0.000001 then leave.
        else v-x0 = v-x.
        v-coun = v-coun + 1.
    end.

    return v-x.
end.


