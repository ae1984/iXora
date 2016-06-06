/*lcbo2pf.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        IMLC: Post Finance Details - BO2
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-1-13 опция BO2
 * AUTHOR
        28/10/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
 */

{global.i}

def shared var s-lc       like lc.lc.
def shared var s-event    like lcevent.event.
def shared var s-number   like lcevent.number.
def shared var s-sts      like lcevent.sts.
def shared var s-lcprod   as char.
def shared var s-ourbank  as char no-undo.

def var v-sum    as deci no-undo.
def var v-crc    as int  no-undo.
def var v-acc    as char no-undo.
def var v-comacc as char no-undo.

def var v-param  as char no-undo.
def var vdel     as char no-undo initial "^".
def var rcode    as int  no-undo.
def var rdes     as char no-undo.
def var v-yes    as logi no-undo.

def new shared var s-jh like jh.jh.

/*def var v-lccow as char.*/

/*def var v-st as logi.
DEF VAR VBANK AS CHAR.

def var v-sum2 as decimal.
def var v-yes as logi init yes.

def var v-arp as char.
def var v-arp_hq as char.
def var v-bnkrnn as char.
def var v-bnkname as char.
def var v-kod as char.
def var v-knp as char.
def var v-kbe as char.
def var v-filrnn as char.
def var v-filname as char.
def var v-rmz  like remtrz.remtrz no-undo.
def var v-benacc as char.*/
/*def var v-avlbnk as int.*/
/*def var v-rmzcor as char.
def var v-benbank as char.
def var v-bname as char.
def var v-str as char.
def var v-sp  as char.
def var v-applic  as char.*/
def var v-bankf as char.
def var i as int.
def var k as int.
/*def var v-opt     as char.
def var v-crcc    as char.
def var v-scorr   as char.

def var v-logsno as char init "no,n,нет,н,1".*/
def var v-nazn    as char.
/*def var v-date    as char.*/
def var v-dacc    as char.
def var v-cacc    as char.
/*def var v-levD    as int.
def var v-levC    as int.*/
def var v-trx     as char.
/*def var v-acctype as char.
def var v-accnum  as char.
def var v-text    as char.
def var v-maillist as char extent 2.
def shared var v-lcsumorg as deci.
def shared var v-lcsumcur as deci.
def shared var v-lcdtexp  as date.
*/
/*FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.
else do:
    message 'Нет параметра OURBNK в sysc!' view-as alert-box.
    return.
end.*/

pause 0.
if s-sts <> 'BO1' and s-sts <> 'Err' then do:
    message "Letter of credit's status should be BO1 or Err!" view-as alert-box.
    return.
end.

message 'Do you want to change Payment status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.


find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.
v-bankf = lc.bank.

find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
if avail lch then v-crc = int(lch.value1).

find first lch where lch.lc = s-lc and lch.kritcode = 'AccPay' no-lock no-error.
if not avail lch or (avail lch and lch.value1 = '') then do:
   message 'There is no deal for ' + s-lc + '!' view-as alert-box error.
   return.
end.
v-acc = lch.value1.

find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
if avail lch then v-comacc = lch.value1.
if v-comacc = '' then do:
    message "Field Commissions Debit Account is empty!" view-as alert-box.
    return.
end.

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'FinAmt' no-lock no-error.
if not avail lceventh or lceventh.value1 = '' then do:
    message "Field Financing Amount is empty!" view-as alert-box error.
    return.
end.
v-sum = deci(lceventh.value1).

/*********POSTINGS**********/
s-jh = 0. i = 1.
/*1-st posting*/
assign v-nazn  = 'Оплата основного долга по ' + s-lc
       v-dacc  = '185512'
       v-cacc  = v-acc
       v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn
       v-trx   = 'uni0208'.

find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.

if avail lceventres then do:
    message "Attention! The 1-st posting was done earlier!" view-as alert-box info.
end.
else do:
    run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message rdes.
        pause.
        message "The 1-st posting was not done!" view-as alert-box error.
        find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
        if avail lceventh then find current lceventh exclusive-lock.
        if not avail lceventh then create lceventh.
        assign lceventh.lc       = s-lc
               lceventh.event    = s-event
               lceventh.number   = s-number
               lceventh.bank     = s-ourbank
               lceventh.kritcode = 'ErrDes'
               lceventh.value1   = string(rcode) + ' ' + rdes.
        run lcstse('BO1','Err').
        return.
    end.
end.

if s-jh > 0 then do:
    create lceventres.
    assign lceventres.lc      = s-lc
           lceventres.event   = s-event
           lceventres.number  = s-number
           lceventres.levD    = 1
           lceventres.dacc    = v-dacc
           lceventres.levC    = 1
           lceventres.cacc    = v-cacc
           lceventres.trx     = v-trx
           lceventres.rem     = v-nazn
           lceventres.amt     = v-sum
           lceventres.crc     = v-crc
           lceventres.com     = no
           lceventres.comcode = ''
           lceventres.rwho    = g-ofc
           lceventres.rwhn    = g-today
           lceventres.jh      = s-jh
           lceventres.jdt     = g-today
           lceventres.bank    = s-ourbank.

    message "The 1-st posting was done!" view-as alert-box info.
end. /*s-jh > 0 */

/* заполнение lceventres для 2-го постинга, проводки в процедуре ELX_ps.p */
assign v-dacc = '650510'
       v-cacc = v-comacc
       v-nazn = 'Требования/обязательства по ' + s-lc.
 find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.
 if not avail lceventres then create lceventres.
 find current lceventres exclusive-lock.
 assign lceventres.lc      = s-lc
        lceventres.event   = s-event
        lceventres.number  = s-number
        lceventres.levD    = 1
        lceventres.dacc    = v-dacc
        lceventres.levC    = 24
        lceventres.cacc    = v-cacc
        lceventres.rem     = v-nazn
        lceventres.amt     = v-sum
        lceventres.crc     = v-crc
        lceventres.com     = no
        lceventres.comcode = ''
        lceventres.rwho    = g-ofc
        lceventres.rwhn    = g-today
        lceventres.bank    = v-bankf.
 find current lceventres no-lock.

 create clsdp.
 assign clsdp.aaa = v-cacc
        clsdp.txb = v-bankf
        clsdp.sts = '16'
        clsdp.rem = s-lc
        clsdp.prm = string(s-number).

run lcstse(s-sts,'BO2').
if s-sts = 'ERR' then do:
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
    if avail lceventh then do:
        find current lceventh exclusive-lock.
        lceventh.value1 = ''.
        find current lceventh no-lock no-error.
    end.
end.
