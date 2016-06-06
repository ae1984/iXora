/* LCpcharg.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Payment - Расчет комиссий
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
       02/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
        10/02/2012 id00810 - исключение для комиссий 953,958,963,999: сумма вводится вручную
        13/02/2012 id00810 - добавлены комиссии для документарных имнкассо (ТЗ 1273)
*/

{global.i}
def shared var s-lc      like lc.lc.
def shared var v-lcsts   as char.
def shared var s-lcprod  as char.
def shared var s-lcpay   like lcpay.lcpay.
def shared var s-paysts  like lcpay.sts.
def var v-dacc        as char.
def var v-dacc1       as char.
def var v-dacc-amount as decimal.
def var v-sum         as decimal.
def var v-crccom      as int.
def var v-codecom     as char.
def var v-crclc       as int.
def var v-codelc     as char.
def var sum           as deci.
def var i             as int.
def var v-tarif       as char no-undo.
def var v-amount      as deci no-undo.
def var v-exabout     as char no-undo.
def var v-per         as deci no-undo.
def var v-qty         as int  no-undo.
def var v-rem1        as char no-undo.
def var v-rem2        as char no-undo.
def var v-title       as char no-undo.
def var v-spcom       as char no-undo.
def var v-arp         as char no-undo.
def buffer b-crc for crc.

{LC.i}
if s-paysts <> 'NEW' then do:
    message "Payment status is not applicable for editting mode!" view-as alert-box error.
    return.
end.

define frame f_pog
    s-lc            label "Reference Number"                         format "x(20)"              skip
    v-dacc          label "Commission Debit Account"                 format "x(20)"              skip
    v-codecom       label "Currency of the Commission Debit Account" format "x(20)"              skip
    v-dacc-amount   label "Balance of the Commission Debit Account"  format ">>>,>>>,>>>,>>9.99" skip
    space(1)
    with width 75 row 4 centered overlay side-labels.

def temp-table wrk
    field bank      as char
    field num       as char
    field commis    as char
    field crccode   as char
    field crc       as int
    field qty       as int
    field ost       as deci
    field proc      as deci
    field min1      as deci
    field max1      as deci
    field amount    as deci
    field rem       as char
    field tariff    as char
    index idxwrk num.
def buffer b-wrk for wrk.

define query qt for wrk.
define browse bt query qt
    displ wrk.num     label "Code"             format "x(4)"
          wrk.commis  label "Comm Description" format "x(30)"
          wrk.tariff  label "Tariffs"          format "x(34)"
          wrk.qty     label "QTY"              format ">>9"
          wrk.amount  label "Amount"           format "->>>,>>>,>>9.99"
          wrk.crccode label "CCY"              format "x(3)"
          wrk.rem     label "Narrative"        format "x(20)"
          with width 110 row 6 centered 15 down overlay no-label title " Commissions for " + s-lcprod + " " NO-ASSIGN SEPARATORS.

def button btn-d label " Save  ".

DEFINE FRAME ft
    bt    SKIP(1)
    btn-d SKIP
    WITH 2 COLUMN SIDE-LABELS
    centered  NO-BOX width 112.

on "end-error" of frame ft do:
   hide frame ft    no-pause.
   hide frame f_pog no-pause.
end.

def frame frrem
    wrk.qty    label "QTY   " format '>>9' skip
    wrk.amount label "Amount" format '->,>>>,>>>,>>9.99' skip
    v-rem1     label "Narrat" format "x(80)" skip
    v-rem2     label "Narrat" format "x(80)" skip
with width 90 side-label overlay centered title v-title.

on 'end-error' of frame frrem do:
    hide frame frrem no-pause.
end.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Payment Amount is empty!" view-as alert-box error.
    return.
end.
v-amount = deci(lcpayh.value1).

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
if avail lcpayh then do:
    v-crclc = int(lcpayh.value1).
    find first crc where crc.crc = v-crclc no-lock no-error.
    if avail crc then v-codelc = crc.code.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
if avail lch then v-dacc = lch.value1.

if v-dacc = '' then do:
    message 'Commission Debit Account is empty!' view-as alert-box error.
    return.
end.

find first aaa where aaa.aaa = v-dacc no-lock no-error.
if avail aaa then do:
    find first b-crc where b-crc.crc = aaa.crc no-lock no-error.
    if avail b-crc then assign v-codecom = b-crc.code v-crccom = b-crc.crc.
    v-dacc-amount = aaa.cbal - aaa.hbal.
    if v-dacc-amount < 0 then v-dacc-amount = 0.
end.

displ s-lc v-dacc v-dacc-amount v-codecom with frame f_pog.

v-sum = 0.

