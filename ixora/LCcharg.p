/* LCcharg.p
 * MODULE
        Аккредитив
 * DESCRIPTION
        Начисление комиссий для аккредитива
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14.1.1
 * AUTHOR
       09/09/2010 aigul
 * BASES
        BANK COMM
 * CHANGES
        10/09/2010 galina - перекомпиляция
        23/09/2010 galina - не записываем нулевые комиссии в LCres
        24/09/2010 galina - перекомпиляция
        07/10/2010 galina - перекомпиляция
        19/01/2011 id00810 - для всех видов аккредитивов
        27/01/2011 id00810 - для импортной гарантии особый счет для комиссии 966
        19/07/2011 id00810 - поле ComAcc для EXPG может быть не заполнено (комиссий нет)
        15/08/2011 id00810 - изменения в связи с MT720
        28/09/2011 id00810 - narraive (назначение платежа) - это название комиссии из тарификатора
        22/11/2011 id00810 - 970 комиссия со счета клиента
        17/01/2012 id00810 - добавлена новая переменная s-fmt
        30/01/2012 id00810 - расчет комиссий, запись количества qty в назначение платежа
        28/02/2012 id00892 - округление суммы комиссии производится после мат. операций
        18.07.2012 Lyubov  - проверка баланса осуществляет по нажатию кнопки Save
        14.03.2013 Lyubov  - ТЗ №1726, изменила счет для 966 комиссии с 285532 на 286931
*/
{global.i}
def shared var s-lc     like lc.lc.
def shared var v-lcsts  as char.
def shared var s-lcprod as char.
def shared var s-fmt    as char.
def var v-dacc        as char no-undo.
def var v-dacc-amount as deci no-undo.
def var v-lctype      as char no-undo.
def var v-sum         as deci no-undo.
DEF VAR VBANK         AS CHAR no-undo.
def var v-temp        as deci no-undo.
def var v-log         as logi no-undo.
def var v-kurs        as char no-undo.
def var v-crc         as int  no-undo.
def var v-tarif       as char no-undo.
def var v-amount      as deci no-undo.
def var v-exabout     as char no-undo.
def var v-per         as deci no-undo.
def var v-qty         as int  no-undo.
def var v-rem1        as char no-undo.
def var v-rem2        as char no-undo.
def var v-title       as char no-undo.

def buffer b-crc for crc.
define frame f_pog
    s-lc            label "Letter of Credit's Code                 " format "x(20)" skip
    v-dacc          label "Commission Debit Account                " format "x(20)" skip
    v-kurs          label "Currency of the Commission Debit Account" format "x(20)" skip
    v-dacc-amount   label "Balance of the Commission Debit Account " format ">>>,>>>,>>>,>>9.99" skip
    v-lctype        label "Letter of credit's type                 " format "x(1)" skip
    space(1)
    with width 75 row 3 centered overlay side-labels.

def temp-table wrk
    FIELD BANK      AS CHAR
    field num       as char
    field commis    as char
    field kurs      as char
    field kurs_code as integer
    field qty       as integer
    field ost       as deci
    field proc      as deci
    field min1      as deci
    field max1      as deci
    field amount    as decimal
    field rem       as char
    field tariff    as char.

def var i as int.

define query qt for wrk.
define browse bt query qt
    displ wrk.num    label "Code"             format "x(4)"
          wrk.commis label "Comm Description" format "x(30)"
          wrk.tariff label "Tariffs"          format "x(34)"
          wrk.qty    label "QTY"              format ">>9"
          wrk.amount label "Amount"           format ">>>,>>>,>>9.99"
          wrk.kurs   label "CCY"              format "x(3)"
          wrk.rem    label "Narrative"        format "x(20)"
          with width 110 row 6 centered 15 down overlay no-label title "Commissions for the letter of credit" NO-ASSIGN SEPARATORS.

def button btn-d   label  " Save  ".

DEFINE FRAME ft
    bt    SKIP(1)
    btn-d SKIP
    WITH 2 COLUMN SIDE-LABELS
    centered  NO-BOX width 112.

