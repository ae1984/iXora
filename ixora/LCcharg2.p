/* LCcharg2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Начисление комиссий для изменений аккредитива
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
       26/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
       14/03/2011 id00810 - комиссии для всех событий
       08/04/2011 id00810 - иная комиссия, без тарификатора
       14/04/2011 id00810 - комиссия 997 за счет аппликанта или 997а - за счет бенефициара
       19/04/2011 id00810 - исправлено деление wrk.rem на строки
       04/05/2011 id00810 - комиссия 996
       11/08/2011 id00810 - новый вид оплаты Chrgs at BNFs expense
       28/09/2011 id00810 - narraive (назначение платежа) - это название комиссии из тарификатора
       02/11/2011 id00810 - переменная s-type(тип комиссии)
       23/12/2011 id00810 - для комиссии 9990 не надо искать код в тарификаторе, т.к. находится комиссия с кодом 999
       30/01/2012 id00810 - расчет комиссий по тарификатору для всех типов комиссий
       11/04/2012 id00810 - дополнила список тарифов, по которым можно вводить сумму (без расчета)
       31.08.2012 Lyubov - поправила округление комиссии в ин. валюте
       23.01.2013 Lyubov - ТЗ №1274, для IDC тип комиссии = 1 и сумма комиссии под кодом 1048 указывается вручную
       24.01.2013 Lyubov - ТЗ №1274, для IDC не проверяется покрытие и коды комиссий ищутся по признаку IDC_com
*/
{global.i}
def shared var s-lc          like LC.LC.
def shared var s-event       like lcevent.event.
def shared var s-number      like lcevent.number.
def shared var s-sts         like lcevent.sts.
def shared var s-lcprod      as char.
def shared var s-type        as char.
def var v-lccow       as char.
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
/*def var v-sp          as char init '996,997'.*/
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

if s-lcprod = 'IDC' then s-type = '1'.

{LC.i}
if s-sts <> 'NEW' then do:
    message "Event status is not applicable for editting mode!" view-as alert-box error.
    return.
end.

if s-type = '' then do:
    message "Field Commission Type is empty!" view-as alert-box error.
    return.
end.

/*if s-type ne '1' then do:
    run lccharg1.p.
    return.
end.*/

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

/*function amtvalid returns char (input p-amt as deci,input p-comcode as char).
    def var res as char.
    res = ''.
    if p-comcode <> '970' and p-comcode <> '966' then do:
        if p-amt < 0 then res = 'Amount must be >= 0!'.
    end.
    else do:
        if p-amt < 0 then do:
            find first lc where lc.LC = s-lc no-lock no-error.
            if avail lc then do:
                if lc.comsum < abs(p-amt) then res = 'Amount must be <= ' + trim(string(lc.comsum,'>>>>>>9.99')) + '!'.
            end.
            else res = 'Amount must be >= 0!'.
        end.
    end.
    return res.
end function.*/

define query qt for wrk.
define browse bt query qt
    displ wrk.num     label "Code"             format "x(4)"
          wrk.commis  label "Comm Description" format "x(30)"
          wrk.tariff  label "Tariffs"          format "x(34)"
          wrk.qty     label "QTY"              format ">>9"
          wrk.amount  label "Amount"           format "->>>,>>>,>>9.99"
          wrk.crccode label "CCY"              format "x(3)"
          wrk.rem     label "Narrative"        format "x(20)"
          /*enable amount validate(amtvalid(amount,wrk.num) = '',amtvalid(amount,wrk.num))*/
          with width 110 row 6 centered 15 down overlay no-label title " Commissions for " + s-lcprod + " " NO-ASSIGN SEPARATORS.

def button btn-d label " Save  ".

DEFINE FRAME ft
    bt   SKIP(1)
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

if s-lcprod <> 'IDC' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
    if avail lch then v-lccow = lch.value1.
    if v-lccow = '' then do:
        message "Field Covered/uncovered is empty!" view-as alert-box error.
        return.
    end.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
if not avail lch or lch.value1 = '' then do:
    message "Field Amount is empty!" view-as alert-box error.
    return.
end.
v-amount = deci(lch.value1).

if lc.lctype = 'I' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'ExAbout' no-lock no-error.
    if avail lch then v-exabout = lch.value1.
    if v-exabout = '1' then do:
        v-per = 0.
        find first lch where lch.lc = s-lc and kritcode = 'PerAmt' no-lock no-error.
        if avail lch and trim(lch.value1) <> '' then do:
            v-per = int(entry(1,lch.value1, '/')).
            if v-per > 0 then v-amount = v-amount + (v-amount * (v-per / 100)).
        end.
    end.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'LCcrc' no-lock no-error.
if avail lch then do:
    v-crclc = int(lch.value1).
    find first crc where crc.crc = v-crclc no-lock no-error.
    if avail crc then v-codelc= crc.code.
