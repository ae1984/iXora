/* vcrep7dat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
     Приложения 7,Отчет о задолжниках по контрактам с ПС, по услугам и фин.займам, MT-105
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM TXB
 * AUTHOR
        16.05.2008 galina
 * CHANGES
        26.05.2008 galina - обнуление значения v-term
        27.05.2008 galina - перекопеляция
        02.02.2009 galina - берем курс доллара из ncrchis
        28/07/2009 galina - исправила адрес клиента и ОКПО банка
        29/10/2009 galina - не выводим в отчет, если сумма нарушения меньше 50 тысяч
        04.04.2011 damir  - добавил к каждому find if avail, добавил во временную табл. данные, через формальные(шт 5). выдавало ошибку.
                            bnkbin,iin,bin во временную таблицу.
                            v-crc,v-bankokpo,v-region,v-prefix,v-address добавил.
        28.04.2011 damir  - поставлены ключи. процедура chbin.i
        06.12.2011 damir - убрал chbin.i, поставил vcmtform.i.
        09.10.2013 damir - Т.З. № 1670.
*/
{vc.i}
{vcmtform_txb.i} /*переход на БИН и ИИН*/

def shared var g-ofc as char.
def shared var g-today as date.

{vc-crosscurs_txb.i}

def input parameter p-vcbank as char.
def input parameter p-depart as inte.
def input parameter p-contract as inte.

def var v-sumgtd as deci.
def var v-sumplat as deci.
def var v-sumost as deci.
def var v-sumkon as deci.
def var v-sumakt as deci.
def var v-sumexc_6 as deci.
def var v-sumgtd_usd as deci.
def var v-sumplat_usd as deci.
def var v-sumost_usd as deci.
def var v-sumkon_usd as deci.
def var v-sumakt_usd as deci.
def var v-sumexc_6_usd as deci.
def var v-term as inte.
def var vp-days as inte.
def var v-name as char no-undo.
def var v-rnn as char no-undo.
def var v-okpo as char no-undo.
def var v-country as char no-undo.
def var v-partnername as char no-undo.
def var v-countryben as char no-undo.
def var v-clntype as char no-undo.
def var v-expimp as char no-undo.
def var v-psnum as char no-undo.
def var v-psdate as date no-undo.
def var v-bincif as char no-undo.
def var v-iincif as char no-undo.
def var v-crc as char no-undo.
def var v-bankokpo as char no-undo.
def var v-region as char no-undo.
def var v-prefix as char no-undo.
def var v-address as char no-undo.
def var v-bnkbin as char.
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

def temp-table t-dntype
    field dntype as char
    index dntype is primary dntype.

def shared var s-vcourbank as char.
def shared var v-god as inte format "9999".
def shared var v-month as inte format "99".
def shared var v-dte as date.
def shared var v-dtb as date.
def shared var v-oper as char.
def shared var s-cif as char.
def shared var s-contract as inte.
def shared var s-contrstat as char initial 'all'.

def shared temp-table t-docs
    field clcif         as char
    field clname        as char
    field okpo          as char format "999999999999"
    field rnn           as char format "999999999999"
    field clntype       as char
    field address       as char
    field region        as char
    field psnum         as char
    field psdate        as date
    field bankokpo      as char
    field ctexpimp      as char
    field ctnum         as char
    field ctdate        as date
    field ctsum         as char
    field ctncrc        as char
    field partner       like vcpartners.name
    field countryben    as char
    field ctterm        as char
    field dolgsum       as char
    field dolgsum_usd   as char
    field cardsend      like vccontrs.cardsend
    field valterm       as integer
    field prefix        as char
    field bnkbin        as char
    field bin           as char
    field iin           as char
    index main is primary clcif ctdate ctsum.

def shared temp-table t-cif
    field clcif       as char
    field clname      as char
    field okpo        as char format "999999999999"
    field rnn         as char format "999999999999"
    field clntype     as char
    field address     as char
    field region      as char
    field psnum       as char
    field psdate      as date
    field bankokpo    as char
    field ctexpimp    as char
    field ctnum       as char
    field ctdate      as date
    field ctsum       as char
    field ctncrc      as char
    field partner     like vcpartners.name
    field countryben  as char
    field ctterm      as char
    field cardsend    like vccontrs.cardsend
    field prefix      as char
    field bnkbin      as char
    field bin         as char
    field iin         as char
    index main is primary clcif ctdate ctsum.

