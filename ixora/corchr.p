/* corchr.p
 * MODULE
        Корреспонденция
 * DESCRIPTION
        Начисление комиссий
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-10-2
 * AUTHOR
       22.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var s-lc     like lc.lc.
def shared var v-lcsts  as char.
def shared var s-lcprod as char.
def shared var s-fmt    as char.
def shared var s-str    as char.
def shared var s-lctype as char.
def var v-sum         as deci no-undo.
DEF VAR VBANK         AS CHAR no-undo.
def var v-temp        as deci no-undo.
def var v-log         as logi no-undo.
def var v-kurs        as char no-undo.
def var h-crc         as int  no-undo init 1.
def var v-tarif       as char no-undo.
def var v-amount      as deci no-undo.
def var v-exabout     as char no-undo.
def var v-per         as deci no-undo.
def var v-qty         as int  no-undo.
def var v-rem1        as char no-undo.
def var v-rem2        as char no-undo.
def var v-title       as char no-undo.

def buffer b-crc for crc.

def temp-table wrk
    FIELD BANK      AS CHAR
    field num       as char
    field commis    as char
    field kurs      as char
    field kurs_code as integer
    field qty       as integer
    field crc       as inte
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

if v-lcsts <> 'NEW' then do:
    message "Free Format Correspondence's status is not applicable for editting mode!" view-as alert-box.
    return.
end.



def frame frcrc
    h-crc    label "Enter the currency" format '>>9' skip
with width 90 side-label overlay centered.
on help of h-crc in frame frcrc do:
    run h-crc2.
    h-crc:screen-value = return-value.
end.
if s-lctype = "I" then update h-crc with frame frcrc.
else h-crc = 1.
on 'end-error' of frame frcrc do:
    hide frame frcrc no-pause.
end.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.

find first crc where crc.crc = h-crc no-lock no-error.
if not avail crc then return.

empty temp-table wrk.

v-qty   = 0 .
for each tarif2 where lookup(string(tarif2.str5),s-str) > 0 and tarif2.stat = 'r' no-lock:
    find first lcres where lcres.lc = s-lc and lcres.comcode = tarif2.str5 no-lock no-error.
    if avail lcres then do:
        if num-entries(lcres.rem,';') = 2 then assign v-rem1 = entry(1,lcres.rem,';') v-qty = int(entry(2,lcres.rem,';')).
        else assign v-rem1 = lcres.rem v-qty = 1.
    end.

    find first lch where lch.lc = s-lc and lch.kritcod = 'lcCrc' no-lock no-error.
    if avail lch and lch.lc begins 'GTEADV' then do:
        find first crc where crc.crc = int(lch.value1) no-lock no-error.
        if avail crc then do:
            h-crc = crc.crc.
            v-kurs = crc.code.
        end.
    end.
    create wrk.
    assign wrk.num       = if avail lcres then lcres.comcode else tarif2.str5
           wrk.commis    = tarif2.pakalp
           wrk.amount    = if avail lcres then lcres.amt else 0
           wrk.BANK      = vbank
           wrk.rem       = if avail lcres then v-rem1 else ''
           wrk.kurs      = crc.code
           wrk.kurs_code = h-crc
           wrk.ost       = round(tarif2.ost / crc.rate[1],2)
           wrk.proc      = tarif2.proc
           wrk.min1      = round(tarif2.min1 / crc.rate[1],2)
           wrk.max1      = round(tarif2.max1 / crc.rate[1],2)
           wrk.qty       = if avail lcres then v-qty else 0.
    if tarif2.ost > 0 then wrk.tariff = trim(string(round(tarif2.ost / crc.rate[1],2),'>>>,>>9.99')).
    if tarif2.proc > 0 then wrk.tariff = trim(string(tarif2.proc,'>>9.99')) + '% ' + trim(string(round(tarif2.min1 / crc.rate[1],2),'>>>,>>9.99')) + '-' + trim(string(round(tarif2.max1 / crc.rate[1],2),'>>>,>>9.99')).
    if wrk.tariff = '' then wrk.tariff = '0.00'.
end.

on "return" of browse bt do:
    v-title = ' ' + wrk.num + ' ' + wrk.commis + ' '.
    if avail wrk then do:
       find current wrk exclusive-lock.
       v-rem1 = substr(wrk.commis,1,80).
       v-rem2 = substr(wrk.commis,81,160).
       displ wrk.amount v-rem1 v-rem2 with frame frrem.
       if wrk.tariff = '0.00' then update wrk.amount v-rem1 v-rem2 with frame frrem.
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
        assign LCres.dacc = '186082'
               LCres.levD = 1.
        find first tarif2 where tarif2.str5 = wrk.num and tarif2.stat = 'r' no-lock no-error.
        if avail tarif2 then
        assign LCres.cacc = string(tarif2.kont)
               LCres.levC = 1.
        assign LCres.crc  = wrk.kurs_code
               LCres.amt  = wrk.amount
               LCres.rwho = g-ofc
               LCres.rwhn = g-today
               LCres.bank = wrk.bank
               LCres.rem  = wrk.rem + ';' + string(wrk.qty).
        find current LCres no-lock no-error.
        hide frame ft no-pause.
    end. /*for each wrk*/
    message "Commissions have been stated!" view-as alert-box.
    hide frame ft no-pause.
end. /*on button*/
OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
apply "value-changed" to browse bt.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW or choose of btn-d.