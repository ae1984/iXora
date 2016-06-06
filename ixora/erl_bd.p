/* er_bd.p
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
        19/09/2007 madiyar
        26/03/2010 madiyar - увеличил возможный срок кредитования до 60 месяцев
*/

{mainhead.i}

def var v-sum as deci no-undo.
def var v-srok as integer no-undo.
def var v-rate as deci no-undo.
def var v-rdt as date no-undo.
def var v-pdt as date no-undo.
def var v-komf as deci no-undo. /* комиссия в фонд покрытия кредитных рисков */
def var v-komv as deci no-undo. /* комиссия за ведение счета */
def var v-komr as deci no-undo. /* комиссия за рассмотрение заявки */
def var v-er as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def var v-dt as date no-undo.
def var v-dt0 as date no-undo.
def var v-prc as deci no-undo.
def var i as integer no-undo.
def var v-ok as logical no-undo.

form
  skip(1)
  v-sum label "Сумма кредита............" format ">>,>>>,>>9.99" /*validate (v-sum > 0 and v-sum <= 3000000, " Сумма должна быть больше 0 и меньше 3,000,000 ! ")*/ " тенге " skip
  v-srok label "Срок кредитования........" validate (v-srok >= 6 and v-srok <= 60, " Срок должен быть от 6 до 60 месяцев ! ") skip
  v-rate label "Ставка вознаграждения...." validate (v-rate >= 0, " Ставка не может быть отрицательной ! ") " % годовых " skip
  v-rdt label  "Дата выдачи.............." skip
  v-pdt label  "Дата первого погашения..." validate (v-pdt > v-rdt and v-pdt - v-rdt < 50, " Некорректная дата первого погашения ! ") skip
  v-komf label "Комиссия - фонд.........." format ">,>>>,>>9.99" help " Комиссия за оформление кредитной документации " skip
  v-komv label "Комиссия - обслуж. счета." format ">,>>>,>>9.99" help " Комиссия за ведение текущего счета " " (ежемесячно) " skip
  v-komr label "Комиссия - рассм.заявки.." format ">,>>>,>>9.99" help " Комиссия за рассмотрение заявки " skip
  skip(1)
  v-er label "Эффективная ставка......." format ">,>>>,>>9.99"  " % годовых " skip(1)
with centered side-label column 1 row 5 title " Расчет эффективной ставки (БД) " frame erf.

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

repeat:

    assign
        v-sum = 0
        v-srok = 36
        v-rate = 19
        v-rdt = g-today
        v-pdt = get-date(v-rdt,1)
        v-komf = 0
        v-komv = 0
        v-komr = 0.

    for each b2cl: delete b2cl. end.
    for each cl2b: delete cl2b. end.

    displ v-sum v-srok v-rate v-rdt v-pdt v-komf v-komv v-komr with frame erf.

    update v-sum with frame erf.
    v-komf = round(v-sum * 0.07,2).
    find first pksysc where pksysc.credtype = '6' and pksysc.sysc = "bdacc" no-lock no-error.
    if avail pksysc then v-komv = round(v-sum * pksysc.deval / 100,2). else v-komv = 0.
    displ v-komf v-komv with frame erf.

    update v-srok with frame erf.

    update v-rate with frame erf.

    update v-rdt with frame erf.

    update v-pdt with frame erf.

    update v-komf with frame erf.

    update v-komv with frame erf.

    update v-komr with frame erf.


    /* расчет */

    run erl_bdf(v-sum,v-srok,v-rate,v-rdt,v-pdt,v-komf,v-komv,v-komr,output v-er).

    displ v-er with frame erf.

    v-ok = no.
    message "Повторить расчет? (y/n) " update v-ok.
    if not v-ok then leave.

end. /* repeat */

hide message no-pause.