end.

if s-type = '4' then do:
    find first sysc where sysc.sysc = 'LCARP' no-lock no-error.
    if avail sysc then do:
        if num-entries(sysc.chval) >= v-crclc then v-arp = entry(v-crclc,sysc.chval).
        else do:
            message "The value LCARP in SYSC is empty!" view-as alert-box error.
            return.
        end.
    end.
    if v-arp = '' then do:
        message "The value LCARP in SYSC is empty!" view-as alert-box error.
        return.
    end.
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
if s-lcprod = 'SBLC'   then find first pksysc where pksysc.sysc = "IMLC" no-lock no-error. else
if s-lcprod = 'EXSBLC' then find first pksysc where pksysc.sysc = "EXLC" no-lock no-error. else
if s-lcprod = 'IDC '   then find first pksysc where pksysc.sysc = "IDC_com" no-lock no-error. else
                            find first pksysc where pksysc.sysc = s-lcprod no-lock no-error.
if avail pksysc and pksysc.chval <> '' then v-spcom = pksysc.chval.
else return.

if lookup(s-type,'2,5') > 0 then do:
    if s-lcprod begins 'ex' then return.
    v-spcom = if lookup(s-lcprod,'imlc,sblc') > 0 then '970' else '966'.
end.
else if lookup(s-type,'3,4') > 0 then do:
    if lookup('970',v-spcom) > 0 then v-spcom = replace(v-spcom,'970,','').
    else if lookup('966',v-spcom) > 0 then v-spcom = replace(v-spcom,'966,','').
end.
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
               wrk.crccode = if lookup(s-type,'1,2,5') > 0 then v-codecom else v-codelc
               wrk.crc     = if lookup(s-type,'1,2,5') > 0 then v-crccom  else v-crclc
               wrk.BANK    = s-ourbank
               wrk.ost     = tarif2.ost
               wrk.proc    = tarif2.proc
               wrk.min1    = tarif2.min1
               wrk.max1    = tarif2.max1.

        find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.comcode = tarif2.str5 no-lock no-error.
        if avail lceventres then do:
            if lceventres.comcode = '970' and lceventres.levD = 25 then wrk.amount = lceventres.amt * -1.
            else if lceventres.comcode = '966' and lceventres.dacc = '285532' then wrk.amount = lceventres.amt * -1.
            else wrk.amount = lceventres.amt.
            wrk.rem  = lceventres.rem.
            wrk.qty  = int(lceventres.info[5]).
            v-sum    = v-sum + wrk.amount.
        end.
        /*else if wrk.num = '996' or wrk.num = '997' then wrk.rem = 'за счет аппликанта'.*/
    end.
end.
/* иная комиссия, без тарификатора */
if lookup(s-type,'2,5') = 0 then do:
    create wrk.
    assign wrk.num       = '9990'
           wrk.tariff    = '0.00'
           wrk.commis    = 'Иные комиссии без учета НДС'
           wrk.crccode   = if s-type = '1' then v-codecom else v-codelc
           wrk.crc       = if s-type = '1' then v-crccom  else v-crclc
           wrk.BANK      = s-ourbank
           wrk.ost       = tarif2.ost
           wrk.proc      = tarif2.proc
           wrk.min1      = tarif2.min1
           wrk.max1      = tarif2.max1.
    find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.comcode = '9990' no-lock no-error.
    if avail lceventres then
    assign wrk.amount = lceventres.amt
           wrk.qty    = int(lceventres.info[5])
           wrk.rem    = lceventres.rem
           wrk.qty    = int(lceventres.info[5]).
    v-sum = v-sum + wrk.amount.
end.
/*  */
/* 996, 997 комиссии */
/*do i = 1 to num-entries(v-sp):
    find first b-wrk where b-wrk.num = entry(i,v-sp)no-lock no-error.
    if avail b-wrk then do:
        create wrk.
        buffer-copy b-wrk except amount to wrk.
        assign wrk.num       = b-wrk.num + 'a'
               wrk.crccode      = v-kurslc
               wrk.crc  = v-crclc.
        find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.comcode = wrk.num no-lock no-error.
        if avail lceventres then assign wrk.amount = lceventres.amt
                                         wrk.qty   = int(lceventres.info[5])
                                        wrk.rem    = lceventres.rem.
        else wrk.rem =  'за счет бенефициара'.
    end.
end.*/
/*  */

