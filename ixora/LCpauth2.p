/*LCpauth2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Проводки по платежу в рамках аккредитива
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
        24/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
    06/01/2011 Vera - добавлены сообщения для пользователя о совершенных операциях, рассылка писем
    21/01/2011 id00810 - уточнение статусов, добавление полей Аппликант и Бенефициар в сообщение
    04/03/2011 id00810 - уточнение реквизитов сделок в тенге для перевода
    18/04/2011 id00810 - перекомпиляция
    19/04/2011 id00810 - в сообщение добавлена сумма оплаты, осуществлен переход на pksysc для определения адресатов
    10/06/2011 id00810 - обработка типа оплаты = 3
    20/06/2011 id00810 - для PG, SBLC
    29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
    03/08/2011 id00810 - обработка статуса ErrA
    13/09/2011 id00810 - обработка ошибки копирования в SWIFT
    02/11/2011 id00810 - учет реквизита ComAmt
    09/11/2011 id00810 - сообщение перенесено в программу смены статуса LCstspay.p
    01/12/2011 id00810 - добавлена проводка по комиссии
    04/01/2012 id00810 - исправлена ошибка в определении суммы 1-ой проводки для типа оплаты = 3
    06/01/2012 id00810 - новый тип платежа Payment (uncovered deals - client's funds)
    11/01/2012 id00810 - деление комиссии: с учетом НДС и без учета НДС
    03/02/2012 id00810 - добавлены комиссии из Charges
    17/02/2012 id00810 - исправлена ошибка в определении суммы перевода (учитывалась только одна комиссия)
    15/03/2012 id00810 - название банка для перевода в ЦО из sysc
    03/04/2012 id00810 - добавление проводок для PG (ptype = 1,2)
    06/06/2012 Lyubov  - проверяется наличие записи о проведении проводок по лимиту в lcpayres
    08.06.2012 Lyubov  - добавила КОД, КБЕ, КНП в транзакцию
    28.06.2012 Lyubov  - для гарантий проводки делаются иначе
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
def var v-ptype     as char no-undo.
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
def var v-parm      as char no-undo extent 4.
def var v-numlim    as int  no-undo.
def var v-revolv    as logi no-undo.
def var v-limcrc    as int  no-undo.
def var v-crcclim   as char no-undo.
def var v-lim-amt   as deci no-undo.
def var v-crcc      as char no-undo.

def buffer b-lcpayres for lcpayres.
def buffer b-crc      for crc.
def buffer b-crchis   for crchis.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.
else do:
    message 'Нет параметра OURBNK в sysc!' view-as alert-box.
    return.
end.

pause 0.
if s-paysts <> 'BO1' and s-paysts <> 'Err' and s-paysts <> 'ErrA' then do:
    message "Letter of credit's status should be BO1 or Err!" view-as alert-box.
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

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'PType' no-lock no-error.
if avail lcpayh then v-ptype = lcpayh.value1.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
if avail lcpayh then v-crc = integer(lcpayh.value1).
find first crc where crc.crc = v-crc no-lock no-error.
if avail crc then v-crcc = crc.code.

if v-ptype = '1' or v-ptype = '2' or v-ptype = '3' or v-ptype = '5' then do:
    if v-ptype = '1' or v-ptype = '2' or v-ptype = '3' then do:
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
    if v-ptype = '1' or v-ptype = '2' or v-ptype = '3'  then find first pksysc where pksysc.sysc = 'ILCARP' no-lock no-error.
    else find first pksysc where pksysc.sysc = 'ILCARP4' no-lock no-error.

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
end.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
if avail lcpayh and lcpayh.value1 <> '' then assign v-sum = deci(lcpayh.value1).

if v-sum <= 0 then do:
    message "Payment Amount must be > 0!" view-as alert-box error.
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

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'AccNum' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Account Number is empty!" view-as alert-box error.
    return.
end.
v-accnum = lcpayh.value1.

/*check balance*/
if s-lcprod <> 'pg' and (v-ptype = '1' or v-ptype = '4' or v-ptype = '6') then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'CollAcc' no-lock no-error.
    if avail lch then v-collacc = lch.value1.
    else do:
        if v-collacc = '' then do:
            message "Field Collateral Debit Account is empty!" view-as alert-box.
            return.
        end.
    end.
    if v-ptype <> '6' and v-collacc <> '' and s-paysts <> 'PAY' then do:
        find first aaa where aaa.aaa = v-collacc no-lock no-error.
        if avail aaa then do:
            run lonbalcrc('cif',aaa.aaa,g-today,'22',yes,aaa.crc, output v-sum2).
            v-sum2 = v-sum2 * (-1).
            if v-sum > v-sum2 then do:
                message "Lack of the balance of the Collateral Debit Account!" view-as alert-box.
                return.
            end.
        end.
    end.
