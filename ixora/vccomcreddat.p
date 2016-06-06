/* vccomcreddat.p
 * MODULE
        Название модуля - Валютный контроль
 * DESCRIPTION
        Описание - Сбор данных branch
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - vccomcred.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур - vccomcred.p
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        25.12.2012 damir - Внедрено Т.З. 1306.
*/

{vccomcredvar.i}
{vcconv.i}

def var v-ourbnk as char.
def var v-nambnk as char.
def var v-cttype as char.
def var v-expimp as char.
def var v-workcond as logi.

def temp-table vcdoc
    field contr  as inte
    field dt     as date
    field sum    as deci
    field docsum as deci
    field sts    as inte.

def temp-table vcdocum
    field contr  as inte
    field dt     as date.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-ourbnk = trim(txb.sysc.chval).

find first txb.cmp no-lock no-error.
if avail txb.cmp then v-nambnk = trim(txb.cmp.name).

v-cttype = "11".
v-expimp = "I".

{vcdocsdiffcoll_txb.i}

for each vccontrs where trim(vccontrs.bank) = v-ourbnk and lookup(trim(vccontrs.cttype),v-cttype) > 0 and
trim(vccontrs.expimp) = v-expimp no-lock:
    if vccontrs.ctdate < s-dtb then next.
    if vccontrs.sts begins "C" and ((not s-closed) or (s-closed and vccontrs.udt < s-dte)) then next.

    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if avail txb.cif then do:
        v-workcond = false.

        {vcdocsdifferent.i}

        {vc_com_exp-cred.i &cttype = "11" &limitexp = "50000" &limitimp = "50000"}

        if v-workcond then do:
            create t-dolgs.
            t-dolgs.txb = v-ourbnk.
            t-dolgs.ncrc = vccontrs.ncrc.
            t-dolgs.days = (s-dte - 1) - vv-term.
            t-dolgs.sumcon = konv2concrc(v-sumplat - (v-sumgtd + v-sumakt),2,vccontrs.ncrc,s-dte - 1).
            t-dolgs.sumusd = v-sumplat - (v-sumgtd + v-sumakt).
            t-dolgs.sumdolg = vv-summa - v-PayReturn.
            t-dolgs.srokrep = check_term(vccontrs.ctterm).
            t-dolgs.cif = txb.cif.cif.
            t-dolgs.depart = inte(txb.cif.jame) mod 1000.
            t-dolgs.namefil = v-nambnk.
            t-dolgs.cifname = trim(txb.cif.sname) + " " + trim(txb.cif.prefix).
            t-dolgs.cifrnn = txb.cif.jss.
            t-dolgs.cifokpo = txb.cif.ssn.
            t-dolgs.contract = vccontrs.contract.
            t-dolgs.ctdate = vccontrs.ctdate.
            t-dolgs.ctterm = vccontrs.ctterm.
            t-dolgs.ctnum = vccontrs.ctnum.
            t-dolgs.ctei = vccontrs.expimp.
            find first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "40" no-lock no-error.
            if available vcdocs then do:
                t-dolgs.cardnum = vccontrs.cardnum.
                t-dolgs.carddt = vccontrs.cardformmc.
            end.
        end.
    end.
end.