if s-type <= '2' and v-dacc-amount < v-sum then do:
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
       displ wrk.amount v-rem1 v-rem2 with frame frrem.
       if wrk.tariff = '0.00' or lookup(wrk.num,'944,953,958,963,996,999,1048') > 0 then do:
        update wrk.amount v-rem1 v-rem2 with frame frrem.
        if wrk.amount < 0 then do:
            if (wrk.num ne '970' and wrk.num ne '966') or lc.comsum = 0  then do:
                message "Amount must be >= 0!" view-as alert-box error.
                hide frame frrem.
                return.
            end.
            else if lc.comsum < abs(wrk.amount) then do:
                message "Amount must be <= " + trim(string(lc.comsum,'>>>>>>9.99')) + "!" view-as alert-box error.
                hide frame frrem.
                return.
            end.
        end.
       end.
       else do:
        update wrk.qty with frame frrem.
        if wrk.ost > 0 then do:
            wrk.amount = round(wrk.ost * wrk.qty,2).
           if wrk.crc  > 1 then wrk.amount = round(wrk.amount / crc.rate[1],0).
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
            find first lceventres where lceventres.LC = s-lc and lceventres.event = s-event and lceventres.comcode = wrk.num and lceventres.number = s-number no-lock no-error.
            if not avail lceventres then do:
                if wrk.amount = 0 then next.
                create lceventres.
                assign lceventres.LC      = s-lc
                       lceventres.event   = s-event
                       lceventres.number  = s-number
                       lceventres.levD    = 1
                       lceventres.com     = yes
                       lceventres.comcode = wrk.num
                       lceventres.bank    = wrk.bank.
            end.
            find current lceventres exclusive-lock no-error.
            if wrk.amount = 0 then do:
                delete lceventres.
                next.
            end.
            if s-type = '1' then do:
                lceventres.dacc = v-dacc.
                if wrk.num = '9990' then assign lceventres.cacc = '461220' lceventres.levC = 1.
                else do:
                    find first tarif2 where tarif2.str5  = wrk.num and tarif2.stat = 'r' no-lock no-error.
                    if avail tarif2 then do:
                        if tarif2.str5 = '970' then do:
                            if wrk.amount > 0 then assign lceventres.cacc = v-dacc
                                                          lceventres.levC = 25.
                            else assign lceventres.dacc = v-dacc
                                        lceventres.levD = 25
                                        lceventres.cacc = v-dacc
                                        lceventres.levC = 1.
                        end.
                        else if tarif2.str5 = '966' then do:
                            if wrk.amount > 0 then assign lceventres.cacc = '285532' lceventres.levC = 1.
                            else assign lceventres.dacc = '285532' lceventres.levD = 1 lceventres.cacc = v-dacc lceventres.levC = 1.
                        end.
                        else assign lceventres.cacc = string(tarif2.kont) lceventres.levC = 1.
                    end.
                end.
            end.
            if s-type = '2' then do:
                if lookup(s-lcprod,'imlc,sblc') > 0
                then assign lceventres.dacc = if v-lccow = '0' then '185511' else '185512'
                            lceventres.levD = 1
                            lceventres.cacc = v-dacc
                            lceventres.levC = 25.
                else assign lceventres.dacc = '185521'
                            lceventres.levD = 1
                            lceventres.cacc = '285532'
                            lceventres.levC = 1.
            end.
            if s-type = '3' then do:
                assign lceventres.dacc = '186082'
                       lceventres.levD = 1.
                if wrk.num = '9990' then assign lceventres.cacc = '461220' lceventres.levC = 1.
                else do:
                    find first tarif2 where tarif2.str5  = wrk.num and tarif2.stat = 'r' no-lock no-error.
                    if avail tarif2 then assign lceventres.cacc = string(tarif2.kont)
                                                lceventres.levC = 1.
                end.
            end.
            if s-type = '4' then do:
                assign lceventres.dacc = v-arp
                       lceventres.levD = 1.
                if wrk.num = '9990' then assign lceventres.cacc = '461220' lceventres.levC = 1.
                else do:
                    find first tarif2 where tarif2.str5  = wrk.num and tarif2.stat = 'r' no-lock no-error.
                    if avail tarif2 then assign lceventres.cacc = string(tarif2.kont)
                                                lceventres.levC = 1.
                end.
            end.
            if s-type = '5' then do:
                assign lceventres.dacc = v-dacc
                       lceventres.levD = 1
                       lceventres.cacc = if lookup(s-lcprod,'imlc,sblc') = 0  then '185521' else if v-lccow = '0' then '185511' else '185512'
                       lceventres.levC = 1.
            end.

            assign
                lceventres.crc     = wrk.crc
                lceventres.amt     = abs(wrk.amount)
                lceventres.rwho    = g-ofc
                lceventres.rwhn    = g-today
                lceventres.rem     = wrk.rem
                lceventres.info[5] = string(wrk.qty).
            end. /*for each wrk*/
            message "Commissions have been stated!" view-as alert-box.
            find current lceventres no-lock no-error.
            hide frame f_pog no-pause.
            hide frame ft no-pause.

    end.
end. /*on button*/
OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
apply "value-changed" to browse bt.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW or choose of btn-d.