end.

if can-find(first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode ne '9990' no-lock)
 or (v-ptype = '2' or v-ptype = '3' or v-ptype = '5') then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
    if avail lch then v-comacc = lch.value1.
    else do:
        if v-comacc = '' then do:
            message "Field Commissions Debit Account is empty!" view-as alert-box.
            return.
        end.
    end.
end.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'KBE' no-lock no-error.
if avail lcpayh and lcpayh.value1 <> '' then v-kbe = lcpayh.value1.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'KNP' no-lock no-error.
if avail lcpayh and lcpayh.value1 <> '' then v-knp = lcpayh.value1.

find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'DtNar' no-lock no-error.
if avail lcpayh then v-date = lcpayh.value1.

/* */
find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
if avail lch then do:
    find first lclimit where lclimit.bank = vbank and lclimit.cif = v-cif and lclimit.number = int(lch.value1) no-lock no-error.
    if avail lclimit then if lclimit.sts = 'FIN' then do:
        assign v-numlim = lclimit.number
               /*v-crclim = lclimit.crc*/.
        find first lclimith where lclimith.bank = vbank and lclimith.cif = v-cif and lclimith.number = v-numlim and lclimith.kritcode = 'revolv' no-lock no-error.
        if avail lclimith then if lclimith.value1 = 'yes' then v-revolv = yes.
    end.
end.

if s-lcprod = 'pg'  and v-ptype = '2' then do:
    find first pksysc where pksysc.sysc = 'pg_pay_acc' no-lock no-error.
    if not avail pksysc then do:
        message "The value pg_pay_acc in the table pksysc is empty!" view-as alert-box error.
        return.
    end.
    do l = 1 to num-entries(pksysc.chval,';'):
        v-parm[l] = entry(l,pksysc.chval,';').
        if num-entries(v-parm[l]) <> 2 then do:
            message "Uncorrect structure of parameter pg_pay_acc in the table pksysc!" view-as alert-box error.
            return.
        end.
    end.
end.
/*********POSTINGS**********/
v-nazn = if s-lcprod <> 'pg' then 'Оплата по аккредитиву ' + s-lc else 'Оплата по гарантии ' + s-lc.
/*if v-ptype = '3' then*/ v-nazn = v-nazn + ', дата валютирования ' + v-date.
s-jh = 0. i = 1.

/* postings 1-4 for uncovered PG (v-ptype = 2) */
if s-lcprod = 'pg'  and v-ptype = '2' then do:
    do j = 1 to (l - 1):
        do m = 1 to 2:
            find first gl where gl.gl = int(entry(m,v-parm[j])) no-lock no-error.
            if not avail gl then do:
                message "Uncorrect account GL " + entry(m,v-parm[j]) + " (parameter pg_pay_acc in the table pksysc)!" view-as alert-box error.
                return.
            end.
            if gl.sub = '' then do:
                if m = 1 then assign v-dacc = string(gl.gl)
                                     v-trx  = 'gl,'.
                         else assign v-cacc = string(gl.gl)
                                     v-trx  = v-trx + 'gl'.

            end.
            else if gl.sub = 'arp' then do:
                if m = 1 then assign v-dacc = v-accnum
                                     v-trx  = 'arp,'.
                         else assign v-cacc = v-accnum
                                     v-trx  = v-trx + 'arp'.
            end.
        end.
        s-jh = 0.
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
        if avail lcpayres then do:
           message "Attention! The posting (" + v-dacc + " - " + v-cacc + ") was done earlier!" view-as alert-box info.
        end.
        else do:
            if v-trx = 'gl,gl' then assign v-trx   = 'uni0144'
                                           v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn.
            else if v-trx = 'gl,arp' then assign v-trx   = 'uni0004'
                                                 v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp.
            else do:
                message "Attention! Unknown transaction " + v-trx + "!" view-as alert-box error.
                return.
            end.
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
            create lcpayres.
            assign lcpayres.lc      = s-lc
                   lcpayres.lcpay   = s-lcpay
                   lcpayres.levD    = 1
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
             message "The posting (" + v-dacc + " - " + v-cacc + ") was done!" view-as alert-box info.
        end.
    end.
