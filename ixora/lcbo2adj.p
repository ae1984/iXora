/*lcbo2adj.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Adjust - проводки, акцепт 2-го менеджера бэк-офиса
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
        14/07/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        19/08/2011 id00810 - использование реквизита ArpAcc (lceventh)
        13/09/2011 id00810 - обработка ошибки копирования в SWIFT
        14/12/2011 id00810 - для случая crc = 1
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        06/06/2012 Lyubov  - изменения по ТЗ, при создании проводки добавлена разбивка по типам счетов AccType
        27.06.2012 Lyubov  - исправлены ошибки.
        06.08.2012 Lyubov  - для 5го типа уровень счета по дебету = 22
*/
{global.i}
{chk-f.i}
{nbankBik.i}
def shared var s-lc       like lc.lc.
def shared var v-lcerrdes as   char.
def shared var s-event    like lcevent.event.
def shared var s-number   like lcevent.number.
def shared var s-sts      like lcevent.sts.
def shared var s-lcprod   as char.

def var v-sum     as deci no-undo.
def var v-crc     as int  no-undo.
def var v-collacc as char no-undo.
def var v-comacc  as char no-undo.

def var v-param as char no-undo.
def var vdel    as char no-undo initial "^".
def var rcode   as int  no-undo.
def var rdes    as char no-undo.
def var v-lccow as char no-undo.
def new shared var s-jh like jh.jh.

def var v-st  as logi no-undo.
DEF VAR VBANK AS CHAR no-undo.

def var v-sum2 as deci no-undo.
def var v-yes  as logi no-undo.

def var v-arp     as char.
def var v-arp_hq  as char.
def var v-bnkrnn  as char.
def var v-bnkname as char.
def var v-kod     as char.
def var v-knp     as char.
def var v-kbe     as char.
def var v-filrnn  as char.
def var v-filname as char.
def var v-rmz     like remtrz.remtrz no-undo.
def var v-benacc  as char.
/*def var v-avlbnk as int.*/
def var v-rmzcor  as char.
def var v-benbank as char.
def var v-bname   as char.
def var v-str     as char.
def var v-sp      as char.
def var v-applic  as char.
def var v-bankf   as char.
def var i         as int.
def var k         as int.
def var v-opt     as char.
def var v-crcc    as char.
def var v-scorr   as char.

def var v-logsno as char init "no,n,нет,н,1".
def var v-nazn    as char.
def var v-date    as char.
def var v-dacc    as char.
def var v-cacc    as char.
def var v-levD    as int.
def var v-levC    as int.
def var v-trx     as char.
def var v-acctype as char.
def var v-accnum  as char.
def var v-text    as char.
def var v-maillist as char extent 2.
def shared var v-lcsumorg as deci.
def shared var v-lcsumcur as deci.
def shared var v-lcdtexp  as date.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.
else do:
    message 'Нет параметра OURBNK в sysc!' view-as alert-box.
    return.
end.

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'Opt' no-lock no-error.
if not avail lceventh or lceventh.value1 = '' then return.
v-opt = lceventh.value1.
if v-opt = 'yes' and vbank = 'TXB00' then do:
    message 'The status BO2 for Adjust/Cover Transfer can be given only in Filial!' view-as alert-box error.
    return.
 end.
if v-opt = 'no' and vbank <> 'TXB00' then do:
   message 'The status BO2 for Adjust/Maintain Charges can be given only in Central Office!' view-as alert-box error.
   return.
end.

pause 0.
if s-sts <> 'BO1' and s-sts <> 'Err' then do:
    message "Letter of credit's status should be BO1 or Err!" view-as alert-box.
    return.
end.

message 'Do you want to change Payment status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.
if v-opt = 'no' then v-bankf = lc.bank.

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'CurCode' no-lock no-error.
if not avail lceventh or lceventh.value1 = '' then do:
    message "Field Currency Code is empty!" view-as alert-box error.
    return.
end.
v-crc = integer(lceventh.value1).

find first crc where crc.crc = v-crc no-lock no-error.
if avail crc then v-crcc = crc.code.