find first txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
if avail txb.sysc then v-bnkbin = txb.sysc.chval.

for each vccontrs where (p-contract = 0 and vccontrs.bank = p-vcbank and (vccontrs.cttype = '1' or vccontrs.cttype = '3' or  vccontrs.cttype = '6')) or
(p-contract > 0 and vccontrs.contract = p-contract)  no-lock:
    if vccontrs.sts = 'C' then next.

    assign v-bincif = "" v-iincif = "" v-clntype = "" v-rnn = "" v-okpo = "" v-name = "" v-expimp = "" v-term = 0 v-prefix = "" v-address = "".

    if vccontrs.expimp = 'e' then v-expimp = "1".
    if vccontrs.expimp = 'i' then v-expimp = "2".

    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.

    /*if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.*/

    v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
    if v-bin = yes then do:
        if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then do:
            v-clntype = "1".
            v-rnn    = "".
            v-okpo   = txb.cif.ssn.
            v-bincif = txb.cif.bin.
        end.
        if (txb.cif.type = 'B' and txb.cif.cgr = 403) then do:
            v-clntype = "2".
            v-rnn     = txb.cif.jss.
            v-okpo    = "".
            v-iincif  = txb.cif.bin.
        end.
    end.
    else do:
        if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then do: v-clntype = "1". v-rnn = "". v-okpo = txb.cif.ssn. end.
        if (txb.cif.type = 'B' and txb.cif.cgr = 403) then do: v-clntype = "2". v-rnn = txb.cif.jss. v-okpo = "". end.
    end.

    v-prefix = trim(txb.cif.prefix).
    v-address = txb.cif.addr[1] + ' ' + txb.cif.addr[2].

    if vccontrs.sts = "N" and (vccontrs.ctdate >= v-dtb and vccontrs.ctdate <= v-dte) then do:
        if (vccontrs.cttype = '6' or vccontrs.cttype = '3') then do:
            vp-days = (integer(substring(vccontrs.ctterm,5,2)) * 360) + integer(substring(vccontrs.ctterm,1,3)).
            if (vp-days < 360 or (vccontrs.ctsum / vccontrs.cursdoc-usd) < 10000) then next.
        end.
        else next.
    end.
    else if vccontrs.sts <> "C" then do:
        vp-days = (integer(substring(vccontrs.ctterm,5,2)) * 360) + integer(substring(vccontrs.ctterm,1,3)).
        run check_sumdlg(vccontrs.contract, v-dte).
        if ((vccontrs.expimp = 'e' and v-sumost_usd > 0) or (vccontrs.expimp = 'i' and v-sumost_usd < 0)) and absolute(v-sumost_usd) > 50000 then do:
            run check_term (vccontrs.contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, v-dte, output v-term).
            if v-term < vp-days then next.
        end.
        else next.
    end.

    find first txb.cmp no-lock no-error.
    if avail txb.cmp then v-bankokpo = substr(txb.cmp.addr[3], 1, 12).
    else v-bankokpo = "".

    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error.
    if avail txb.sub-cod then v-region = txb.sub-cod.ccode.
    else v-region = "".

    assign v-psnum = "" v-psdate = ?.

    if vccontrs.cttype = '1' then do:
        find vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.
        if avail vcps then do:
            v-psnum = vcps.dnnum + string(vcps.num).
            v-psdate = vcps.dndate.
        end.
        else do:
            v-psnum = "".
            v-psdate = ?.
        end.
    end.

    find txb.crc where txb.crc.crc = vccontrs.ncrc no-lock no-error.
    if avail txb.crc then v-crc = string(txb.crc.code).

    find vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
    if avail vcpartner then v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).

    create t-docs.
    t-docs.clcif = vccontrs.cif.
    t-docs.clname = v-name.
    t-docs.okpo = v-okpo.
    t-docs.rnn = v-rnn.
    t-docs.clntype = v-clntype.
    t-docs.address = v-address.
    t-docs.region = v-region.
    t-docs.psnum = v-psnum.
    t-docs.psdate = v-psdate.
    t-docs.bankokpo = v-bankokpo.
    t-docs.ctexpimp = v-expimp.
    t-docs.ctnum = vccontrs.ctnum.
    t-docs.ctdate = vccontrs.ctdate.
    t-docs.ctsum = trim(string((vccontrs.ctsum / 1000), ">>>>>>>>>>>>>>9.99")).
    t-docs.ctncrc = v-crc.
    t-docs.partner = v-partnername.
    t-docs.countryben = vcpartner.country.
    t-docs.ctterm = vccontrs.ctterm.
    t-docs.dolgsum = trim(string((absolute(v-sumost) / 1000), ">>>>>>>>>>>>>>9.99")).
    t-docs.dolgsum_usd = trim(string((absolute(v-sumost_usd) / 1000), ">>>>>>>>>>>>>>9.99")).
    t-docs.cardsend = vccontrs.cardsend.
    t-docs.valterm = v-term.
    t-docs.prefix = v-prefix.
    if v-bin then do:
        t-docs.bnkbin = v-bnkbin.
        t-docs.bin = v-bincif.
        t-docs.iin = v-iincif.
    end.

    hide message no-pause.
    message LN[i].
    if i = 8 then i = 1.
    else i = i + 1.
