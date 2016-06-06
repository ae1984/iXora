/* erl_f.p
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
        03/04/2007 Saltanat - добавила возможность редактирования
        01/07/2008 madiyar - закомментировал что-то непонятное с аккредитивами
        28/06/2010 madiyar - убрал значения по-умолчанию по комиссиям
        20/09/2010 madiyar - ежемесячная комиссия
        03/02/2011 madiyar - проценты, как и по ФЛ, могут быть начиная с определенной даты
        14/02/2011 madiyar - исправления в аннуитете
*/

{mainhead.i}

def var v-sum as deci no-undo.
def var v-sumcr as deci no-undo.
def var v-sumga as deci no-undo.
def var v-sumak as deci no-undo.
def var v-crc as integer no-undo.
def var v-srok as integer no-undo.
def var v-srokv as integer no-undo.
def var v-rate as deci no-undo.
def var v-ratega as deci no-undo.
def var v-sumpremga_min as deci no-undo.
def var v-gr as integer no-undo.
def var v-grdes as character no-undo.
def var v-rdt as date no-undo.
def var v-duedt as date no-undo.
def var v-pdt as date no-undo.
def var v-pdtprc as date no-undo.
def var v-pdtod as date no-undo.
def var v-komf as deci no-undo.
def var v-komfy as deci no-undo.
def var v-komfy_min as deci no-undo.
def var v-komv as deci no-undo.
def var v-komo as deci no-undo.
def var v-komovyp as integer no-undo.
def var v-komovyp_des as char no-undo.
def var v-komn as deci no-undo.
def var v-komr as deci no-undo.
def var v-komr2 as deci no-undo.
def var v-komp as deci no-undo.
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

def var vgl as integer no-undo.
def var vdes as char no-undo.

define temp-table t-gr no-undo
  field gr as integer
  field grdes as character
  index idx is primary gr.

create t-gr.
assign t-gr.gr = 1 t-gr.grdes = "аннуитет".
create t-gr.
assign t-gr.gr = 2 t-gr.grdes = "равными долями".


define temp-table t-komovyp no-undo
  field code as integer
  field des as character
  index idx is primary code.

create t-komovyp.
assign t-komovyp.code = 1 t-komovyp.des = "ежегодно".
create t-komovyp.
assign t-komovyp.code = 2 t-komovyp.des = "1 раз в полгода".
create t-komovyp.
assign t-komovyp.code = 3 t-komovyp.des = "ежеквартально".
create t-komovyp.
assign t-komovyp.code = 4 t-komovyp.des = "ежемесячно".

form
  skip(1)
  v-sum label "Сумма кредита (тенге)........." format ">>>,>>>,>>>,>>9.99" validate (v-sum > 0, " Сумма должна быть больше 0 ! ") " " v-crc format "9" label "Валюта выдачи" skip
  v-sumcr label "   кредит....................." format ">>>,>>>,>>>,>>9.99" validate (v-sumcr > 0, " Сумма должна быть больше 0 ! ") skip
  v-sumga label "   гарантия..................." format ">>>,>>>,>>>,>>9.99" validate (v-sumga >= 0, " Сумма должна быть неотрицательная ! ") skip
  v-sumak label "   аккредитив................." format ">>>,>>>,>>>,>>9.99" validate (v-sumak >= 0, " Сумма должна быть неотрицательная ! ") skip
  v-srok label "Срок кредитования (мес)......." validate (v-srok > 0, " Некорректный срок ! ") skip
  v-srokv label "Период доступности (мес)......" validate (v-srokv >= 0, " Некорректный срок ! ") skip
  v-rate label "Ставка вознаграждения кред..." validate (v-rate >= 0, " Ставка не может быть отрицательной ! ") " % годовых " skip
  v-ratega label "Ставка вознаграждения гарант." validate (v-ratega >= 0, " Ставка не может быть отрицательной ! ") " % годовых " " " v-sumpremga_min label "но не менее" validate (v-sumpremga_min >= 0, " Сумма должна быть неотрицательная ! ") skip
  v-gr format ">9" label "График погашения............." validate (can-find(t-gr where t-gr.gr = v-gr no-lock), " Некорректный график ! ") help "F2 - справочник"
  " " v-grdes format "x(23)" no-label skip
  v-rdt label  "Дата выдачи.................." skip
  v-pdt label  "Дата предп. 1-го погашения..." validate (v-pdt > v-rdt and v-pdt - v-rdt < 50, " Некорректная дата первого погашения %% ! ") skip
  v-pdtprc label  "Дата 1-го погашения %%......." validate (v-pdtprc > v-rdt and v-pdtprc <= v-duedt and ((day(v-pdtprc) = day(v-pdt)) or (v-pdtprc = v-duedt)), " Некорректная дата первого погашения %% ! ") skip
  v-pdtod label  "Дата 1-го погашения ОД......." validate (v-pdtod > v-rdt and v-pdtod <= v-duedt and ((day(v-pdtod) = day(v-pdt)) or (v-pdtod = v-duedt)), " Некорректная дата первого погашения ОД ! ") skip
  v-komf label "Комиссия - предост.кредита..." format ">>>,>>>,>>>,>>9.99" help " Комиссия за предоставление кредита " skip
  v-komfy label " -||- ежегодно (% от ОД)....." format ">>9.99" " " v-komfy_min label "но не менее" format ">>>,>>>,>>>,>>9.99" skip
  v-komv label "Комиссия - оформ.кр.док......" format ">>>,>>>,>>>,>>9.99" help " Комиссия за оформление кредитной документации " skip
  v-komo label "Комиссия - обслуживание 7 МРП" format ">>>,>>>,>>>,>>9.99" help " Комиссия за обслуживание кредита " " " v-komovyp label "с выплатой" format ">9" validate (can-find(t-komovyp where t-komovyp.code = v-komovyp no-lock), " Некорректный график ! ") v-komovyp_des no-label skip
  v-komn label "Комиссия - непокр.аккредитив." format ">>>,>>>,>>>,>>9.99" help " Комиссия за открытие непокрытого аккредитива " skip
  v-komr label "Комиссия - риски аккред.(%).." format ">>9.99" help " Комиссия за риски (при открытии аккредитива) в %" skip
  v-komp label "Комиссия - подтверждение...." format ">>>,>>>,>>>,>>9.99" help " Комиссия за подтверждение гарантии (аккредитива) иностр. банком " skip
  skip(1)
  v-sumd label "Сумма депозита (тенге)...." format ">>>,>>>,>>>,>>9.99" help " Сумма депозита, предоставленного в залог " " " v-crcd format "9" label "Валюта" skip
  v-rated label "Ставка по депозиту......." validate (v-rated >= 0, " Ставка не может быть отрицательной ! ") " % годовых " skip
  skip(1)
  v-er label "Эффективная ставка......." format ">,>>>,>>9.99"  " % годовых " skip(1)
  v-ok label "Выйти" skip(1)
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

