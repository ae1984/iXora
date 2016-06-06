/* erl_f.p
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Расчет эффективных ставок по потребительским кредитам
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
        31/01/2007 madiyar
 * BASES
        BANK COMM
 * CHANGES
        21/05/2008 madiyar - перекомпиляция
        08/07/08 marinav - кол-во дней 100
        16/02/2010 madiyar - произвольная дата погашения %% и ОД; распространил на ЭК
        28/06/2010 madiyar - убрал значения по-умолчанию по комиссиям
        03/02/2011 madiyar - изменил проверку дат
        14/02/2011 madiyar - исправления в аннуитете
        05/08/2011 madiyar - ежемесячная комиссия за обслуживание кредита
*/

{mainhead.i}

def var v-sum as deci no-undo.
def var v-crc as integer no-undo.
def var v-srok as integer no-undo.
def var v-rate as deci no-undo.
def var v-gr as integer no-undo.
def var v-grdes as character no-undo.
def var v-rdt as date no-undo.
def var v-duedt as date no-undo.
def var v-pdt as date no-undo.
def var v-pdtprc as date no-undo.
def var v-pdtod as date no-undo.
def var v-komf as deci no-undo.
def var v-komfy as deci no-undo.
def var v-komv as deci no-undo.
def var v-komr as deci no-undo.
def var v-komob as deci no-undo.
def var v-er as deci no-undo.

def var v-sumd as deci no-undo.
def var v-crcd as integer no-undo.
def var v-rated as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def var v-dt as date no-undo.
def var v-dt0 as date no-undo.
def var v-prc as deci no-undo.
def var i as integer no-undo.
def var v-ok as logical no-undo.

define temp-table t-gr no-undo
  field gr as integer
  field grdes as character
  index idx is primary gr.

/*
create t-gr.
assign t-gr.gr = 1 t-gr.grdes = "аннуитет".
create t-gr.
assign t-gr.gr = 2 t-gr.grdes = "аннуитет с nn мес".
create t-gr.
assign t-gr.gr = 3 t-gr.grdes = "равными долями".
create t-gr.
assign t-gr.gr = 4 t-gr.grdes = "равными долями с nn мес".
*/

create t-gr.
assign t-gr.gr = 1 t-gr.grdes = "аннуитет".
create t-gr.
assign t-gr.gr = 2 t-gr.grdes = "равными долями".
create t-gr.
assign t-gr.gr = 3 t-gr.grdes = "ЭК (на всю сумму)".

form
  skip(1)
  v-sum label "Сумма кредита (тенге)...." format ">>>,>>>,>>>,>>9.99" validate (v-sum > 0, " Сумма должна быть больше 0 ! ") " " v-crc format "9" label "Валюта выдачи" skip
  v-srok label "Срок кредитования........" validate (v-srok > 0, " Некорректный срок ! ") skip
  v-rate label "Ставка вознаграждения...." validate (v-rate >= 0, " Ставка не может быть отрицательной ! ") " % годовых " skip
  v-gr format ">9" label "График погашения........." validate (can-find(t-gr where t-gr.gr = v-gr no-lock), " Некорректный график ! ") help "F2 - справочник"
  " " v-grdes format "x(23)" no-label skip
  v-rdt label  "Дата выдачи.............." skip
  v-pdt label  "Дата предп. 1го погашения" validate (v-pdt > v-rdt and v-pdt - v-rdt < 50, " Некорректная дата предполагаемого первого погашения! ") skip
  v-pdtprc label  "Дата 1го погашения %%...." validate (v-pdtprc > v-rdt and v-pdtprc <= v-duedt and ((day(v-pdtprc) = day(v-pdt)) or (v-pdtprc = v-duedt)), " Некорректная дата первого погашения %% ! ") skip
  v-pdtod label  "Дата 1го погашения ОД...." validate (v-pdtod > v-rdt and v-pdtod <= v-duedt and ((day(v-pdtod) = day(v-pdt)) or (v-pdtod = v-duedt)), " Некорректная дата первого погашения ОД ! ") skip
  v-komf label "Комиссия - пред.кредита.." format ">>>,>>>,>>>,>>9.99" help " Комиссия за предоставление кредита " " + " v-komfy format ">>>,>>>,>>>,>>9.99" label "ежегодно" skip
  v-komv label "Комиссия - оформ.кр.док.." format ">>>,>>>,>>>,>>9.99" help " Комиссия за оформление кредитной документации " skip
  v-komr label  "Комиссия - обналичивание." format ">>>,>>>,>>>,>>9.99" help " Комиссия за обналичивание " skip
  v-komob label "Комиссия - обслуживание.." format ">>>,>>>,>>>,>>9.99" help " Комиссия за обслуживание кредита " skip
  skip(1)
  v-sumd label "Сумма депозита (тенге)..." format ">>>,>>>,>>>,>>9.99" help " Сумма депозита, предоставленного в залог " " " v-crcd format "9" label "Валюта" skip
  v-rated label "Ставка по депозиту......." validate (v-rated >= 0, " Ставка не может быть отрицательной ! ") " % годовых " skip
  skip(1)
  v-er label "Эффективная ставка......." format ">,>>>,>>9.99"  " % годовых " skip(1)
