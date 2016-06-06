/*LCppost.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Вывод проводок
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
        13/04/2011 id00810 - отражение переводов (3 и 4 постинги)
        18/04/2011 id00810 - перекомпиляция
        16/06/2011 id00810 - изменение в проводках согласно новому ТЗ
        29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
        02/11/2011 id00810 - учет реквизита ComAmt
        01/12/2011 id00810 - добавлена проводка по комиссии
        06/01/2012 id00810 - новый тип платежа Payment (uncovered deals - client's funds)
        11/01/2012 id00810 - деление комиссии: с учетом НДС и без учета НДС
        03/02/2012 id00810 - добавлены комиссии из Charges
        03/04/2012 id00810 - добаавление проводок для PG (ptype = 1,2)
        07.05.2012 Lyubov - проверка баланса только в случае, если статус NEW
        28.06.2012 Lyubov  - проводки по PG\EXPG образуются иначе 220310 -> 286920, 286920 -> 4612(20\11)
        23.08.2012 Lyubov  - MetroComBank исправила на ForteBank
        09/08/2013 galina - ТЗ1886 отражаем проводки ппо комиссии через счета конвертации
        26/08/2013 galina - ТЗ2051 берем курс из crchis если тада проводки меньше текущей
        09/09/2013 galina - ТЗ2074 отражение через счета конвертации только при признании комиссии на доходы
*/

{global.i}
define stream m-out.

def shared var s-lc     like lc.lc.
def shared var s-lcpay  like lcpay.lcpay.
def shared var s-paysts like lcpay.sts.
def shared var s-lcprod as char.
def shared var v-cif     as char.

def var v-sum     as deci no-undo.
def var v-com     as deci no-undo.
def var v-comi    as deci no-undo.
def var v-crc     as int  no-undo.
def var v-crcc    as char no-undo.
def var v-collacc as char no-undo.
def var v-comacc  as char no-undo.
def var v-depacc  as char no-undo.
def var v-dacc    as char no-undo.
def var v-cacc    as char no-undo.
def var v-levD    as int  no-undo.
def var v-levC    as int  no-undo.
def var v-lccow   as char no-undo.
def var v-sum2    as deci no-undo.
def var v-arp     as char no-undo.
def var v-arp_hq  as char no-undo.
def var v-gl      as int  no-undo.
def var v-ptype   as char no-undo.
def var v-nazn    as char no-undo.
def var v-date    as char no-undo.
def var v-scorr   as char no-undo.
def var v-acctype as char no-undo.
def var v-accnum  as char no-undo.
def var v-bank    as char no-undo.
def var i         as int  no-undo.
def var k         as int  no-undo.
def var j         as int  no-undo.
def var l         as int  no-undo.
def var m         as int  no-undo.
def var v-gar     as logi no-undo.
def var v-comacct as char no-undo.
def var v-comaccti as char no-undo.
def var v-numlim  as int  no-undo.
def var v-revolv  as logi no-undo.
def var v-limcrc  as int  no-undo.
def var v-crcclim as char no-undo.
def var v-lim-amt as deci no-undo.
def var v-name    as char no-undo init 'Collateral Debet Account'.
def var v-param   as char no-undo extent 4.
def var v-daccgl  as int  no-undo.
def var v-daccgldes as char no-undo.
def var v-caccgl  as int  no-undo.
def var v-caccgldes as char no-undo.
def var v-amt1 as deci no-undo.

def buffer b-crc for crc.
def buffer b-crchis for crchis.

def temp-table wrk
    field num    as int
    field numdis as char
    field bank   as char
    field dc     as char
    field gldes  as char
    field rem    as char
    field jdt    as date
    FIELD acc    AS CHAR
    FIELD gl     AS integer
    field sum    as decimal
    field cur    as char
    index ind1 is primary num.

define query qt for wrk.
define browse bt query qt
    displ wrk.numdis label "№"          format "x(3)"
          wrk.bank   label "Bank"       format "x(5)"
          wrk.dc     label "Dt/Ct"      format "x(2)"
          wrk.acc    label "Client Acc" format "x(20)"
          wrk.gl     label "Ledger Acc" format "999999"
          wrk.gldes  label "Ledger Account  Description" format "x(30)"
          wrk.sum    label "Amount"     format ">>>,>>>,>>9.99"
          wrk.cur    label "CCY"        format "x(3)"
          wrk.jdt    label "Value Dt"   format "99/99/99"
          wrk.rem    label "Narrative"  format "x(30)"
          with width 115 row 8 15 down overlay no-label title "Postings" NO-ASSIGN SEPARATORS.

def button btn-e   label  " Print in Excel  ".

DEFINE FRAME ft
    bt    SKIP(1)
    btn-e SKIP
    WITH width 115 1 COLUMN SIDE-LABELS
    NO-BOX.

on "end-error" of frame ft do:
    hide frame ft no-pause.
end.

{LC.i}
find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.
if s-lcprod = 'pg' then v-gar = yes.

find first lcpayh where lcpayh.bank = s-ourbank and  lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'PType' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Payment Type is empty!" view-as alert-box error.
    return.
