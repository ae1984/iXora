/* prov-afn2.p
 * MODULE
        --
 * DESCRIPTION
        Отчет по итогам классификации кредитов, вошедших в портфели однородных МСБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.6.2
 * AUTHOR
        28/04/2012 dmitriy
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def shared var dat1 as date.

def shared temp-table wrk
    field cifname as char
    field cif as char
    field branch as char
    field grp as int
    field crc as char
    field opnamt as deci
    field od as deci
    field od-day as int
    field perc-tg as deci
    field perc-day as deci
    field portf as char
    field res-perc as deci
    field res-sum as deci
    field pooln as char
    field od13 as deci
    field rezerv as deci
    index cif cif.

def shared var s-td as date.
def var v-poolsumm as deci extent 4.

def shared var POROG as deci.
def shared var REZERV as deci extent 4.

def var portfname as char extent 4 init ["Однор.МСБ", "Проч.однор.МСБ", "Индив.МСБ", "Метрокредит"].

def var i as int.
def var v-od1 as deci.
def var v-od7 as deci.
def var v-od13 as deci.
def var v-prc as deci.
def var v-days_od as integer no-undo.
def var v-days_prc as integer no-undo.
def var v-%tg as deci.
def var v-opnamt as deci.
def var kurs as deci.
def var res as deci.
def var v-rezerv as deci.

def shared var v-sum_msb as deci no-undo.

find first txb.sysc where txb.sysc.sysc = "MSB%REZ" no-lock no-error.
if avail txb.sysc then do:
    POROG = txb.sysc.deval.
    REZERV[1] = decimal(entry(1, txb.sysc.chval, "|")).
    REZERV[2] = decimal(entry(2, txb.sysc.chval, "|")).
    REZERV[3] = 0.
end.

find first txb.cmp no-lock no-error.

        v-opnamt = 0.
        v-od1 = 0.
        v-od7 = 0.
        v-%tg = 0.

/* Однородные МСБ */
v-poolsumm[1] = 0.
for each txb.lon where
        txb.lon.grp = 16 or
        txb.lon.grp = 26 or
        txb.lon.grp = 56 or
        txb.lon.grp = 66
no-lock:
        if txb.lon.opnamt <= 0 then next.

        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= dat1 - 1 no-lock no-error.

         /* ОД */
        run lonbalcrc_txb('lon',txb.lon.lon,dat1,"1,7",no,txb.lon.crc,output res).
        v-od1 = res * txb.crchis.rate[1].

        run lonbalcrc_txb('lon', txb.lon.lon, dat1, "13", no, txb.lon.crc, output res).
        v-od13 = res * txb.crchis.rate[1].

        /* %% начисленные */
        run lonbalcrc_txb('lon',txb.lon.lon,/*s-td*/ dat1,"2,9",yes,txb.lon.crc,output res).
        v-%tg = res * txb.crchis.rate[1].

        run lndayspr_txb(txb.lon.lon,/*s-td*/ dat1,no,output v-days_od,output v-days_prc).

        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.

        /* запись в WRK */
        create wrk.
        wrk.pooln = "1".
        wrk.cif = txb.cif.cif.
        wrk.cifname = trim(txb.cif.prefix) + txb.cif.name.
        wrk.grp = txb.lon.grp.
        wrk.branch = txb.cmp.name.
        wrk.od = v-od1. /*+ v-od7 + v-od13*/
        wrk.perc-tg = v-%tg.
        wrk.opnamt = txb.lon.opnamt.
        wrk.crc = txb.crc.code.
        wrk.od-day = v-days_od.
        wrk.perc-day = v-days_prc.
        wrk.portf = portfname[1].
        wrk.od13 = v-od13.
        wrk.res-sum = (wrk.od / 100) * REZERV[1].
        wrk.rezerv = REZERV[1].
        v-poolsumm[1] = v-poolsumm[1] + wrk.od.
end.


/* Прочие однородные МСБ */
v-poolsumm[2] = 0.

for each txb.lon where
        txb.lon.grp = 10 or
        txb.lon.grp = 14 or
        txb.lon.grp = 15 or
        txb.lon.grp = 24 or
        txb.lon.grp = 25 or
        txb.lon.grp = 50 or
        txb.lon.grp = 54 or
        txb.lon.grp = 55 or
        txb.lon.grp = 64 or
        txb.lon.grp = 65
