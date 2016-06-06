/* dcpbo2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC, ODC - Payment: проводки по платежу, смена статуса BO1 - BO2
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
        13/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
        28.12.2012 Lyubov - добавила передачу параметров процедуре dcmtpay
*/
{global.i}
{chk-f.i}

def shared var s-lc       like lc.lc.
def shared var v-lcsts    as char.
def shared var s-paysts   like lcpay.sts.
def shared var s-lcpay    like lcpay.lcpay.
def shared var s-lcprod   as char.
def shared var v-lcsumorg as deci.
def shared var v-lcsumcur as deci.
def shared var v-lcdtexp  as date.
def shared var v-lcerrdes as char.
def shared var v-cif      as char.
def shared var v-cifname  as char.

def var v-sum     as deci no-undo.
def var v-sum3    as deci no-undo.
def var v-com     as deci no-undo.
def var v-comi    as deci no-undo.
def var v-crc     as int  no-undo.
def var v-collacc as char no-undo.
def var v-comacc  as char no-undo.
def var v-param   as char no-undo.
def var vdel      as char no-undo initial "^".
def var rcode     as int  no-undo.
def var rdes      as char no-undo.
def new shared var s-jh like jh.jh.
def var v-lccow   as char.

def var v-st        as logi no-undo.
DEF VAR VBANK       AS CHAR no-undo.
def var v-sum2      as deci no-undo.
def var v-yes       as logi no-undo.
def var v-arp       as char no-undo.
def var v-arp_hq    as char no-undo.
def var v-bnkrnn    as char no-undo.
def var v-knp       as char no-undo.
def var v-kbe       as char no-undo.
def var v-filrnn    as char no-undo.
def var v-filname   as char no-undo.
def var v-rmz       like remtrz.remtrz no-undo.
def var v-benacc    as char no-undo.
def var v-rmzcor    as char no-undo.
def var v-benbank   as char no-undo.
def var v-bname     as char no-undo.
def var v-applic    as char no-undo.
def var i           as int  no-undo.
def var k           as int  no-undo.
def var j           as int  no-undo.
def var l           as int  no-undo.
def var m           as int  no-undo.
def var v-logsno    as char no-undo init "no,n,нет,н,1".
def var v-nazn      as char no-undo.
def var v-date      as char no-undo.
def var v-dacc      as char no-undo.
def var v-cacc      as char no-undo.
def var v-levD      as int  no-undo.
def var v-levC      as int  no-undo.
def var v-trx       as char no-undo.
def var v-accnum    as char no-undo.
def var v-comacct   as char no-undo.
def var v-comaccti  as char no-undo.
def var v-bankname  as char no-undo.
def var v-parm      as char no-undo.
def var v-crcc      as char no-undo.
def var v-par       as char no-undo.
def var v-scorr     as char no-undo.
def var v-name      as char no-undo init "Drawer's Account".
def buffer b-lcpayres for lcpayres.
/*def buffer b-crc      for crc.
def buffer b-crchis   for crchis.*/

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.
else do:
    message 'Нет параметра OURBNK в sysc!' view-as alert-box.
    return.
end.

pause 0.
if s-paysts <> 'BO1' and s-paysts <> 'Err' and s-paysts <> 'ErrA' then do:
    message "Letter of DC status should be BO1 or Err!" view-as alert-box.
    return.
end.

message 'Do you want to change Payment status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

if s-paysts = 'ErrA' then do:
    run LCstspay(s-paysts,'BO2').
    find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
    if avail lcpayh then do:
        find current lcpayh exclusive-lock.
        lcpayh.value1 = ''.
        find current lcpayh no-lock no-error.
    end.
    return.
end.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
if avail lcpayh then v-crc = integer(lcpayh.value1).
find first crc where crc.crc = v-crc no-lock no-error.
if avail crc then v-crcc = crc.code.

find first sysc where sysc.sysc = 'LCARP' no-lock no-error.
if avail sysc then do:
    if num-entries(sysc.chval) >= v-crc then v-arp = entry(v-crc,sysc.chval).
    else do:
        message "The value LCARP in SYSC is empty!" view-as alert-box error.
        return.
    end.
end.
if v-arp = '' then do:
    message "The value LCARP in SYSC is empty!" view-as alert-box error.
    return.
end.
find first arp where arp.arp = v-arp no-lock no-error.
if not avail arp then do:
    message "The ARP-account " + v-arp + " was not found!" view-as alert-box error.
    return.
