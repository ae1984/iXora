/* sbork3.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        27/09/2012 id01143
 * BASES
        BANK COMM TXB
 * CHANGES
        06/02/2013 sayat(id01143) - ТЗ № 1697 1)добавлен перевод в тенге сумм залогов-депозитов,
                                              2)добавлен расчет суммы обеспечения по частично покрытым УО из ТФ
                                              3)добавлен переход на ИИН/БИН
        02/09/2013 galina - ТЗ1918 перекомпиляция

 */

def input parameter p-dt as date.

/******************************************************************************/

def var v-fil     as   char format "x(10)".
def var v-amt     as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-prsramt as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-prvzamt as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-cif     as   char format "x(10)".
def var v-dt      as   date format "99/99/9999".
def var v-zalamt  as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-zalgar  as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-zaldep  as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-zalog   as   char format "x(80)".
def var v-zalog1  as   char format "x(80)".
def var v-opnamt    as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-clname1   as char.
def var v-clrnn1    as char.
def var v-clbin1    as char.
def var v-clname2   as char.
def var v-clrnn2    as char.
def var v-clbin2    as char.
def var v-lon       as char.
def var v-lonintrate as   deci.
def var v-claddr    as char.

def var v-lcsum1 as deci no-undo.
def var v-lcsum2 as deci no-undo.
def var v-lcsum3 as deci no-undo.

def var nm as char.
def buffer b-cif for txb.cif.
def buffer b-aaa for txb.aaa.
def var v-gar as logi.
def var v-cov as char.
def var v-cod as char.
def var v-dt1 as date.
def var v-dt2 as date.
def var v-per as int.
def var v-vid as char.
/******************************************************************************/
/*Временные таблицы*********************************************/
def shared temp-table t-deps /*временная таблица для сбора данных по депозитам*/
    field fil       as char
    field acc       as char
    field amt       as deci
    field opndt     as date
    field duedt     as date
    field intrate   as deci
    field client    as char
    field clrnn     as char
    field clbin     as char
    field depcrc    as int
    field depgl     as int.

def shared temp-table t-clink
    field clname1   as char
    field clrnn1    as char
    field clbin1    as char
    field clname2   as char
    field clrnn2    as char
    field clbin2    as char
    field linktype  as char
    field pay       as char.


def shared temp-table t-loan /*временная таблица для сбора данных по кредитам*/
    field fil       as char format "x(30)"   /*филиал*/
    field lon       as char  /*субсчет ГК*/
    field opnamt    as deci
    field amt       as deci
    field prsramt   as deci
    field prvzamt   as deci
    field intrate   as deci
    field zalamt    as deci
    field zalgar    as deci
    field zaldep    as deci
    field zalog     as char
    field zalog1    as char
    field sts       as char
    field opndt     as date
    field isdt      as date
    field duedt     as date
    field grp       as int
    field client    as char
    field clrnn     as char
    field clbin     as char
    field loncrc    as int
    field claddr    as char
    field vid       as char.
/***************************************************************/
def var s-ourbank as char no-undo.
def var d-rates as deci no-undo extent 20.
def var v-crc as int no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

for each txb.crc no-lock:
  d-rates[txb.crc.crc] = txb.crc.rate[1].
end.
/*********************/
/*Сбор данных***********************************************************************************************************************************************************/
v-fil = s-ourbank.
v-dt = p-dt.