on help of v-komovyp in frame erf do:
  {itemlist.i
       &file = "t-komovyp"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-komovyp.code label 'КОД' format '>9'
                    t-komovyp.des label 'ОПИСАНИЕ' format 'x(50)'
                   "
       &chkey = "code"
       &chtype = "integer"
       &index  = "idx"
       &end = "if keyfunction(lastkey) = 'end-error' then return."
  }
  v-komovyp = t-komovyp.code.
  v-komovyp_des = t-komovyp.des.
  displ v-komovyp v-komovyp_des with frame erf.
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
        v-sumcr = 0 v-sumga = 0 v-sumak = 0
        v-srok = 12
        v-srokv = 0
        v-rate = 0
        v-ratega = 0
        v-gr = 2
        v-grdes = "равными долями"
        v-rdt = g-today
        v-duedt = get-date(g-today,12)
        v-pdt = get-date(v-rdt,1)
        v-pdtprc = v-pdt
        v-pdtod = v-pdt
        v-komf = 0
        v-komfy = 0 /*0.5*/
        v-komfy_min = 0 /*15000*/
        v-komv = 0 /*14905*/.

    /*
    run perev ('',940,0,1,1,'',output v-komo, output vgl, output vdes).
    */

    assign
        v-komn = 0
        v-komr = 0
        v-komp = 0
        v-sumd = 0
        v-crcd = 1
        v-rated = 0
        v-er = 0.

    for each b2cl: delete b2cl. end.
    for each cl2b: delete cl2b. end.

    displ v-sum v-crc v-srok v-srokv v-rate v-gr v-grdes v-rdt v-pdtprc v-pdt v-pdtod v-komf v-komfy v-komv v-komr v-sumd v-crcd v-rated v-er with frame erf.

    update v-sum with frame erf.
    update v-crc with frame erf.
    update v-sumcr with frame erf.
    update v-sumga with frame erf.
    update v-sumak with frame erf.

    /*
    v-komf = round(v-sum / 200,2).
    displ v-komf with frame erf.
    */

    if v-sumak > 0 then do:
        v-komn = round(v-sumak / 1000,2).
        if v-komn < 15685 then v-komn = 15685.
        if v-komn > 78425 then v-komn = 78425.
        displ v-komn with frame erf.
    end.

    /*
    else v-komr = round(v-sum * 1.2 / 100,2).
    */
    displ v-komr with frame erf.

    update v-srok with frame erf.

    v-duedt = get-date(v-rdt,v-srok).

    update v-srokv with frame erf.
    update v-rate with frame erf.
    update v-ratega with frame erf.
    update v-sumpremga_min with frame erf.

    update v-gr with frame erf.
    find first t-gr where t-gr.gr = v-gr no-lock no-error.
    if avail t-gr then do: v-grdes = t-gr.grdes. displ v-grdes with frame erf. end.

    update v-rdt with frame erf.

    v-duedt = get-date(v-rdt,v-srok).

    update v-pdt with frame erf.
    update v-pdtprc with frame erf.
    update v-pdtod with frame erf.

    update v-komf with frame erf.
    update v-komfy with frame erf.
    update v-komfy_min with frame erf.

    update v-komv with frame erf.

    update v-komo with frame erf.
    update v-komovyp with frame erf.

    if v-sumak > 0 then do:
        update v-komn with frame erf.
        update v-komr with frame erf.
    end.

    if v-sumga + v-sumak > 0 then update v-komp with frame erf.

    update v-sumd with frame erf.
    update v-crcd with frame erf.
    update v-rated with frame erf.

    /* расчет */
    v-komr2 = round(v-sumak * v-komr / 100,2).
    run erl_uf(v-sum,v-srok,v-rate,v-gr,v-rdt,v-pdt,v-pdtprc,v-pdtod,v-komf + v-komv + v-komn + v-komr2 + v-komp,v-komfy,v-komfy_min,v-komo,v-komovyp,v-sumd,v-rated,output v-er).

    displ v-er with frame erf.

    v-ok = no.
    hide message.
    /*message "Повторить расчет? (y/n) "*/ update v-ok with frame erf.
    if v-ok then leave.

end. /* repeat */

hide message no-pause.