end.
find first sub-cod where sub-cod.acc   = arp.arp
                     and sub-cod.sub   = "arp"
                     and sub-cod.d-cod = "clsa"
                     no-lock no-error.
if avail sub-cod then if sub-cod.ccode ne "msc" then do:
    message "The ARP-account " + v-arp + " is closed!" view-as alert-box error.
    return.
end.

find first pksysc where pksysc.sysc = 'ILCARP' no-lock no-error.
if avail pksysc then do:
    if num-entries(pksysc.chval) >= v-crc then v-arp_hq = entry(v-crc,pksysc.chval).
    else do:
        message "The value ILCARP in pksysc is empty!" view-as alert-box error.
        return.
    end.
end.
if v-arp_hq = '' then do:
    message "The value ILCARP in pksysc is empty!" view-as alert-box error.
    return.
end.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'SCor202' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Correspondent Bank is empty!" view-as alert-box error.
    return.
end.
v-scorr = lcpayh.value1.

if s-lcprod = 'idc' then v-name = 'Document Account'.
find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CollAcc' no-lock no-error.
if avail lcpayh then v-collacc = lcpayh.value1.
if v-collacc = '' then do:
    message "Field " + v-name + " is empty!" view-as alert-box.
    return.
end.
find first aaa where aaa.aaa = v-collacc no-lock no-error.
if not avail aaa then do:
    message "The CIF-account " + v-collacc + " was not found!" view-as alert-box error.
    return.
end.
find first sub-cod where sub-cod.acc   = aaa.aaa
                     and sub-cod.sub   = "cif"
                     and sub-cod.d-cod = "clsa"
                     no-lock no-error.
if avail sub-cod then if sub-cod.ccode ne "msc" then do:
    message "The CIF-account " + v-collacc + " is closed!" view-as alert-box error.
    return.
end.
if s-lcprod = 'idc' then do:
    run lonbalcrc('cif',aaa.aaa,g-today,'1',yes,aaa.crc, output v-sum3).
    v-sum3 = v-sum3 * (-1).
    if v-sum > v-sum3 then do:
        message "Lack of the balance of the " + v-name + "!" view-as alert-box.
        return.
    end.
end.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
if avail lcpayh and lcpayh.value1 <> '' then assign v-sum = deci(lcpayh.value1).

if v-sum <= 0 then do:
    message "Payment Amount must be > 0!" view-as alert-box error.
    return.
end.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'Number' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Number is empty!" view-as alert-box error.
    return.
end.
v-sum2 = deci(lcpayh.value1).

find first pksysc where pksysc.sysc = s-lcprod + '_acc' no-lock no-error.
if not avail pksysc then do:
    message "The value " + s-lcprod + "_acc in the table pksysc is empty!" view-as alert-box error.
    return.
end.
v-par = pksysc.chval.
if num-entries(v-par) <> 4 then do:
    message "Uncorrect structure of parameter " + s-lcprod + "_acc in the table pksysc!" view-as alert-box error.
    return.
end.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtE' no-lock no-error.
if avail lcpayh then if lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).

if v-com > 0 then do:
    find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAccT' no-lock no-error.
    if avail lcpayh then if lcpayh.value1 ne '' then v-comacct = lcpayh.value1.
    if v-comacct = '' then do:
        message "Field Commission Account Type(amt excl.VAT) is empty!" view-as alert-box error.
        return.
    end.
end.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtI' no-lock no-error.
if avail lcpayh then if lcpayh.value1 ne '' then v-comi = deci(lcpayh.value1).

if v-comi > 0 then do:
    find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAccTI' no-lock no-error.
    if avail lcpayh then if lcpayh.value1 ne '' then v-comaccti = lcpayh.value1.
    if v-comaccti = '' then do:
        message "Field Commission Account Type(amt incl.VAT) is empty!" view-as alert-box error.
        return.
    end.
end.

if can-find(first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode ne '9990' no-lock)
  then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
    if avail lch then v-comacc = lch.value1.
    else do:
        if v-comacc = '' then do:
            message "Field Commissions Account is empty!" view-as alert-box.
            return.
        end.
    end.
end.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'KBE' no-lock no-error.
if avail lcpayh and lcpayh.value1 <> '' then v-kbe = lcpayh.value1.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'KNP' no-lock no-error.
if avail lcpayh and lcpayh.value1 <> '' then v-knp = lcpayh.value1.

