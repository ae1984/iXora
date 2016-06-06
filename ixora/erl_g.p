/* erl_g.p
 * MODULE
        Расчет эффективных ставок
 * DESCRIPTION
        Расчет эффективных ставок по гарантиям
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
        12/05/2010 madiyar - скопировал из erl_bd.p с изменениями
 * BASES
        BANK
 * CHANGES
        14/05/2010 madiyar - убрал комиссию
*/

{mainhead.i}

def var v-sum as deci no-undo.
def var v-srok as integer no-undo.
def var v-rate as deci no-undo.
def var v-rdt as date no-undo.
def var v-pdt as date no-undo.
def var v-komf as deci no-undo. /* комиссия */
def var v-komfekv as deci no-undo.
def var v-er as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def var v-dt as date no-undo.
def var v-dt0 as date no-undo.
def var v-prc as deci no-undo.
def var i as integer no-undo.
def var v-ok as logical no-undo.

/*
def var v-crc as integer no-undo.
def var v-crccode as char no-undo.
def var v-komfr as deci no-undo.
def var v-komfmin as deci no-undo.
*/

form
  skip(1)
  v-sum   label "Сумма гарантии......................." format ">>>,>>>,>>>,>>9.99" /*validate (v-sum > 0 and v-sum <= 3000000, " Сумма должна быть больше 0 и меньше 3,000,000! ")*/
  /*
  v-crc   label "Валюта" format ">9" validate(can-find(crc where crc.crc = v-crc no-lock),"Некорректная валюта!") v-crccode no-label */
  skip
  v-srok  label "Срок (календ. дней).................." validate (v-srok > 0 and v-srok <= 365, " Срок должен быть от 1 до 365 дней! ") skip
  v-rate  label "Ставка вознаграждения................" validate (v-rate >= 0, " Ставка не может быть отрицательной! ") " % годовых " skip(1)
  v-rdt   label "Дата выдачи.........................." skip
  v-pdt   label "Дата погашения......................." skip(1)
  /*
  v-komfr label "Ставка по комиссии за выпуск гарантии" format ">>9.99" validate (v-rate >= 0, " Ставка не может быть отрицательной! ") "%  "
  "не менее" v-komfmin no-label format "zzz,zz9.99" "KZT в эквиваленте " skip
  v-komf  label "Комиссия за выпуск гарантии.........." format ">,>>>,>>>,>>9.99"
  " (Экв." v-komfekv no-label format "z,zzz,zzz,zz9.99" "KZT)" skip
  skip(1)
  */
  v-er    label "Эффективная ставка..................." format ">,>>>,>>9.99"  "% годовых " skip(1)
with centered side-label column 1 row 5 title " Расчет эффективной ставки (гарантии) " frame erf.

{er.i}

repeat:

    assign
        v-sum = 0
        v-srok = 7
        v-rate = 24
        v-rdt = g-today
        v-pdt = g-today + 7.
        /*
        v-komfr = 0.2
        v-komfmin = 4000
        v-komf = 0
        v-komfekv = 0
        v-crc = 1
        v-crccode = "KZT".
        */

    empty temp-table b2cl.
    empty temp-table cl2b.

    displ v-sum v-srok v-rate v-rdt v-pdt /*v-komfr v-komfmin v-komf v-komfekv v-crc v-crccode*/ with frame erf.

    update v-sum with frame erf.
    /*
    update v-crc with frame erf.
    find first crc where crc.crc = v-crc no-lock no-error.
    if avail crc then v-crccode = crc.code. else v-crccode = ''.
    displ v-crccode with frame erf.
    */

    update v-srok with frame erf.
    v-pdt = v-rdt + v-srok.
    displ v-pdt with frame erf.

    update v-rate with frame erf.

    update v-rdt with frame erf.
    v-pdt = v-rdt + v-srok.
    displ v-pdt with frame erf.
    /*
    update v-komfr with frame erf.
    update v-komfmin with frame erf.

    v-komf = round(v-sum * v-komfr / 100,2).
    if v-crc = 1 then do:
        if v-komf < v-komfmin then v-komf = v-komfmin.
        v-komfekv = v-komf.
    end.
    else do:
        if v-komf * crc.rate[1] < v-komfmin then v-komf = round(v-komfmin / crc.rate[1],2).
        v-komfekv = v-komf * crc.rate[1].
    end.
    displ v-komf with frame erf.
    displ v-komfekv with frame erf.

    update v-komf with frame erf.
    v-komfekv = v-komf * crc.rate[1].
    displ v-komfekv with frame erf.
    */

    /* расчет */

    run erl_gf(v-sum,v-srok,v-rate,v-rdt,v-pdt,0,output v-er).

    displ v-er with frame erf.

    v-ok = no.
    message "Повторить расчет? (y/n) " update v-ok.
    if not v-ok then leave.

end. /* repeat */

hide message no-pause.

