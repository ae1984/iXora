/* erl_bdf.p
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Расчет эффективных ставок по кредитам БД
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
        17/01/2007 madiyar
 * BASES
        bank, comm
 * CHANGES
        19/06/2008 madiyar - mainhead.i -> global.i
        15/02/2011 madiyar - подправил формирование графика
*/

{global.i}

/*
def stream rep.
output stream rep to rep.csv.
put stream rep unformatted "Дата;Дней;Сумма;ОД;Проценты;Комиссия" skip.
*/

def input parameter v-sum as deci no-undo.
def input parameter v-srok as integer no-undo.
def input parameter v-rate as deci no-undo.
def input parameter v-rdt as date no-undo.
def input parameter v-pdt as date no-undo.
def input parameter v-komf as deci no-undo. /* комиссия в фонд покрытия кредитных рисков */
def input parameter v-komv as deci no-undo. /* комиссия за ведение счета */
def input parameter v-komr as deci no-undo. /* комиссия за рассмотрение заявки */

def output parameter v-er as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def var v-dt as date no-undo.
def var v-dt0 as date no-undo.
def var v-od as deci no-undo.
def var v-prc as deci no-undo.
def var i as integer no-undo.
def var v-ok as logical no-undo.
def var v-sum0 as deci no-undo.

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


for each b2cl: delete b2cl. end.
for each cl2b: delete cl2b. end.

/* расчет */

v-dt0 = v-rdt.
v-sum0 = v-sum.

do i = 1 to v-srok:
    
    if i = 1 then v-dt = v-pdt.
    else
    if i = v-srok then v-dt = get-date(v-rdt,v-srok).
    else
    v-dt = get-date(v-dt0,1).
    
    run day-360(v-dt0,v-dt - 1,360,output dn1,output dn2).
    v-prc = round(dn1 * v-sum * v-rate / 100 / 360,2).
    if i = v-srok then v-od = v-sum0.
    else v-od = round(v-sum / v-srok,0).
    v-sum0 = v-sum0 - v-od.
    
    create cl2b.
    cl2b.dt = v-dt.
    cl2b.days = v-dt - v-rdt.
    cl2b.sum = v-od + v-prc + v-komv.
    
    /*
    put stream rep unformatted
            cl2b.dt format "99/99/9999" ";"
            cl2b.days format ">>>>>9" ";"
            replace(trim(string(cl2b.sum,">>>>>>>>9.99")),'.',',') ";"
            replace(trim(string(v-od,">>>>>>>>9.99")),'.',',') ";"
            replace(trim(string(v-prc,">>>>>>>>9.99")),'.',',') ";"
            replace(trim(string(v-komv,">>>>>>>>9.99")),'.',',') ";" skip.
    */

    if i = v-srok then leave.
    else v-dt0 = v-dt.
    
end.

v-er = get_er(v-sum,v-komf + v-komr,0.0,0.0).

/*
output stream rep close.
unix silent cptwin rep.csv excel.
*/

