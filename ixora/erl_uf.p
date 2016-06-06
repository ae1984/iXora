/* erl_uf.p
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Расчет эффективных ставок по кредитам ЮЛ
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
        12/02/2007 madiyar
 * BASES
        BANK COMM
 * CHANGES
        03.04.07 Saltanat - Внесла изменения в расчет
        19/06/2008 madiyar - mainhead.i -> global.i
        20/09/2010 madiyar - ежемесячная комиссия
        03/02/2011 madiyar - проценты, как и по ФЛ, могут быть начиная с определенной даты
        14/02/2011 madiyar - исправления в аннуитете
*/

{global.i}

def stream rep.
output stream rep to rep.csv.
put stream rep unformatted "Дата;Дней;Сумма;ОД;Проценты;Комиссия" skip.

def input parameter v-sum as deci no-undo.
def input parameter v-srok as integer no-undo.
def input parameter v-rate as deci no-undo.
def input parameter v-gr as integer no-undo.
def input parameter v-rdt as date no-undo.
def input parameter v-pdt as date no-undo.
def input parameter v-pdtprc as date no-undo.
def input parameter v-pdtod as date no-undo.
def input parameter v-kom1 as deci no-undo.
def input parameter v-komy as deci no-undo.
def input parameter v-komy_min as deci no-undo.
def input parameter v-komo as deci no-undo.
def input parameter v-komovyp as deci no-undo.
def input parameter v-sumd as deci no-undo.
def input parameter v-rated as deci no-undo.

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

def var v-mpayment as deci no-undo.
def var v-mpayment_od as deci no-undo.
def var v-cpayment_od as deci no-undo.
def var v-sum0 as deci no-undo.
def var v-komypay as deci no-undo.
def var v-komomonth as integer no-undo init 99999999.

if v-komovyp = 1 then v-komomonth = 12.
else if v-komovyp = 2 then v-komomonth = 6.
else if v-komovyp = 3 then v-komomonth = 3.
else if v-komovyp = 4 then v-komomonth = 1.

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
v-sum0 = v-sum.
v-cpayment_od = 0.

v-dt0_prc = v-rdt.

if v-gr = 2 then do: /* равномерная */

    v-mpayment_od = round(v-sum / coun, 2).

    do i = 1 to v-srok:

        if i = 1 then v-dt = v-pdt.
        else
        if i = v-srok then v-dt = get-date(v-rdt,v-srok).
        else
        v-dt = get-date(v-dt0,1).

        v-prc = 0.
        if v-dt >= v-pdtprc then do:
            run day-360(v-dt0_prc,v-dt - 1,360,output dn1,output dn2).
            v-prc = round(dn1 * v-sum0 * v-rate / 100 / 360,2).
            v-dt0_prc = v-dt.
        end.

        v-komypay = 0.
        if i mod 12 = 0 then do:
            v-komypay = round(v-sum0 * v-komy / 100,2).
            if v-komypay < v-komy_min then v-komypay = v-komy_min.
        end.
        if ((i mod v-komomonth) = 0) /*and (i / v-komomonth = 1)*/ then v-komypay = v-komypay + v-komo.

        if v-dt >= v-pdtod then do:
            if i = v-srok then v-cpayment_od = v-sum0.
            else v-cpayment_od = v-mpayment_od.
            v-sum0 = v-sum0 - v-cpayment_od.
        end.

        create cl2b.
        cl2b.dt = v-dt.
        cl2b.days = v-dt - v-rdt.
        cl2b.sum = v-cpayment_od + v-prc + v-komypay.

        put stream rep unformatted
            cl2b.dt format "99/99/9999" ";"
            cl2b.days format ">>>>>9" ";"
            replace(trim(string(cl2b.sum,">>>>>>>>>>>9.99")),'.',',') ";"
            replace(trim(string(v-cpayment_od,">>>>>>>>>>>9.99")),'.',',') ";"
            replace(trim(string(v-prc,">>>>>>>>>>>9.99")),'.',',') ';'
            replace(trim(string(v-komypay,">>>>>>>>>>>9.99")),'.',',') skip.

        v-dt0 = v-dt.

    end.

end.
else do: /* аннуитет */

    v-mpayment = round(v-sum * v-rate / 1200 / (1 - 1 / exp(1 + v-rate / 1200,coun)),2).

    do i = 1 to v-srok:

        if i = 1 then v-dt = v-pdt.
        else
        if i = v-srok then v-dt = get-date(v-rdt,v-srok).
        else
        v-dt = get-date(v-dt0,1).

        v-prc = 0.
        if v-dt >= v-pdtprc then do:
            run day-360(v-dt0_prc,v-dt - 1,360,output dn1,output dn2).
            v-prc = round(dn1 * v-sum0 * v-rate / 100 / 360,2).
            v-dt0_prc = v-dt.
        end.

        v-komypay = 0.
        if i mod 12 = 0 then do:
            v-komypay = round(v-sum0 * v-komy / 100,2).
            if v-komypay < v-komy_min then v-komypay = v-komy_min.
        end.
        if ((i mod v-komomonth) = 0) /*and (i / v-komomonth = 1)*/ then v-komypay = v-komypay + v-komo.

        v-cpayment_od = 0.
        if v-dt >= v-pdtod then do:
            /*
            if i = 1 then v-cpayment_od = v-mpayment - round(30 * v-sum * v-rate / 100 / 360,2).
            else v-cpayment_od = v-mpayment - v-prc.
            */
            v-cpayment_od = v-mpayment - v-prc.
        end.
        else v-cpayment_od = 0.

        if i = v-srok then v-cpayment_od = v-sum0.

        v-sum0 = v-sum0 - v-cpayment_od.

        create cl2b.
        cl2b.dt = v-dt.
        cl2b.days = v-dt - v-rdt.
        cl2b.sum = v-cpayment_od + v-prc + v-komypay.

        put stream rep unformatted
            cl2b.dt format "99/99/9999" ";"
            cl2b.days format ">>>>>9" ";"
            replace(trim(string(cl2b.sum,">>>>>>>>>>>9.99")),'.',',') ";"
            replace(trim(string(v-cpayment_od,">>>>>>>>>>>9.99")),'.',',') ";"
            replace(trim(string(v-prc,">>>>>>>>>>>9.99")),'.',',') ';'
            replace(trim(string(v-komypay,">>>>>>>>>>>9.99")),'.',',') skip.

        v-dt0 = v-dt.

    end.

end.


v-er = get_er(v-sum,v-kom1,0.0,0.0).


output stream rep close.
unix silent cptwin rep.csv excel.