end.
v-ptype = lcpayh.value1.
v-bank = if v-ptype = '5' then 'TXB00' else s-ourbank.

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CurCode' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Currency Code is empty!" view-as alert-box error.
    return.
end.
v-crc = integer(lcpayh.value1).

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
    if v-ptype = '1' or v-ptype = '2' or v-ptype = '3' then find first pksysc where pksysc.sysc = 'ILCARP' no-lock no-error.
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
    if v-crc > 1 then do:
        find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'SCor202' no-lock no-error.
        if not avail lcpayh or lcpayh.value1 = '' then do:
            message "Field Sender's Correspondent (MT 202) is empty!" view-as alert-box error.
            return.
        end.
        v-scorr = lcpayh.value1.
    end.
end.

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'DtNar' no-lock no-error.
if (not avail lcpayh or lcpayh.value1 = '') and s-paysts = 'new' then do:
    message "Field Date for Narrative is empty!" view-as alert-box error.
    return.
end.
if avail lcpayh then v-date = lcpayh.value1.

if not v-gar and (v-ptype = '2' or v-ptype = '3' or v-ptype = '5') then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
    if avail lch then v-comacc = lch.value1.
    else do:
        if v-comacc = '' then do:
            message "Field Commissions Debit Account is empty!" view-as alert-box error.
            return.
        end.
    end.
end.

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Payment Amount is empty!" view-as alert-box error.
    return.
end.
v-sum = deci(lcpayh.value1).

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmt' no-lock no-error.
if not avail lcpayh then find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtE' no-lock no-error.
if avail lcpayh then if lcpayh.value1 ne '' then v-com = deci(lcpayh.value1).

if v-com > 0 then do:
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAccT' no-lock no-error.
    if avail lcpayh then if lcpayh.value1 ne '' then v-comacct = lcpayh.value1.
    if v-comacct = '' then do:
        message "Field Commission Account Type(amt excl.VAT) is empty!" view-as alert-box error.
        return.
    end.
end.
find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAmtI' no-lock no-error.
if avail lcpayh then if lcpayh.value1 ne '' then v-comi = deci(lcpayh.value1).

if v-comi > 0 then do:
    find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'ComAccTI' no-lock no-error.
    if avail lcpayh then if lcpayh.value1 ne '' then v-comaccti = lcpayh.value1.
    if v-comaccti = '' then do:
        message "Field Commission Account Type(amt incl.VAT) is empty!" view-as alert-box error.
        return.
    end.
end.
find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'AccType' no-lock no-error.
if (not avail lcpayh or lcpayh.value1 = '') and s-paysts = 'new' then do:
    message "Field Account Type is empty!!!!" view-as alert-box error.
    return.
end.
if avail lcpayh then v-acctype = lcpayh.value1.

find first codfr where codfr.codfr = 'lcacctype'
                   and codfr.code  = v-acctype
                   no-lock no-error.

if avail codfr then v-acctype = substr(codfr.name[1],1,6).

find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'AccNum' no-lock no-error.
if not avail lcpayh or lcpayh.value1 = '' then do:
    message "Field Account Number is empty!" view-as alert-box error.
    return.
end.
v-accnum = lcpayh.value1.
/*check balance*/
if not v-gar and (v-ptype = '1' or v-ptype = '3' or v-ptype = '4') then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'CollAcc' no-lock no-error.
    if avail lch then v-collacc = lch.value1.
    if v-ptype = '3' then do:
        v-name = "Client's Account".
        find first lcpayh where lcpayh.bank = s-ourbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CollAcc' no-lock no-error.
        if avail lcpayh then v-collacc = lcpayh.value1.
    end.
    if v-collacc = '' then do:
        message "Field " + v-name + " is empty!" view-as alert-box.
        return.
    end.
    if v-collacc <> '' and s-paysts = 'NEW' then do:
        find first aaa where aaa.aaa = v-collacc no-lock no-error.
        if avail aaa then do:
            if v-ptype = '1' or v-ptype = '4' then run lonbalcrc('cif',aaa.aaa,g-today,'22',yes,aaa.crc, output v-sum2).
            else run lonbalcrc('cif',aaa.aaa,g-today,'1',yes,aaa.crc, output v-sum2).
            v-sum2 = v-sum2 * (-1).
            if v-sum > v-sum2 then do:
                message "Lack of the balance of the " + v-name + "!" view-as alert-box.
                return.
            end.
        end.
    end.
end.
if not v-gar and v-ptype = '6' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'CollAcc' no-lock no-error.
    if avail lch then v-collacc = lch.value1.
    if v-collacc = '' then do:
        message "Field " + v-name + " is empty!" view-as alert-box.
        return.
    end.
end.
if v-gar and v-ptype = '1' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'DepAcc' no-lock no-error.
    if avail lch then v-depacc = lch.value1.
    if v-depacc = '' then do:
        message "Field Collateral Deposit Account is empty!" view-as alert-box.
        return.
    end.
