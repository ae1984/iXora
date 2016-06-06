/* vcrep50-txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        vcrep50
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        26.04.2012 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        09.08.2012 damir - добавил проверку num-entries, выходили ошибки.
        09.15.2012 damir - добавил clecod Т.З. №1385.
        01.02.2013 damir - Обнаружены ошибки - поиск БИН/ИИН. Исправлено. Добавил chbin_txb.i.
*/
{chbin_txb.i}

def shared var v-dtb as date format "99/99/9999".
def shared var v-dte as date format "99/99/9999".
def shared var v-pay as integer init 1.
def shared var g-ofc as char.

def var s-ourbank as char no-undo.

def shared temp-table wrk-ish
    field bank      as char
    field rmz       as char
    field fio       as char
    field rez1      as char
    field rnn       as char
    field bin       as char
    field tranz     as char
    field knp       as char
    field dt        as date
    field acc       as char
    field fcrc      as char
    field amt       as decimal
    field usd-amt   as decimal
    field st        as char
    field rez2      as char
    field secK      as char
    field secK1     as char
    field bn        as char
    field crgl      as char
    field c-rmz     as char
    field dgk       as inte
    field cgk       as inte
    field clecod    as inte.

def shared temp-table wrk-vh
    field bank      as char
    field rmz       as char
    field fio       as char
    field rez1      as char
    field rnn       as char
    field bin       as char
    field tranz     as char
    field knp       as char
    field dt        as date
    field acc       as char
    field fcrc      as char
    field amt       as decimal
    field usd-amt   as decimal
    field st        as char
    field rez2      as char
    field secK      as char
    field secK1     as char
    field bn        as char
    field drgl      as char
    field c-rmz     as char
    field dgk       as inte
    field cgk       as inte
    field clecod    as inte.

def var v-amt    as deci.
def var v-acc    as char.
def var v-dgk    as inte.
def var v-cgk    as inte.
def var i        as inte.
def var v-clecod as inte.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

find first txb.sysc where txb.sysc.sysc = "CLECOD" no-lock no-error.
if avail txb.sysc then v-clecod = txb.sysc.inval.