/*********POSTINGS**********/
s-jh = 0. i = 1.

if s-lcprod = 'idc' then do:
    /*1-st posting + transfer to CO */
    assign v-dacc = v-collacc
           v-cacc = v-arp
           v-levD = 1
           v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + v-knp
           v-trx   = "uni0113".
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = v-levD and lcpayres.dacc = v-dacc no-lock no-error.
    if avail lcpayres then do:
        message "Attention! The posting (" + v-dacc + " - " + v-cacc + ") was done earlier!" view-as alert-box info.
    end.
    else do:
        run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            message "The posting (" + v-dacc + " - " + v-cacc + ") was not done!" view-as alert-box error.
            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
            if avail lcpayh then find current lcpayh exclusive-lock.
            if not avail lcpayh then create lcpayh.
            assign lcpayh.lc       = s-lc
                   lcpayh.lcpay    = s-lcpay
                   lcpayh.bank     = vbank
                   lcpayh.kritcode = 'ErrDes'
                   lcpayh.value1   = string(rcode) + ' ' + rdes.
            run LCstspay('BO1','Err').
            return.
        end.
    end.

    if s-jh > 0 then do:
        /*создаем перевод в ЦО*/
        if v-crc > 1 then do:
            find first sysc where sysc.sysc = 'bankname' no-lock no-error.
            if avail sysc then v-bankname = sysc.chval.

            find first txb where txb.bank = 'TXB00' and txb.consolid no-lock no-error.
            if avail txb then v-bnkrnn = entry(1,txb.params).

            find first cmp no-lock no-error.
            if avail cmp then assign v-filrnn = cmp.addr[2] v-filname = cmp.name.

            run rmzcre (s-lcpay,
            v-sum - v-com - v-comi,
            v-arp,
            v-filrnn,
            v-filname,
            'TXB00',
            v-arp_hq,
            'АО ' + v-bankname,
            v-bnkrnn,
            '0',
             no,
             v-knp,
            '14',
            v-kbe,
            v-nazn ,
            '1P',
            0,
            5,
            g-today) .
            v-rmz = return-value.
        end.
        if v-rmz <> '' then do:
            find first remtrz where remtrz.remtrz = v-rmz exclusive-lock no-error.
            if avail remtrz then do:
                remtrz.rsub = 'arp'.
                find current remtrz no-lock no-error.
            end.
        end.
        create lcpayres.
        assign lcpayres.lc      = s-lc
               lcpayres.lcpay   = s-lcpay
               lcpayres.levD    = v-levD
               lcpayres.dacc    = v-dacc
               lcpayres.levC    = 1
               lcpayres.cacc    = v-cacc
               lcpayres.trx     = v-trx
               lcpayres.rem     = v-nazn
               lcpayres.amt     = v-sum
               lcpayres.crc     = v-crc
               lcpayres.com     = no
               lcpayres.comcode = ''
               lcpayres.rwho    = g-ofc
               lcpayres.rwhn    = g-today
               lcpayres.jh      = s-jh
               lcpayres.jdt     = g-today
               lcpayres.bank    = VBANK.
        if v-rmz <> '' then do:
            assign lcpayres.rem     = lcpayres.rem  + ' (перевод в ЦО ' + v-rmz + ')'
                   lcpayres.info[1] = v-rmz.
            for each jl where jl.jh = s-jh exclusive-lock:
                jl.rem[1] = jl.rem[1] + ' (перевод в ЦО ' + v-rmz + ')'.
            end.
        end.
        message "The posting (" + v-dacc + " - " + v-cacc + ") was done!" view-as alert-box info.
    end. /*s-jh > 0 */

    if v-com > 0 then do:
        /* the first commission posting */
        assign s-jh = 0
               v-dacc = v-arp
               v-cacc = v-comacct
               v-param = if v-crc = 1 or not v-cacc begins '4' then string(v-com) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + 'Оплата комиссии ' + s-lc
                                      else string(v-com) + vdel + string(v-crc) + vdel + v-dacc + vdel + 'Оплата комиссии ' + s-lc + vdel + '1' + vdel + v-cacc
               v-trx   = if v-crc = 1 or not v-cacc begins '4' then 'vnb0001' else 'vnb0060'.
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode = '9990' and lcpayres.levC = 1 and lcpayres.cacc = v-cacc no-lock no-error.
        if avail lcpayres then do:
            message "Attention! The posting for commission (" + v-dacc + " - " + v-cacc + ") was done earlier!" view-as alert-box info.
        end.
        else do:
            run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                message "The posting for commission (" + v-dacc + " - " + v-cacc + ") was not done!" view-as alert-box error.
                find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
                if avail lcpayh then find current lcpayh exclusive-lock.
                if not avail lcpayh then create lcpayh.
                assign lcpayh.lc       = s-lc
                       lcpayh.lcpay    = s-lcpay
                       lcpayh.bank     = vbank
                       lcpayh.kritcode = 'ErrDes'
                       lcpayh.value1   = string(rcode) + ' ' + rdes.
                run LCstspay('BO1','Err').
                return.
            end.
            create lcpayres.
            assign lcpayres.lc      = s-lc
                   lcpayres.lcpay   = s-lcpay
                   lcpayres.levD    = 1
                   lcpayres.dacc    = v-dacc
                   lcpayres.levC    = 1
                   lcpayres.cacc    = v-cacc
                   lcpayres.trx     = v-trx
                   lcpayres.rem     = 'Оплата комиссии ' + s-lc
                   lcpayres.amt     = v-com
                   lcpayres.crc     = v-crc
                   lcpayres.com     = yes
                   lcpayres.comcode = '9990'
                   lcpayres.rwho    = g-ofc
                   lcpayres.rwhn    = g-today
                   lcpayres.jh      = s-jh
                   lcpayres.jdt     = g-today
                   lcpayres.bank    = VBANK.

            message "The posting for commission (" + v-dacc + " - " + v-cacc + ") was done!" view-as alert-box info.
        end.
    end.
    if v-comi > 0 then do:
        /* the 2-nd commission posting */
        assign s-jh = 0
               v-dacc = v-arp
               v-cacc = v-comaccti
               v-param = if v-crc = 1 or not v-cacc begins '4' then string(v-comi) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + 'Оплата комиссии ' + s-lc
                                      else string(v-comi) + vdel + string(v-crc) + vdel + v-dacc + vdel + 'Оплата комиссии ' + s-lc + vdel + '1' + vdel + v-cacc
               v-trx   = if v-crc = 1 or not v-cacc begins '4' then 'vnb0001' else 'vnb0060'.
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode = '9990' and lcpayres.levC = 1 and lcpayres.cacc = v-cacc no-lock no-error.
        if avail lcpayres then do:
            message "Attention! The posting for commission (" + v-dacc + " - " + v-cacc + ") was done earlier!" view-as alert-box info.
        end.
        else do:
            run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                message "The posting for commission (" + v-dacc + " - " + v-cacc + ") was not done!" view-as alert-box error.
                find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
                if avail lcpayh then find current lcpayh exclusive-lock.
                if not avail lcpayh then create lcpayh.
                assign lcpayh.lc       = s-lc
                       lcpayh.lcpay    = s-lcpay
                       lcpayh.bank     = vbank
                       lcpayh.kritcode = 'ErrDes'
                       lcpayh.value1   = string(rcode) + ' ' + rdes.
                run LCstspay('BO1','Err').
                return.
            end.
            create lcpayres.
            assign lcpayres.lc      = s-lc
                   lcpayres.lcpay   = s-lcpay
                   lcpayres.levD    = 1
                   lcpayres.dacc    = v-dacc
                   lcpayres.levC    = 1
                   lcpayres.cacc    = v-cacc
                   lcpayres.trx     = v-trx
                   lcpayres.rem     = 'Оплата комиссии ' + s-lc
                   lcpayres.amt     = v-comi
                   lcpayres.crc     = v-crc
                   lcpayres.com     = yes
                   lcpayres.comcode = '9990'
                   lcpayres.rwho    = g-ofc
                   lcpayres.rwhn    = g-today
                   lcpayres.jh      = s-jh
                   lcpayres.jdt     = g-today
                   lcpayres.bank    = VBANK.

            message "The posting for commission (" + v-dacc + " - " + v-cacc + ") was done!" view-as alert-box info.
        end.
    end.