end.
/* */
find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
if avail lch then do:
    find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = v-cif and lclimit.number = int(lch.value1) no-lock no-error.
    if avail lclimit then if lclimit.sts = 'FIN' then do:
        assign v-numlim = lclimit.number
               /*v-crclim = lclimit.crc*/.
        find first lclimith where lclimith.bank = s-ourbank and lclimith.cif = v-cif and lclimith.number = v-numlim and lclimith.kritcode = 'revolv' no-lock no-error.
        if avail lclimith then if lclimith.value1 = 'yes' then v-revolv = yes.
    end.
end.
if v-gar and v-ptype = '2' then do:
    find first pksysc where pksysc.sysc = 'pg_pay_acc' no-lock no-error.
    if not avail pksysc then do:
        message "The value pg_pay_acc in the table pksysc is empty!" view-as alert-box error.
        return.
    end.
    do l = 1 to num-entries(pksysc.chval,';'):
        v-param[l] = entry(l,pksysc.chval,';').
        if num-entries(v-param[l]) <> 2 then do:
            message "Uncorrect structure of parameter pg_pay_acc in the table pksysc!" view-as alert-box error.
            return.
        end.
    end.
end.
/*********POSTINGS**********/
k = 0.
i = 0.
v-nazn = if not v-gar then 'Оплата по аккредитиву ' + s-lc else 'Оплата по гарантии ' + s-lc.
/*if v-ptype = '3' then*/ v-nazn = v-nazn + ', дата валютирования ' + v-date.

/* postings 1-4 for uncovered PG (v-ptype = 2) */
if v-gar and v-ptype = '2' then do:
    do j = 1 to (l - 1):
        do m = 1 to 2:
            find first gl where gl.gl = int(entry(m,v-param[j])) no-lock no-error.
            if not avail gl then do:
                message "Uncorrect account GL " + entry(m,v-param[j]) + " (parameter pg_pay_acc in the table pksysc)!" view-as alert-box error.
                return.
            end.
            if gl.sub = '' then do:
                if m = 1 then assign v-dacc      = string(gl.gl)
                                     v-daccgl    = gl.gl
                                     v-daccgldes = trim(gl.des).
                         else assign v-cacc      = string(gl.gl)
                                     v-caccgl    = gl.gl
                                     v-caccgldes = trim(gl.des).
            end.
            else if gl.sub = 'arp' then do:
                if m = 1 then assign v-dacc      = v-accnum
                                     v-daccgl    = gl.gl
                                     v-daccgldes = trim(gl.des).
                         else assign v-cacc      = v-accnum
                                     v-caccgl    = gl.gl
                                     v-caccgldes = trim(gl.des).
            end.
        end.
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
        i = i + 1.
        k = k + 1.
        /*debit*/
        create wrk.
        assign wrk.numdis = string(i)
               wrk.bank   = v-bank
               wrk.num    = k
               wrk.dc     = 'Dt'
               wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
               wrk.cur    = v-crcc
               wrk.sum    = if avail lcpayres then lcpayres.amt else v-sum
               wrk.jdt    = if avail lcpayres then lcpayres.jdt  else g-today
               wrk.rem    = if avail lcpayres then lcpayres.rem  else v-nazn
               wrk.gl     = v-daccgl
               wrk.gldes  = v-daccgldes.
        /*credit*/
        k = k + 1.

        create wrk.
        assign wrk.bank  = v-bank
               wrk.num   = k
               wrk.dc    = 'Ct'
               wrk.acc   = if avail lcpayres then lcpayres.cacc else v-cacc
               wrk.cur   = v-crcc
               wrk.sum   = if avail lcpayres then lcpayres.amt else v-sum
               wrk.jdt   = if avail lcpayres then lcpayres.jdt  else g-today
               wrk.rem   = if avail lcpayres then lcpayres.rem  else v-nazn
               wrk.gl    = v-caccgl
               wrk.gldes = v-caccgldes.

    end.
end.
/*1-st posting for all v-ptype except 6*/
if v-ptype <> '6' then do:
if v-ptype = '1' or v-ptype = '4' then do:
    if not v-gar then do:
        assign v-dacc = v-collacc
               v-cacc = if v-ptype = '1' then v-arp else '185511'
               v-levD = 22.
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 22 no-lock no-error.
    end.
    else do:
        assign v-dacc = v-accnum
               v-cacc = if v-ptype = '1' then v-arp else '185521'
               v-levD = 1.
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
    end.
end.
if v-ptype = '2' or v-ptype = '3' then do:
    assign v-dacc = v-accnum
           v-cacc = v-arp.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
end.
if v-ptype = '5' then do:
    assign v-dacc = v-accnum
           v-cacc = v-arp_hq
           v-gl   = 286071.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
end.
i = i + 1.
k = k + 1.
/*debit*/
create wrk.
assign wrk.numdis = string(i)
       wrk.bank   = v-bank
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
       wrk.cur    = v-crcc
       wrk.sum    = if avail lcpayres then lcpayres.amt else v-sum
       wrk.jdt    = if avail lcpayres then lcpayres.jdt  else g-today
       wrk.rem    = if avail lcpayres then lcpayres.rem  else v-nazn.

