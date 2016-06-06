/* vcrepexpire1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по истекшим контрактам
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
        17.01.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        20.01.2012 aigul - исправила поиск последних плат дк
*/

def var v-client as char.
def var v-fil as char.
def var v-id as char.
def var i as integer.
def input parameter p-bank as char.
def input parameter dt as date.
def input parameter v-cttype as char.
/*def input parameter v-dtb       as date.
def input parameter v-dte       as date.*/
def var v-sum-docs as decimal.
def var v-sum-act as decimal.
def var v-sum02 as decimal.
def var v-sum03 as decimal.
def var v-sum-docs1 as decimal.
def var v-sum-act1 as decimal.
def var v-sum021 as decimal.
def var v-sum031 as decimal.
def var v-sume as decimal.
def var v-sumi as decimal.
def new shared var v-cif like cif.cif.
def new shared var v-cifname as char.
def new shared var v-rnn as char.
def new shared var v-depart as int.
def new shared var v-ppname as char.
def shared temp-table wrk
    field cif as char
    field fil as char
    field num as int
    field cif_name as char
    field ctnum as char
    field ctdate as date
    field cttype as char
    field psnum as char
    field ctsum as decimal format ">>>,>>>,>>>,>>9.99"
    field ctval as char
    field lastdt as date
    field expimp as char.
def buffer b-ncrchis for ncrchis.
def var v-sts as logical initial no.
for each vccontrs where (vccontrs.bank = p-bank or p-bank = "ALL") and (vccontrs.cttype = v-cttype or v-cttype = 'ALL')
and vccontrs.lastdate <> ? and vccontrs.lastdate < dt and vccontrs.sts <> "C" no-lock break by vccontrs.cif:
    if first-of(vccontrs.cif) then do:
        v-cif = vccontrs.cif.
        if connected ("txb") then disconnect "txb".
        find first comm.txb where comm.txb.bank = vccontrs.bank and comm.txb.consolid = true no-lock no-error.
        if avail comm.txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run vcrequest-bank (vccontrs.bank,vccontrs.cif, vccontrs.rwho, output v-cifname, output v-fil, output v-id).
            disconnect "txb".
        end.
    end.

    v-sum-docs = 0.
    v-sum-docs1 = 0.
    v-sum-act = 0.
    v-sum-act1 = 0.
    v-sum02 = 0.
    v-sum021 = 0.
    v-sum03 = 0.
    v-sum031 = 0.
    v-sume = 0.
    v-sumi = 0.
    def buffer b-vcdocs for vcdocs.
    /*find first vcps where vcps.contract = vccontrs.contract  no-lock no-error.
    if avail vcps then do:
        if vcps.dntype <> "01" then next.
    end.*/
    for each vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock:
        for each vcdocs where vcdocs.contract = vccontrs.contract
        and (vcdocs.dntype = "14" or vcdocs.dntype = "17" or vcdocs.dntype = "02" or vcdocs.dntype = "03")
        and vcdocs.dndate < (dt - 365) no-lock:
            /*find first b-vcdocs where b-vcdocs.contract = vcdocs.contract and b-vcdocs.dndate > (dt - 365) no-lock
            no-error.
            if avail b-vcdocs then next.*/
            if vcdocs.dntype = "14" then do:
                do i = 1 to num-entries(vcdocs.sumpercent) :
                    v-sum-docs1 = vcdocs.sum * integer(entry(i, vcdocs.sumpercent)) / 100 / vcdocs.cursdoc-con.
                    accumulate v-sum-docs1 (total).
                end.
            end.
            v-sum-docs = (accum total v-sum-docs1).

            if vcdocs.dntype = "02" then do:
                do i = 1 to num-entries(vcdocs.sumpercent) :
                    v-sum021 = vcdocs.sum * integer(entry(i, vcdocs.sumpercent)) / 100 / vcdocs.cursdoc-con.
                    accumulate v-sum021 (total).
                end.
            end.
            v-sum02 = (accum total v-sum021).

            if vcdocs.dntype = "03" then do:
                do i = 1 to num-entries(vcdocs.sumpercent) :
                    v-sum031 = vcdocs.sum * integer(entry(i, vcdocs.sumpercent)) / 100 / vcdocs.cursdoc-con.
                    accumulate v-sum031 (total).
                end.
            end.
            v-sum03 = (accum total v-sum031).

            if vcdocs.dntype = "17" then do:
                do i = 1 to num-entries(vcdocs.sumpercent) :
                    v-sum-act1 = vcdocs.sum * integer(entry(i, vcdocs.sumpercent)) / 100 / vcdocs.cursdoc-con.
                    accumulate v-sum-act1 (total).
                end.
            end.
            v-sum-act = (accum total v-sum-act1).
        end.
        find last vcdocs where vcdocs.contract = vccontrs.contract and
        (vcdocs.dntype = "14" or vcdocs.dntype = "17" or vcdocs.dntype = "02" or vcdocs.dntype = "03") no-lock
        no-error.
        if avail vcdocs and vcdocs.dndate + 365  < dt then do:
            if vccontrs.expimp = "e" then v-sume = v-sum02 - v-sum03.
            if vccontrs.expimp = "i" then v-sumi = v-sum03 - v-sum02.
            /*if vccontrs.expimp = "e" and (v-sume <> v-sum-docs + v-sum-act or (v-sume - v-sum-docs + v-sum-act) > 50000)  then next.*/
            if (vccontrs.expimp = "i" and (v-sumi = v-sum-docs + v-sum-act or (v-sumi - v-sum-docs + v-sum-act) <= 50000))
            or (vccontrs.expimp = "e" and (v-sume = v-sum-docs + v-sum-act or (v-sume - v-sum-docs + v-sum-act) <= 50000)) then do:
                create wrk.
                if v-cifname <> "" then wrk.cif_name = v-cifname.
                else wrk.cif_name = vccontrs.cif.
                wrk.cif = vccontrs.cif.
                wrk.ctnum = vccontrs.ctnum.
                wrk.ctdate = vccontrs.ctdate.
                wrk.cttype = vccontrs.cttype.
                if vccontrs.cttype = "1" then wrk.psnum = vcps.dnnum + string(vcps.num).
                else wrk.psnum = "".
                wrk.ctsum = vccontrs.ctsum.
                find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
                if avail ncrc then wrk.ctval = ncrc.code.
                wrk.lastdt = vccontrs.lastdate.
                wrk.expimp = vccontrs.expimp.
                wrk.fil = v-fil.
            end.
        end.
    end.
end.