on "end-error" of frame ft do:
   hide frame ft no-pause.
   hide frame f_pog no-pause.
end.


def frame frrem
    wrk.qty    label "QTY   " format '>>9' skip
    wrk.amount label "Amount" format '>,>>>,>>>,>>9.99' skip
    v-rem1     label "Narrat" format "x(80)" skip
    v-rem2     label "Narrat" format "x(80)" skip
with width 90 side-label overlay centered title v-title.

on 'end-error' of frame frrem do:
    hide frame frrem no-pause.
end.

find first lc where lc.lc = s-lc no-lock no-error.
if avail lc then v-lctype = lc.lctype.

find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
if avail lch then v-dacc = lch.value1.

if v-lcsts <> 'NEW' then do:
    message "Letter of credit's status is not applicable for editting mode!" view-as alert-box.
    return.
end.

if v-dacc = '' then do:
    if s-lcprod <> 'expg' then message 'Commission Debit Account is empty!' view-as alert-box.
    return.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
if not avail lch or lch.value1 = '' then do:
    message "Field Amount is empty!" view-as alert-box error.
    return.
end.
v-amount = deci(lch.value1).

if lc.lctype = 'I' and s-fmt ne '720' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'ExAbout' no-lock no-error.
    if avail lch then v-exabout = lch.value1.
    if v-exabout = '' then do:
        message "Field ExAbout is empty!" view-as alert-box.
        return.
    end.

    if v-exabout = '1' then do:
        v-per = 0.
        find first lch where lch.lc = s-lc and kritcode = 'PerAmt' no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then do:
            v-per = int(entry(1,lch.value1, '/')).
            if v-per > 0 then v-amount = v-amount + (v-amount * (v-per / 100)).
        end.
        else do:
            message "Field PerAmt is empty!" view-as alert-box.
            return.
        end.
    end.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
v-crc = int(lch.value1).
find first crc where crc.crc = v-crc no-lock no-error.
if not avail crc then return.

find first aaa where aaa.aaa = v-dacc no-lock no-error.
if avail aaa then do:
    find first b-crc where b-crc.crc = aaa.crc no-lock no-error.
    if avail b-crc then v-kurs = b-crc.code.
    v-dacc-amount = aaa.cbal - aaa.hbal.
    if v-dacc-amount < 0 then v-dacc-amount = 0.
end.

displ s-lc v-dacc v-dacc-amount  v-kurs  v-lctype with frame f_pog.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.

empty temp-table wrk.

find first pksysc where pksysc.sysc = s-lcprod no-lock no-error.
if avail pksysc and pksysc.chval <> '' then do:
    do i = 1 to num-entries(pksysc.chval):
        assign v-tarif = entry(i, pksysc.chval)
               v-qty   = 0 .
        find first tarif2 where tarif2.str5 = v-tarif and tarif2.stat = 'r' no-lock no-error.
        if avail tarif2 then do:
            find first lcres where lcres.lc = s-lc and lcres.comcode = tarif2.str5 no-lock no-error.
            if avail lcres then do:
                if num-entries(lcres.rem,';') = 2 then assign v-rem1 = entry(1,lcres.rem,';') v-qty = int(entry(2,lcres.rem,';')).
                else assign v-rem1 = lcres.rem v-qty = 1.
            end.
            create wrk.
            assign wrk.num       = if avail lcres then lcres.comcode else tarif2.str5
                   wrk.commis    = tarif2.pakalp
                   wrk.amount    = if avail lcres then lcres.amt else 0
                   wrk.BANK      = vbank
                   wrk.rem       = if avail lcres then v-rem1 else ''
                   wrk.kurs      = v-kurs
                   wrk.kurs_code = b-crc.crc
                   wrk.ost       = tarif2.ost
                   wrk.proc      = tarif2.proc
                   wrk.min1      = tarif2.min1
                   wrk.max1      = tarif2.max1
                   wrk.qty       = if avail lcres then v-qty else 0.
            if tarif2.ost > 0 then wrk.tariff = trim(string(tarif2.ost,'>>>,>>9.99')).
            if tarif2.proc > 0 then wrk.tariff = trim(string(tarif2.proc,'>>9.99')) + '% ' + trim(string(tarif2.min1,'>>>,>>9.99')) + '-' + trim(string(tarif2.max1,'>>>,>>9.99')).
            if wrk.tariff = '' then wrk.tariff = '0.00'.

            /*v-sum = v-sum + wrk.amount.*/
        end.
    end.