if not v-gar and v-ptype <> '2' and v-ptype <> '3' and v-ptype <> '5' then do:
    find first aaa where aaa.aaa = wrk.acc no-lock no-error.
    if avail aaa then do:
        find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levD and trxlev.gl = aaa.gl no-lock no-error.
        if avail trxlev then do:
            wrk.gl = trxlev.glr.
            find first gl where gl.gl = trxlev.glr no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
    end.
end.
else do:
    wrk.gl = if v-ptype = '5' or (can-do('1,2',v-ptype) and v-gar ) then int(v-acctype) else int(wrk.acc).
    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).
end.

/*credit*/
k = k + 1.

create wrk.
assign wrk.bank = v-bank
       wrk.num  = k
       wrk.dc   = 'Ct'
       wrk.acc  = if avail lcpayres then lcpayres.cacc else v-cacc
       wrk.cur  = v-crcc
       wrk.sum  = if avail lcpayres then lcpayres.amt else v-sum
       wrk.jdt  = if avail lcpayres then lcpayres.jdt  else g-today
       wrk.rem  = if avail lcpayres then lcpayres.rem  else v-nazn.

if v-ptype = '1' or v-ptype = '2' or v-ptype = '3' then do:
 find first arp where arp.arp = wrk.acc no-lock no-error.
 if avail arp then do:
     wrk.gl = arp.gl.
     find first gl where gl.gl = arp.gl no-lock no-error.
     if avail gl then wrk.gldes = trim(gl.des).
 end.
end.
else do:
     wrk.gl = if v-ptype = '4' then int(wrk.acc) else v-gl.
     find first gl where gl.gl = wrk.gl no-lock no-error.
     if avail gl then wrk.gldes = trim(gl.des).
end.
end.

 if v-ptype <> '5' then do:
    /*2-nd posting only for v-type = 1,2,3,4,6*/
    i = i + 1.
    if v-ptype = '1' or v-ptype = '4' or v-ptype = '6' then do:
        if not v-gar then do:
            assign v-dacc = '652000'
                   v-cacc = v-collacc
                   v-levC = 23.
            find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levC = v-levC no-lock no-error.
        end.
        else do:
            assign v-dacc = '655561'
                   v-cacc = '605561'
                   v-levC = 1.
            find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levC = v-levC and lcpayres.cacc = v-cacc no-lock no-error.
        end.
    end.
    else do:
        if not v-gar then do:
            assign v-dacc = '650510'
                   v-cacc = v-comacc
                   v-levC = 24.
            find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levC = v-levC no-lock no-error.
        end.
        else do:
            assign v-dacc = '655562'
                   v-cacc = '605562'
                   v-levC = 1.
            find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levC = v-levC and lcpayres.cacc = v-cacc no-lock no-error.
        end.
    end.

    /*debit*/
    k = k + 1.

    create wrk.
    assign wrk.numdis = string(i)
           wrk.bank   = s-ourbank
           wrk.num    = k
           wrk.dc     = 'Dt'
           wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
           wrk.gl     = int(wrk.acc)
           wrk.cur    = v-crcc
           wrk.sum    = if avail lcpayres then lcpayres.amt else v-sum
           wrk.jdt    = if avail lcpayres then lcpayres.jdt  else g-today
           wrk.rem    = if avail lcpayres then lcpayres.rem  else v-nazn.

    find first gl where gl.gl = int(wrk.acc) no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).

    /*credit*/
    k = k + 1.

    create wrk.
    assign wrk.bank = s-ourbank
           wrk.num  = k
           wrk.dc   = 'Ct'
           wrk.acc  = if avail lcpayres then lcpayres.cacc else v-cacc
           wrk.cur  = v-crcc
           wrk.sum  = if avail lcpayres then lcpayres.amt else v-sum
           wrk.jdt  = if avail lcpayres then lcpayres.jdt  else g-today
           wrk.rem  = if avail lcpayres then lcpayres.rem  else v-nazn.

    if not v-gar then do:
        find first aaa where aaa.aaa = wrk.acc no-lock no-error.
        if avail aaa then do:
            find first trxlev where trxlev.sub = "CIF" and trxlev.lev = v-levC and trxlev.gl = aaa.gl no-lock no-error.
            if avail trxlev then do:
                wrk.gl = trxlev.glr.
                find first gl where gl.gl = trxlev.glr no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.
        end.
    end.
    else do:
        wrk.gl = int(wrk.acc).
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).
    end.
end.
/******/