end. /*if s-lcprod = 'idc' */

/* Commission postings from charges */
for each lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode ne '9990' and lcpayres.jh = 0 no-lock:
    if lcpayres.amt = 0 then next.
    find first tarif2 where tarif2.str5 = lcpayres.comcode and tarif2.stat = 'r' no-lock no-error.
    if not avail tarif2 then return.
    assign v-param = string(lcpayres.amt) + vdel + string(lcpayres.crc) + vdel + v-comacc + vdel + string(tarif2.kont) + vdel + s-lc + ' ' + lcpayres.rem + vdel + '1' + vdel + '4' + vdel + '840'
           v-trx   = 'cif0015'
           s-jh    = 0.
    run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
       message rdes.
       pause.
       message "The commission posting (" + lcpayres.comcode + ") was not done!" view-as alert-box error.
       find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
       if avail lcpayh then find current lcpayh exclusive-lock.
       if not avail lcpayh then create lcpayh.
       assign lcpayh.lc       = s-lc
              lcpayh.lcpay    = s-lcpay
              lcpayh.bank     = vbank
              lcpayh.kritcode = 'ErrDes'
              lcpayh.value1   = string(rcode) + ' ' + rdes.
       run LCstspay('BO1','Err').
       return.
    end.

    if s-jh > 0 then do:
        find first b-lcpayres where rowid(b-lcpayres) = rowid(lcpayres) exclusive-lock no-error.
        if avail b-lcpayres then
        assign b-lcpayres.rwho   = g-ofc
               b-lcpayres.rwhn   = g-today
               b-lcpayres.jh     = s-jh
               b-lcpayres.jdt    = g-today
               b-lcpayres.trx    = v-trx.
        v-st = yes.

        find current b-lcpayres no-lock no-error.
    end.
    message "The commission posting (" + lcpayres.comcode + ") was done!" view-as alert-box info.