for each txb.lon no-lock by txb.lon.lon :
    v-lon = txb.lon.lon.
    v-cif = txb.lon.cif.
    if txb.lon.sts = "C" then do:
        v-amt = 0.
        v-prsramt = 0.
        v-prvzamt = 0.
        for each txb.trxbal where txb.trxbal.subled = "lon" and txb.trxbal.acc = txb.lon.lon and (txb.trxbal.level = 15 or txb.trxbal.level = 35) no-lock:
            v-amt = v-amt + absolute(txb.trxbal.dam - txb.trxbal.cam).
        end.
    end.
    else do:
        v-amt = 0.
        v-prsramt = 0.
        v-prvzamt = 0.
        for each txb.trxbal where txb.trxbal.subled = "lon" and txb.trxbal.acc = txb.lon.lon and (txb.trxbal.level = 1 or txb.trxbal.level = 41 or txb.trxbal.level = 7) no-lock:
            if txb.trxbal.level = 1 then v-amt = v-amt + txb.trxbal.dam - txb.trxbal.cam.
            if txb.trxbal.level = 7 then v-prsramt = v-prsramt + txb.trxbal.dam - txb.trxbal.cam.
            if txb.trxbal.level = 41 then v-prvzamt = v-prvzamt - txb.trxbal.dam + txb.trxbal.cam.
        end.
    end.
    /*run lonbalcrc_txb('lon',txb.lon.lon, v-dt, "1,7", no, txb.lon.crc, output v-amt).*/
    find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and v-dt > txb.ln%his.stdat no-lock no-error.
    if avail txb.ln%his then v-lonintrate = txb.ln%his.intrate.
    else v-lonintrate = 0.
    v-zalamt = 0.
    v-zalgar = 0.
    v-zaldep = 0.
    v-zalog = "".
    v-zalog1 = "".
    for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
        if txb.lonsec1.crc = 0 then next.
        case txb.lonsec1.lonsec:
            when 3 then v-zaldep = v-zaldep + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
            when 6 then v-zalgar = v-zalgar + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
            otherwise v-zalamt = v-zalamt + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
        end case.
        find first txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
        if avail txb.lonsec then do:
            if lookup(txb.lonsec.des1,v-zalog) = 0 then do:
                if v-zalog <> '' then v-zalog = v-zalog + ','.
                v-zalog = v-zalog + txb.lonsec.des1.
            end.
        end.
        if v-zalog1 = "" then v-zalog1 = txb.lonsec1.prm + " " + txb.lonsec1.pielikums[3].
        else v-zalog1 = v-zalog1 + ", " + txb.lonsec1.prm + " " + txb.lonsec1.pielikums[3].
    end.

    find first txb.cif where txb.cif.cif = v-cif no-lock no-error.
    if avail txb.cif then do:
        v-clname1 = txb.cif.name.
        v-clrnn1 = txb.cif.jss.
        v-clbin1 = txb.cif.bin.
        if num-entries(txb.cif.addr[1],",") = 7 then v-claddr = txb.cif.addr[1].
        else do:
            if num-entries(txb.cif.addr[2],",") = 7 then v-claddr = txb.cif.addr[2].
            else v-claddr = "".
        end.

        create t-loan.
            t-loan.fil = v-fil.
            t-loan.lon = txb.lon.lon.
            t-loan.opnamt = txb.lon.opnamt.
            t-loan.amt = v-amt.
            t-loan.prsramt = v-prsramt.
            t-loan.prvzamt = v-prvzamt.
            t-loan.opndt = txb.lon.opndt.
        find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
        if avail txb.lnscg then t-loan.isdt = txb.lnscg.stdat.
            t-loan.duedt = txb.lon.duedt.
           t-loan.intrate = v-lonintrate.
           t-loan.loncrc = txb.lon.crc.
           t-loan.sts = txb.lon.sts.
           t-loan.grp = txb.lon.grp.
           t-loan.zalamt = v-zalamt.
           t-loan.zalgar = v-zalgar.
           t-loan.zaldep = v-zaldep.
           t-loan.zalog = v-zalog.
           t-loan.zalog1 = v-zalog1.
           t-loan.client = v-clname1.
           t-loan.clrnn = v-clrnn1.
           t-loan.clbin = v-clbin1.
           t-loan.claddr = v-claddr.
           t-loan.vid = "lon".


        for each txb.sub-cod where txb.sub-cod.acc = v-cif and (txb.sub-cod.ccode = "chief" or txb.sub-cod.ccode = "mainbk") no-lock:
            find last txb.cif where trim(txb.cif.name) = trim(txb.sub-cod.rcode) no-lock no-error.
            v-clname2 = txb.sub-cod.rcode.
            if avail txb.cif then do:
                v-clrnn2 = txb.cif.jss.
                v-clbin2 = txb.cif.bin.
            end.
            else do:
                v-clrnn2 = "".
                v-clbin2 = "".
            end.
            find first t-clink where t-clink.clname1 = v-clname1 and t-clink.clrnn1 = v-clrnn1 and t-clink.clbin1 = v-clbin1 and t-clink.clname2 = v-clname2 and t-clink.clrnn2 = v-clrnn2 and t-clink.clbin2 = v-clbin2 and t-clink.linktype = txb.sub-cod.ccode no-lock no-error.
            if not avail t-clink then do:
                create t-clink.
                t-clink.clname1 = v-clname1.
                t-clink.clrnn1 = v-clrnn1.
                t-clink.clbin1 = v-clbin1.
                t-clink.clname2 = v-clname2.
                t-clink.clrnn2 = v-clrnn2.
                t-clink.clbin2 = v-clbin2.
                t-clink.linktype = txb.sub-cod.ccode.
            end.
        end.
        for each txb.founder where txb.founder.cif = v-cif no-lock:
            v-clname2 = txb.founder.name.
            v-clrnn2 = txb.founder.rnn.
            v-clbin2 = txb.founder.bin.
            find first t-clink where t-clink.clname1 = v-clname1 and t-clink.clrnn1 = v-clrnn1 and t-clink.clbin1 = v-clbin1 and t-clink.clname2 = v-clname2 and t-clink.clrnn2 = v-clrnn2 and t-clink.clbin2 = v-clbin2 and t-clink.linktype = "pay" no-lock no-error.
            if not avail t-clink then do:
                create t-clink.
                t-clink.clname1 = v-clname1.
                t-clink.clrnn1 = v-clrnn1.
                t-clink.clbin1 = v-clbin1.
                t-clink.clname2 = v-clname2.
                t-clink.clrnn2 = v-clrnn2.
                t-clink.clbin2 = v-clbin2.
                t-clink.linktype = "pay".
                t-clink.pay = txb.founder.reschar[1].
            end.
        end.
        for each txb.aaa where txb.aaa.cif = v-cif no-lock:
            if txb.aaa.gl = 220620 or txb.aaa.gl = 220720 or txb.aaa.gl = 221510 or txb.aaa.gl = 221710 or  txb.aaa.gl = 221910 or txb.aaa.gl = 224015 or txb.aaa.gl = 224025 then do:
                create t-deps.
                t-deps.fil = v-fil.
                t-deps.acc = txb.aaa.aaa.
                t-deps.depcrc = txb.aaa.crc.
                find last txb.aab where txb.aab.aaa = txb.aaa.aaa no-lock no-error.
                if avail txb.aab then t-deps.amt = txb.aab.bal.
                else t-deps.amt = 0.
                t-deps.opndt = txb.aaa.regdt.
                t-deps.duedt = txb.aaa.expdt.
                t-deps.client = v-clname1.
                t-deps.clrnn = v-clrnn1.
                t-deps.clbin =v-clbin1.
                t-deps.depgl = txb.aaa.gl.
                find last txb.accr where txb.accr.aaa = txb.aaa.aaa no-lock no-error.
                if avail txb.accr then t-deps.intrate = txb.accr.rate.
                find last txb.compens where txb.compens.acc = txb.aaa.aaa no-lock no-error.
                if avail txb.compens then do:
                    t-deps.intrate = txb.aaa.rate.
                end.
            end.
        end.
    end.