if v-ptype <> '4' and v-ptype <> '6' then do:
    /* 3-rd and 4-th postings for v-ptype = 1,2,3,5*/
    if v-ptype < '4' then do:
        /* 3-rd  */
        i = i + 1.
        v-dacc = v-arp.
        if v-crc = 1 then do:
            find first LCswtacc where LCswtacc.crc = v-crc no-lock no-error.
            if avail LCswtacc then assign v-cacc = LCswtacc.acc  v-gl = lcswtacc.gl.
        end.
        else assign  v-cacc = v-arp_hq  v-gl = 287090.
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levC = 1 and lcpayres.cacc = v-arp_hq no-lock no-error.
        k = k + 1.

        create wrk.
        assign wrk.numdis = string(i)
               wrk.bank   = s-ourbank
               wrk.num    = k
               wrk.dc     = 'Dt'.
               wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc.
        assign wrk.cur    = v-crcc
               wrk.sum    = v-sum - v-com - v-comi
               wrk.jdt    = if avail lcpayres then lcpayres.jdt else g-today
               wrk.rem    = if avail lcpayres then lcpayres.rem else v-nazn.

        find first arp where arp.arp = wrk.acc no-lock no-error.
        if avail arp then wrk.gl = arp.gl.

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

        /*Credit*/
        k = k + 1.

        create wrk.
        assign wrk.bank = 'TXB00'
               wrk.num = k
               wrk.dc  = 'Ct'.
               wrk.acc = if avail lcpayres then lcpayres.cacc else v-cacc.
        assign wrk.cur    = v-crcc
               wrk.sum    = v-sum - v-com - v-comi
               wrk.jdt    = if avail lcpayres then lcpayres.jdt else g-today
               wrk.rem    = if avail lcpayres then lcpayres.rem else v-nazn
               wrk.gl     = v-gl.
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).
    end.
    /* 4-th posting for v-ptype = 1,2,3 and 3-rd for v-ptype = 5 */
    if v-crc > 1 then do:
       i = i + 1.
       if v-ptype = '5' then assign v-dacc = '186082' v-gl = 186082.
       else assign v-dacc = v-arp_hq v-gl = 287090.

       find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
       k = k + 1.

       create wrk.
       assign wrk.numdis = string(i)
              wrk.bank   = 'TXB00'
              wrk.num    = k
              wrk.dc     = 'Dt'.
              wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc.
        assign
              wrk.cur    = v-crcc
              wrk.sum    = v-sum - v-com - v-comi
              wrk.jdt    = if avail lcpayres then lcpayres.jdt else g-today
              wrk.rem    = if avail lcpayres then lcpayres.rem else v-nazn
              wrk.gl     = v-gl.
       find first gl where gl.gl = wrk.gl no-lock no-error.
       if avail gl then wrk.gldes = trim(gl.des).

       /*Credit*/
       k = k + 1.

       find first LCswtacc where LCswtacc.accout = v-scorr and LCswtacc.crc = v-crc no-lock no-error.
       if avail LCswtacc then assign v-cacc = LCswtacc.acc v-gl = lcswtacc.gl.

       create wrk.
       assign wrk.bank = 'TXB00'
              wrk.num = k
              wrk.dc  = 'Ct'.
              wrk.acc = if avail lcpayres then lcpayres.cacc else v-cacc.
        assign
              wrk.cur    = v-crcc
              wrk.sum    = v-sum - v-com - v-comi
              wrk.jdt    = if avail lcpayres then lcpayres.jdt else g-today
              wrk.rem    = if avail lcpayres then lcpayres.rem else v-nazn
              wrk.gl     = v-gl.

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

        /* 4-th for v-ptype = '5' */
        if v-ptype = '5' then do:
            i = i + 1.
            assign v-dacc = v-arp_hq v-gl = 286071
                   v-cacc  ='186082'  .

           find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
           k = k + 1.
           create wrk.
           assign wrk.numdis = string(i)
                  wrk.bank   = 'TXB00'
                  wrk.num    = k
                  wrk.dc     = 'Dt'.
                  wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc.
            assign
                  wrk.cur    = v-crcc
                  wrk.sum    = v-sum
                  wrk.jdt    = if avail lcpayres then lcpayres.jdt else g-today
                  wrk.rem    = if avail lcpayres then lcpayres.rem else v-nazn
                  wrk.gl     = v-gl.
           find first gl where gl.gl = wrk.gl no-lock no-error.
           if avail gl then wrk.gldes = trim(gl.des).

           /*Credit*/
           k = k + 1.
           create wrk.
           assign wrk.bank = 'TXB00'
                  wrk.num = k
                  wrk.dc  = 'Ct'.
                  wrk.acc = if avail lcpayres then lcpayres.cacc else v-cacc.
            assign
                  wrk.cur    = v-crcc
                  wrk.sum    = v-sum
                  wrk.jdt    = if avail lcpayres then lcpayres.jdt else g-today
                  wrk.rem    = if avail lcpayres then lcpayres.rem else v-nazn
                  wrk.gl     = 186082.

            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
    end.

end.

if v-ptype <= '3' then do:

    if v-com > 0 then do:
        /* the 5-th posting */
        i = i + 1.
        assign v-dacc = v-arp
               v-cacc = v-comacct.
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode = '9990' and lcpayres.levC = 1 and lcpayres.dacc = v-dacc and lcpayres.cacc = v-cacc no-lock no-error.
        k = k + 1.

        create wrk.
        assign wrk.numdis = string(i)
               wrk.bank   = s-ourbank
               wrk.num    = k
               wrk.dc     = 'Dt'
               wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
               wrk.sum    = if avail lcpayres then lcpayres.amt else v-com
               wrk.cur    = v-crcc
               wrk.jdt    = if avail lcpayres and lcpayres.jh > 0 then lcpayres.jdt else g-today
               wrk.rem    = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc.
        find first arp where arp.arp = wrk.acc no-lock no-error.
        if avail arp then wrk.gl = arp.gl.
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

