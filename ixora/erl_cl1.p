/* erl_cl.p
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Расчет эффективных ставок по розничным кредитам
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
        31.03.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/


{global.i}


def stream rep.
output stream rep to rep.csv.
put stream rep unformatted "Дата;Дней;Сумма;ОД;Проценты" skip.


def input parameter v-sum as deci no-undo.
def input parameter v-srok as integer no-undo.
def input parameter v-rate as deci no-undo.
def input parameter v-odpr as deci no-undo.

def input parameter v-rdt as date no-undo.
def input parameter v-pdt as date no-undo.
def input parameter v-pdtprc as date no-undo.
def input parameter v-pdtod as date no-undo.
def input parameter v-kom1 as deci no-undo.

def output parameter v-er as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def var v-dt as date no-undo.
def var v-dt0 as date no-undo.
def var v-dt0_prc as date no-undo.
def var v-prc as deci no-undo.
def var i as integer no-undo.
def var coun as integer no-undo.
def var v-ok as logical no-undo.

def var v-mpayment_od as deci no-undo.
def var v-cpayment_od as deci no-undo.
def var v-sum0 as deci no-undo.
def var v-sum1 as deci no-undo.

{er.i}

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
    else
    if v-num = 0 then v-datres = v-date.
    else do:
      mm = (month(v-date) + v-num) mod 12.
      if mm = 0 then mm = 12.
      yy = year(v-date) + integer(((month(v-date) + v-num) - mm) / 12).
      run mondays(mm,yy,output dd).
      if day(v-date) < dd then dd = day(v-date).
      v-datres = date(mm,dd,yy).
    end.
    return (v-datres).
end function.


empty temp-table b2cl.
empty temp-table cl2b.

/* расчет */

v-dt0 = v-rdt.
coun = 0.

do i = 1 to v-srok:

    if i = 1 then v-dt = v-pdt.
    else
    if i = v-srok then v-dt = get-date(v-rdt,v-srok).
    else
    v-dt = get-date(v-dt0,1).

    if v-dt >= v-pdtod then coun = coun + 1.

    v-dt0 = v-dt.

end.

v-dt0 = v-rdt.
v-sum1 = v-sum.
v-cpayment_od = 0.

v-dt0_prc = v-rdt.

do i = 1 to v-srok:

v-mpayment_od = round(v-sum1 * v-odpr / 100, 2).
v-sum0 = v-sum1.
v-sum1 = v-sum1 - v-mpayment_od.

    if i = 1 then v-dt = v-pdt.
    else
    if i = v-srok then v-dt = get-date(v-rdt,v-srok).
    else
    v-dt = get-date(v-dt0,1).

    v-prc = 0.
    if v-dt >= v-pdtprc then do:
        run day-360(v-dt0_prc,v-dt - 1,360,output dn1,output dn2). /*определяет кол-во дней между погашениями*/
        v-prc = round(dn1 * v-sum0 * v-rate / 100 / 360,2). /*вознаграждение %*/
        v-dt0_prc = v-dt.
    end.

    v-cpayment_od = 0.
    if v-dt >= v-pdtod then do:
        if i = v-srok then v-cpayment_od = v-sum0. /*последний платеж*/
        else v-cpayment_od = v-mpayment_od. /*ежемесячный платеж*/
        v-sum0 = v-sum0 - v-cpayment_od. /*остаток ОД*/
    end.

    create cl2b.
    cl2b.dt = v-dt. /*дата погашения*/
    cl2b.days = v-dt - v-rdt. /*кол-во дней*/
    cl2b.sum = v-cpayment_od + v-prc. /*сумма погашения + % + комиссия*/

    put stream rep unformatted
        cl2b.dt format "99/99/9999" ";"
        cl2b.days format ">>>>>9" ";"
        replace(trim(string(cl2b.sum,">>>>>>>>>>>9.99")),'.',',') ";"
        replace(trim(string(v-cpayment_od,">>>>>>>>>>>9.99")),'.',',') ";"
        replace(trim(string(v-prc,">>>>>>>>>>>9.99")),'.',',') ";" skip.

    v-dt0 = v-dt.

end.

v-er = get_er2(v-sum,v-kom1,0.0,0.0).
output stream rep close.
unix silent cptwin rep.csv excel.