end.

/*  */
if v-sum2 > 0 then do:
    v-nazn = 'Списание отправленных на инкассо документов по ' + s-lc.
    do m = 1 to 4 by 2:
       find first gl where gl.gl = int(entry(m,v-par)) no-lock no-error.
        if not avail gl then do:
            message "Uncorrect account GL " + entry(m,v-par) + " (parameter " + s-lcprod + "_acc in the table pksysc)!" view-as alert-box error.
            return.
        end.
        if gl.sub = '' then do:
            if m = 1 then assign v-dacc = string(gl.gl)
                                 v-trx  = 'gl,'.
                     else assign v-cacc = string(gl.gl)
                                 v-trx  = v-trx + 'gl'.
        end.
        else if gl.sub = 'arp' then do:
            if m = 1 then assign v-dacc = entry(m + 1,v-par)
                                 v-trx  = 'arp,'.
                     else assign v-cacc = entry(m + 1,v-par)
                                 v-trx  = v-trx + 'arp'.
        end.
    end.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
    if not avail lcpayres then do:
        if v-trx = 'gl,gl' then assign v-trx   = 'uni0144'
                                       v-param = string(v-sum2) + vdel + '1' + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn.
        else if v-trx = 'gl,arp' then assign v-trx   = 'uni0004'
                                             v-param = string(v-sum2) + vdel + '1' + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp.
        else do:
            message "Attention! Unknown transaction " + v-trx + "!" view-as alert-box error.
            return.
        end.
        v-parm = v-trx + ';' + v-param.
        create lcpayres.
        assign lcpayres.lc      = s-lc
               lcpayres.lcpay   = s-lcpay
               lcpayres.levD    = 1
               lcpayres.dacc    = v-dacc
               lcpayres.levC    = 1
               lcpayres.cacc    = v-cacc
               lcpayres.trx     = v-trx
               lcpayres.rem     = v-nazn
               lcpayres.amt     = v-sum2
               lcpayres.crc     = 1
               lcpayres.com     = no
               lcpayres.comcode = ''
               lcpayres.rwho    = g-ofc
               lcpayres.rwhn    = g-today
               lcpayres.bank    = 'TXB00'.
    end.
end.
/* подготовка к списанию с коррсчета в ЦО, само списание в процедуре ELX_ps.p, там же проводки по списанию документов с внебаланса */
/* для ODC перевод в филиал там же в процедуре ELX_ps.p, в филиале перевод денег на счет клиента в процедуре LCPAY_ps.p */
find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'Scor202' no-lock no-error.
if avail lcpayh and lcpayh.value1 <> '' then do:
    find first LCswtacc where LCswtacc.accout = lcpayh.value1 and LCswtacc.crc = v-crc no-lock no-error.
    if avail LCswtacc then v-dacc = LCswtacc.acc.