end.
if v-ptype < '5' then do:
/*1-st posting*/
s-jh = 0.
if v-ptype = '1' then do:
    if s-lcprod = 'pg'
    then assign v-dacc = v-accnum
                v-cacc = v-arp
                v-levD = 1
                v-param = string(v-sum) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + ''
                v-trx   = "vnb0010".
    else assign v-dacc = v-collacc
                v-cacc = v-arp
                v-levD = 22
                v-param = string(v-sum) + vdel + string(v-crc) + vdel + string(v-levD) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + v-knp
                v-trx   = "uni0118".
end.
if v-ptype = '2' or v-ptype = '3' then do:
    if s-lcprod = 'pg'
    then assign v-dacc = v-accnum
                v-cacc = v-arp
                v-levD = 1
                v-param = string(v-sum) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + ''
                v-trx   = "vnb0010".
    else assign v-dacc = '185512'
                v-cacc = v-arp
                v-levD = 1
                v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp
                v-trx   = 'uni0004'.
end.
if v-ptype = '4' then do:
    if s-lcprod <> 'pg' then do:
        assign v-dacc = v-collacc
               v-cacc = '185511'
               v-levD = 22
               v-param = string(v-sum) + vdel + string(v-crc) + vdel + string(v-levD) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn
               v-trx   = "cif0019".
    end.
    else do:
        assign v-dacc = '285521'
               v-cacc = '185521'
               v-levD = 1
               v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn
               v-trx   = "uni0144".
    end.
