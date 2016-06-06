/* vcrepk8dat.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        28.05.2012 aigul
 * BASES
        BANK TXB COMM
 * CHANGES
        16.07.2012 damir - подкинул, добавил vcmtform_txb.i,funcvc_txb.i, пропускаем контракты меньше 10000 USD, обработку данных запись производится в
        wrkTemp.
        05.03.2013 damir - Внедрено Т.З. № 1713.
*/
def shared var g-ofc like txb.ofc.ofc.
def shared var g-today as date.

{vcmtform_txb.i}
{funcvc_txb.i}
{vcrepk8var.i}
{vc-crosscurs_txb.i}

def input parameter p-bank as char.

def var v-bank as char.
def var v-bcode as char.
def var v-sumi as decimal.
def var v-sumiusd as decimal.
def var v-sume as decimal.
def var v-sumeusd as decimal.
def var v-addr as char.
def var v-region  as char.
def var v-cursdoc-usd as decimal.
def var v-totalsume as deci.
def var v-totalsumi as deci.
def var v-totalsum as deci.
def var v-sum1 as deci.
def var v-sum2 as deci.

def buffer b-wrk  for wrk.
def buffer b-wrk2 for wrk.

find txb.cmp no-lock no-error.
v-bank = txb.cmp.name.
v-bcode = substr(string(txb.cmp.code),1,2).
if length(v-bcode) < 2 then v-bcode = "0" + v-bcode.

for each vccontrs where vccontrs.bank = p-bank and vccontrs.cttype = "2" no-lock break by vccontrs.cttype:
    if konv2usd(vccontrs.ctsum, vccontrs.ncrc, vccontrs.ctdate) < 10000 then next.
    create wrk.
    wrk.bank = vccontrs.bank.
    wrk.cif = vccontrs.cif.
    wrk.bbin = s-bnkbin.
    wrk.contract = vccontrs.contract.
    wrk.ctnum = vccontrs.ctnum.
    wrk.ctdate = vccontrs.ctdate.
    find vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
    if avail vcpartner then wrk.partner = trim(vcpartner.name) + " " + trim(vcpartner.formasob).
    find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if avail txb.cif then do:
        wrk.cname = trim(txb.cif.sname) + " " + txb.cif.prefix.
        wrk.prefix = txb.cif.prefix.
        if v-bin then do:
            wrk.bin = txb.cif.bin.
            wrk.rnn = txb.cif.jss.
        end.
        wrk.okpo = trim(txb.cif.ssn).
        v-addr = trim(txb.cif.addr[1]).
        if trim(txb.cif.addr[2]) <> "" then do:
            if v-addr <> "" then v-addr = v-addr + "; ".
            v-addr = v-addr + trim(txb.cif.addr[2]).
        end.
        v-addr = trim(substr(v-addr, 1, 100)).
        wrk.adr = v-addr.
        find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "regionkz"
        and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-region = txb.sub-cod.ccode.
        else v-region = "".
        wrk.obl = v-region.
        if txb.cif.prefix = "ТОО" then wrk.ctype = "1".
        if txb.cif.prefix = "ИП" then wrk.ctype = "2".
    end.
    wrk.expimp = vccontrs.expimp.
    if vccontrs.expimp = "i" then wrk.inout = "1".
    if vccontrs.expimp = "e" then wrk.inout = "2".

    v-sumi = 0.
    v-sume = 0.

    for each vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dndate >= v-dt1 and vcdocs.dndate <= v-dt2  and
    (vcdocs.dntype = "02" or vcdocs.dntype = "03")  no-lock:
        if vcdocs.dntype = "02" and vccontrs.expimp = "e" then do:
            v-sumeusd = konv2usd(vcdocs.sum,vcdocs.pcrc,vcdocs.dndate).
            v-sume = v-sume + v-sumeusd.
        end.
        if vcdocs.dntype = "03" and vccontrs.expimp = "i" then do:
            v-sumiusd = konv2usd(vcdocs.sum,vcdocs.pcrc,vcdocs.dndate).
            v-sumi = v-sumi + v-sumiusd.
        end.
    end.
    wrk.amte = v-sume.
    wrk.amti = v-sumi.
end.

for each wrk no-lock break by wrk.cif:
    if first-of(wrk.cif) then do:
        for each b-wrk where b-wrk.cif = wrk.cif no-lock break by b-wrk.expimp:
            if first-of(b-wrk.expimp) then do:
                v-sum1 = 0. v-sum2 = 0.
                for each b-wrk2 where b-wrk2.cif = b-wrk.cif and b-wrk2.expimp = b-wrk.expimp no-lock:
                    v-sum1 = v-sum1 + b-wrk2.amte.
                    v-sum2 = v-sum2 + b-wrk2.amti.
                end.
                create wrkTemp.
                wrkTemp.bank     = wrk.bank.
                wrkTemp.cif      = wrk.cif.
                wrkTemp.bbin     = wrk.bbin.
                wrkTemp.contract = wrk.contract.
                wrkTemp.ctnum    = wrk.ctnum.
                wrkTemp.ctdate   = wrk.ctdate.
                wrkTemp.cname    = wrk.cname.
                wrkTemp.okpo     = wrk.okpo.
                wrkTemp.prefix   = wrk.prefix.
                wrkTemp.partner  = wrk.partner.
                wrkTemp.bin      = wrk.bin.
                wrkTemp.rnn      = wrk.rnn.
                wrkTemp.ctype    = wrk.ctype.
                wrkTemp.adr      = wrk.adr.
                wrkTemp.obl      = wrk.obl.
                wrkTemp.inout    = wrk.inout.
                wrkTemp.expimp   = b-wrk.expimp.
                wrkTemp.amti     = v-sum2.
                wrkTemp.amte     = v-sum1.
                wrkTemp.note     = wrk.note.
                /*if v-sum1 > 100000 or v-sum2 > 100000 then message wrk.cif b-wrk.expimp v-sum1 v-sum2 view-as alert-box.*/
            end.
        end.
    end.
end.

for each wrk exclusive-lock:
    delete wrk.
end.