/********************/

        if v-cacc begins '4' and v-crcc <> 'KZT' then do:
            k = k + 1.
            create wrk.
            assign wrk.dc     = 'Ct'
                   wrk.bank   = s-ourbank
                   wrk.num    = k
                   wrk.acc    = '285800'
                   wrk.gl     = 285800
                   wrk.sum    = if avail lcpayres then lcpayres.amt else v-com
                   wrk.jdt    = if avail lcpayres and lcpayres.jh > 0 then lcpayres.jdt else g-today
                   wrk.cur    = v-crcc
                   wrk.rem    = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc.
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).



            v-amt1 = v-com.
            if not avail lcpayres or lcpayres.jh = 0 or (lcpayres.jh > 0 and g-today = lcpayres.jdt) then do:
                find first crc where crc.crc = v-crc no-lock no-error.
                if avail crc then v-amt1 = v-com * crc.rate[1].

            end.

            if avail lcpayres and lcpayres.jh > 0 and g-today > lcpayres.jdt then do:
                find first crchis where crchis.rdt = lcpayres.jdt and crchis.crc = lcpayres.crc no-lock no-error.
                if avail crchis then v-amt1 = lcpayres.amt * crchis.rate[1].

            end.

            k = k + 1.
            create wrk.
            assign wrk.dc     = 'Dt'
                   wrk.num    = k
                   wrk.bank   = s-ourbank
                   wrk.acc    = '185900'
                   wrk.gl     = 185900
                   wrk.sum    = v-amt1
                   wrk.jdt    = if avail lcpayres and lcpayres.jh > 0 then lcpayres.jdt else g-today
                   wrk.rem    = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc
                   wrk.cur    = 'KZT'.
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).

        end.

/*******************/

        k = k + 1.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.num = k
               wrk.dc  = 'Ct'
               wrk.acc = if avail lcpayres then lcpayres.cacc else v-cacc
               wrk.sum = if v-cacc begins '4' then v-amt1 else (if avail lcpayres then lcpayres.amt else v-com)
               wrk.cur = if v-cacc begins '4' then 'KZT' else v-crcc
               wrk.jdt = if avail lcpayres and lcpayres.jh > 0 then lcpayres.jdt else g-today
               wrk.rem = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc
               wrk.gl  = int(wrk.acc).

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).
    end.
    if v-comi > 0 then do:
        /* the 6-th posting */
        i = i + 1.
        assign v-dacc = v-arp
               v-cacc = v-comaccti.
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode = '9990' and lcpayres.levC = 1 and lcpayres.dacc = v-dacc and lcpayres.cacc = v-cacc no-lock no-error.
        k = k + 1.

        create wrk.
        assign wrk.numdis = string(i)
               wrk.bank   = s-ourbank
               wrk.num    = k
               wrk.dc     = 'Dt'
               wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
               wrk.sum    = if avail lcpayres then lcpayres.amt else v-comi
               wrk.cur    = v-crcc
               wrk.jdt    = if avail lcpayres and lcpayres.jh > 0 then lcpayres.jdt else g-today
               wrk.rem    = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc.
        find first arp where arp.arp = wrk.acc no-lock no-error.
        if avail arp then wrk.gl = arp.gl.
        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).

/********************/
        if v-comaccti begins '4' then do:
            k = k + 1.
            create wrk.
            assign wrk.bank   = s-ourbank
                   wrk.dc     = 'Ct'
                   wrk.num    = k
                   wrk.acc    = '285800'
                   wrk.gl     = 285800
                   wrk.sum    = v-comi
                   wrk.jdt    = if avail lcpayres and lcpayres.jh > 0 then lcpayres.jdt else g-today
                   wrk.cur    = v-crcc
                   wrk.rem    = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc.
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
            v-amt1 = v-comi.
            if not avail lcpayres or lcpayres.jh = 0 or (lcpayres.jh > 0 and g-today = lcpayres.jdt) then do:
                 find first crc where crc.crc = v-crc no-lock no-error.
                 if avail crc then v-amt1 = v-comi * crc.rate[1].

            end.

            if avail lcpayres and lcpayres.jh > 0 and g-today > lcpayres.jdt then do:
                find first crchis where crchis.rdt = lcpayres.jdt and crchis.crc = lcpayres.crc no-lock no-error.
                if avail crchis then v-amt1 = lcpayres.amt * crchis.rate[1].

            end.



            k = k + 1.
            create wrk.
            assign wrk.bank   = s-ourbank
                   wrk.dc     = 'Dt'
                   wrk.num    = k
                   wrk.acc    = '185900'
                   wrk.gl     = 185900
                   wrk.sum    = v-amt1
                   wrk.jdt    = if avail lcpayres and lcpayres.jh > 0 then lcpayres.jdt else g-today
                   wrk.rem    = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc
                   wrk.cur    = 'KZT'.
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.