end.

for each txb.cif,
    each txb.aaa where txb.aaa.cif = txb.cif.cif
                   and (string(txb.aaa.gl) begins '2223' or string(txb.aaa.gl) begins '2208' or string(txb.aaa.gl) begins '2240' or txb.aaa.gl =  213110 or txb.aaa.gl =  213120 ) no-lock.
    v-lcsum1 = 0.
    find first txb.trxlevgl where txb.trxlevgl.gl     eq  txb.aaa.gl
                              and txb.trxlevgl.subled eq  'cif'
                              and txb.trxlevgl.level  eq  7
                              no-lock no-error.
    if not avail txb.trxlevgl then next.

    for each txb.jl where txb.jl.acc    = txb.aaa.aaa
                      and txb.jl.lev    = 7
                      and txb.jl.subled = 'cif' no-lock:
        if txb.jl.dc = 'd' then v-lcsum1 = v-lcsum1 + txb.jl.dam.
                           else v-lcsum1 = v-lcsum1 - txb.jl.cam.
    end.
    if v-lcsum1 = 0 then next.
    v-cif = cif.cif.
    v-amt = 0.
    v-prsramt = 0.
    v-prvzamt = 0.
    v-zalamt = 0.
    v-zalgar = 0.
    v-zaldep = 0.
    v-zalog = "".
    v-zalog1 = "".
    v-clname1 = txb.cif.name.
    v-clrnn1 = txb.cif.jss.
    v-clbin1 = txb.cif.bin.
    v-vid = "".
    if num-entries(txb.cif.addr[1],",") = 7 then v-claddr = txb.cif.addr[1].
    else do:
        if num-entries(txb.cif.addr[2],",") = 7 then v-claddr = txb.cif.addr[2].
        else v-claddr = "".
    end.


    find first txb.garan where txb.garan.garan = txb.aaa.aaa and txb.garan.cif = txb.cif.cif no-lock no-error.
	if avail txb.garan then do:
        v-amt = txb.garan.sumtreb.
        v-zalamt = txb.garan.sum * d-rates[txb.aaa.crc].
        v-vid = "gar1".
        for each txb.lonsec1 where txb.lonsec1.lon = txb.garan.garan no-lock:
            if txb.lonsec1.crc = 0 then next.
            case txb.lonsec1.lonsec:
                when 3 then v-zaldep = v-zaldep + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
                when 6 then v-zalgar = v-zalgar + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
                otherwise v-zalamt = v-zalamt + txb.lonsec1.secamt * d-rates[txb.lonsec1.crc].
            end case.
            find first txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
            if avail txb.lonsec then do:
                if lookup(txb.lonsec.des1,v-zalog) = 0 then do:
                    if v-zalog <> '' then v-zalog = v-zalog + ','.
                    v-zalog = v-zalog + txb.lonsec.des1.
                end.
            end.
            if v-zalog1 = "" then v-zalog1 = txb.lonsec1.prm + " " + txb.lonsec1.pielikums[3].
            else v-zalog1 = v-zalog1 + ", " + txb.lonsec1.prm + " " + txb.lonsec1.pielikums[3].
        end.
    end.
    else assign v-amt  = v-lcsum1
                v-zalamt = v-lcsum1 * d-rates[txb.aaa.crc]
                v-vid = "gar".

    create t-loan.
            t-loan.fil = v-fil.
            t-loan.lon = txb.aaa.aaa. /*txb.lon.lon.*/
            t-loan.opnamt = v-amt. /*txb.lon.opnamt.*/
            t-loan.amt = v-amt.
            t-loan.prsramt = v-prsramt.
            t-loan.prvzamt = v-prvzamt.
            t-loan.opndt = txb.aaa.regdt.
            t-loan.isdt = txb.aaa.regdt.
            t-loan.duedt = txb.aaa.expdt.
            t-loan.intrate = 0. /*v-lonintrate.*/
            t-loan.loncrc = txb.aaa.crc. /*txb.lon.crc.*/
            t-loan.sts = "U". /*txb.lon.sts.*/
            /*t-loan.grp = "".*/ /*txb.lon.grp.*/
            t-loan.zalamt = v-zalamt.
            t-loan.zalgar = v-zalgar.
            t-loan.zaldep = v-zaldep.
            t-loan.zalog = v-zalog.
            t-loan.zalog1 = v-zalog1.
            t-loan.client = v-clname1.
            t-loan.clrnn = v-clrnn1.
            t-loan.clbin = v-clbin1.
            t-loan.claddr = v-claddr.
            t-loan.vid = v-vid.

    for each txb.sub-cod where txb.sub-cod.acc = v-cif and (txb.sub-cod.ccode = "chief" or txb.sub-cod.ccode = "mainbk") no-lock:
        find last b-cif where trim(b-cif.name) = trim(txb.sub-cod.rcode) no-lock no-error.
        v-clname2 = txb.sub-cod.rcode.
        if avail b-cif then do:
            v-clrnn2 = b-cif.jss.
            v-clbin2 = b-cif.bin.
        end.
        else do:
            v-clrnn2 = "".
            v-clbin2 = "".
        end.
        find first t-clink where t-clink.clname1 = v-clname1 and t-clink.clrnn1 = v-clrnn1 and t-clink.clbin1 = v-clbin1 and t-clink.clname2 = v-clname2 and t-clink.clrnn2 = v-clrnn2 and t-clink.clbin2 = v-clbin2 and t-clink.linktype = txb.sub-cod.ccode no-lock no-error.
        if not avail t-clink then do:
            create t-clink.
                t-clink.clname1 = v-clname1.
                t-clink.clrnn1 = v-clrnn1.
                t-clink.clbin1 = v-clbin1.
                t-clink.clname2 = v-clname2.
                t-clink.clrnn2 = v-clrnn2.
                t-clink.clbin2 = v-clbin2.
                t-clink.linktype = txb.sub-cod.ccode.
        end.
    end.
    for each txb.founder where txb.founder.cif = v-cif no-lock:
        v-clname2 = txb.founder.name.
        v-clrnn2 = txb.founder.rnn.
        v-clbin2 = txb.founder.bin.
        find first t-clink where t-clink.clname1 = v-clname1 and t-clink.clrnn1 = v-clrnn1 and t-clink.clbin1 = v-clbin1 and t-clink.clname2 = v-clname2 and t-clink.clrnn2 = v-clrnn2 and t-clink.clbin2 = v-clbin2 and t-clink.linktype = "pay" no-lock no-error.
        if not avail t-clink then do:
            create t-clink.
                t-clink.clname1 = v-clname1.
                t-clink.clrnn1 = v-clrnn1.
                t-clink.clbin1 = v-clbin1.
                t-clink.clname2 = v-clname2.
                t-clink.clrnn2 = v-clrnn2.
                t-clink.clbin2 = v-clbin2.
                t-clink.linktype = "pay".
                t-clink.pay = txb.founder.reschar[1].
        end.
    end.
    for each b-aaa where b-aaa.cif = v-cif no-lock:
        if b-aaa.gl = 220620 or b-aaa.gl = 220720 or b-aaa.gl = 221510 or b-aaa.gl = 221710 or  b-aaa.gl = 221910 or b-aaa.gl = 224015 or b-aaa.gl = 224025 then do:
            find first t-deps where t-deps.fil = v-fil and t-deps.acc = b-aaa.aaa
                and t-deps.client = v-clname1 and t-deps.clrnn = v-clrnn1
                and t-deps.clbin =v-clbin1 and t-deps.depgl = b-aaa.gl no-lock no-error.
            if not avail t-deps then do:
                create t-deps.
                    t-deps.fil = v-fil.
                    t-deps.acc = b-aaa.aaa.
                    t-deps.depcrc = b-aaa.crc.
                    find last txb.aab where txb.aab.aaa = b-aaa.aaa no-lock no-error.
                    if avail txb.aab then t-deps.amt = txb.aab.bal.
                    else t-deps.amt = 0.
                    t-deps.opndt = b-aaa.regdt.
                    t-deps.duedt = b-aaa.expdt.
                    t-deps.client = v-clname1.
                    t-deps.clrnn = v-clrnn1.
                    t-deps.clbin =v-clbin1.
                    t-deps.depgl = b-aaa.gl.
                    find last txb.accr where txb.accr.aaa = b-aaa.aaa no-lock no-error.
                    if avail txb.accr then t-deps.intrate = txb.accr.rate.
                    find last txb.compens where txb.compens.acc = b-aaa.aaa no-lock no-error.
                    if avail txb.compens then do:
                        t-deps.intrate = b-aaa.rate.
                    end.
            end.
        end.
    end.