for each txb.joudoc where txb.joudoc.whn >= v-dtb and txb.joudoc.whn <= v-dte no-lock:
    find first txb.joudop where txb.joudop.docnum = txb.joudoc.docnum no-lock no-error.
    if avail txb.joudop then next.
    find first txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.sts = 6  no-lock no-error.
    if not avail txb.jl then next.
    if txb.joudoc.rem[1] matches "*CASH002*" or  txb.joudoc.rem[1] matches "*CASH001*" then next.
    if txb.joudoc.rem[2] matches "*CASH002*" or  txb.joudoc.rem[2] matches "*CASH001*" then next.
    /*out*/
    if txb.joudoc.cracc <> "" then do:
        v-acc = "".
        v-amt = 0.
        i = 0.
        v-dgk = 0.
        v-cgk = 0.
        if txb.joudoc.crcur = 1 then next.
        for each txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.sts = 6  no-lock:
            if txb.jl.cam <> 0 then v-cgk = txb.jl.gl.
            if txb.jl.dam <> 0 then v-dgk = txb.jl.gl.
        end.
        find last txb.ncrchis where txb.ncrchis.crc = txb.joudoc.crcur and txb.ncrchis.rdt <= /*txb.jl.jdt*/ txb.joudoc.whn no-lock no-error.
        if avail txb.ncrchis then v-amt = txb.joudoc.cramt  * txb.ncrchis.rate[1].
        find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= /*txb.jl.jdt*/ txb.joudoc.whn no-lock no-error.
        if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
        find first txb.aaa where txb.aaa.aaa = txb.joudoc.cracc no-lock no-error.
        if avail txb.aaa then v-acc = txb.aaa.aaa.
        if v-acc <> "" and v-amt <= 50000 then next.
        if v-acc = "" and v-amt <= 10000 then next.
        create wrk-ish.
        wrk-ish.dgk = v-dgk.
        wrk-ish.cgk = v-cgk.
        wrk-ish.rmz = txb.joudoc.docnum.
        wrk-ish.bank = s-ourbank.
        wrk-ish.clecod = v-clecod.
        find first cifmin where cifmin.cifmin = txb.joudoc.kfmcif no-lock no-error.
        if avail cifmin then do:
            wrk-ish.fio = cifmin.fam + " "  + cifmin.name + " " + cifmin.mname.
            wrk-ish.rnn = cifmin.rnn.
            wrk-ish.bin = cifmin.iin.
        end.
        if (wrk-ish.fio <> joudoc.info) or wrk-ish.fio = "" then wrk-ish.fio = joudoc.info.
        if v-bin then do:
            if txb.joudoc.whn ge v-bin_rnn_dt then do:
                if wrk-ish.bin eq "" and txb.joudoc.perkod ne "" then wrk-ish.bin = txb.joudoc.perkod.
                if wrk-ish.bin ne "" then do:
                    find first txb.cif where txb.cif.bin = wrk-ish.bin no-lock no-error.
                    if avail txb.cif then if wrk-ish.rnn eq "" then wrk-ish.rnn =  txb.cif.jss.
                end.
            end.
            else do:
                if wrk-ish.rnn = "" and txb.joudoc.perkod ne "" then wrk-ish.rnn = txb.joudoc.perkod.
                if wrk-ish.rnn ne "" then do:
                    find first txb.cif where txb.cif.jss = wrk-ish.rnn no-lock no-error.
                    if avail txb.cif then if wrk-ish.bin eq "" then wrk-ish.bin =  txb.cif.bin.
                end.
            end.
        end.
        else do:
            if wrk-ish.rnn = "" and txb.joudoc.perkod ne "" then wrk-ish.rnn = txb.joudoc.perkod.
            if wrk-ish.rnn ne "" then do:
                find first txb.cif where txb.cif.jss = wrk-ish.rnn no-lock no-error.
                if avail txb.cif then if wrk-ish.bin eq "" then wrk-ish.bin =  txb.cif.bin.
            end.
        end.

        wrk-ish.acc = v-acc.
        wrk-ish.tranz = "исходящий" + " " + joudoc.rem[1] + " " + joudoc.rem[2].
        wrk-ish.dt = /*txb.jl.jdt*/ txb.joudoc.whn.
        find first txb.crc where txb.crc.crc = txb.joudoc.crcur no-lock no-error.
        if avail txb.crc then wrk-ish.fcrc = txb.crc.code.
        wrk-ish.amt = txb.joudoc.cramt / 1000.
        wrk-ish.usd-amt = v-amt / 1000.
        wrk-ish.bn = txb.joudoc.benname.
        find first txb.remtrz where txb.remtrz.jh3 = txb.joudoc.jh no-lock no-error.
        if avail txb.remtrz then do:
            wrk-ish.c-rmz = txb.remtrz.remtrz.
            find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
            txb.sub-cod.d-cod = "iso3166" no-lock no-error.
            if avail txb.sub-cod then wrk-ish.st = txb.sub-cod.ccode.
            find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz
            and txb.sub-cod.d-cod = "eknp" no-lock no-error.
            if avail txb.sub-cod then do:
                wrk-ish.rez1 = substr(txb.sub-cod.rcode,1,1).
                wrk-ish.secK1 = substr(txb.sub-cod.rcode,2,1).
                wrk-ish.rez2 = substr(txb.sub-cod.rcode,4,1).
                wrk-ish.secK = substr(txb.sub-cod.rcode,5,1).
                wrk-ish.knp = substr(txb.sub-cod.rcode,7,3).
            end.
        end.
        else do:
            find first txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.cam = txb.joudoc.cramt no-lock no-error.
            if avail txb.jl then do:
                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln
                and txb.trxcods.codfr = "spnpl" no-lock no-error.
                if available txb.trxcods then wrk-ish.knp = txb.trxcods.code.

                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln - 1
                and txb.trxcods.codfr = "locat" no-lock no-error.
                if available txb.trxcods then wrk-ish.rez1 = txb.trxcods.code.

                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln
                and txb.trxcods.codfr = "locat" no-lock no-error.
                if available txb.trxcods then wrk-ish.rez2 = txb.trxcods.code.

                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln - 1
                and txb.trxcods.codfr = "secek" no-lock no-error.
                if available txb.trxcods then wrk-ish.secK1 = txb.trxcods.code.
                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln
                and txb.trxcods.codfr = "secek" no-lock no-error.
                if available txb.trxcods then wrk-ish.secK = txb.trxcods.code.

                find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum
                and txb.sub-cod.d-cod = "iso3166" no-lock no-error.
                if avail txb.sub-cod then wrk-ish.st = txb.sub-cod.ccode.
            end.
        END.
        wrk-ish.crgl = string(txb.joudoc.jh) + "  " + txb.joudoc.docnum + " " + wrk-ish.c-rmz.
    end.
    /*in*/
    if txb.joudoc.dracc <> "" then do:
        v-acc = "".
        v-amt = 0.
        i = 0.
        v-dgk = 0.
        v-cgk = 0.
        if txb.joudoc.drcur = 1 then next.
        for each txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.sts = 6  no-lock:
            if txb.jl.cam <> 0 then v-cgk = txb.jl.gl.
            if txb.jl.dam <> 0 then v-dgk = txb.jl.gl.
        end.
        find last txb.ncrchis where txb.ncrchis.crc = txb.joudoc.drcur and txb.ncrchis.rdt <= /*txb.jl.jdt*/ txb.joudoc.whn no-lock no-error.
        if avail txb.ncrchis then v-amt = txb.joudoc.cramt  * txb.ncrchis.rate[1].
        find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= /*txb.jl.jdt*/ txb.joudoc.whn no-lock no-error.
        if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
        find first txb.aaa where txb.aaa.aaa = txb.joudoc.dracc no-lock no-error.
        if avail txb.aaa then v-acc = txb.aaa.aaa.
        if v-acc <> "" and v-amt <= 50000 then next.
        if v-acc = "" and v-amt <= 10000 then next.
        create wrk-vh.
        wrk-vh.dgk = v-dgk.
        wrk-vh.cgk = v-cgk.
        wrk-vh.rmz = txb.joudoc.docnum.
        wrk-vh.bank = s-ourbank.
        wrk-vh.clecod = v-clecod.
        find first cifmin where cifmin.cifmin = txb.joudoc.kfmcif no-lock no-error.
        if avail cifmin then do:
            wrk-vh.fio = cifmin.fam + " "  + cifmin.name + " " + cifmin.mname.
            wrk-vh.rnn = cifmin.rnn.
            wrk-vh.bin = cifmin.iin.
        end.
        if (wrk-vh.fio <> joudoc.info) or wrk-vh.fio = "" then wrk-vh.fio = joudoc.info.
        if v-bin then do:
            if txb.joudoc.whn ge v-bin_rnn_dt then do:
                if wrk-vh.bin eq "" and txb.joudoc.perkod ne "" then wrk-vh.bin = txb.joudoc.perkod.
                if wrk-vh.bin ne "" then do:
                    find first txb.cif where txb.cif.bin = wrk-vh.bin no-lock no-error.
                    if avail txb.cif then if wrk-vh.rnn eq "" then wrk-vh.rnn =  txb.cif.jss.
                end.
            end.
            else do:
                if wrk-vh.rnn = "" and txb.joudoc.perkod ne "" then wrk-vh.rnn = txb.joudoc.perkod.
                if wrk-vh.rnn ne "" then do:
                    find first txb.cif where txb.cif.jss = wrk-vh.rnn no-lock no-error.
                    if avail txb.cif then if wrk-vh.bin eq "" then wrk-vh.bin =  txb.cif.bin.
                end.
            end.
        end.
        else do:
            if wrk-vh.rnn = "" and txb.joudoc.perkod ne "" then wrk-vh.rnn = txb.joudoc.perkod.
            if wrk-vh.rnn ne "" then do:
                find first txb.cif where txb.cif.jss = wrk-vh.rnn no-lock no-error.
                if avail txb.cif then if wrk-vh.bin eq "" then wrk-vh.bin =  txb.cif.bin.
            end.
        end.
        wrk-vh.acc = v-acc.
        wrk-vh.tranz = "входящий" + " " + joudoc.rem[1] + " " + joudoc.rem[2].
        wrk-vh.dt = /*txb.jl.jdt*/ txb.joudoc.whn.
        find first txb.crc where txb.crc.crc = txb.joudoc.drcur no-lock no-error.
        if avail txb.crc then wrk-vh.fcrc = txb.crc.code.
        wrk-vh.amt = txb.joudoc.cramt / 1000.
        wrk-vh.usd-amt = v-amt / 1000.
        wrk-vh.bn = txb.joudoc.benname.
        find first txb.remtrz where txb.remtrz.jh3 = txb.joudoc.jh no-lock no-error.
        if avail txb.remtrz then do:
            wrk-vh.c-rmz = txb.remtrz.remtrz.
            find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
            txb.sub-cod.d-cod = "iso3166" no-lock no-error.
            if avail txb.sub-cod then wrk-vh.st = txb.sub-cod.ccode.
            find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz
            and txb.sub-cod.d-cod = "eknp" no-lock no-error.
            if avail txb.sub-cod then do:
                wrk-vh.rez1 = substr(txb.sub-cod.rcode,1,1).
                wrk-vh.secK1 = substr(txb.sub-cod.rcode,3,1).
                wrk-vh.rez2 = substr(txb.sub-cod.rcode,4,1).
                wrk-vh.secK = substr(txb.sub-cod.rcode,5,1).
                wrk-vh.knp = substr(txb.sub-cod.rcode,7,3).
            end.
        end.
        else do:
            find first txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.dam = txb.joudoc.dramt no-lock no-error.
            if avail txb.jl then do:
                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln
                and txb.trxcods.codfr = "spnpl" no-lock no-error.
                if available txb.trxcods then wrk-vh.knp = txb.trxcods.code.

                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln + 1
                and txb.trxcods.codfr = "locat" no-lock no-error.
                if available txb.trxcods then wrk-vh.rez1 = txb.trxcods.code.
                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln
                and txb.trxcods.codfr = "locat" no-lock no-error.
                if available txb.trxcods then wrk-vh.rez2 = txb.trxcods.code.

                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln + 1
                and txb.trxcods.codfr = "secek" no-lock no-error.
                if available txb.trxcods then wrk-vh.secK1 = txb.trxcods.code.
                find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                and txb.trxcods.trxln = txb.jl.ln
                and txb.trxcods.codfr = "secek" no-lock no-error.
                if available txb.trxcods then wrk-vh.secK = txb.trxcods.code.

                find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum
                and txb.sub-cod.d-cod = "iso3166" no-lock no-error.
                if avail txb.sub-cod then wrk-vh.st = txb.sub-cod.ccode.
            end.
        end.
        wrk-vh.drgl = string(txb.joudoc.jh) + "  " + txb.joudoc.docnum + " " + wrk-vh.c-rmz.
    end.
    hide message no-pause.
    message "BASE - " s-ourbank " JOUDOC - " txb.joudoc.docnum.
