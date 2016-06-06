/* aaablock.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Блокировка всех счетов клиента на сумму просроченной задолженности по кредиту
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
        20/03/2012 dmitriy
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def shared var g-today as date.
def shared var g-ofc as char.

def var v-ln as int.
def var vbal7 as deci.
def var vbal4 as deci.
def var vbal5 as deci.
def var v-shtraf as deci.
def var v-kommis as deci.
def var fullod as deci.
def var fullod-crc as deci.

def temp-table wrk
    field aaa like txb.aaa.aaa
    field who as char
    field whn as date
    field regdt as date
    field tim like txb.aas.tim
    field point as int
    field depart as int
    field ln as int
    field sic as char
    field chkno as int
    field chkamt as deci
    field payee as char
    field delaas as char.

def var v-propath as char no-undo.
v-propath = propath.

for each txb.cif no-lock:
    fullod = 0. vbal7 = 0.
    find first txb.lon where txb.lon.cif = txb.cif.cif no-lock no-error.
    if avail txb.lon then do:
        for each txb.lon where txb.lon.cif = txb.cif.cif and txb.lon.grp <> 90 and txb.lon.grp <> 92 no-lock:

            v-kommis = 0.
            find last txb.lons where txb.lons.lon = txb.lon.lon no-lock no-error.
            if avail txb.lons then v-kommis = txb.lons.amt.

            v-shtraf = 0.
            find last txb.hislon where txb.hislon.lon = txb.lon.lon and txb.hislon.fdt <= g-today no-lock no-error.
            if avail txb.hislon then assign v-shtraf = (txb.hislon.tdam[2] - txb.hislon.tcam[2]).

            run lonbalcrc_txb('lon',txb.lon.lon,g-today,"7",yes,txb.lon.crc,output vbal7).
            run lonbalcrc_txb('lon',txb.lon.lon,g-today,"4",yes,txb.lon.crc,output vbal4).
            run lonbalcrc_txb('lon',txb.lon.lon,g-today,"5",yes,txb.lon.crc,output vbal5).

            if vbal7 + vbal4 + vbal5 + v-kommis + v-shtraf = 0 then next.

            if txb.lon.crc <> 1 then do:
                find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= g-today no-lock no-error.
                if avail txb.crchis then do:
                    vbal7 = vbal7 * txb.crchis.rate[1].
                    vbal4 = vbal4 * txb.crchis.rate[1].
                    vbal5 = vbal5 * txb.crchis.rate[1].
                    v-kommis = v-kommis * txb.crchis.rate[1].
                    v-shtraf = v-shtraf * txb.crchis.rate[1].
                end.
            end.

            fullod = fullod + vbal7 + vbal4 + vbal5 + v-kommis + v-shtraf.

        end.

        if fullod <= 0 then next.
        else do:

            for each txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.sta <> "C" no-lock:
                find last txb.aas where txb.aas.aaa = txb.aaa.aaa no-lock no-error.
                if avail txb.aas then v-ln = txb.aas.ln + 1.
                else v-ln = 1.

                fullod-crc = 0.
                find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt <= g-today no-lock no-error.
                if avail txb.crchis then fullod-crc = fullod / txb.crchis.rate[1].

                create wrk.
                wrk.aaa = txb.aaa.aaa.
                wrk.who = g-ofc.
                wrk.whn = g-today.
                wrk.regdt = g-today.
                wrk.tim = time.
                wrk.point = 0.
                wrk.depart = 0.
                wrk.ln = v-ln.
                wrk.sic = "HB".
                wrk.chkno = 0.
                wrk.chkamt = fullod-crc.
                wrk.payee = "Автоблокировка на сумму проср.задолженности".
                wrk.delaas = "k".
            end.
        end.
    end.
end.

propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error.
for each wrk no-lock:
    do transaction on error undo, return:
        find first txb.aas where txb.aas.aaa = wrk.aaa and txb.aas.payee = wrk.payee exclusive-lock no-error.
        if not avail txb.aas then do:
            create txb.aas.
            txb.aas.aaa = wrk.aaa.
            txb.aas.who = wrk.who.
            txb.aas.whn = wrk.whn.
            txb.aas.regdt = wrk.regdt.
            txb.aas.tim = wrk.tim.
            txb.aas.point = wrk.point.
            txb.aas.depart = wrk.depart.
            txb.aas.ln = wrk.ln.
            txb.aas.sic = wrk.sic.
            txb.aas.chkno = wrk.chkno.
            txb.aas.chkamt = wrk.chkamt.
            txb.aas.payee = wrk.payee.
            txb.aas.delaas = wrk.delaas.
        end.
        else do:
            txb.aas.who = wrk.who.
            txb.aas.whn = wrk.whn.
            txb.aas.regdt = wrk.regdt.
            txb.aas.tim = wrk.tim.
            txb.aas.point = wrk.point.
            txb.aas.depart = wrk.depart.
            txb.aas.ln = wrk.ln.
            txb.aas.sic = wrk.sic.
            txb.aas.chkno = wrk.chkno.
            txb.aas.chkamt = wrk.chkamt.
            txb.aas.payee = wrk.payee.
            txb.aas.delaas = wrk.delaas.
        end.
    end.
end.
propath = v-propath.