no-lock:
    if txb.lon.opnamt <= 0 then next.

    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= dat1 no-lock no-error.

    v-opnamt = txb.lon.opnamt.

    /* ОД */
    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"1,7",no,txb.lon.crc,output res).
    v-od1 = res * txb.crchis.rate[1].

    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"7",no,txb.lon.crc,output res).
    v-od7 = res * txb.crchis.rate[1].

    run lonbalcrc_txb('lon', txb.lon.lon, dat1, "13", no, txb.lon.crc, output res).
    v-od13 = res * txb.crchis.rate[1].

    /* %% начисленные */
    run lonbalcrc_txb('lon',txb.lon.lon,/*s-td*/ dat1,"2,9",yes,txb.lon.crc,output res).
    v-%tg = res * txb.crchis.rate[1].

    run lndayspr_txb(txb.lon.lon,/*s-td*/ dat1,no,output v-days_od,output v-days_prc).

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.

    /* запись в WRK */
    create wrk.
    wrk.cif = txb.cif.cif.
    wrk.cifname = txb.cif.name.
    wrk.grp = txb.lon.grp.
    wrk.branch = txb.cmp.name.
    wrk.od = v-od1. /*+ v-od7 + v-od13.*/
    wrk.perc-tg = v-%tg.
    wrk.opnamt = txb.lon.opnamt.
    wrk.crc = txb.crc.code.
    wrk.od-day = v-days_od.
    wrk.perc-day = v-days_prc.
    wrk.od13 = v-od13.


    if wrk.od <= POROG then do:
        wrk.pooln = "2".
        wrk.portf = portfname[2].
        wrk.res-perc = 0.02.
        v-poolsumm[2] = v-poolsumm[2] + wrk.od.
        wrk.res-sum = (wrk.od / 100) * REZERV[2].
        wrk.rezerv = REZERV[2].
    end.

    if wrk.od > POROG then do:
        wrk.pooln = "3".
        wrk.portf = portfname[3].
        wrk.res-perc = round((v-od1 + v-od7 + v-od13) / v-od13, 2).
        v-poolsumm[3] = v-poolsumm[3] + wrk.od.
        wrk.res-sum = round((wrk.od / 100) * REZERV[3], 2).
        wrk.rezerv = REZERV[3].
    end.

end. /* lon */

/* Однородные Метрокредит */
for each txb.lon where
    txb.lon.grp = 90 or
    txb.lon.grp = 92
no-lock:
        v-rezerv = 0.
        if txb.lon.opnamt <= 0 then next.

        find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < dat1 no-lock no-error.
        if avail txb.lonhar then do:
            if txb.lonhar.lonstat = 1 then v-rezerv = 0.
            if txb.lonhar.lonstat = 2 then v-rezerv = 5.
            if txb.lonhar.lonstat = 3 then v-rezerv = 10.
            if txb.lonhar.lonstat = 4 then v-rezerv = 20.
            if txb.lonhar.lonstat = 5 then v-rezerv = 25.
            if txb.lonhar.lonstat = 6 then v-rezerv = 50.
            if txb.lonhar.lonstat = 7 then v-rezerv = 100.
        end.
        else do:
            v-rezerv = REZERV[4].
        end.

        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= dat1 - 1 no-lock no-error.

         /* ОД */
        run lonbalcrc_txb('lon',txb.lon.lon,dat1,"1,7",no,txb.lon.crc,output res).
        v-od1 = res * txb.crchis.rate[1].

        run lonbalcrc_txb('lon', txb.lon.lon, dat1, "13", no, txb.lon.crc, output res).
        v-od13 = res * txb.crchis.rate[1].

        /* %% начисленные */
        run lonbalcrc_txb('lon',txb.lon.lon,/*s-td*/ dat1,"2,9",yes,txb.lon.crc,output res).
        v-%tg = res * txb.crchis.rate[1].

        run lndayspr_txb(txb.lon.lon,/*s-td*/ dat1,no,output v-days_od,output v-days_prc).

        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.

        /* запись в WRK */
        create wrk.
        wrk.pooln = "4".
        wrk.cif = txb.cif.cif.
        wrk.cifname = trim(txb.cif.prefix) + txb.cif.name.
        wrk.grp = txb.lon.grp.
        wrk.branch = txb.cmp.name.
        wrk.od = v-od1. /*+ v-od7 + v-od13*/
        wrk.perc-tg = v-%tg.
        wrk.opnamt = txb.lon.opnamt.
        wrk.crc = txb.crc.code.
        wrk.od-day = v-days_od.
        wrk.perc-day = v-days_prc.
        wrk.portf = portfname[4].
        wrk.od13 = v-od13.
        wrk.res-sum = (wrk.od / 100) * v-rezerv.
        wrk.rezerv = v-rezerv.
        v-poolsumm[4] = v-poolsumm[4] + wrk.od.
end.