end.
for each txb.joudop where txb.joudop.whn >= v-dtb and txb.joudop.whn <= v-dte no-lock:
    find first txb.joudoc where /*txb.joudoc.jh = txb.jl.jh*/ txb.joudoc.docnum = txb.joudop.docnum
    no-lock no-error.
    if avail txb.joudoc then do:
        find first txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.sts = 6  no-lock no-error.
        if not avail txb.jl then next.
        if txb.joudoc.rem[1] matches "*CASH002*" or  txb.joudoc.rem[1] matches "*CASH001*" then next.
        if txb.joudoc.rem[2] matches "*CASH002*" or  txb.joudoc.rem[2] matches "*CASH001*" then next.
        /*out*/
        if txb.joudoc.cracc <> "" then do:
            v-acc = "".
            v-amt = 0.
            i = 0.
            v-dgk = 0.
            v-cgk = 0.
            if txb.joudoc.crcur = 1 then next.
            for each txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.sts = 6  no-lock:
                if txb.jl.cam <> 0 then v-cgk = txb.jl.gl.
                if txb.jl.dam <> 0 then v-dgk = txb.jl.gl.
                hide message no-pause.
                message "BASE - " s-ourbank " JOUDOP - " txb.joudoc.docnum " JL - " txb.jl.jh.
            end.
            find last txb.ncrchis where txb.ncrchis.crc = txb.joudoc.crcur and txb.ncrchis.rdt <= /*txb.jl.jdt*/ txb.joudop.whn no-lock no-error.
            if avail txb.ncrchis then v-amt = txb.joudoc.cramt  * txb.ncrchis.rate[1].
            find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= /*txb.jl.jdt*/ txb.joudop.whn no-lock no-error.
            if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
            find first txb.aaa where txb.aaa.aaa = txb.joudoc.cracc no-lock no-error.
            if avail txb.aaa then v-acc = txb.aaa.aaa.
            if v-acc <> "" and v-amt <= 50000 then next.
            if v-acc = "" and v-amt <= 10000 then next.
            create wrk-ish.
            wrk-ish.dgk = v-dgk.
            wrk-ish.cgk = v-cgk.
            wrk-ish.rmz = txb.joudoc.docnum.
            wrk-ish.bank = s-ourbank.
            wrk-ish.clecod = v-clecod.
            find first cifmin where cifmin.cifmin = txb.joudoc.kfmcif no-lock no-error.
            if avail cifmin then do:
                wrk-ish.fio = cifmin.fam + " "  + cifmin.name + " " + cifmin.mname.
                wrk-ish.rnn = cifmin.rnn.
                wrk-ish.bin = cifmin.iin.
            end.
            if (wrk-ish.fio <> joudoc.info) or wrk-ish.fio = "" then wrk-ish.fio = joudoc.info.
            if v-bin then do:
                if txb.joudoc.whn ge v-bin_rnn_dt then do:
                    if wrk-ish.bin eq "" and txb.joudoc.perkod ne "" then wrk-ish.bin = txb.joudoc.perkod.
                    if wrk-ish.bin ne "" then do:
                        find first txb.cif where txb.cif.bin = wrk-ish.bin no-lock no-error.
                        if avail txb.cif then if wrk-ish.rnn eq "" then wrk-ish.rnn =  txb.cif.jss.
                    end.
                end.
                else do:
                    if wrk-ish.rnn = "" and txb.joudoc.perkod ne "" then wrk-ish.rnn = txb.joudoc.perkod.
                    if wrk-ish.rnn ne "" then do:
                        find first txb.cif where txb.cif.jss = wrk-ish.rnn no-lock no-error.
                        if avail txb.cif then if wrk-ish.bin eq "" then wrk-ish.bin =  txb.cif.bin.
                    end.
                end.
            end.
            else do:
                if wrk-ish.rnn = "" and txb.joudoc.perkod ne "" then wrk-ish.rnn = txb.joudoc.perkod.
                if wrk-ish.rnn ne "" then do:
                    find first txb.cif where txb.cif.jss = wrk-ish.rnn no-lock no-error.
                    if avail txb.cif then if wrk-ish.bin eq "" then wrk-ish.bin =  txb.cif.bin.
                end.
            end.
            wrk-ish.acc = v-acc.
            wrk-ish.tranz = "исходящий" + " " + joudoc.rem[1] + " " + joudoc.rem[2].
            wrk-ish.dt = /*txb.jl.jdt*/ txb.joudop.whn.
            find first txb.crc where txb.crc.crc = txb.joudoc.crcur no-lock no-error.
            if avail txb.crc then wrk-ish.fcrc = txb.crc.code.
            wrk-ish.amt = txb.joudoc.cramt / 1000.
            wrk-ish.usd-amt = v-amt / 1000.
            wrk-ish.bn = txb.joudoc.benname.
            find first txb.remtrz where txb.remtrz.jh3 = txb.joudoc.jh no-lock no-error.
            if avail txb.remtrz then do:
                wrk-ish.c-rmz = txb.remtrz.remtrz.
                find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                txb.sub-cod.d-cod = "iso3166" no-lock no-error.
                if avail txb.sub-cod then wrk-ish.st = txb.sub-cod.ccode.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz
                and txb.sub-cod.d-cod = "eknp" no-lock no-error.
                if avail txb.sub-cod then do:
                    wrk-ish.rez1 = substr(txb.sub-cod.rcode,1,1).
                    wrk-ish.secK1 = substr(txb.sub-cod.rcode,2,1).
                    wrk-ish.rez2 = substr(txb.sub-cod.rcode,4,1).
                    wrk-ish.secK = substr(txb.sub-cod.rcode,5,1).
                    wrk-ish.knp = substr(txb.sub-cod.rcode,7,3).
                end.
            end.
            else do:
                find first txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.cam = txb.joudoc.cramt no-lock no-error.
                if avail txb.jl then do:
                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln
                    and txb.trxcods.codfr = "spnpl" no-lock no-error.
                    if available txb.trxcods then wrk-ish.knp = txb.trxcods.code.

                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln - 1
                    and txb.trxcods.codfr = "locat" no-lock no-error.
                    if available txb.trxcods then wrk-ish.rez1 = txb.trxcods.code.

                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln
                    and txb.trxcods.codfr = "locat" no-lock no-error.
                    if available txb.trxcods then wrk-ish.rez2 = txb.trxcods.code.

                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln - 1
                    and txb.trxcods.codfr = "secek" no-lock no-error.
                    if available txb.trxcods then wrk-ish.secK1 = txb.trxcods.code.
                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln
                    and txb.trxcods.codfr = "secek" no-lock no-error.
                    if available txb.trxcods then wrk-ish.secK = txb.trxcods.code.

                    find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum
                    and txb.sub-cod.d-cod = "iso3166" no-lock no-error.
                    if avail txb.sub-cod then wrk-ish.st = txb.sub-cod.ccode.
                end.
            END.
            /*i = num-entries(joudop.fname,"^").
            if wrk-ish.st = " " and  i >= 9 then wrk-ish.st = entry(9,txb.joudop.fname,"^").*/
            if wrk-ish.st = " " then do:
                if (substr(txb.joudop.type,1,3) = "TR1" or substr(txb.joudop.type,1,3) = "RT1") and num-entries(txb.joudop.lname,",") >= 4 then wrk-ish.st = entry(4,txb.joudop.lname,",").
                if (substr(txb.joudop.type,1,3) = "FR1" or substr(txb.joudop.type,1,3) = "RF1") and num-entries(txb.joudop.fname,"^") >= 9 then wrk-ish.st = entry(9,txb.joudop.fname,"^").
                if (substr(txb.joudop.type,1,3) = "FR2" or substr(txb.joudop.type,1,3) = "RF2") and num-entries(txb.joudop.lname,"^") >= 4 then wrk-ish.st = entry(4,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "TN3" or substr(txb.joudop.type,1,3) = "NT3") and num-entries(txb.joudop.lname,"^") >= 5 then wrk-ish.st = entry(5,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "TN4" or substr(txb.joudop.type,1,3) = "NT4") and num-entries(txb.joudop.lname,"^") >= 3 then wrk-ish.st = entry(3,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "TN5" or substr(txb.joudop.type,1,3) = "NT5") and num-entries(txb.joudop.lname,"^") >= 4 then wrk-ish.st = entry(4,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "FR3" or substr(txb.joudop.type,1,3) = "RF3") and num-entries(txb.joudop.lname,"^") >= 4 then wrk-ish.st = entry(4,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "TR2" or substr(txb.joudop.type,1,3) = "RT2") and num-entries(txb.joudop.lname,",") >= 4 then wrk-ish.st = entry(4,txb.joudop.lname,",").
                if (substr(txb.joudop.type,1,3) = "TR3" or substr(txb.joudop.type,1,3) = "RT3") and num-entries(txb.joudop.lname,",") >= 4 then wrk-ish.st = entry(4,txb.joudop.lname,",").
                if (substr(txb.joudop.type,1,3) = "TR4" or substr(txb.joudop.type,1,3) = "RT4") and num-entries(txb.joudop.lname,",") >= 4 then wrk-ish.st = entry(4,txb.joudop.lname,",").
            end.
            wrk-ish.crgl = string(txb.joudoc.jh) + "  " + txb.joudoc.docnum + " " + wrk-ish.c-rmz.
        end.
        /*in*/
        if txb.joudoc.dracc <> "" then do:
            v-acc = "".
            v-amt = 0.
            i = 0.
            v-dgk = 0.
            v-cgk = 0.
            if txb.joudoc.drcur = 1 then next.
            for each txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.sts = 6  no-lock:
                if txb.jl.cam <> 0 then v-cgk = txb.jl.gl.
                if txb.jl.dam <> 0 then v-dgk = txb.jl.gl.
                hide message no-pause.
                message "BASE - " s-ourbank " JOUDOP - " txb.joudoc.docnum " JL - " txb.jl.jh.
            end.
            find last txb.ncrchis where txb.ncrchis.crc = txb.joudoc.drcur and txb.ncrchis.rdt <= /*txb.jl.jdt*/ txb.joudop.whn no-lock no-error.
            if avail txb.ncrchis then v-amt = txb.joudoc.cramt  * txb.ncrchis.rate[1].
            find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= /*txb.jl.jdt*/ txb.joudop.whn no-lock no-error.
            if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
            find first txb.aaa where txb.aaa.aaa = txb.joudoc.dracc no-lock no-error.
            if avail txb.aaa then v-acc = txb.aaa.aaa.
            if v-acc <> "" and v-amt <= 50000 then next.
            if v-acc = "" and v-amt <= 10000 then next.
            create wrk-vh.
            wrk-vh.dgk = v-dgk.
            wrk-vh.cgk = v-cgk.
            wrk-vh.rmz = txb.joudoc.docnum.
            wrk-vh.bank = s-ourbank.
            wrk-vh.clecod = v-clecod.
            find first cifmin where cifmin.cifmin = txb.joudoc.kfmcif no-lock no-error.
            if avail cifmin then do:
                wrk-vh.fio = cifmin.fam + " "  + cifmin.name + " " + cifmin.mname.
                wrk-vh.rnn = cifmin.rnn.
                wrk-vh.bin = cifmin.iin.
            end.
            if (wrk-vh.fio <> joudoc.info) or wrk-vh.fio = "" then wrk-vh.fio = joudoc.info.
            if v-bin then do:
                if txb.joudoc.whn ge v-bin_rnn_dt then do:
                    if wrk-vh.bin eq "" and txb.joudoc.perkod ne "" then wrk-vh.bin = txb.joudoc.perkod.
                    if wrk-vh.bin ne "" then do:
                        find first txb.cif where txb.cif.bin = wrk-vh.bin no-lock no-error.
                        if avail txb.cif then if wrk-vh.rnn eq "" then wrk-vh.rnn =  txb.cif.jss.
                    end.
                end.
                else do:
                    if wrk-vh.rnn = "" and txb.joudoc.perkod ne "" then wrk-vh.rnn = txb.joudoc.perkod.
                    if wrk-vh.rnn ne "" then do:
                        find first txb.cif where txb.cif.jss = wrk-vh.rnn no-lock no-error.
                        if avail txb.cif then if wrk-vh.bin eq "" then wrk-vh.bin =  txb.cif.bin.
                    end.
                end.
            end.
            else do:
                if wrk-vh.rnn = "" and txb.joudoc.perkod ne "" then wrk-vh.rnn = txb.joudoc.perkod.
                if wrk-vh.rnn ne "" then do:
                    find first txb.cif where txb.cif.jss = wrk-vh.rnn no-lock no-error.
                    if avail txb.cif then if wrk-vh.bin eq "" then wrk-vh.bin =  txb.cif.bin.
                end.
            end.
            wrk-vh.acc = v-acc.
            wrk-vh.tranz = "входящий" + " " + joudoc.rem[1] + " " + joudoc.rem[2].
            wrk-vh.dt = /*txb.jl.jdt*/ txb.joudop.whn.
            find first txb.crc where txb.crc.crc = txb.joudoc.drcur no-lock no-error.
            if avail txb.crc then wrk-vh.fcrc = txb.crc.code.
            wrk-vh.amt = txb.joudoc.cramt / 1000.
            wrk-vh.usd-amt = v-amt / 1000.
            wrk-vh.bn = txb.joudoc.benname.
            find first txb.remtrz where txb.remtrz.jh3 = txb.joudoc.jh no-lock no-error.
            if avail txb.remtrz then do:
                wrk-vh.c-rmz = txb.remtrz.remtrz.
                find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                txb.sub-cod.d-cod = "iso3166" no-lock no-error.
                if avail txb.sub-cod then wrk-vh.st = txb.sub-cod.ccode.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz
                and txb.sub-cod.d-cod = "eknp" no-lock no-error.
                if avail txb.sub-cod then do:
                    wrk-vh.rez1 = substr(txb.sub-cod.rcode,1,1).
                    wrk-vh.secK1 = substr(txb.sub-cod.rcode,3,1).
                    wrk-vh.rez2 = substr(txb.sub-cod.rcode,4,1).
                    wrk-vh.secK = substr(txb.sub-cod.rcode,5,1).
                    wrk-vh.knp = substr(txb.sub-cod.rcode,7,3).
                end.
            end.
            else do:
                find first txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.dam = txb.joudoc.dramt no-lock no-error.
                if avail txb.jl then do:
                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln
                    and txb.trxcods.codfr = "spnpl" no-lock no-error.
                    if available txb.trxcods then wrk-vh.knp = txb.trxcods.code.

                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln + 1
                    and txb.trxcods.codfr = "locat" no-lock no-error.
                    if available txb.trxcods then wrk-vh.rez1 = txb.trxcods.code.
                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln
                    and txb.trxcods.codfr = "locat" no-lock no-error.
                    if available txb.trxcods then wrk-vh.rez2 = txb.trxcods.code.

                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln + 1
                    and txb.trxcods.codfr = "secek" no-lock no-error.
                    if available txb.trxcods then wrk-vh.secK1 = txb.trxcods.code.
                    find txb.trxcods where txb.trxcods.trxh = txb.jl.jh
                    and txb.trxcods.trxln = txb.jl.ln
                    and txb.trxcods.codfr = "secek" no-lock no-error.
                    if available txb.trxcods then wrk-vh.secK = txb.trxcods.code.

                    find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum
                    and txb.sub-cod.d-cod = "iso3166" no-lock no-error.
                    if avail txb.sub-cod then wrk-vh.st = txb.sub-cod.ccode.
                end.
            end.
            /*i = num-entries(joudop.fname,"^").
            if wrk-vh.st = " " and  i >= 9 then wrk-vh.st = entry(9,joudop.fname,"^").*/
            if wrk-vh.st = " " then do:
                if (substr(txb.joudop.type,1,3) = "TR1" or substr(txb.joudop.type,1,3) = "RT1") and num-entries(txb.joudop.lname,",") >= 4 then wrk-vh.st = entry(4,txb.joudop.lname,",").
                if (substr(txb.joudop.type,1,3) = "FR1" or substr(txb.joudop.type,1,3) = "RF1") and num-entries(txb.joudop.fname,"^") >= 9 then wrk-vh.st = entry(9,txb.joudop.fname,"^").
                if (substr(txb.joudop.type,1,3) = "FR2" or substr(txb.joudop.type,1,3) = "RF2") and num-entries(txb.joudop.lname,"^") >= 4 then wrk-vh.st = entry(4,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "TN3" or substr(txb.joudop.type,1,3) = "NT3") and num-entries(txb.joudop.lname,"^") >= 5 then wrk-vh.st = entry(5,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "TN4" or substr(txb.joudop.type,1,3) = "NT4") and num-entries(txb.joudop.lname,"^") >= 3 then wrk-vh.st = entry(3,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "TN5" or substr(txb.joudop.type,1,3) = "NT5") and num-entries(txb.joudop.lname,"^") >= 4 then wrk-vh.st = entry(4,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "FR3" or substr(txb.joudop.type,1,3) = "RF3") and num-entries(txb.joudop.lname,"^") >= 4 then wrk-vh.st = entry(4,txb.joudop.lname,"^").
                if (substr(txb.joudop.type,1,3) = "TR2" or substr(txb.joudop.type,1,3) = "RT2") and num-entries(txb.joudop.lname,",") >= 4 then wrk-vh.st = entry(4,txb.joudop.lname,",").
                if (substr(txb.joudop.type,1,3) = "TR3" or substr(txb.joudop.type,1,3) = "RT3") and num-entries(txb.joudop.lname,",") >= 4 then wrk-vh.st = entry(4,txb.joudop.lname,",").
                if (substr(txb.joudop.type,1,3) = "TR4" or substr(txb.joudop.type,1,3) = "RT4") and num-entries(txb.joudop.lname,",") >= 4 then wrk-vh.st = entry(4,txb.joudop.lname,",").
            end.
            wrk-vh.drgl = string(txb.joudoc.jh) + "  " + txb.joudoc.docnum + " " + wrk-vh.c-rmz.
        end.
    end.
    hide message no-pause.
    message "BASE - " s-ourbank " JOUDOP - " txb.joudop.docnum.