end.

procedure check_sumdlg.
    def input parameter p-contract like vccontrs.contract.
    def input parameter p-dte as date.

    def var vp-curs as deci no-undo.
    def var vp-sum as deci.
    def var vp-sum_usd as deci.
    def var i as integer.

    find vccontrs where vccontrs.contract = p-contract no-lock no-error.

    /* статус */
    if lookup(vccontrs.sts, "a,s") > 0 or vccontrs.sts = "n" then do:
        find first vcps where vcps.contract = p-contract no-lock no-error.
        find first vcdocs where vcdocs.contract = p-contract no-lock no-error.
        if (lookup(vccontrs.sts, "a,s") > 0 and (not avail vcps) and (not avail vcdocs)) or
        (vccontrs.sts = "n" and ((avail vcps) or (avail vcdocs))) then
        do transaction:
            find current vccontrs exclusive-lock.
            if avail vccontrs then do:
                if lookup(vccontrs.sts, "a,s") > 0 then vccontrs.sts = "N".
                else vccontrs.sts = "A".
            end.
            find current vccontrs no-lock.
        end.
    end.

    if vccontrs.sts <> "N" then do:
        /* ГТД */
        for each t-dntype. delete t-dntype.
        end.
        for each txb.codfr where txb.codfr.codfr = "vcdoc" and txb.codfr.name[5] = "g" no-lock:
            create t-dntype.
            t-dntype.dntype = txb.codfr.code.
        end.
        v-sumgtd = 0.
        v-sumgtd_usd = 0.
        for each vcdocs where vcdocs.contract = p-contract and
        can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) and vcdocs.dndate <= p-dte no-lock:
            if vcdocs.payret then vp-sum = - vcdocs.sum.
            else vp-sum = vcdocs.sum.
            run crosscurs (vcdocs.pcrc, 2, vcdocs.dndate, output vp-curs).
            vp-sum_usd = vp-sum / vp-curs.
            vp-sum = vp-sum / vcdocs.cursdoc-con.
            accumulate vp-sum (total).
            accumulate vp-sum_usd (total).
        end.
        v-sumgtd = (accum total vp-sum).
        v-sumgtd_usd = (accum total vp-sum_usd).

        if vccontrs.cttype = '6' then do:
          /*сумма полученного займа*/
            for each t-dntype. delete t-dntype.
            end.
            for each txb.codfr where txb.codfr.codfr = "vcdoc" and txb.codfr.name[5] = "p" no-lock:
                create t-dntype.
                t-dntype.dntype = txb.codfr.code.
            end.
            v-sumexc_6 = 0.
            v-sumexc_6_usd = 0.
            for each vcdocs where vcdocs.contract = p-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) and
            (if vccontrs.expimp = 'i' then vcdocs.dntype = '02' else vcdocs.dntype = '03') and vcdocs.info[2] = '1' and vcdocs.dndate <= p-dte no-lock:
                if vcdocs.payret then vp-sum = - vcdocs.sum.
                else vp-sum = vcdocs.sum.
                run crosscurs (vcdocs.pcrc, 2, vcdocs.dndate, output vp-curs).
                vp-sum_usd = vp-sum / vp-curs.
                vp-sum = vp-sum / vcdocs.cursdoc-con.
                accumulate vp-sum (total).
                accumulate vp-sum_usd (total).
            end.
            v-sumexc_6 = (accum total vp-sum).
            v-sumexc_6_usd = (accum total vp-sum_usd).

            /*погашение займа*/

            for each t-dntype. delete t-dntype.
            end.
            for each txb.codfr where txb.codfr.codfr = "vcdoc" and txb.codfr.name[5] = "p" no-lock:
                create t-dntype.
                t-dntype.dntype = txb.codfr.code.
            end.
            v-sumplat = 0.
            v-sumplat_usd = 0.
            for each vcdocs where vcdocs.contract = p-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) and
            (if vccontrs.expimp = 'i' then vcdocs.dntype = '03' else vcdocs.dntype = '02')and vcdocs.info[2] = '1' and vcdocs.dndate <= p-dte no-lock:
                if vcdocs.payret then vp-sum = - vcdocs.sum.
                else vp-sum = vcdocs.sum.
                run crosscurs (vcdocs.pcrc, 2, vcdocs.dndate, output vp-curs).
                vp-sum_usd = vp-sum / vp-curs.
                vp-sum = vp-sum / vcdocs.cursdoc-con.
                accumulate vp-sum (total).
                accumulate vp-sum_usd (total).
            end.
            v-sumplat = (accum total vp-sum).
            v-sumplat_usd = (accum total vp-sum_usd).
        end.
        else do:
            v-sumexc_6 = 0.
        end.

        /* Платежные док-ты */

        if vccontrs.cttype <> '6' then do:
            for each t-dntype. delete t-dntype.
            end.
            for each txb.codfr where txb.codfr.codfr = "vcdoc" and txb.codfr.name[5] = "p" no-lock:
                create t-dntype.
                t-dntype.dntype = txb.codfr.code.
            end.
            v-sumplat = 0.
            v-sumplat_usd = 0.
            for each vcdocs where vcdocs.contract = p-contract and can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) and vcdocs.dndate <= p-dte no-lock:
                if vcdocs.payret then vp-sum = - vcdocs.sum.
                else vp-sum = vcdocs.sum.
                run crosscurs (vcdocs.pcrc, 2, vcdocs.dndate, output vp-curs).
                vp-sum_usd = (vp-sum / vp-curs).
                vp-sum = (vp-sum / vcdocs.cursdoc-con).
                accumulate vp-sum (total).
                accumulate vp-sum_usd (total).
            end.
            v-sumplat = (accum total vp-sum).
            v-sumplat_usd = (accum total vp-sum_usd).
        end.

        /* Акты */
        v-sumakt = 0.
        v-sumakt_usd = 0.
        for each vcdocs where vcdocs.contract = p-contract and vcdocs.dntype = "17" and vcdocs.dndate <= p-dte no-lock:
            run crosscurs (vcdocs.pcrc, 2, vcdocs.dndate, output vp-curs).
            accumulate vcdocs.sum / vcdocs.cursdoc-con (total).
            accumulate vcdocs.sum / vp-curs(total).
        end.
        v-sumakt = (accum total vcdocs.sum / vcdocs.cursdoc-con).
        v-sumakt_usd = (accum total vcdocs.sum / vp-curs).
    end.
    else do:
        v-sumgtd = 0.
        v-sumplat = 0.
        v-sumexc_6 = 0.
    end.

    if vccontrs.cttype = '6' then do:
        v-sumkon = v-sumexc_6.
        v-sumkon_usd = v-sumexc_6_usd.
    end.

    if vccontrs.cttype = '3' then do:
        v-sumkon = v-sumakt.
        v-sumkon_usd = v-sumakt_usd.
    end.

    if vccontrs.cttype = '2' or vccontrs.cttype = '1' then do:
        v-sumkon = v-sumgtd.
        v-sumkon_usd = v-sumgtd_usd.
    end.
    v-sumost = v-sumkon - v-sumplat.
    v-sumost_usd = v-sumkon_usd - v-sumplat_usd.
end.