empty temp-table wrk.
if s-lcprod = 'IMLC' or s-lcprod = 'SBLC'
then find first pksysc where pksysc.sysc = "IMLCpay" no-lock no-error.
else if s-lcprod = 'IDC' or s-lcprod = 'ODC'
then find first pksysc where pksysc.sysc = "DCpay" no-lock no-error.
else find first pksysc where pksysc.sysc = "PGpay" no-lock no-error.
if avail pksysc and pksysc.chval <> '' then v-spcom = pksysc.chval.
else return.

do i = 1 to num-entries(v-spcom):
    assign v-tarif = entry(i, v-spcom)
           v-qty   = 0 .
    find first tarif2 where tarif2.str5 = v-tarif and tarif2.stat = 'r' no-lock no-error.
    if avail tarif2 then do:
        create wrk.
        wrk.num = tarif2.num + tarif2.kod.
        if tarif2.ost > 0 then wrk.tariff = trim(string(tarif2.ost,'>>>,>>9.99')).
        if tarif2.proc > 0 then wrk.tariff = trim(string(tarif2.proc,'>>9.99')) + '% ' + trim(string(tarif2.min1,'>>>,>>9.99')) + '-' + trim(string(tarif2.max1,'>>>,>>9.99')).
        if wrk.tariff = '' then wrk.tariff = '0.00'.
        assign wrk.commis  = tarif2.pakalp
               wrk.crccode = v-codecom
               wrk.crc     = v-crccom
               wrk.BANK    = s-ourbank
               wrk.ost     = tarif2.ost
               wrk.proc    = tarif2.proc
               wrk.min1    = tarif2.min1
               wrk.max1    = tarif2.max1.

        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.comcode = tarif2.str5 no-lock no-error.
        if avail lcpayres then assign wrk.amount = lcpayres.amt
                                      wrk.rem    = lcpayres.rem
                                      wrk.qty    = int(lcpayres.info[5]).
        v-sum    = v-sum + wrk.amount.
    end.
end.

if  v-dacc-amount < v-sum then do:
    message "Lack of the balance!" view-as alert-box.
    hide frame f_pog no-pause.
    hide frame ft no-pause.
    return.
end.

on "return" of browse bt do:
    v-title = ' ' + wrk.num + ' ' + wrk.commis + ' '.
    if avail wrk then do:
       find current wrk exclusive-lock.
       v-rem1 = substr(wrk.commis,1,80).
       v-rem2 = substr(wrk.commis,81,160).
       displ wrk.qty wrk.amount v-rem1 v-rem2 with frame frrem.
       if wrk.tariff = '0.00' or lookup(wrk.num,'953,958,963,999') > 0 then update wrk.amount v-rem1 v-rem2 with frame frrem.
       else do:
        update wrk.qty with frame frrem.
        if wrk.ost > 0 then do:
            wrk.amount = round(wrk.ost * wrk.qty,2).
           if wrk.crc  > 1 then wrk.amount = round(wrk.amount / crc.rate[1],2).
        end.
        else do:
            wrk.amount = round(v-amount * wrk.proc / 100 * crc.rate[1],2).
            if wrk.min1 > 0 and wrk.amount < wrk.min1 then wrk.amount = wrk.min1.
            if wrk.max1 > 0 and wrk.amount > wrk.max1 then wrk.amount = wrk.max1.
            wrk.amount = wrk.amount * wrk.qty.
            if wrk.crc  > 1 then wrk.amount = round(wrk.amount / crc.rate[1],2).
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
    if v-dacc-amount < v-sum then do:
        message "Lack of the balance!" view-as alert-box.
        hide frame f_pog no-pause.
        hide frame ft no-pause.
        return.
    end.
    else do:
        for each wrk no-lock:
            find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.comcode = wrk.num no-lock no-error.
            if not avail lcpayres then do:
                if wrk.amount = 0 then next.
                create lcpayres.
                assign lcpayres.LC      = s-lc
                       lcpayres.lcpay   = s-lcpay
                       lcpayres.levD    = 1
                       lcpayres.com     = yes
                       lcpayres.comcode = wrk.num
                       lcpayres.bank    = wrk.bank.
            end.
            find current lcpayres exclusive-lock no-error.
            if wrk.amount = 0 then do:
                delete lcpayres.
                next.
            end.
            lcpayres.dacc = v-dacc.
            find first tarif2 where tarif2.str5  = wrk.num and tarif2.stat = 'r' no-lock no-error.
            if avail tarif2 then assign lcpayres.cacc = string(tarif2.kont) lcpayres.levC = 1.
            assign
                lcpayres.crc     = wrk.crc
                lcpayres.amt     = abs(wrk.amount)
                lcpayres.rwho    = g-ofc
                lcpayres.rwhn    = g-today
                lcpayres.rem     = wrk.rem
                lcpayres.info[5] = string(wrk.qty).
            end. /*for each wrk*/
            message "Commissions have been stated!" view-as alert-box.
            find current lcpayres no-lock no-error.
            hide frame f_pog no-pause.
            hide frame ft no-pause.

    end.
end. /*on button*/
OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
apply "value-changed" to browse bt.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW or choose of btn-d.