if v-opt = 'yes' then do:
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
end.
else do:
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ArpAcc' no-lock no-error.
    if avail lceventh then v-arp = lceventh.value1.
    if v-arp = '' then do:
        message "Field ARP Account is empty!" view-as alert-box error.
        return.
    end.
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

/*if v-crc > 1 then do:*/
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'SCor202' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message "Field Sender's Correspondent (MT 202) is empty!" view-as alert-box error.
        return.
    end.
    v-scorr = lceventh.value1.
/*end.*/

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'PAmt' no-lock no-error.
if not avail lceventh or lceventh.value1 = '' then do:
    message "Field Payment Amount is empty!" view-as alert-box error.
    return.
end.
v-sum = deci(lceventh.value1).

if v-opt = 'yes' then do:
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'AccType' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message "Field Account Type is empty!" view-as alert-box error.
        return.
    end.
    v-acctype = lceventh.value1.

    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'AccNum' no-lock no-error.
    if not avail lceventh or lceventh.value1 = '' then do:
        message "Field Account Number is empty!" view-as alert-box error.
        return.
    end.
    v-accnum = lceventh.value1.
end.


find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'KOD' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-kod = lceventh.value1.

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'KBE' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-kbe = lceventh.value1.

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'KNP' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-knp = lceventh.value1.


/*********POSTINGS**********/
if v-opt = 'yes' then assign v-nazn  = 'Перевод покрытия по ' + s-lc
                             /*v-bank1 = s-ourbank
                             v-bank2 = 'TXB00'*/.
else do:
    assign v-nazn  = 'Расчеты по ' + s-lc.
           /*v-bank1 = 'TXB00'*/ .
    /*find first lc where lc.lc = s-lc no-lock no-error.
    if avail lc then v-bank2 = lc.bank.*/
end.

s-jh = 0. i = 1.

/*1-st posting*/
if v-opt = 'yes' then do:
    assign v-dacc  = v-accnum
           v-cacc  = v-arp.
    if lookup(v-acctype, '8,9,12') > 0 then do:
    v-levD = 1.
    v-levC = 1.
        v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + substr(v-kod,1,1) + vdel + substr(v-kod,2,1) + vdel + v-knp.
        v-trx = 'uni0004'.
    end.
    else if v-acctype = '5' then do:
    v-levD = 22.
    v-levC = 1.
       v-param = string(v-sum) + vdel + string(v-crc) + vdel + '22' + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + v-knp.
       v-trx   = 'uni0118'.
    end.

end.
else do:
    v-levD = 1.
    v-levC = 1.
    if v-crc > 1 then do:
        find first LCswtacc where LCswtacc.accout = v-scorr and LCswtacc.crc = v-crc no-lock no-error.
        if avail LCswtacc then assign v-dacc  = LCswtacc.acc
                                      v-cacc  = v-arp_hq
                                      v-knp   = if s-lcprod = 'pg' then '182' else '181'
                                      v-param = string(v-sum) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + '2' + vdel + '4' + vdel + v-knp
                                      v-trx   = "uni0017".
    end.
    else assign v-dacc  = v-scorr
                v-cacc  = v-arp_hq
                v-param = string(v-sum) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + ''
                v-trx   = "vnb0010".
end.
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
               lceventh.bank     = vbank
               lceventh.kritcode = 'ErrDes'
               lceventh.value1   = string(rcode) + ' ' + rdes.
        run lcstse('BO1','Err').
        return.
    end.
end.