end.

/*if v-dacc-amount < v-sum then do:
    message "Lack of the balance!" view-as alert-box.
    hide frame f_pog no-pause.
    hide frame ft no-pause.
    return.
end.*/

on "return" of browse bt do:
    v-title = ' ' + wrk.num + ' ' + wrk.commis + ' '.
    if avail wrk then do:
       find current wrk exclusive-lock.
       v-rem1 = substr(wrk.commis,1,80).
       v-rem2 = substr(wrk.commis,81,160).
       displ wrk.amount v-rem1 v-rem2 with frame frrem.
       if wrk.tariff = '0.00' or lookup(wrk.num,'953,958,963,999') > 0 then update wrk.amount v-rem1 v-rem2 with frame frrem.
       else do:
        update wrk.qty with frame frrem.
        if wrk.ost > 0 then wrk.amount = round(wrk.ost * wrk.qty,2).
        else do:
            wrk.amount = round(v-amount * wrk.proc / 100 * crc.rate[1],2).
            if wrk.min1 > 0 and wrk.amount < wrk.min1 then wrk.amount = wrk.min1.
            if wrk.max1 > 0 and wrk.amount > wrk.max1 then wrk.amount = wrk.max1.
            wrk.amount = round(wrk.amount * wrk.qty,2).
        end.
        display wrk.amount with frame frrem.
        update v-rem1 v-rem2 with frame frrem.
       end.
       wrk.rem = trim(trim(v-rem1) + ' ' + trim(v-rem2)).
       hide frame frrem.
       release wrk.
       close query qt.
       open query qt for each wrk no-lock.
       browse bt:refresh().
   end.
end.

on choose of btn-d do:
    for each wrk no-lock.
        v-sum = v-sum + wrk.amount.
    end.
    if v-dacc-amount < v-sum then do:
        message "Lack of the balance!" view-as alert-box.
        hide frame f_pog no-pause.
        hide frame ft no-pause.
        return.
    end.
    else do:
        for each wrk no-lock:
            find first LCres where LCres.LC = s-lc and lcres.com and LCres.comcode = wrk.num no-lock no-error.
            if not avail LCres then do:
                if wrk.amount = 0 then next.
                create LCres.
                assign LCres.LC      = s-lc
                       LCres.com     = yes
                       LCres.comcode = wrk.num.
            end.
            find current lcres exclusive-lock no-error.
            if wrk.amount = 0 then do:
                delete lcres.
                next.
            end.
            assign LCres.dacc = v-dacc
                   LCres.levD = 1.
            find first tarif2 where tarif2.str5 = wrk.num and tarif2.stat = 'r' no-lock no-error.
            if avail tarif2 then do:
                if tarif2.str5 = '970' then
                assign LCres.cacc = v-dacc
                       LCres.levC = 25.
                else if tarif2.str5 = '966' then
                assign LCres.cacc = '286931'
                       LCres.levC = 1.
                else
                assign LCres.cacc = string(tarif2.kont)
                       LCres.levC = 1.
            end.
            assign LCres.crc  = wrk.kurs_code
                   LCres.amt  = wrk.amount
                   LCres.rwho = g-ofc
                   LCres.rwhn = g-today
                   LCres.bank    = wrk.bank
                   LCres.rem  = wrk.rem + ';' + string(wrk.qty).
            find current LCres no-lock no-error.
           /* hide frame f_pog no-pause.
            hide frame ft no-pause.*/
        end. /*for each wrk*/
        message "Commissions have been stated!" view-as alert-box.
        hide frame f_pog no-pause.
        hide frame ft no-pause.
    end.
end. /*on button*/
OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
apply "value-changed" to browse bt.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW or choose of btn-d.