with centered side-label column 1 row 3 title " Расчет эффективной ставки (БД) " frame erf.

on help of v-gr in frame erf do:
  {itemlist.i
       &file = "t-gr"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-gr.gr label 'КОД' format '>9'
                    t-gr.grdes label 'ОПИСАНИЕ' format 'x(50)'
                   "
       &chkey = "gr"
       &chtype = "integer"
       &index  = "idx"
       &end = "if keyfunction(lastkey) = 'end-error' then return."
  }
  v-gr = t-gr.gr.
  displ v-gr with frame erf.
end.

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
        v-crc = 1
        v-srok = 12
        v-rate = 0
        v-gr = 2
        v-grdes = "равными долями"
        v-rdt = g-today
        v-duedt = get-date(g-today,12)
        v-pdt = get-date(v-rdt,1)
        v-pdtprc = v-pdt
        v-pdtod = v-pdt
        v-komf = 0
        v-komfy = 0
        v-komv = 0
        v-komr = 0
        v-komob = 0
        v-sumd = 0
        v-crcd = 1
        v-rated = 0
        v-er = 0.

    empty temp-table b2cl.
    empty temp-table cl2b.

    displ v-sum v-crc v-srok v-rate v-gr v-grdes v-rdt v-pdt v-pdtprc v-pdtod v-komf v-komfy v-komv v-komr v-komob v-sumd v-crcd v-rated v-er with frame erf.

    update v-sum with frame erf.
    update v-crc with frame erf.
    /*
    if v-crc = 1 then v-komr = round(v-sum / 200,2).
    else v-komr = round(v-sum * 1.2 / 100,2).
    displ v-komr with frame erf.
    */

    update v-srok with frame erf.

    v-duedt = get-date(v-rdt,v-srok).

    update v-rate with frame erf.

    update v-gr with frame erf.
    find first t-gr where t-gr.gr = v-gr no-lock no-error.
    if avail t-gr then do: v-grdes = t-gr.grdes. displ v-grdes with frame erf. end.

    update v-rdt with frame erf.

    v-duedt = get-date(v-rdt,v-srok).

    update v-pdt with frame erf.
    update v-pdtprc with frame erf.
    update v-pdtod with frame erf.

    if v-gr = 1 and (v-pdtod <> v-pdtprc) then message "При аннуитете дата первого погашения ОД и %% должны совпадать!" view-as alert-box error.
    else do:
        update v-komf with frame erf.
        update v-komfy with frame erf.

        update v-komv with frame erf.

        update v-komr with frame erf.

        update v-komob with frame erf.

        update v-sumd with frame erf.
        update v-crcd with frame erf.
        update v-rated with frame erf.

        /* расчет */

        run erl_ff(v-sum,v-srok,v-rate,v-gr,v-rdt,v-pdt,v-pdtprc,v-pdtod,v-komf + v-komv + v-komr,v-komfy,v-komob,v-sumd,v-rated,output v-er).

        displ v-er with frame erf.
    end.

    v-ok = no.
    message "Повторить расчет? (y/n) " update v-ok.
    if not v-ok then leave.

end. /* repeat */

hide message no-pause.