if s-jh > 0 then do:
    if v-opt = 'yes' then do:
        /*создаем перевод в ЦО*/
        if v-crc > 1 then do:
            find first txb where txb.bank = 'TXB00' and txb.consolid no-lock no-error.
            if avail txb then v-bnkrnn = entry(1,txb.params).

            find first cmp no-lock no-error.
            if avail cmp then assign v-filrnn = cmp.addr[2] v-filname = cmp.name.

            run rmzcre (s-number,
            v-sum,
            v-arp,
            v-filrnn, /*чей РНН*/
            v-filname,
            'TXB00',
            v-arp_hq,
            v-nbankru,
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
        else do:
            find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'BenAcc' no-lock no-error.
            if avail lceventh and lceventh.value1 <> '' then v-benacc = lceventh.value1.

            find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'BenIns' no-lock no-error.
            if avail lceventh and lceventh.value1 <> '' then v-benbank = lceventh.value1.

            find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'BenPay' no-lock no-error.
            if avail lceventh and lceventh.value1 <> '' then v-bname = lceventh.value1.

            find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'BenRNN' no-lock no-error.
            if avail lceventh and lceventh.value1 <> '' then v-bnkrnn = lceventh.value1.

            find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
            if avail lch and lch.value1 <> '' then v-applic = lch.value1.

            find first cmp no-lock no-error.
            if avail cmp then assign v-filrnn = cmp.addr[2] v-filname = cmp.name.

            run rmzcre (s-number,
            v-sum,
            v-arp,
            v-filrnn, /*чей РНН*/
            v-filname,
            v-benbank, /*банк-получатель*/
            v-benacc, /*корр счет */
            v-bname,
            v-bnkrnn, /*где брать*/
            '0',
             no,
             v-knp,
            '14',
            v-kbe,
            v-nazn + '. Аппликант ' + v-applic,
            '1P',
            0,
            2,
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
        v-text = ' (перевод в ЦО '.
    end.
    else do:
        /*создаем перевод в филиал*/
       find first txb where txb.bank = v-bankf no-lock no-error.
       if not avail txb then return.

       if connected ("txb") then disconnect "txb".
       connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
          find first cmp no-lock no-error.
          if avail cmp then assign v-filrnn = cmp.addr[2] v-filname = cmp.name.
       if connected ("txb") then disconnect "txb".

            /*find first txb where txb.bank = 'TXB00' and txb.consolid no-lock no-error.
            if avail txb then v-bnkrnn = entry(1,txb.params).
            */
            find first cmp no-lock no-error.
            if avail cmp then assign v-bnkrnn = cmp.addr[2] v-bnkname = cmp.name.

            run rmzcre (s-number,
            v-sum,
            v-arp_hq,
            v-bnkrnn,
            v-bnkname,
            v-bankf,
            v-arp,
            v-filname,
            v-filrnn,
            '0',
             no,
             v-knp,
            '14',
            '14',
            v-nazn ,
            '1P',
            0,
            5,
            g-today) .
            v-rmz = return-value.
            if v-rmz <> '' then do:
                find first remtrz where remtrz.remtrz = v-rmz exclusive-lock no-error.
                if avail remtrz then do:
                    remtrz.rsub = 'arp'.
                    find current remtrz no-lock no-error.
                end.
            end.
            v-text = ' (перевод в филиал '.
    end.

    create lceventres.
    assign lceventres.lc      = s-lc
           lceventres.event   = s-event
           lceventres.number  = s-number
           lceventres.levD    = v-levD
           lceventres.dacc    = v-dacc
           lceventres.levC    = v-levC
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
           lceventres.bank    = VBANK.
    if v-rmz <> '' then do:
        assign lceventres.rem     = lceventres.rem  + v-text +  v-rmz + ')'
               lceventres.info[1] = v-rmz.
        for each jl where jl.jh = s-jh exclusive-lock:
            jl.rem[1] = jl.rem[1] + v-text  + v-rmz + ')'.
        end.
    end.
    message "The 1-st posting was done!" view-as alert-box info.
end. /*s-jh > 0 */

/* для v-opt = 'yes' подготовка к списанию с коррсчета в ЦО, само списание в процедуре ELX_ps.p,
   для v-opt = 'no' заполнение lceventres, проводки в процедуре ELX_ps.p */

 if v-opt = 'yes' and  v-crc > 1 then do:
    find first LCswtacc where LCswtacc.accout = v-scorr and LCswtacc.crc = v-crc no-lock no-error.
     if avail LCswtacc then v-benacc = LCswtacc.acc.
     else do:
         message 'Неопределен коррсчет'.
         pause.
         find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
         if avail lceventh then find current lceventh exclusive-lock.
         if not avail lceventh then create lceventh.
         assign lceventh.lc       = s-lc
                lceventh.event    = s-event
                lceventh.number   = s-number
                lceventh.bank     = vbank
                lceventh.kritcode = 'ErrDes'
                lceventh.value1   = 'Неопределен коррсчет'.
         run lcstse('BO1','Err').
         return.
     end.
     if avail lceventres and lceventres.info[3] = '' then do:
         v-param = string(v-sum) + vdel + v-arp_hq + vdel + v-benacc + vdel + v-nazn /*+ vdel +  substr(v-kbe,1,1) + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp*/.
         /*создаем запись */
         create clsdp.
         assign clsdp.aaa = v-arp_hq
                clsdp.txb = 'TXB00'
                clsdp.sts = '12'
                clsdp.rem = v-rmz
                clsdp.prm = v-param.
         release clsdp.
     end.
 end.
 else if v-opt = 'no' then do:
        assign v-dacc = v-arp
               v-cacc = '186082'.
        find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.
        if not avail lceventres then create lceventres.
        find current lceventres exclusive-lock.
        assign lceventres.lc      = s-lc
               lceventres.event   = s-event
               lceventres.number  = s-number
               lceventres.levD    = 1
               lceventres.dacc    = v-dacc
               lceventres.levC    = 1
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
        assign clsdp.aaa = v-arp_hq
               clsdp.txb = v-bankf
               clsdp.sts = '15'
               clsdp.rem = s-lc
               clsdp.prm = string(s-number).
end.

if v-crc > 1 and v-opt = 'yes' then do:
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'MT202' no-lock no-error.
    if avail lceventh and lookup(lceventh.value1,v-logsno) = 0 then do:
        if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
            message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
            find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
            if avail lceventh then find current lceventh exclusive-lock.
            else create lceventh.
            assign lceventh.lc       = s-lc
                   lceventh.event    = s-event
                   lceventh.number   = s-number
                   lceventh.bank     = vbank
                   lceventh.kritcode = 'ErrDes'
                   lceventh.value1   = "There is no file $HOME/.ssh/id_swift!".
            run lcstse(s-sts,'Err').
        end.
        run lcmtext('202',yes) no-error.
        if error-status:error then do:
            find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
            if avail lceventh then find current lceventh exclusive-lock.
            else create lceventh.
            assign lceventh.lc       = s-lc
                   lceventh.event    = s-event
                   lceventh.number   = s-number
                   lceventh.bank     = vbank
                   lceventh.kritcode = 'ErrDes'
                   lceventh.value1   = "File wasn't copied to SWIFT Alliance!".
            find current lceventh no-lock no-error.
            run lcstse(s-sts,'Err').
            v-lcerrdes = "File wasn't copied to SWIFT Alliance!".
            return.
        end.
    end.
end.
run lcstse(s-sts,'BO2').
if s-sts = 'ERR' then do:
    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
    if avail lceventh then do:
        find current lceventh exclusive-lock.
        lceventh.value1 = ''.
        find current lceventh no-lock no-error.
    end.
end.
/*
/* сообщение */
find first pksysc where pksysc.sysc = "lcmail" no-lock no-error.
if avail pksysc and trim(pksysc.chval) <> '' then do:
    do k = 1 to num-entries(pksysc.chval,';'):
        v-sp = entry(k,pksysc.chval,';').
        do i = 1 to num-entries(v-sp):
            if trim(entry(i,v-sp)) <> '' then do:
                if v-maillist[k] <> '' then v-maillist[k] = v-maillist[k] + ','.
                v-maillist[k] = v-maillist[k] + trim(entry(i,v-sp)) + "@metrocombank.kz".
            end.
        end.
    end.
end.
v-maillist[1] = 'id00810@metrocombank.kz'.
if v-maillist[1] <> '' then do:
    v-str = 'Референс инструмента: ' + s-lc + '~n' + '~n' + 'Аппликант: ' .

    find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
    if avail lch then v-str = v-str + trim(substr(lch.value1,1,35)) + '~n' + '~n' + 'Бенефициар: '.
    else  v-str = v-str + '~n' + '~n' + 'Бенефициар: '.

    find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
    if avail lch then v-str = v-str + trim(substr(lch.value1,1,35)) + '~n' + '~n' + 'Сумма сделки(первоначальная): '.
    else  v-str = v-str + '~n' + '~n' + 'Сумма сделки(первоначальная: '.

    find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
    if avail lch then do:
        v-lcsumorg = deci(lch.value1).
        v-lcsumcur = deci(lch.value1).
        v-str = v-str + trim(replace(string(deci(lch.value1),'>>>>>>>>9.99'),'.',',')) + '~n' + '~n' + 'Сумма оплаты: '.
    end.
    else  v-str = v-str + '~n' + '~n' + 'Сумма оплаты: '.
    v-str = v-str +  trim(replace(string(v-sum,'>>>>>>>>9.99'),'.',',')) + '~n' + '~n' + 'Сумма сделки(текущая): '.

    /*amendment*/
    if s-lcprod <> 'pg' then
    for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
        find first jh where jh.jh = lcamendres.jh no-lock no-error.
        if not avail jh then next.

        if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsumcur = v-lcsumcur + lcamendres.amt.
        if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsumcur = v-lcsumcur - lcamendres.amt.
    end.
    else
    for each lcamendres where lcamendres.lc = s-lc and (lcamendres.dacc = '605561' or  lcamendres.dacc = '655561' or lcamendres.dacc = '605562' or  lcamendres.dacc = '655562') and lcamendres.jh > 0 no-lock:
       find first jh where jh.jh = lcamendres.jh no-lock no-error.
       if not avail jh then next.
       if lcamendres.dacc = '605561' or lcamendres.dacc = '605562' then v-lcsumcur = v-lcsumcur + lcamendres.amt.
       else v-lcsumcur = v-lcsumcur - lcamendres.amt.
    end.

    /*payment*/
    for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
        find first jh where jh.jh = lcpayres.jh no-lock no-error.
        if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
    end.
    /*event*/
    for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24 or lceventres.dacc = '655561' or lceventres.dacc = '655562') and lceventres.jh > 0 no-lock:
        find first jh where jh.jh = lceventres.jh no-lock no-error.
        if avail jh then v-lcsumcur = v-lcsumcur - lceventres.amt.
    end.
    v-str = v-str + trim(replace(string(v-lcsumcur,'>>>>>>>>9.99'),'.',',')) + '~n' + '~n' + 'Валюта сделки: '.

    find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
    if avail lch then do:
       find first crc where crc.crc = integer(lch.value1) no-lock no-error.
       if avail crc then v-str = v-str + crc.code + '~n' + '~n' + 'Дата выпуска аккредитива: '.
    end.
    else  v-str = v-str + '~n' + '~n' + 'Дата выпуска аккредитива: '.

    find first lch where lch.lc = s-lc and lch.kritcode = 'DtIs' no-lock no-error.
    if avail lch then v-str = v-str + lch.value1 + '~n' + '~n' + 'Дата истечения аккредитива: '.
    else  v-str = v-str + '~n' + '~n' + 'Дата истечения аккредитива: '.

    find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
    if avail lch then do:
        v-lcdtexp = date(lch.value1).
        v-str = v-str + lch.value1 + '~n'.
    end.
    else  v-str = v-str + '~n'.
    /*v-sp = "id00810@metrocombank.kz".*/
    /*v-sp = "id00581@metrocombank.kz,id00799@metrocombank.kz,id00652@metrocombank.kz,id00775@metrocombank.kz,id00369@metrocombank.kz,id00185@metrocombank.kz,id00258@metrocombank.kz".*/
    run mail2(v-maillist[1],"METROCOMBANK <abpk@metrocombank.kz>", 'test Оплата аккредитива',v-str, "", "","").
    if v-maillist[2] <> '' then run mail2(v-maillist[2],"METROCOMBANK <abpk@metrocombank.kz>", 'test Оплата аккредитива',v-str, "", "","").
end.
*/