end.

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
    if v-ptype <> '4' then do:
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
            v-filrnn, /*чей РНН*/
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
        else do:
            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'BenAcc' no-lock no-error.
            if avail lcpayh and lcpayh.value1 <> '' then v-benacc = lcpayh.value1.

            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'BenIns' no-lock no-error.
            if avail lcpayh and lcpayh.value1 <> '' then v-benbank = lcpayh.value1.

            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'BenPay' no-lock no-error.
            if avail lcpayh and lcpayh.value1 <> '' then v-bname = lcpayh.value1.

            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'BenRNN' no-lock no-error.
            if avail lcpayh and lcpayh.value1 <> '' then v-bnkrnn = lcpayh.value1.

            find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
            if avail lch and lch.value1 <> '' then v-applic = lch.value1.

            find first cmp no-lock no-error.
            if avail cmp then assign v-filrnn = cmp.addr[2] v-filname = cmp.name.

            run rmzcre (s-lcpay,
            v-sum - v-com - v-comi,
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
    end. /*v-ptype <> '4' */
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
end.

if v-ptype <= '3' then do:
   if v-com > 0 then do:
        /* the 5-th posting */
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
        /* the 6-th posting */
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
end.
if v-ptype = '4' or v-ptype = '6' then do:
    s-jh = 0.
    /*2-nd posting for v-ptype = '4,6' */
    if s-lcprod <> 'pg' then do:
        assign v-dacc = '652000'
               v-cacc = v-collacc
               v-levC  = 23
               v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + string(v-levC) + vdel + v-cacc + vdel + v-nazn
               v-trx   = "cif0018".
    end.
    else do:
        assign v-dacc = '655561'
               v-cacc = '605561'
               v-levC = 1
               v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn.
               v-trx   = "uni0144".
    end.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levC = v-levC and lcpayres.cacc = v-cacc no-lock no-error.
    if avail lcpayres then do:
        message "Attention! The posting (" + v-dacc + " - " + v-cacc + ") was done earlier!" view-as alert-box info.
    end.
    else do:
        run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
            if avail lcpayh then find current lcpayh exclusive-lock.
            else create lcpayh.
            assign lcpayh.lc       = s-lc
                   lcpayh.lcpay    = s-lcpay
                   lcpayh.bank     = vbank
                   lcpayh.kritcode = 'ErrDes'
                   lcpayh.value1   = string(rcode) + ' ' + rdes.
           run LCstspay('BO1','Err').
           return.
        end.
        if s-jh > 0 then do:
            create lcpayres.
            assign lcpayres.lc      = s-lc
                   lcpayres.lcpay   = s-lcpay
                   lcpayres.dacc    = v-dacc
                   lcpayres.cacc    = v-cacc
                   lcpayres.amt     = v-sum
                   lcpayres.crc     = v-crc
                   lcpayres.com     = no
                   lcpayres.comcode = ''
                   lcpayres.rwho    = g-ofc
                   lcpayres.rwhn    = g-today
                   lcpayres.jh      = s-jh
                   lcpayres.jdt     = g-today
                   lcpayres.trx     = v-trx
                   lcpayres.levC    = v-levC
                   lcpayres.levD    = 1
                   lcpayres.rem     = v-nazn.
        /*v-st = yes.*/
        end.
    end.
end. /*v-ptype = '4' */
else do:
    /* для v-ptype = '1' или '2' или '3' подготовка к списанию с коррсчета в ЦО, само списание в процедуре ELX_ps.p,
        проводки по 6-му классу (требования/обязательства) в процедуре LCPAY_ps.p, заполнение поля lcpayres.info[2] в процедуре 7T_ps.p,
       для v-ptype = '5' заполнение lcpayres, проводки в процедуре ELX_ps.p */
    if v-crc > 1 then do:
        find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'Scor202' no-lock no-error.
        if avail lcpayh and lcpayh.value1 <> '' then do:
            find first LCswtacc where LCswtacc.accout = lcpayh.value1 and LCswtacc.crc = v-crc no-lock no-error.
            if avail LCswtacc then v-benacc = LCswtacc.acc.
        end.
        if v-benacc = '' then do:
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
        if v-ptype <> '5' then do:
            if avail lcpayres and lcpayres.info[3] = '' then do:
                v-param = string(v-sum - v-com - v-comi) + vdel + v-arp_hq + vdel + v-benacc + vdel + v-nazn.  /*+ vdel +  substr(v-kbe,1,1) + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp.*/
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
        else do:
            do while i <= 3:
                if i = 1 then assign v-dacc = v-accnum
                                     v-cacc = v-arp_hq.
                else
                if i = 2 then assign v-dacc = '186082'
                                     v-cacc = v-benacc.
                else          assign v-dacc = v-arp_hq
                                     v-cacc = '186082'.
                find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
                if not avail lcpayres then create lcpayres.
                find current lcpayres exclusive-lock.
                assign lcpayres.lc      = s-lc
                       lcpayres.lcpay   = s-lcpay
                       lcpayres.levD    = 1
                       lcpayres.dacc    = v-dacc
                       lcpayres.levC    = 1
                       lcpayres.cacc    = v-cacc
                       lcpayres.rem     = v-nazn
                       lcpayres.amt     = v-sum
                       lcpayres.crc     = v-crc
                       lcpayres.com     = no
                       lcpayres.comcode = ''
                       lcpayres.rwho    = g-ofc
                       lcpayres.rwhn    = g-today
                       lcpayres.bank    = VBANK.
                find current lcpayres no-lock.
                i = i + 1.
            end.
            create clsdp.
            assign clsdp.aaa = v-arp_hq
                   clsdp.txb = 'TXB00'
                   clsdp.sts = '14'
                   clsdp.rem = s-lc
                   clsdp.prm = string(s-lcpay).
       end.
    end.
end.
/*Commission postings*/
for each lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode ne '9990' and lcpayres.jh = 0 no-lock:
    if lcpayres.amt = 0 then next.
    find first tarif2 where tarif2.str5 = lcpayres.comcode and tarif2.stat = 'r' no-lock no-error.
    if not avail tarif2 then return.

    if lookup(s-lcprod,'PG,EXPG') > 0 and lookup(lcpayres.comcode,'967,968,969,952,955,956,957,953,954,958,959,941,942,943,944,945,946,947') > 0 then do:
        assign v-param = string(lcpayres.amt) + vdel + v-comacc + vdel + '286920' + vdel + s-lc + ' ' + lcpayres.rem + vdel + string(lcpayres.amt) + vdel + string(tarif2.kont)
               v-trx   = 'cif0023'.
    end.

    else assign v-param = string(lcpayres.amt) + vdel + string(lcpayres.crc) + vdel + v-comacc + vdel + string(tarif2.kont) + vdel + s-lc + ' ' + lcpayres.rem + vdel + '1' + vdel + '4' + vdel + '840'
                v-trx   = 'cif0015'.

    s-jh = 0.
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

 if v-revolv and v-ptype <> '5' then do:
    /* limit posting */
    assign s-jh   = 0
           v-dacc = '612530'
           v-cacc = '662530'
           v-levD = 1.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = v-levD and lcpayres.dacc = v-dacc no-lock no-error.
    /*find first lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lclimitres.info[1] = 'pay' and lclimitres.info[2] = string(s-lcpay) and lclimitres.jh > 0 no-lock no-error.*/
    /*if avail lclimitres then do:*/

    if avail lcpayres then do:
        message "Attention! The posting for limit (" + v-dacc + " - " + v-cacc + ") was done earlier!" view-as alert-box info.
    end.
    else do:
        find first lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lclimitres.info[1] = 'create' and lclimitres.jh > 0 no-lock no-error.
        if avail lclimitres then find first jh where jh.jh = lclimitres.jh no-lock no-error.
        if avail jh then assign /*v-limsum = lclimitres.amt*/ v-limcrc = lclimitres.crc.
        if v-crc = v-limcrc then assign v-lim-amt = v-sum
                                        v-crcclim    = v-crcc.
        else do:
            find first b-crc where b-crc.crc = v-limcrc no-lock no-error.
            if avail b-crc then v-crcclim = b-crc.code.
            find last crchis where crchis.crc = v-crc and crchis.rdt < jh.jdt no-lock no-error.
            find last b-crchis where b-crchis.crc = v-limcrc and b-crchis.rdt < jh.jdt no-lock no-error.
            if avail b-crchis then v-lim-amt = round((v-sum * crchis.rate[1]) / b-crchis.rate[1],2).
        end.
        assign v-param = string(v-lim-amt) + vdel + string(v-limcrc) + vdel + v-dacc + vdel +
                                  v-cacc + vdel + 'Восстановление доступного остатка по возобновляемым кредитам в рамках ТФ, ' + s-lc  + ' '  + v-cifname
                        v-trx   = 'uni0144'.
            s-jh = 0.
            run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
               message rdes.
               pause.
               message "The posting for limit was not done!" view-as alert-box error.
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
               create lcpayres.
                    assign lcpayres.lc      = s-lc
                           lcpayres.lcpay   = s-lcpay
                           lcpayres.levD    = 1
                           lcpayres.dacc    = v-dacc
                           lcpayres.levC    = 1
                           lcpayres.cacc    = v-cacc
                           lcpayres.trx     = v-trx
                           lcpayres.rem     = 'Восстановление доступного остатка по возобновляемым кредитам в рамках ТФ, ' + s-lc
                           lcpayres.amt     = v-lim-amt
                           lcpayres.crc     = v-limcrc
                           lcpayres.com     = no
                           lcpayres.comcode = ''
                           lcpayres.rwho    = g-ofc
                           lcpayres.rwhn    = g-today
                           lcpayres.jh      = s-jh
                           lcpayres.jdt     = g-today
                           lcpayres.bank    = VBANK.

                create lclimitres.
                assign lclimitres.cif     =  v-cif
                       lclimitres.number  = v-numlim
                       lclimitres.lc      = s-lc
                       lclimitres.dacc    = v-dacc
                       lclimitres.cacc    = v-cacc
                       lclimitres.amt     = v-lim-amt
                       lclimitres.crc     = v-limcrc
                       lclimitres.rwho    = g-ofc
                       lclimitres.rwhn    = g-today
                       lclimitres.jh      = s-jh
                       lclimitres.jdt     = g-today
                       lclimitres.trx     = v-trx
                       lclimitres.rem     = 'Восстановление доступного остатка по возобновляемым кредитам в рамках ТФ, ' + s-lc  + ' '  + v-cifname
                       lclimitres.bank    = VBANK
                       lclimitres.info[1] = 'pay'
                       lclimitres.info[2] = string(s-lcpay).
                v-st = yes.
            end.
            message "The posting for limit was done!" view-as alert-box info.
        end.
end.
if v-ptype = '4' or v-ptype = '6' then run LCstspay(s-paysts,'FIN').
else do:
    if v-crc > 1 and v-ptype <= '3' then do:
        v-yes = no.
        find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT202' no-lock no-error.
        if avail lcpayh and lookup(lcpayh.value1,v-logsno) = 0 then v-yes = yes.
        else do:
            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT756' no-lock no-error.
            if avail lcpayh and lookup(lcpayh.value1,v-logsno) = 0 then v-yes = yes.
        end.
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
            run LCmtpay no-error.
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
    run LCstspay(s-paysts,'BO2').
end.
if s-paysts = 'ERR' then do:
    find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
    if avail lcpayh then do:
        find current lcpayh exclusive-lock.
        lcpayh.value1 = ''.
        find current lcpayh no-lock no-error.
    end.
end.
/* сообщение */
/*find first pksysc where pksysc.sysc = "lcmail" no-lock no-error.
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
    for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or lcpayres.levC = 24 or lcpayres.dacc = '655561' or lcpayres.dacc = '655562') and lcpayres.jh > 0 no-lock:
        find first jh where jh.jh = lcpayres.jh no-lock no-error.
        if avail jh then v-lcsumcur = v-lcsumcur - lcpayres.amt.
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
    run mail(v-maillist[1],"METROCOMBANK <abpk@metrocombank.kz>", 'Оплата аккредитива',v-str, "", "","").
    if v-maillist[2] <> '' then run mail(v-maillist[2],"METROCOMBANK <abpk@metrocombank.kz>", 'Оплата аккредитива',v-str, "", "","").
end.*/

