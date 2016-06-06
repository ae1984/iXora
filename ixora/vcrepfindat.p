/* vcrepfindat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Задолжники по финансовым займам
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
        --/--/2013 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
*/
{vcrepfinvar.i}
{comm-txb_txb.i}
{vcconv.i}

def var v-ourbnk as char.
v-ourbnk = comm-txb().

def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

def var v-term as inte.
def var v-lg as logi.
def var v-lender as char.
def var v-borrower as char.
/*--------------------------------------------------------------------------------------------------------------------------------*/
def var v-docsgtd as char.
def var v-docsplat as char.
def var v-docsakt as char.

def var v-sumgtd as deci.
def var v-sumplat as deci.
def var v-sumakt as deci.
def var v-sum as deci.
def var v-sumexc_6 as deci.
def var v-sumost as deci.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then do:
    find comm.txb where comm.txb.bank = txb.sysc.chval no-lock no-error.
    if not avail comm.txb then do:
        MESSAGE "This's no record in comm.txb" view-as alert-box.
        return.
    end.
end.
else do:
    MESSAGE "This's no record in sysc" view-as alert-box.
    return.
end.

v-docsgtd = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("g",trim(txb.codfr.name[5])) > 0 no-lock:
    v-docsgtd = v-docsgtd + trim(txb.codfr.code) + ",".
end.

v-docsplat = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("p",trim(txb.codfr.name[5])) > 0 no-lock:
    v-docsplat = v-docsplat + trim(txb.codfr.code) + ",".
end.

v-docsakt = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("o",trim(txb.codfr.name[5])) > 0 and lookup(trim(txb.codfr.code),"17,07") > 0 no-lock:
    v-docsakt = v-docsakt + trim(txb.codfr.code) + ",".
end.
/*--------------------------------------------------------------------------------------------------------------------------------*/

for each vccontrs where vccontrs.bank = v-ourbnk and vccontrs.cttype = "6" and vccontrs.sts <> "C" no-lock:
    /*if not (vccontrs.ctnum = "111" and vccontrs.ctdate = 08/12/2011) then next.*/ /*TEMP*/

    v-lg = false.
    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if not (avail txb.cif and substr(string(txb.cif.geo,"999"),3,1) = "1") then next.

    find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" no-lock no-error.
    find first vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
    /*Срок движения капитала*/
    v-term = 0.
    run check_term (vccontrs.contract, ?, ?, ?, ?, v-dt, output v-term).

    /* сумма актов по контракту */
    v-sumakt = 0.
    for each vcdocs where vcdocs.contract = vccontrs.contract no-lock:
        if not (lookup(trim(vcdocs.dntype),v-docsakt) > 0 and vcdocs.dndate < v-dt) then next.

        if vcdocs.payret then v-sum = - vcdocs.sum.
        else v-sum = vcdocs.sum.
        v-sum = v-sum / vcdocs.cursdoc-con.
        accumulate v-sum(total).
    end.
    v-sumakt = (accum total v-sum).

    /* сумма ГТД по контракту */
    v-sumgtd = 0.
    for each vcdocs where vcdocs.contract = vccontrs.contract no-lock:
        if not (lookup(trim(vcdocs.dntype),v-docsgtd) > 0 and vcdocs.dndate < v-dt) then next.

        if vcdocs.payret then v-sum = - vcdocs.sum.
        else v-sum = vcdocs.sum.
        v-sum = v-sum / vcdocs.cursdoc-con.
        accumulate v-sum(total).
    end.
    v-sumgtd = (accum total v-sum).

    /* сумма платежных документов по контракту */
    v-sumplat = 0.
    for each vcdocs where vcdocs.contract = vccontrs.contract and (if vccontrs.expimp = 'i' then vcdocs.dntype = '03' else vcdocs.dntype = '02') and vcdocs.info[2] = '1' no-lock:
        if not (lookup(trim(vcdocs.dntype),v-docsplat) > 0 and vcdocs.dndate < v-dt) then next.

        if vcdocs.payret then v-sum = - vcdocs.sum.
        else v-sum = vcdocs.sum.
        v-sum = v-sum / vcdocs.cursdoc-con.
        accumulate v-sum(total).
    end.
    v-sumplat = (accum total v-sum).

    v-sumexc_6 = 0.
    for each vcdocs where vcdocs.contract = vccontrs.contract and (if vccontrs.expimp = 'i' then vcdocs.dntype = '02' else vcdocs.dntype = '03') and vcdocs.info[2] = '1' no-lock:
        if not (lookup(trim(vcdocs.dntype),v-docsplat) > 0 and vcdocs.dndate < v-dt) then next.

        if vcdocs.payret then v-sum = - vcdocs.sum.
        else v-sum = vcdocs.sum.
        v-sum = v-sum / vcdocs.cursdoc-con.
        accumulate v-sum (total).
    end.
    v-sumexc_6 = (accum total v-sum).

    /*Остаток*/
    v-sumost = v-sumplat - v-sumexc_6.

    /*message "v-sumost=" v-sumost skip "v-sumplat=" v-sumplat skip "v-sumexc_6=" v-sumexc_6 view-as alert-box.

    message "v-term=" v-term "sumUSD=" konv2usd(v-sumost,vccontrs.ncrc,v-dt - 1) view-as alert-box.*/

    if vccontrs.expimp = "E" then do:
        v-lg = v-term > 180 and konv2usd(v-sumost,vccontrs.ncrc,v-dt - 1) > 500000 and not avail vcrslc.

        v-lender = trim(trim(vcpartners.formasob) + " " + trim(vcpartners.name)).
        v-borrower = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
    end.
    else do:
        v-lg = v-term > 180 and konv2usd(v-sumost,vccontrs.ncrc,v-dt - 1) > 100000 and not avail vcrslc.

        v-lender = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
        v-borrower = trim(trim(vcpartners.formasob) + " " + trim(vcpartners.name)).
    end.

    if v-lg then do:
        create t-dolgs.
        t-dolgs.lender = v-lender.
        t-dolgs.borrower = v-borrower.
        t-dolgs.ctnum = vccontrs.ctnum.
        t-dolgs.ctdate = vccontrs.ctdate.
        t-dolgs.sumdolg = konv2usd(v-sumost,vccontrs.ncrc,v-dt - 1).
        t-dolgs.ctterm = string(v-term).
    end.

    hide message no-pause.
    message comm.txb.info " - " LN[i].
    if i = 8 then i = 1.
    else i = i + 1.
end.