end.
if v-dacc = '' then do:
    message 'Неопределен коррсчет'.
    pause.
    find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
    if avail lcpayh then find current lcpayh exclusive-lock.
    else create lcpayh.
    assign lcpayh.lc       = s-lc
           lcpayh.lcpay    = s-lcpay
           lcpayh.bank     = vbank
           lcpayh.kritcode = 'ErrDes'
           lcpayh.value1   = 'Неопределен коррсчет'.
    run LCstspay('BO1','Err').
    return.
end.
if s-lcprod = 'odc' then do:
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc  no-lock no-error.
    if not avail lcpayres then do:
        create lcpayres.
        assign lcpayres.lc      = s-lc
               lcpayres.lcpay   = s-lcpay
               lcpayres.levD    = 1
               lcpayres.dacc    = if s-lcprod = 'odc' then v-dacc else v-arp_hq
               lcpayres.levC    = 1
               lcpayres.cacc    = if s-lcprod = 'odc' then v-arp_hq else v-dacc
               lcpayres.rem     = 'Оплата по документарному инкассо ' + s-lc
               lcpayres.amt     = v-sum - v-com - v-comi
               lcpayres.crc     = v-crc
               lcpayres.com     = no
               lcpayres.comcode = ''
               lcpayres.rwho    = g-ofc
               lcpayres.rwhn    = g-today
               lcpayres.bank    = 'TXB00'.
        find first cmp no-lock no-error.
        if avail cmp then assign v-filrnn = cmp.addr[2] v-filname = cmp.name.
        create clsdp.
        assign clsdp.aaa = v-dacc
               clsdp.txb = 'TXB00'
               clsdp.sts = '18'
               clsdp.rem = s-lc
               clsdp.prm = string(s-lcpay) + vdel + v-arp + vdel + v-filrnn + vdel + v-filname + ';' + v-parm.
    end.
end.
else do:
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-collacc no-lock no-error.
    if avail lcpayres and lcpayres.info[3] = '' then do:
        v-param = string(v-sum - v-com - v-comi) + vdel + v-arp_hq + vdel + v-dacc + vdel + 'Оплата по документарному инкассо ' + s-lc.
        find first clsdp where clsdp.aaa = v-arp_hq and clsdp.txb = 'TXB00' and clsdp.sts = '12' and clsdp.rem = lcpayres.info[1] no-lock no-error.
        if not avail clsdp then do:
            create clsdp.
            assign clsdp.aaa = v-arp_hq
               clsdp.txb = 'TXB00'
               clsdp.sts = '12'
               clsdp.rem = v-rmz
               clsdp.prm = v-param + ';' + v-parm.
        end.
    end.
end.

if s-lcprod = 'IDC' then do:
    v-yes = no.
    find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT400' no-lock no-error.
    if avail lcpayh and lookup(lcpayh.value1,v-logsno) = 0 then v-yes = yes.
    if v-yes then do:
        if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
            message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
                if avail lcpayh then find current lcpayh exclusive-lock.
                else create lcpayh.
                assign lcpayh.value1   = "There is no file $HOME/.ssh/id_swift!"
                       lcpayh.lc       = s-lc
                       lcpayh.lcpay    = s-lcpay
                       lcpayh.kritcode = 'ErrDes'
                       lcpayh.bank     = vbank.
                run LCstspay(s-paysts,'Err').
                return.
        end.
        run dcmtpay('400',yes).
        if error-status:error then do:
            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
            if avail lcpayh then find current lcpayh exclusive-lock.
            else create lcpayh.
            assign lcpayh.value1   = "File wasn't copied to SWIFT Alliance!"
                   lcpayh.lc       = s-lc
                   lcpayh.lcpay    = s-lcpay
                   lcpayh.kritcode = 'ErrDes'
                   lcpayh.bank     = vbank.
            run LCstspay(s-paysts,'Err').
            v-lcerrdes = "File wasn't copied to SWIFT Alliance!".
            return.
        end.
    end.
end.
if s-paysts = 'ERR' then do:
    find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
    if avail lcpayh then do:
        find current lcpayh exclusive-lock.
        lcpayh.value1 = ''.
        find current lcpayh no-lock no-error.
    end.
end.
run LCstspay(s-paysts,'BO2').

