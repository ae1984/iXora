/* vcreppr2dat.p
 * MODULE
        Приложение 2
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
        12.04.2011 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        03.06.2011 aigul - вывод только внешних платежей, так как в типе 4 могут храниться и внутр платежи
        09.06.2011 aigul - искать страну по справочнику
*/
def shared var v-dtb as date format "99/99/9999".
def shared var v-dte as date format "99/99/9999".
def shared var v-pay as integer init 1.
def var s-ourbank as char no-undo.

def var i as int.
def var v-fio as char format "x(40)".
def var v-rnn as char.
def var v-rnnd as decimal.
def var v-bn as char format "x(40)".
def var v-bin as char.
def var v as char.
def var v-rez1 as char no-undo.
def var v-acc as char.
def var v-crc as decimal.
def var v-amt as decimal format ">>>,>>>,>>>,>>9.99".
def var v-knpK as char.
def var v-knp as char.
def var v-tranz as char.
def var v-tranzK as char.
def var v-dt as date format "99/99/9999" no-undo.
def var v-rez2 as char.
def var v-secK as char.
def var v-st as char.
def var v-zs as char.
def var rep_f as logi initial false no-undo.
def var v-fmRem as char no-undo.
def shared temp-table wrk-ish
    field bank as char
    field rmz as char
    field fio as char
    field rez1 as char
    field rnn as char
    field bin as char
    field tranz as char
    field knp as char
    field dt as date
    field acc as char
    field fcrc as char
    field amt as decimal
    field usd-amt as decimal
    field st as char
    field rez2 as char
    field secK as char
    field bn as char
    field crgl as char.
def shared temp-table wrk-vh
    field bank as char
    field rmz as char
    field fio as char
    field rez1 as char
    field rnn as char
    field bin as char
    field tranz as char
    field knp as char
    field dt as date
    field acc as char
    field fcrc as char
    field amt as decimal
    field usd-amt as decimal
    field st as char
    field rez2 as char
    field secK as char
    field bn as char
    field drgl as char.