/*******************/


        k = k + 1.
        create wrk.
        assign wrk.bank   = s-ourbank
               wrk.num = k
               wrk.dc  = 'Ct'
               wrk.acc = if avail lcpayres then lcpayres.cacc else v-cacc
               wrk.sum = if v-comaccti begins '4' then v-amt1 else (if avail lcpayres then lcpayres.amt else v-comi)
               wrk.cur = if v-comaccti begins '4' then 'KZT' else v-crcc
               wrk.jdt = if avail lcpayres and lcpayres.jh > 0 then lcpayres.jdt else g-today
               wrk.rem = if avail lcpayres then lcpayres.rem else 'Оплата комиссии ' + s-lc
               wrk.gl  = int(wrk.acc).

        find first gl where gl.gl = wrk.gl no-lock no-error.
        if avail gl then wrk.gldes = trim(gl.des).
    end.
end.
if v-revolv and v-ptype <> '5' then do:
    /* limit posting */
    i = i + 1.
    assign v-dacc = '612530'
           v-cacc = '662530'
           v-levD = 1.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = v-levD and lcpayres.dacc = v-dacc no-lock no-error.
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
    /*debit*/
    k = k + 1.

    create wrk.
    assign wrk.numdis = string(i)
           wrk.bank   = s-ourbank
           wrk.num    = k
           wrk.dc     = 'Dt'
           wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
           wrk.gl     = int(wrk.acc)
           wrk.cur    = v-crcclim
           wrk.sum    = if avail lcpayres then lcpayres.amt else v-lim-amt
           wrk.jdt    = if avail lcpayres then lcpayres.jdt  else g-today
           wrk.rem    = if avail lcpayres then lcpayres.rem  else 'Восстановление доступного остатка по возобновляемым кредитам в рамках ТФ, ' + s-lc.

    find first gl where gl.gl = int(wrk.acc) no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).

    /*credit*/
    k = k + 1.

    create wrk.
    assign wrk.bank = s-ourbank
           wrk.num  = k
           wrk.dc   = 'Ct'
           wrk.acc  = if avail lcpayres then lcpayres.cacc else v-cacc
           wrk.cur  = v-crcclim
           wrk.sum  = if avail lcpayres then lcpayres.amt else v-lim-amt
           wrk.jdt  = if avail lcpayres then lcpayres.jdt  else g-today
           wrk.rem  = if avail lcpayres then lcpayres.rem  else 'Восстановление доступного остатка по возобновляемым кредитам в рамках ТФ, ' + s-lc
           wrk.gl   = int(wrk.acc).
    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).

end.
if v-ptype = '3' then do:
    assign v-dacc = v-collacc
           v-cacc = v-accnum.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.dacc = v-dacc and lcpayres.cacc = v-cacc no-lock no-error.
    i = i + 1.
    k = k + 1.
    /*debit*/
    create wrk.
    assign wrk.numdis = string(i)
       wrk.bank   = v-bank
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
       wrk.cur    = v-crcc
       wrk.sum    = if avail lcpayres then lcpayres.amt else v-sum
       wrk.jdt    = if avail lcpayres then lcpayres.jdt  else g-today
       wrk.rem    = if avail lcpayres then lcpayres.rem  else v-nazn.
    find first aaa where aaa.aaa = wrk.acc no-lock no-error.
        if avail aaa then do:
            find first trxlev where trxlev.sub = "CIF" and trxlev.lev = 1 and trxlev.gl = aaa.gl no-lock no-error.
            if avail trxlev then do:
                wrk.gl = trxlev.glr.
                find first gl where gl.gl = trxlev.glr no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.
        end.
    /*credit*/
    k = k + 1.

    create wrk.
    assign wrk.bank = v-bank
       wrk.num  = k
       wrk.dc   = 'Ct'
       wrk.acc  = if avail lcpayres then lcpayres.cacc else v-cacc
       wrk.cur  = v-crcc
       wrk.sum  = if avail lcpayres then lcpayres.amt else v-sum
       wrk.jdt  = if avail lcpayres then lcpayres.jdt  else g-today
       wrk.rem  = if avail lcpayres then lcpayres.rem  else v-nazn
       wrk.gl   = int(wrk.acc).
    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).