end.

/* Trade Finance */
for each lc where lc.bank = v-fil and lc.lctype = 'i' and lookup(lc.lcsts,'fin,cls,cln') > 0 no-lock:
    v-fil = lc.bank.
    v-amt = 0.
    v-prsramt = 0.
    v-prvzamt = 0.
    v-zalamt = 0.
    v-zalgar = 0.
    v-zaldep = 0.
    v-zalog = "".
    v-zalog1 = "".
    if lc.lc begins 'pg' then v-gar = yes. else v-gar = no.

    find first lch where lch.lc = lc.lc and lch.kritcode = 'cover' no-lock no-error.
    if not avail lch or lch.value1 = '' then next.

    v-cov = lch.value1.
    v-cod = if v-gar then 'Date' else 'DtIs'.

    find first lch where lch.lc = lc.lc and lch.kritcode = v-cod no-lock no-error.
    if not avail lch or lch.value1 = '' then next.

    v-dt1 = date(lch.value1).

    find first lch where lch.lc = lc.lc and lch.kritcode = 'DtExp' no-lock no-error.
    if not avail lch or lch.value1 = '' then next.

    find last lcamendh where lcamendh.bank = v-fil and lcamendh.lc = lc.lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
    if avail lcamendh then v-dt2 = date(lcamendh.value1).
    else v-dt2 = date(lch.value1).

    /* подсчет остатка */
    assign v-lcsum1 = 0
           v-lcsum2 = 0
           v-lcsum3 = 0.
    find first lch where lch.lc = lc.lc and lch.kritcode = 'amount' no-lock no-error.
    if avail lch then v-lcsum1 = decimal(lch.value1).

    find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
    if avail lch and lch.value1 ne '' then do:
        v-per = int(entry(1,lch.value1, '/')).
        if v-per > 0 then v-lcsum1 = v-lcsum1 + (v-lcsum1 * (v-per / 100)).
    end.

    /* amendment */
    if v-gar then
        for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.dacc = '605561' or  lcamendres.dacc = '655561' or lcamendres.dacc = '605562' or  lcamendres.dacc = '655562') and lcamendres.jh > 0  no-lock:
            find first txb.jh where txb.jh.jh = lcamendres.jh no-lock no-error.
            if avail txb.jh then do:
                if lcamendres.dacc = '605561' or lcamendres.dacc = '605562' then v-lcsum1 = v-lcsum1 + lcamendres.amt.
                else v-lcsum1 = v-lcsum1 - lcamendres.amt.
            end.
        end.
    else
        for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.levD = 23 or  lcamendres.levD = 24 or lcamendres.levC = 23 or  lcamendres.levC = 24) and lcamendres.jh > 0  no-lock:
            find first txb.jh where txb.jh.jh = lcamendres.jh no-lock no-error.
            if avail txb.jh then do:
                if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsum1 = v-lcsum1 + lcamendres.amt.
                else v-lcsum1 = v-lcsum1 - lcamendres.amt.
            end.
        end.
    v-lcsum2 = v-lcsum1.
    /* expire, cancel */
    if v-gar then find first lceventres where lceventres.lc = lc.lc and (lceventres.event = 'exp' or lceventres.event = 'cnl') and lceventres.number = 1 and (lceventres.dacc = '655561' or lceventres.dacc = '655562') and lceventres.jh > 0 no-lock no-error.
    else find first lceventres where lceventres.lc = lc.lc and (lceventres.event = 'exp' or lceventres.event = 'cnl') and lceventres.number = 1 and (lceventres.levC = 23 or  lceventres.levC = 24) and lceventres.jh > 0 no-lock no-error.
    if avail lceventres then do:
        find first txb.jh where txb.jh.jh = lceventres.jh no-lock no-error.
        if avail jh then v-lcsum2 = 0.
    end.
    if v-lcsum2 <> 0 then do:
        /* payment */
        if v-gar then do:
            for each lcpayres where lcpayres.lc = lc.lc and (lcpayres.dacc = '655561' or lcpayres.dacc = '655562') and lcpayres.jh > 0 no-lock:
                find first txb.jh where txb.jh.jh = lcpayres.jh no-lock no-error.
                if avail jh then v-lcsum2 = v-lcsum2 - lcpayres.amt.
            end.
        end.
        else
            for each lcpayres where lcpayres.lc = lc.lc and (lcpayres.levC = 23 or  lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
                find first txb.jh where txb.jh.jh = lcpayres.jh no-lock no-error.
                if avail jh then v-lcsum2 = v-lcsum2 - lcpayres.amt.
            end.
        /* event */
        for each lceventres where lceventres.lc = lc.lc and lceventres.event <> 'exp' and lceventres.event <> 'cnl' and (lceventres.dacc = '655561' or lceventres.dacc = '655562' or lceventres.levC = 23 or  lceventres.levC = 24) and lceventres.jh > 0 no-lock.
            find first txb.jh where txb.jh.jh = lceventres.jh no-lock no-error.
            if avail jh then v-lcsum2 = v-lcsum2 - lceventres.amt.
        end.
    end.

    if v-lcsum2 = 0 then next.
    v-crc = 0.
    find first lch where lch.lc = lc.lc and lch.kritcode = 'lcCrc' no-lock no-error.
    if avail lch and lch.value1 <> ? then v-crc = integer(trim(lch.value1)).
    if v-crc <> 0 then do:
        v-amt = round(v-lcsum2,2).
        if v-cov = '0' then v-zaldep = round(v-lcsum1 * d-rates[v-crc],2).
        else if v-cov = '2' then do:
            find first lch where lch.lc = lc.lc and lch.kritcode = 'CovAmt' no-lock no-error.
            if avail lch and lch.value1 <> ? then v-zaldep = round(decimal(trim(lch.value1)) * d-rates[v-crc],2).
        end.
    end.


    find first txb.cif where txb.cif.cif = lc.cif no-lock no-error.
    if avail txb.cif then do:
        v-cif = txb.cif.cif.
        v-clname1 = txb.cif.name.
        v-clrnn1 = txb.cif.jss.
        v-clbin1 = txb.cif.bin.
        if num-entries(txb.cif.addr[1],",") = 7 then v-claddr = txb.cif.addr[1].
        else do:
            if num-entries(txb.cif.addr[2],",") = 7 then v-claddr = txb.cif.addr[2].
            else v-claddr = "".
        end.
    end.
    v-zalog = if v-cov = '0' then 'Деньги(депозиты)' else ''.
    v-zalog1 = if v-cov = '0' then 'Деньги(депозиты)' else ''.
    create t-loan.
            t-loan.fil = v-fil.
            t-loan.lon = lc.lc. /*txb.lon.lon.*/
            t-loan.opnamt = v-amt. /*txb.lon.opnamt.*/
            t-loan.amt = v-amt.
            t-loan.prsramt = v-prsramt.
            t-loan.prvzamt = v-prvzamt.
            t-loan.opndt = v-dt1.
            t-loan.isdt = v-dt1.
            t-loan.duedt = v-dt2.
            t-loan.intrate = 0. /*v-lonintrate.*/
            t-loan.loncrc = int(lch.value1). /*txb.lon.crc.*/
            t-loan.sts = "U". /*txb.lon.sts.*/
            /*t-loan.grp = "".*/ /*txb.lon.grp.*/
            t-loan.zalamt = v-zalamt.
            t-loan.zalgar = v-zalgar.
            t-loan.zaldep = v-zaldep.
            t-loan.zalog = v-zalog.
            t-loan.zalog1 = v-zalog1.
            t-loan.client = v-clname1.
            t-loan.clrnn = v-clrnn1.
            t-loan.clbin = v-clbin1.
            t-loan.claddr = v-claddr.
            if v-gar then t-loan.vid = "gar". else t-loan.vid = "acr".

    for each txb.sub-cod where txb.sub-cod.acc = v-cif and (txb.sub-cod.ccode = "chief" or txb.sub-cod.ccode = "mainbk") no-lock:
        find last b-cif where trim(b-cif.name) = trim(txb.sub-cod.rcode) no-lock no-error.
        v-clname2 = txb.sub-cod.rcode.
        if avail b-cif then do:
            v-clrnn2 = b-cif.jss.
            v-clbin2 = b-cif.bin.
        end.
        else do:
            v-clrnn2 = "".
            v-clbin2 = "".
        end.
        find first t-clink where t-clink.clname1 = v-clname1 and t-clink.clrnn1 = v-clrnn1 and t-clink.clbin1 = v-clbin1 and t-clink.clname2 = v-clname2 and t-clink.clrnn2 = v-clrnn2 and t-clink.clbin2 = v-clbin2 and t-clink.linktype = txb.sub-cod.ccode no-lock no-error.
        if not avail t-clink then do:
            create t-clink.
                t-clink.clname1 = v-clname1.
                t-clink.clrnn1 = v-clrnn1.
                t-clink.clbin1 = v-clbin1.
                t-clink.clname2 = v-clname2.
                t-clink.clrnn2 = v-clrnn2.
                t-clink.clbin2 = v-clbin2.
                t-clink.linktype = txb.sub-cod.ccode.
        end.
    end.
    for each txb.founder where txb.founder.cif = v-cif no-lock:
        v-clname2 = txb.founder.name.
        v-clrnn2 = txb.founder.rnn.
        v-clbin2 = txb.founder.bin.
        find first t-clink where t-clink.clname1 = v-clname1 and t-clink.clrnn1 = v-clrnn1 and t-clink.clbin1 = v-clbin1 and t-clink.clname2 = v-clname2 and t-clink.clrnn2 = v-clrnn2 and t-clink.clbin2 = v-clbin2 and t-clink.linktype = "pay" no-lock no-error.
        if not avail t-clink then do:
            create t-clink.
                t-clink.clname1 = v-clname1.
                t-clink.clrnn1 = v-clrnn1.
                t-clink.clbin1 = v-clbin1.
                t-clink.clname2 = v-clname2.
                t-clink.clrnn2 = v-clrnn2.
                t-clink.clbin2 = v-clbin2.
                t-clink.linktype = "pay".
                t-clink.pay = txb.founder.reschar[1].
        end.
    end.
    for each b-aaa where b-aaa.cif = v-cif no-lock:
        if b-aaa.gl = 220620 or b-aaa.gl = 220720 or b-aaa.gl = 221510 or b-aaa.gl = 221710 or  b-aaa.gl = 221910 or b-aaa.gl = 224015 or b-aaa.gl = 224025 then do:
            find first t-deps where t-deps.fil = v-fil and t-deps.acc = b-aaa.aaa
                and t-deps.client = v-clname1 and t-deps.clrnn = v-clrnn1
                and t-deps.clbin =v-clbin1 and t-deps.depgl = b-aaa.gl no-lock no-error.
            if not avail t-deps then do:
                create t-deps.
                    t-deps.fil = v-fil.
                    t-deps.acc = b-aaa.aaa.
                    t-deps.depcrc = b-aaa.crc.
                    find last txb.aab where txb.aab.aaa = b-aaa.aaa no-lock no-error.
                    if avail txb.aab then t-deps.amt = txb.aab.bal.
                    else t-deps.amt = 0.
                    t-deps.opndt = b-aaa.regdt.
                    t-deps.duedt = b-aaa.expdt.
                    t-deps.client = v-clname1.
                    t-deps.clrnn = v-clrnn1.
                    t-deps.clbin =v-clbin1.
                    t-deps.depgl = b-aaa.gl.
                    find last txb.accr where txb.accr.aaa = b-aaa.aaa no-lock no-error.
                    if avail txb.accr then t-deps.intrate = txb.accr.rate.
                    find last txb.compens where txb.compens.acc = b-aaa.aaa no-lock no-error.
                    if avail txb.compens then do:
                        t-deps.intrate = b-aaa.rate.
                    end.
            end.
        end.
    end.
end.