/* fszd-2.p
 * MODULE
        СБ
 * DESCRIPTION
        Отчет FS_ЗД "Банковские займы по виду обеспечения"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        fszd
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        01/11/2011 dmitriy
 * BASES
        TXB BANK COMM
 * CHANGES
        05/03/2012 dmitriy - курс берется за предыдущий день
*/

def var k2res as deci init 0.
def var k2rescrc as deci init 0.
def var k2nonres as deci init 0.
def var k2nonrescrc as deci init 0.

def var k3res as deci init 0.
def var k3rescrc as deci init 0.
def var k3nonres as deci init 0.
def var k3nonrescrc as deci init 0.

def var k4res as deci init 0.
def var k4rescrc as deci init 0.
def var k4nonres as deci init 0.
def var k4nonrescrc as deci init 0.

def var k5res as deci init 0.
def var k5rescrc as deci init 0.
def var k5nonres as deci init 0.
def var k5nonrescrc as deci init 0.

def var k6res as deci init 0.
def var k6rescrc as deci init 0.
def var k6nonres as deci init 0.
def var k6nonrescrc as deci init 0.

def var kurs as deci.

def shared var s-dat as date no-undo format '99/99/9999'.

def shared temp-table wrk
    field branch as integer
    field k2res as deci
    field k2rescrc as deci
    field k2nonres as deci
    field k2nonrescrc as deci

    field k3res as deci
    field k3rescrc as deci
    field k3nonres as deci
    field k3nonrescrc as deci

    field k4res as deci
    field k4rescrc as deci
    field k4nonres as deci
    field k4nonrescrc as deci

    field k5res as deci
    field k5rescrc as deci
    field k5nonres as deci
    field k5nonrescrc as deci

    field k6res as deci
    field k6rescrc as deci
    field k6nonres as deci
    field k6nonrescrc as deci.


def shared var txbname as char.
def buffer b-lonsec1 for txb.lonsec1.
def var kod_buham as integer.
def var bilance as decimal.

find first txb.cmp no-lock no-error.
if avail txb.cmp then txbname = txb.cmp.name.

for each txb.lon no-lock:

    if txb.lon.opnamt <= 0 then next.

    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= s-dat - 1 no-lock no-error.
    if avail txb.crchis then kurs = txb.crchis.rate[1].

    for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
        find last b-lonsec1 where b-lonsec1.lon = txb.lon.lon and b-lonsec1.lonsec = 2 no-lock no-error.
        if available b-lonsec1 then kod_buham = 2.
        else do:
            find last b-lonsec1 where b-lonsec1.lon = txb.lon.lon no-lock no-error.
            if available b-lonsec1 then kod_buham = b-lonsec1.lonsec.
            else kod_buham = 4.
        end.
    end.

    run lonbalcrc_txb ('lon',txb.lon.lon,s-dat,"1,7",no,txb.lon.crc, output bilance).

    if txb.lon.crc <> 1 then bilance = bilance * kurs.

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.

    if avail txb.cif then do:

        if kod_buham = 2 then do:
                if txb.cif.geo = '011' or txb.cif.geo = '021' then do:
                    k2res = k2res + bilance.
                    if txb.lon.crc <> 1 then k2rescrc = k2rescrc + bilance.
                end.

                if txb.cif.geo = '012' or txb.cif.geo = '013' or txb.cif.geo = '022' or txb.cif.geo = '023' then do:
                    k2nonres = k2nonres + bilance.
                    if txb.lon.crc <> 1 then k2nonrescrc = k2nonrescrc + bilance.
                end.
        end.

        if kod_buham = 3 then do:

                if txb.cif.geo = '011' or txb.cif.geo = '021' then do:
                    k3res = k3res + bilance.
                    if txb.lon.crc <> 1 then k3rescrc = k3rescrc + bilance.
                end.

                if txb.cif.geo = '012' or txb.cif.geo = '013' or txb.cif.geo = '022' or txb.cif.geo = '023' then do:
                    k3nonres = k3nonres + bilance.
                    if txb.lon.crc <> 1 then k3nonrescrc = k3nonrescrc + bilance.
                end.

        end.

        if kod_buham = 4 or kod_buham = 1 then do:

                if txb.cif.geo = '011' or txb.cif.geo = '021' then do:
                    k4res = k4res + bilance.
                    if txb.lon.crc <> 1 then k4rescrc = k4rescrc + bilance.
                end.

                if txb.cif.geo = '012' or txb.cif.geo = '013' or txb.cif.geo = '022' or txb.cif.geo = '023' then do:
                    k4nonres = k4nonres + bilance.
                    if txb.lon.crc <> 1 then k4nonrescrc = k4nonrescrc + bilance.
                end.

        end.

        if kod_buham = 5 then do:

                if txb.cif.geo = '011' or txb.cif.geo = '021' then do:
                    k5res = k5res + bilance.
                    if txb.lon.crc <> 1 then k5rescrc = k5rescrc + bilance.
                end.

                if txb.cif.geo = '012' or txb.cif.geo = '013' or txb.cif.geo = '022' or txb.cif.geo = '023' then do:
                    k5nonres = k5nonres + bilance.
                    if txb.lon.crc <> 1 then k5nonrescrc = k5nonrescrc + bilance.
                end.

        end.

        if kod_buham = 6 then do:

                if txb.cif.geo = '011' or txb.cif.geo = '021' then do:
                    k6res = k6res + bilance.
                    if txb.lon.crc <> 1 then k6rescrc = k6rescrc + bilance.
                end.

                if txb.cif.geo = '012' or txb.cif.geo = '013' or txb.cif.geo = '022' or txb.cif.geo = '023' then do:
                    k6nonres = k6nonres + bilance.
                    if txb.lon.crc <> 1 then k6nonrescrc = k6nonrescrc + bilance.
                end.

        end.
    end.
end. /* lon */

create wrk.
    wrk.branch = cmp.code.

    wrk.k2res = k2res.
    wrk.k2rescrc = k2rescrc.
    wrk.k2nonres = k2nonres.
    wrk.k2nonrescrc = k2nonrescrc.

    wrk.k3res = k3res.
    wrk.k3rescrc = k3rescrc.
    wrk.k3nonres = k3nonres.
    wrk.k3nonrescrc = k3nonrescrc.

    wrk.k4res = k4res.
    wrk.k4rescrc = k4rescrc.
    wrk.k4nonres = k4nonres.
    wrk.k4nonrescrc = k4nonrescrc.

    wrk.k5res = k5res.
    wrk.k5rescrc = k5rescrc.
    wrk.k5nonres = k5nonres.
    wrk.k5nonrescrc = k5nonrescrc.

    wrk.k6res = k6res.
    wrk.k6rescrc = k6rescrc.
    wrk.k6nonres = k6nonres.
    wrk.k6nonrescrc = k6nonrescrc.

k2res = 0.
k2rescrc = 0.
k2nonres = 0.
k2nonrescrc = 0.

k3res = 0.
k3rescrc = 0.
k3nonres = 0.
k3nonrescrc = 0.

k4res = 0.
k4rescrc = 0.
k4nonres = 0.
k4nonrescrc = 0.

k5res = 0.
k5rescrc = 0.
k5nonres = 0.
k5nonrescrc = 0.

k6res = 0.
k6rescrc = 0.
k6nonres = 0.
k6nonrescrc = 0.