end.
/*for each txb.remtrz where txb.remtrz.jh <> ? no-lock:
create wrk-rmz.
wrk.remtrz = txb.remtrz.remtrz.
wrk.sqn = substr(txb.remtrz.sqn,7,10).
end.*/


for each txb.remtrz where txb.remtrz.valdt2 >= v-dtb and txb.remtrz.valdt2 <= v-dte and remtrz.jh3 = ? no-lock:
    find first txb.jh where txb.jh.jh = txb.remtrz.jh1 and txb.jh.sts = 6 no-lock no-error.
    if not avail txb.jh then next.
    if txb.remtrz.fcrc = 1 then next.
    v-acc = "".
    v-amt = 0.
    i = 0.
    find last txb.ncrchis where txb.ncrchis.crc = txb.remtrz.fcrc and txb.ncrchis.rdt <= txb.remtrz.rdt no-lock no-error.
    if avail txb.ncrchis then v-amt = txb.remtrz.amt * txb.ncrchis.rate[1].
    find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= txb.remtrz.rdt no-lock no-error.
    if avail txb.ncrchis then v-amt = v-amt / txb.ncrchis.rate[1].
    /*out*/
    if /*txb.remtrz.sacc <> "" and*/ (txb.remtrz.ptype = '2' or txb.remtrz.ptype = '6' or (txb.remtrz.ptype = '4' and txb.remtrz.rbank = "VALOUT")) then do:
        find first txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
        if avail txb.aaa then v-acc = txb.aaa.aaa.
        if v-acc <> "" and v-amt <= 50000 then next.
        if v-acc = "" and v-amt <= 10000 then next.
        create wrk-ish.
        wrk-ish.cgk = txb.remtrz.crgl.
        wrk-ish.dgk = txb.remtrz.drgl.
        wrk-ish.rmz = txb.remtrz.remtrz.
        wrk-ish.c-rmz = substr(txb.remtrz.sqn,7,10).
        wrk-ish.bank = s-ourbank.
        wrk-ish.clecod = v-clecod.
        find first cifmin where cifmin = txb.remtrz.kfmcif no-lock no-error.
        if avail cifmin THEN do:
            wrk-ish.fio = cifmin.fam + " " + cifmin.name + " " + cifmin.mname.
            wrk-ish.rnn = cifmin.rnn.
            wrk-ish.bin = cifmin.iin.
        end.
        if not avail cifmin then do:
            find first txb.cif where  txb.cif.cif = txb.remtrz.kfmcif no-lock no-error.
            if avail txb.cif THEN do:
                wrk-ish.fio = txb.cif.name.
                wrk-ish.rnn = txb.cif.jss.
                wrk-ish.bin = txb.cif.bin.
            end.
            else do:
                find first txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
                if avail txb.aaa then do:
                    find first txb.cif where  txb.cif.cif = txb.aaa.cif no-lock no-error.
                    if avail txb.cif THEN do:
                        wrk-ish.fio = txb.cif.name.
                        wrk-ish.rnn = txb.cif.jss.
                        wrk-ish.bin = txb.cif.bin.
                    end.
                end.
            end.
        end.
        if wrk-ish.fio = "" then do:
            i = index(txb.remtrz.ord,"RNN").
            if i > 0 then do:
                wrk-ish.fio = txb.remtrz.ord.
                wrk-ish.rnn = substr(txb.remtrz.ord,i + 3,13).
            end.
            else do:
                wrk-ish.fio = txb.remtrz.ord.
                wrk-ish.rnn = txb.remtrz.ord.
            end.
        end.
        wrk-ish.acc = v-acc.
        wrk-ish.tranz = "исходящий" + " " + remtrz.detpay[1] + " " + remtrz.detpay[2] + " " + remtrz.detpay[3]+ " " + remtrz.detpay[4].
        wrk-ish.dt = txb.remtrz.valdt2.
        find first txb.crc where txb.crc.crc = txb.remtrz.fcrc no-lock no-error.
        if avail txb.crc then wrk-ish.fcrc = txb.crc.code.
        wrk-ish.amt = txb.remtrz.amt / 1000.
        wrk-ish.usd-amt = v-amt / 1000.
        wrk-ish.crgl = string(txb.remtrz.crgl) + " " + txb.remtrz.remtrz + " " + wrk-ish.c-rmz.
        wrk-ish.bn = txb.remtrz.bn[1].

        find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.d-cod = "iso3166"
        no-lock no-error.
        if avail txb.sub-cod then wrk-ish.st = txb.sub-cod.ccode.

        find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz
        and txb.sub-cod.d-cod = "eknp" no-lock no-error.
        if avail txb.sub-cod then do:
            wrk-ish.rez1 = substr(txb.sub-cod.rcode,1,1).
            wrk-ish.secK1 = substr(txb.sub-cod.rcode,2,1).
            wrk-ish.rez2 = substr(txb.sub-cod.rcode,4,1).
            wrk-ish.secK = substr(txb.sub-cod.rcode,5,1) .
            /*wrk-ish.knp = substr(txb.sub-cod.rcode,7,3).*/

            find txb.codfr where txb.codfr.codfr = 'spnpl' and txb.codfr.code = substr(txb.sub-cod.rcode,7,3) no-lock no-error.
            if avail txb.codfr then wrk-ish.knp =  /*trim(codfr.name[1])*/ codfr.code.
        end.
    end.
    /*in*/
    if /*txb.remtrz.racc <> "" and*/ (txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7' or (txb.remtrz.ptype = '4' and txb.remtrz.rbank <> "VALOUT")) then do:
        find first txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
        if avail txb.aaa then v-acc = txb.aaa.aaa.
        if v-acc <> "" and v-amt <= 50000 then next.
        if v-acc = "" and v-amt <= 10000 then next.
        create wrk-vh.
        wrk-vh.cgk = txb.remtrz.crgl.
        wrk-vh.dgk = txb.remtrz.drgl.
        wrk-vh.rmz = txb.remtrz.remtrz.
        wrk-vh.c-rmz = substr(txb.remtrz.sqn,7,10).
        wrk-vh.bank = s-ourbank.
        wrk-vh.clecod = v-clecod.
        find first cifmin where cifmin = txb.remtrz.kfmcif no-lock no-error.
        if avail cifmin THEN do:
            wrk-vh.fio = cifmin.fam + " " + cifmin.name + " " + cifmin.mname.
            wrk-vh.rnn = cifmin.rnn.
            wrk-vh.bin = cifmin.iin.
        end.
        if not avail cifmin then do:
            find first txb.cif where  txb.cif.cif = txb.remtrz.kfmcif no-lock no-error.
            if avail txb.cif THEN do:
                wrk-vh.fio = txb.cif.name.
                wrk-vh.rnn = txb.cif.jss.
                wrk-vh.bin = txb.cif.bin.
            end.
            else do:
                find first txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
                if avail txb.aaa then do:
                    find first txb.cif where  txb.cif.cif = txb.aaa.cif no-lock no-error.
                    if avail txb.cif THEN do:
                        wrk-vh.fio = txb.cif.name.
                        wrk-vh.rnn = txb.cif.jss.
                        wrk-vh.bin = txb.cif.bin.
                    end.
                end.
            end.
        end.
        if wrk-vh.fio = "" then do:
            i = index(txb.remtrz.ord,"RNN").
            if i > 0 then do:
                wrk-vh.fio = txb.remtrz.ord.
                wrk-vh.rnn = substr(txb.remtrz.ord,i + 3,13).
            end.
            else do:
                wrk-vh.fio = txb.remtrz.ord.
                wrk-vh.rnn = txb.remtrz.ord.
            end.
        end.
        wrk-vh.acc = v-acc.
        wrk-vh.tranz = "входящий" + " " + remtrz.detpay[1] + " " + remtrz.detpay[2] + " " + remtrz.detpay[3]+ " " + remtrz.detpay[4].
        wrk-vh.dt = txb.remtrz.valdt2.
        find first txb.crc where txb.crc.crc = txb.remtrz.fcrc no-lock no-error.
        if avail txb.crc then wrk-vh.fcrc = txb.crc.code.
        wrk-vh.amt = txb.remtrz.amt / 1000.
        wrk-vh.usd-amt = v-amt / 1000.
        wrk-vh.drgl = string(txb.remtrz.drgl) + " " + txb.remtrz.remtrz + " " + wrk-vh.c-rmz.
        wrk-vh.bn = txb.remtrz.bn[1].

        find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.d-cod = "iso3166"
        no-lock no-error.
        if avail txb.sub-cod then wrk-vh.st = txb.sub-cod.ccode.

        find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz
        and txb.sub-cod.d-cod = "eknp" no-lock no-error.
        if avail txb.sub-cod then do:
            wrk-vh.rez1 = substr(txb.sub-cod.rcode,1,1).
            wrk-vh.secK1 = substr(txb.sub-cod.rcode,2,1).
            wrk-vh.rez2 = substr(txb.sub-cod.rcode,4,1).
            wrk-vh.secK = substr(txb.sub-cod.rcode,5,1).
            /*wrk-vh.knp = substr(txb.sub-cod.rcode,7,3).*/

            find txb.codfr where txb.codfr.codfr = 'spnpl' and txb.codfr.code = substr(txb.sub-cod.rcode,7,3) no-lock no-error.
            if avail txb.codfr then wrk-vh.knp =  /*trim(codfr.name[1])*/ codfr.code.
        end.
    end.
    hide message no-pause.
    message "BASE - " s-ourbank " REMTRZ - " txb.remtrz.remtrz.
end.