end.
if v-gar and v-ptype = '1' then do:
    assign v-dacc = v-depacc
           v-cacc = v-accnum.
    find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.dacc = v-dacc and lcpayres.cacc = v-cacc no-lock no-error.
    i = i + 1.
    k = k + 1.
    /*debit*/
    create wrk.
    assign wrk.numdis = string(i)
       wrk.bank   = v-bank
       wrk.num    = k
       wrk.dc     = 'Dt'
       wrk.acc    = if avail lcpayres then lcpayres.dacc else v-dacc
       wrk.cur    = v-crcc
       wrk.sum    = if avail lcpayres then lcpayres.amt else v-sum
       wrk.jdt    = if avail lcpayres then lcpayres.jdt  else g-today
       wrk.rem    = if avail lcpayres then lcpayres.rem  else v-nazn.
    find first aaa where aaa.aaa = wrk.acc no-lock no-error.
        if avail aaa then do:
            find first trxlev where trxlev.sub = "CIF" and trxlev.lev = 1 and trxlev.gl = aaa.gl no-lock no-error.
            if avail trxlev then do:
                wrk.gl = trxlev.glr.
                find first gl where gl.gl = trxlev.glr no-lock no-error.
                if avail gl then wrk.gldes = trim(gl.des).
            end.
        end.
    /*credit*/
    k = k + 1.
    create wrk.
    assign wrk.bank = v-bank
       wrk.num  = k
       wrk.dc   = 'Ct'
       wrk.acc  = if avail lcpayres then lcpayres.cacc else v-cacc
       wrk.cur  = v-crcc
       wrk.sum  = if avail lcpayres then lcpayres.amt else v-sum
       wrk.jdt  = if avail lcpayres then lcpayres.jdt  else g-today
       wrk.rem  = if avail lcpayres then lcpayres.rem  else v-nazn
       wrk.gl   = int(v-acctype).
    find first gl where gl.gl = wrk.gl no-lock no-error.
    if avail gl then wrk.gldes = trim(gl.des).

end.

/* commissions */
for each lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.com and lcpayres.comcode ne '9990' and lcpayres.amt <> 0 no-lock:
    i = i + 1.
    k = k + 1.
    create wrk.
    assign wrk.bank   = lcpayres.bank
           wrk.acc    = lcpayres.dacc
           wrk.dc     = 'Dt'
           wrk.num    = k
           wrk.numdis = string(i)
           wrk.sum    = lcpayres.amt.
    find first aaa where aaa.aaa = lcpayres.dacc no-lock no-error.
    if avail aaa then do:
        find first trxlev where trxlev.sub = "CIF" and trxlev.lev = lcpayres.levD and trxlev.gl = aaa.gl no-lock no-error.
        if avail trxlev then do:
            wrk.gl = trxlev.glr.
            find first gl where gl.gl = aaa.gl no-lock no-error.
            if avail gl then wrk.gldes = trim(gl.des).
        end.
    end.
    find first crc where crc.crc = lcpayres.crc no-lock no-error.
    if avail crc then wrk.cur = crc.code.

    if lcpayres.jh > 0 then wrk.jdt = lcpayres.jdt.
    else wrk.jdt = g-today.
    wrk.rem = lcpayres.rem.

    k = k + 1.
    create wrk.
    assign wrk.bank = lcpayres.bank
           wrk.dc   = 'Ct'
           wrk.num  = k
           wrk.acc  = lcpayres.cacc
           wrk.sum  = lcpayres.amt.
   find first tarif2 where tarif2.str5 = lcpayres.comcode and tarif2.stat = 'r' no-lock no-error.
   if avail tarif2 then
   assign wrk.gl    = tarif2.kont
          wrk.gldes = tarif2.pakal.
   find first crc where crc.crc = lcpayres.crc no-lock no-error.
   if avail crc then wrk.cur = crc.code.

   if lcpayres.jh > 0 then wrk.jdt = lcpayres.jdt.
   else wrk.jdt = g-today.
   wrk.rem = lcpayres.rem.
end.

/* */
on choose of btn-e do:
    output stream m-out to impl_postings.htm.
    put stream m-out unformatted "<html><head><title>ForteBank</title>"
                                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                                 "<p><b>Letter of Credit No / Номер Аккредитива " + s-lc + "</b></p>".
    put stream m-out unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                 "<tr style=""font:bold"">"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">№ / Номер строки</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Bank / Банк</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Debit/Credit / Дебет/Кредит</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Client Account Number / Счет </td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Number / Балансовый счет</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Ledger Account  Description / Наменование Балансового счета</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Amount / Сумма</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Currency / Курс</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Value Date/Дата операции</td>"
                                 "<td bgcolor=""#C0C0C0"" align=""center"">Narrative / Комментарии</td></tr>" skip.

    for each wrk no-lock:
        put stream m-out unformatted
        "<tr>".
/*        if wrk.numdis <> '' then put stream m-out unformatted "<td rowspan = 2>" wrk.numdis "</td>" .*/
        put stream m-out unformatted "<td>" wrk.numdis "</td>" .

        put stream m-out unformatted
        "<td>" wrk.bank "</td>"
        "<td>" wrk.dc "</td>"
        "<td>`" string(wrk.acc) "</td>"

        "<td>`" string(wrk.gl) "</td>"
        "<td>" wrk.gldes "</td>"

        "<td>" replace(replace(trim(string(wrk.sum,'>>>,>>>,>>9.99')),',',' '),'.',',') "</td>"
        "<td>" wrk.cur "</td>"
        "<td>" string(wrk.jdt,'99/99/9999') "</td>"
        "<td>" wrk.rem "</td></tr>" skip.
    end.
    put stream m-out "</table></body></html>" skip.
    output stream m-out close.
    unix silent cptwin impl_postings.htm excel.
end.

OPEN QUERY  qt FOR EACH wrk.
ENABLE ALL WITH FRAME ft.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW. /*or choose of btn-e.*/