def var KOd as char.
def var KBe as char.
def var KNP as char.
def var res1 as int.
def var res2 as int.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).
output to time.txt append.
/*out*/
v-amt = 0.
i = 0.
KOd = "".
KBe = "".
KNP = "".
if v-pay = 1 or v-pay = 3 then do:
    v-fio = "".
    v-rnn = "".
    v-rnnd = 0.
    v-bn = "".
    v-bin = "".
    v = "".
    v-rez1 = "".
    v-acc = "".
    v-crc = 0.
    v-amt = 0.
    v-knpK = "".
    v-knp = "".
    v-tranz = "".
    v-tranzK = "".
    v-dt = ?.
    v-rez2 = "".
    v-secK = "".
    v-st = "".
    v-zs = "".
    v-fmRem = "".
    KOd = "".
    KBe = "".
    KNP = "".
    /*быстрые переводы*/
    for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte
    and (txb.jl.gl = 287034 or txb.jl.gl = 287035 or txb.jl.gl = 287036 or txb.jl.gl = 287037 ) no-lock:
        find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                  and txb.trxcods.trxln = txb.jl.ln
                  and txb.trxcods.codfr = "spnpl" no-lock no-error.
       if available txb.trxcods then KNP = txb.trxcods.code.

       find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                      and txb.trxcods.trxln = txb.jl.ln
                      and txb.trxcods.codfr = "locat" no-lock no-error.
       if available txb.trxcods then do:
          KOd = txb.trxcods.code.
       end.

       find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                      and txb.trxcods.trxln = txb.jl.ln
                      and txb.trxcods.codfr = "secek" no-lock no-error.
       if available txb.trxcods then do:
          KBe = txb.trxcods.code.
       end.
       v-rez2 = KOd.
       v-secK = KBe.
       v-knp = KNP.
        find first txb.joudoc where txb.joudoc.jh = txb.jl.jh no-lock no-error.
        if avail txb.joudoc then do:
           find first txb.cif where txb.cif.jss = txb.joudoc.perkod no-lock no-error.
            if avail txb.cif then v-bin = txb.cif.bin.
            find last txb.ncrchis where txb.ncrchis.crc = txb.joudoc.drcur and txb.ncrchis.rdt <= txb.jl.jdt no-lock no-error.
            if avail txb.ncrchis then v-amt = txb.joudoc.cramt  * txb.ncrchis.rate[1].
            find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= txb.jl.jdt no-lock no-error.
            if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
            /*
            if jl.acc = "" and sum-usd <= 10000 then next.
            if jl.acc <> "" and sum-usd <= 50000 then next.
            */
            /*find first kfmoper where kfmoper.jh = txb.jl.jh no-lock no-error.
            if avail kfmoper then do:
                find first kfmprth where kfmprth.operid = kfmoper.operid and kfmprth.datacod = "prtBCoun" and partid = 2 no-lock no-error.
                if avail kfmprth then v-st = kfmprth.datavalue.
            end.
            if v-st = "" then do:*/
                find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and txb.sub-cod.d-cod = "iso3166"
                no-lock no-error.
                if avail txb.sub-cod then v-st = txb.sub-cod.ccode.
            /*end.*/
            find first txb.arp where txb.arp.arp = txb.jl.acc no-lock no-error.
            if avail txb.arp then do:
                if txb.arp.geo = '021' then v-rez1 = '1'.
                if txb.arp.geo = '022' then v-rez1 = '2'.
                if (v-st = 'KZ') then next.
                if (v-st = "" or v-st = 'msc') then do:
                    if v-rez1 = '1' and v-rez2 = '1' then next.
                end.
                if v-amt > 10000 then do:
                    i = i + 1.
                    create wrk-ish.
                    wrk-ish.rmz = "jou".
                    wrk-ish.bank = s-ourbank.
                    wrk-ish.fio = txb.joudoc.info.
                    wrk-ish.rez1 = v-rez1.
                    find first txb.aaa where txb.aaa.aaa = txb.joudoc.cracc no-lock no-error.
                    if avail txb.aaa then wrk-ish.acc = txb.joudoc.cracc.
                    else wrk-ish.acc = "".
                    wrk-ish.rnn = txb.joudoc.perkod.
                    wrk-ish.bin = v-bin.
                    wrk-ish.tranz = "исходящий" + " " + arp.des + " " + txb.jl.rem[1].
                    wrk-ish.knp = v-knp.
                    wrk-ish.dt = txb.jl.jdt.
                    find first txb.crc where txb.crc.crc = txb.joudoc.drcur no-lock no-error.
                    if avail txb.crc then wrk-ish.fcrc = txb.crc.code.
                    wrk-ish.amt = txb.joudoc.dramt / 1000.
                    wrk-ish.usd-amt = v-amt / 1000.
                    wrk-ish.st = v-st.
                    wrk-ish.rez2 = v-rez2.
                    wrk-ish.secK = v-secK.
                    wrk-ish.bn = txb.joudoc.benname.
                    wrk-ish.crgl = string(txb.jl.gl) + "  " + txb.joudoc.docnum.
                    /*displ i arp.geo arp.cgr arp.des jl.acc format "x(20)" joudoc.dracc format "x(20)" joudoc.cracc format "x(20)"
                    joudoc.dramt joudoc.cramt sum-usd joudoc.drcur joudoc.crcur.*/
                end.
            end.
        end.
    end.
    v-fio = "".
    v-rnn = "".
    v-rnnd = 0.
    v-bn = "".
    v-bin = "".
    v = "".
    v-rez1 = "".
    v-acc = "".
    v-crc = 0.
    v-amt = 0.
    v-knpK = "".
    v-knp = "".
    v-tranz = "".
    v-tranzK = "".
    v-dt = ?.
    v-rez2 = "".
    v-secK = "".
    v-st = "".
    v-zs = "".
    v-fmRem = "".
    KOd = "".
    KBe = "".
    KNP = "".
    /*валютные переводы*/
    for each txb.remtrz where txb.remtrz.valdt2 >= v-dtb and txb.remtrz.valdt2 <= v-dte and
    (txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6' or (txb.remtrz.ptype = '4' and txb.remtrz.rbank = "VALOUT")) no-lock:

        if txb.remtrz.fcrc = 2 then v-amt = txb.remtrz.amt.
        else do:
           find last txb.ncrchis where txb.ncrchis.crc = txb.remtrz.fcrc and txb.ncrchis.rdt <= txb.remtrz.rdt no-lock no-error.
           if avail txb.ncrchis then v-amt = txb.remtrz.amt * txb.ncrchis.rate[1].
           find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= txb.remtrz.rdt no-lock no-error.
           if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
        end.
        find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz
        and txb.sub-cod.d-cod = "eknp" no-lock no-error.
        if avail txb.sub-cod then do:
            v-rez1 = substr(txb.sub-cod.rcode,1,1).
            v-rez2 = substr(txb.sub-cod.rcode,4,1).
            v-secK = substr(txb.sub-cod.rcode,5,1).
            v-knpK = substr(txb.sub-cod.rcode,7,3).

            if substr(txb.sub-cod.rcode,2,1) <> '9' then next.
            find txb.codfr where txb.codfr.codfr = 'spnpl' and txb.codfr.code = substr(txb.sub-cod.rcode,7,3) no-lock no-error.
            if avail txb.codfr then v-knp =  /*trim(codfr.name[1])*/ codfr.code.
        end.

        /*find first kfmoper where kfmoper.jh = txb.remtrz.jh1 no-lock no-error.
        if avail kfmoper then do:
            find first kfmprth where kfmprth.operid = kfmoper.operid and kfmprth.datacod = "prtBCoun" and partid = 2 no-lock no-error.
            if avail kfmprth then v-st = kfmprth.datavalue.
        end.
        if v-st = "" then do:*/
            find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.d-cod = "iso3166"
            no-lock no-error.
            if avail txb.sub-cod then v-st = txb.sub-cod.ccode.
        /*end.*/
        if (v-st = 'KZ') then next.
        if (v-st = "" or v-st = 'msc') then do:
            if v-rez1 = '1' and v-rez2 = '1' then next.
        end.
        if (txb.remtrz.sacc = "")  and  v-amt <= 10000 then next.
        if (txb.remtrz.sacc <> "")  then do:
            find first txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
            if avail txb.aaa and v-amt <= 50000 then next.
            if not avail txb.aaa then do:
                if v-amt <= 10000 then next.
            end.
        end.
        create wrk-ish.
        wrk-ish.rmz = "rmz".
        wrk-ish.bank = s-ourbank.
        find first cifmin where cifmin = txb.remtrz.kfmcif no-lock no-error.
        if avail cifmin THEN do:
            assign wrk-ish.fio = cifmin.fam + " " + cifmin.name + " " + cifmin.mname.
            wrk-ish.rnn = cifmin.rnn.
            wrk-ish.bin = cifmin.iin.
        end.
        if not avail cifmin then do:
            find first txb.cif where  txb.cif.cif = txb.remtrz.kfmcif no-lock no-error.
            if avail txb.cif THEN do:
                assign wrk-ish.fio = txb.cif.name.
                wrk-ish.rnn = txb.cif.jss.
                wrk-ish.bin = txb.cif.bin.
            end.
        end.
        if wrk-ish.fio = "" then do:
            res1 = index(txb.remtrz.ord,"RNN").
            if res1 > 0 then assign wrk-ish.fio = txb.remtrz.ord wrk-ish.rnn = substr(txb.remtrz.ord,res1 + 3,13).
            else assign wrk-ish.fio = txb.remtrz.ord  wrk-ish.rnn = txb.remtrz.ord.
        end.
        wrk-ish.rez1 = v-rez1.
        wrk-ish.tranz = "исходящий".
        wrk-ish.knp = v-knp.
        wrk-ish.dt = txb.remtrz.valdt2.
        find first txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
        if avail txb.aaa then wrk-ish.acc = txb.remtrz.sacc.
        else wrk-ish.acc = "".
        find first txb.crc where txb.crc.crc = txb.remtrz.fcrc no-lock no-error.
        if avail txb.crc then wrk-ish.fcrc = txb.crc.code.
        wrk-ish.amt = txb.remtrz.amt / 1000.
        wrk-ish.usd-amt = v-amt / 1000.
        wrk-ish.st = v-st.
        wrk-ish.rez2 = v-rez2.
        wrk-ish.secK = v-secK.
        wrk-ish.bn = txb.remtrz.bn[1].
        wrk-ish.crgl = string(txb.remtrz.crgl) + " " + txb.remtrz.remtrz + " " + string(txb.remtrz.drgl).
        /*displ remtrz.rdt remtrz.fcrc remtrz.amt v-amt remtrz.bn remtrz.sacc remtrz.racc remtrz.ptype v-rez1 v-rez2
        v-secK v-knp remtrz.racc remtrz.sacc remtrz.crgl remtrz.drgl.*/
    end.
    v-fio = "".
    v-rnn = "".
    v-rnnd = 0.
    v-bn = "".
    v-bin = "".
    v = "".
    v-rez1 = "".
    v-acc = "".
    v-crc = 0.
    v-amt = 0.
    v-knpK = "".
    v-knp = "".
    v-tranz = "".
    v-tranzK = "".
    v-dt = ?.
    v-rez2 = "".
    v-secK = "".
    v-st = "".
    v-zs = "".
    v-fmRem = "".
    KOd = "".
    KBe = "".
    KNP = "".
    /*метроэкспресс*/
    for each translat where translat.date >= v-dtb and translat.date <= v-dte no-lock:
        find first txb.sub-cod where txb.sub-cod.sub = 'trl' and txb.sub-cod.acc = translat.nomer and txb.sub-cod.d-cod = 'iso3166'
        no-lock no-error.
        if avail txb.sub-cod then do:
            if (txb.sub-cod.ccode = 'KZ' or txb.sub-cod.ccode = 'msc') then next.
            find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then v-st = txb.codfr.code.
        end.
        find first txb.sub-cod where txb.sub-cod.sub = 'trl' and txb.sub-cod.acc = translat.nomer and txb.sub-cod.d-cod = "eknp"
        no-lock no-error.
        if avail txb.sub-cod then do:
            v-rez1 = substr(txb.sub-cod.rcode,1,1).
            v-rez2 = substr(txb.sub-cod.rcode,4,1).
            v-secK = substr(txb.sub-cod.rcode,5,1).
            v-knpK = substr(txb.sub-cod.rcode,7,3).
            if trim(v-knpK) = '321' then next.
            find txb.codfr where txb.codfr.codfr = 'spnpl' and txb.codfr.code = substr(txb.sub-cod.rcode,7,3) no-lock no-error.
            v-knp = trim(txb.codfr.name[1]).
        end.
        if v-rez1 = "1" and v-rez2 = "1" then next.
        /*find first txb.sub-cod where txb.sub-cod.sub = 'trl' and txb.sub-cod.acc = translat.nomer
        and txb.sub-cod.d-cod = 'zsgavail' and txb.sub-cod.ccode = "1" no-lock  no-error.
        if not avail txb.sub-cod then next.*/
        if translat.crc = 2 then v-amt = translat.summa.
        else do:
            find last txb.ncrchis where txb.ncrchis.crc = translat.crc and txb.ncrchis.rdt <=  translat.date - 1 no-lock no-error.
            if avail txb.ncrchis then v-amt = translat.summa * txb.ncrchis.rate[1].
            find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= translat.date - 1 no-lock no-error.
            if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
        end.
        find first txb.cif where txb.cif.jss = translat.rnn no-lock no-error.
        if avail txb.cif then v-bin = txb.cif.bin.
        if v-amt > 10000 then do:
        create wrk-ish.
            wrk-ish.bank = s-ourbank.
            wrk-ish.rmz = translat.nomer.
            wrk-ish.fio = translat.fam + ' ' + translat.name + ' ' + translat.otch.
            wrk-ish.rez1 = v-rez1.
            wrk-ish.rnn = translat.rnn.
            wrk-ish.bin = v-bin.
            wrk-ish.tranz = 'исходящий'.
            wrk-ish.knp = v-knp.
            wrk-ish.dt = translat.date.
            find first txb.crc where txb.crc.crc = translat.crc no-lock no-error.
            if avail txb.crc then wrk-ish.fcrc = txb.crc.code.
            wrk-ish.amt = translat.summa / 1000.
            wrk-ish.usd-amt = v-amt / 1000.
            wrk-ish.st = v-st.
            wrk-ish.rez2 = v-rez2.
            wrk-ish.secK = v-secK.
            wrk-ish.bn = translat.rec-fam + ' ' + translat.rec-name + ' ' + translat.rec-otch.
        end.
    end.
end.
/*in*/
KOd = "".
KBe = "".
KNP = "".
if v-pay = 2 or v-pay = 3 then do:
    v-fio = "".
    v-rnn = "".
    v-rnnd = 0.
    v-bn = "".
    v-bin = "".
    v = "".
    v-rez1 = "".
    v-acc = "".
    v-crc = 0.
    v-amt = 0.
    v-knpK = "".
    v-knp = "".
    v-tranz = "".
    v-tranzK = "".
    v-dt = ?.
    v-rez2 = "".
    v-secK = "".
    v-st = "".
    v-zs = "".
    v-fmRem = "".
    KOd = "".
    KBe = "".
    KNP = "".
    for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte
    and (txb.jl.gl = 187034 or txb.jl.gl = 187035 or txb.jl.gl = 187036 or txb.jl.gl = 187037 ) no-lock:
       find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                  and txb.trxcods.trxln = txb.jl.ln
                  and txb.trxcods.codfr = "spnpl" no-lock no-error.
       if available txb.trxcods then KNP = txb.trxcods.code.

       find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                      and txb.trxcods.trxln = txb.jl.ln
                      and txb.trxcods.codfr = "locat" no-lock no-error.
       if available txb.trxcods then do:
          KOd = txb.trxcods.code.
       end.

       find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                      and txb.trxcods.trxln = txb.jl.ln
                      and txb.trxcods.codfr = "secek" no-lock no-error.
       if available txb.trxcods then do:
          KBe = txb.trxcods.code.
       end.
       v-rez2 = KOd.
       v-secK = KBe.
       v-knp = KNP.
        find first txb.joudoc where txb.joudoc.jh = txb.jl.jh no-lock no-error.
        if avail txb.joudoc then do:
            find first txb.cif where txb.cif.jss = txb.joudoc.perkod no-lock no-error.
            if avail txb.cif then v-bin = txb.cif.bin.
            find last txb.ncrchis where txb.ncrchis.crc = txb.joudoc.crcur and txb.ncrchis.rdt <= txb.jl.jdt no-lock no-error.
            if avail txb.ncrchis then v-amt = txb.joudoc.cramt  * txb.ncrchis.rate[1].
            find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= txb.jl.jdt no-lock no-error.
            if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
            /*
            if jl.acc = "" and sum-usd <= 10000 then next.
            if jl.acc <> "" and sum-usd <= 50000 then next.
            */
            /*find first kfmoper where kfmoper.jh = txb.jl.jh no-lock no-error.
            if avail kfmoper then do:
                find first kfmprth where kfmprth.operid = kfmoper.operid and kfmprth.datacod = "prtBCoun" and partid = 2 no-lock no-error.
                if avail kfmprth then v-st = kfmprth.datavalue.
            end.
            if v-st = "" then do:*/
                find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and txb.sub-cod.d-cod = "iso3166"
                no-lock no-error.
                if avail txb.sub-cod then v-st = txb.sub-cod.ccode.
            /*end.*/
            find first txb.arp where txb.arp.arp = txb.jl.acc no-lock no-error.
            if avail txb.arp then do:
                if txb.arp.geo = '021' then v-rez1 = '1'.
                if txb.arp.geo = '022' then v-rez1 = '2'.
                if (v-st = 'KZ') then next.
                if (v-st = "" or v-st = 'msc') then do:
                    if v-rez1 = '1' and v-rez2 = '1' then next.
                end.
                if v-amt > 10000 then do:
                    i = i + 1.
                    create wrk-vh.
                    wrk-vh.rmz = "jou".
                    wrk-vh.bank = s-ourbank.
                    wrk-vh.fio = txb.joudoc.info.
                    wrk-vh.rez1 = v-rez1.
                    wrk-vh.rnn = txb.joudoc.perkod.
                    wrk-vh.bin = v-bin.
                    wrk-vh.tranz = "входящий" + " " + arp.des + " " + txb.jl.rem[1].
                    wrk-vh.knp = v-knp.
                    wrk-vh.dt = txb.jl.jdt.
                    find first txb.aaa where txb.aaa.aaa = txb.joudoc.dracc no-lock no-error.
                    if avail txb.aaa then wrk-vh.acc = txb.joudoc.dracc.
                    else wrk-vh.acc = "".
                    find first txb.crc where txb.crc.crc = txb.joudoc.crcur no-lock no-error.
                    if avail txb.crc then wrk-vh.fcrc = txb.crc.code.
                    wrk-vh.amt = txb.joudoc.cramt / 1000.
                    wrk-vh.usd-amt = v-amt / 1000.
                    wrk-vh.st = v-st.
                    wrk-vh.rez2 = v-rez2.
                    wrk-vh.secK = v-secK.
                    wrk-vh.bn = txb.joudoc.benname.
                    wrk-vh.drgl = string(txb.jl.gl) + " " + txb.joudoc.docnum.
                    /*displ i arp.geo arp.cgr arp.des jl.acc format "x(20)" joudoc.dracc format "x(20)" joudoc.cracc format "x(20)"
                    joudoc.dramt joudoc.cramt sum-usd joudoc.drcur joudoc.crcur.*/
                end.
            end.
        end.
    end.
    v-fio = "".
    v-rnn = "".
    v-rnnd = 0.
    v-bn = "".
    v-bin = "".
    v = "".
    v-rez1 = "".
    v-acc = "".
    v-crc = 0.
    v-amt = 0.
    v-knpK = "".
    v-knp = "".
    v-tranz = "".
    v-tranzK = "".
    v-dt = ?.
    v-rez2 = "".
    v-secK = "".
    v-st = "".
    v-zs = "".
    v-fmRem = "".
    KOd = "".
    KBe = "".
    KNP = "".
    for each txb.remtrz where txb.remtrz.valdt2 >= v-dtb and txb.remtrz.valdt2 <= v-dte
    and /*txb.remtrz.ptype <> '4'*/ (txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7') no-lock:
        if txb.remtrz.fcrc = 2 then v-amt = txb.remtrz.amt.
        else do:
           find last txb.ncrchis where txb.ncrchis.crc = txb.remtrz.fcrc and txb.ncrchis.rdt <= txb.remtrz.rdt no-lock no-error.
           if avail txb.ncrchis then v-amt = txb.remtrz.amt * txb.ncrchis.rate[1].
           find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= txb.remtrz.rdt no-lock no-error.
           if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
        end.
        find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz
        and txb.sub-cod.d-cod = "eknp" no-lock no-error.
        if avail txb.sub-cod then do:
            v-rez1 = substr(txb.sub-cod.rcode,1,1).
            v-rez2 = substr(txb.sub-cod.rcode,4,1).
            v-secK = substr(txb.sub-cod.rcode,5,1).
            v-knpK = substr(txb.sub-cod.rcode,7,3).
            if substr(sub-cod.rcode,5,1) <> '9' then next.


        find txb.codfr where txb.codfr.codfr = 'spnpl' and txb.codfr.code = substr(txb.sub-cod.rcode,7,3) no-lock no-error.
        if avail txb.codfr then v-knp =  /*trim(codfr.name[1])*/ codfr.code.
        end.
        /*find first kfmoper where kfmoper.jh = txb.remtrz.jh1 no-lock no-error.
        if avail kfmoper then do:
            find first kfmprth where kfmprth.operid = kfmoper.operid and kfmprth.datacod = "prtBCoun" and partid = 2 no-lock no-error.
            if avail kfmprth then v-st = kfmprth.datavalue.
        end.
        if v-st = "" then do:*/
            find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.d-cod = "iso3166"
            no-lock no-error.
            if avail txb.sub-cod then v-st = txb.sub-cod.ccode.
        /*end.*/
        if (v-st = 'KZ') then next.
        if (v-st = "" or v-st = 'msc') then do:
            if v-rez1 = '1' and v-rez2 = '1' then next.
        end.
        if (txb.remtrz.racc = "")  and  v-amt <= 10000 then next.
        if (txb.remtrz.racc <> "") then do:
            find first txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
            if avail txb.aaa and v-amt <= 50000 then next.
            if not avail txb.aaa then do:
                if v-amt <= 10000 then next.
            end.
        end.

        create wrk-vh.
        wrk-vh.rmz = "rmz".
        wrk-vh.bank = s-ourbank.
        find first cifmin where cifmin = txb.remtrz.kfmcif no-lock no-error.
        if avail cifmin THEN do:
            assign wrk-vh.fio = cifmin.fam + " " + cifmin.name + " " + cifmin.mname.
            wrk-vh.rnn = cifmin.rnn.
            wrk-vh.bin = cifmin.iin.
        end.
        if not avail cifmin then do:
            find first txb.cif where  txb.cif.cif = txb.remtrz.kfmcif no-lock no-error.
            if avail txb.cif THEN do:
                assign wrk-ish.fio = txb.cif.name.
                wrk-ish.rnn = txb.cif.jss.
                wrk-ish.bin = txb.cif.bin.
            end.
        end.
        res1 = index(txb.remtrz.ord,"RNN").
            if res1 > 0 then assign wrk-vh.fio = txb.remtrz.ord wrk-vh.rnn = substr(txb.remtrz.ord,res1 + 3,13).
            else assign wrk-vh.fio = txb.remtrz.ord  wrk-ish.rnn = txb.remtrz.ord.
        wrk-vh.rez1 = v-rez1.
        wrk-vh.tranz = "входящий".
        wrk-vh.knp = v-knp.
        wrk-vh.dt = txb.remtrz.valdt2.
        find first txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
        if avail txb.aaa then wrk-vh.acc = txb.remtrz.racc.
        else wrk-vh.acc = "".
        find first txb.crc where txb.crc.crc = txb.remtrz.fcrc no-lock no-error.
        if avail txb.crc then wrk-vh.fcrc = txb.crc.code.
        wrk-vh.amt = txb.remtrz.amt / 1000.
        wrk-vh.usd-amt = v-amt / 1000.
        wrk-vh.st = v-st.
        wrk-vh.rez2 = v-rez2.
        wrk-vh.secK = v-secK.
        wrk-vh.bn = txb.remtrz.bn[1].
        wrk-vh.drgl = string(txb.remtrz.drgl) + " " + txb.remtrz.remtrz + " " + string(txb.remtrz.crgl).
        /*displ remtrz.rdt remtrz.fcrc remtrz.amt v-amt remtrz.bn remtrz.sacc remtrz.racc remtrz.ptype v-rez1 v-rez2
        v-secK v-knp remtrz.racc remtrz.sacc remtrz.crgl remtrz.drgl.*/
    end.
    v-fio = "".
    v-rnn = "".
    v-rnnd = 0.
    v-bn = "".
    v-bin = "".
    v = "".
    v-rez1 = "".
    v-acc = "".
    v-crc = 0.
    v-amt = 0.
    v-knpK = "".
    v-knp = "".
    v-tranz = "".
    v-tranzK = "".
    v-dt = ?.
    v-rez2 = "".
    v-secK = "".
    v-st = "".
    v-zs = "".
    v-fmRem = "".
    KOd = "".
    KBe = "".
    KNP = "".
    for each r-translat no-lock:
        if r-translat.crc = 2 then v-amt = r-translat.summa.
        else do:
           find last txb.crchis where txb.crchis.crc = r-translat.crc and  txb.crchis.rdt <= r-translat.date no-lock no-error.
           if avail txb.crchis then v-amt = r-translat.summa * txb.crchis.rate[1].
        end.
        v-st = "RU".
        find first txb.sub-cod where txb.sub-cod.sub = 'trl' and txb.sub-cod.acc = r-translat.nomer and txb.sub-cod.d-cod = "eknp"
        no-lock no-error.
        if avail txb.sub-cod then do:
            v-rez1 = substr(txb.sub-cod.rcode,1,1).
            v-rez2 = substr(txb.sub-cod.rcode,4,1).
            v-secK = substr(txb.sub-cod.rcode,5,1).
            v-knpK = substr(txb.sub-cod.rcode,7,3).
            if trim(v-knpK) = '321' then next.
            find txb.codfr where txb.codfr.codfr = 'spnpl' and txb.codfr.code = substr(txb.sub-cod.rcode,7,3) no-lock no-error.
            if avail txb.codfr then v-knp = trim(txb.codfr.name[1]).
        end.
        if v-rez1 = "1" and v-rez2 = "1" then next.
        /*find first txb.sub-cod where txb.sub-cod.sub = 'trl' and txb.sub-cod.acc = r-translat.nomer
        and txb.sub-cod.d-cod = 'zsgavail' and txb.sub-cod.ccode = "1" no-lock  no-error.
        if not avail txb.sub-cod then next.*/
        if r-translat.crc = 2 then v-amt = r-translat.summa.
        else do:
            find last txb.ncrchis where txb.ncrchis.crc = r-translat.crc and txb.ncrchis.rdt <=  r-translat.date - 1 no-lock no-error.
            if avail txb.ncrchis then v-amt = r-translat.summa * txb.ncrchis.rate[1].
            find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= r-translat.date - 1 no-lock no-error.
            if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
        end.

        if v-amt > 10000 then do:
        create wrk-vh.
            wrk-vh.bank = r-translat.rec-code.
            wrk-vh.rmz = r-translat.nomer.
            wrk-vh.fio = r-translat.fam + ' ' + r-translat.name + ' ' + r-translat.otch.
            wrk-vh.rez1 = v-rez1.
            wrk-ish.rnn = ''.
            wrk-vh.bin = '' .
            wrk-vh.tranz = 'входящий'.
            wrk-vh.knp = v-knp.
            wrk-vh.dt = r-translat.date.
            find first txb.crc where txb.crc.crc = r-translat.crc no-lock no-error.
            if avail txb.crc then wrk-vh.fcrc = txb.crc.code.
            wrk-vh.amt = r-translat.summa / 1000.
            wrk-vh.usd-amt = v-amt / 1000.
            wrk-vh.st = v-st.
            wrk-vh.rez2 = v-rez2.
            wrk-vh.secK = v-secK.
            wrk-vh.bn = r-translat.rec-fam + ' ' + r-translat.rec-name + ' ' + r-translat.rec-otch.
        end.
    end.
end.