/* r-pril2-2.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет об отдельных счетах по операциям с филиалами и представительствами иностранных компаний
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-8-2
 * AUTHOR
        23.10.2012 dmitriy
 * BASES
        TXB COMM
 * CHANGES
*/

def shared temp-table wrk-cif
field fil as char
field cif as char
field name as char
field sec as char
field geo as char
field opf as char
field aaa as char
field gl  as int
field crc as char
field gl7 as char
field ost  as deci
field osttg as deci
field dam as deci
field cam as deci.

def shared var v-dt as date.

def var vbal like txb.jl.dam.

find first txb.cmp no-lock no-error.

for each txb.cif where txb.cif.geo = "022" and (txb.cif.prefix begins "Филиал" or txb.cif.prefix begins "Представительство") no-lock:
    for each txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.sta <> "C" no-lock:

            find txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
            if txb.lgr.led = 'ODA' then next.

            create wrk-cif.

            wrk-cif.fil = substr(txb.cmp.name, 25).
            wrk-cif.cif = txb.cif.cif.
            wrk-cif.name = txb.cif.name.
            wrk-cif.geo = txb.cif.geo.
            wrk-cif.opf = txb.cif.prefix.
            wrk-cif.aaa = txb.aaa.aaa.
            wrk-cif.gl  = txb.aaa.gl.

            find first txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
            if avail txb.crc then wrk-cif.crc = txb.crc.code.

            if txb.aaa.crc = 1 then wrk-cif.gl7 = "1".
            if txb.aaa.crc = 4 or txb.aaa.crc = 5 then wrk-cif.gl7 = "3". /* ДВВ */
            if txb.aaa.crc <> 1 and txb.aaa.crc <> 4 and txb.aaa.crc <> 5 then wrk-cif.gl7 = "2". /* СКВ */

            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'secek' and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
            if avail txb.sub-cod then wrk-cif.sec = txb.sub-cod.ccod.

            vbal = 0.

            find last txb.histrxbal where txb.histrxbal.acc = txb.aaa.aaa and txb.histrxbal.dt < v-dt and txb.histrxbal.level = 1 no-lock no-error.
            if avail txb.histrxbal then vbal = txb.histrxbal.cam - txb.histrxbal.dam.

            find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt < v-dt no-lock no-error.
            if avail txb.crchis then do:
                wrk-cif.ost = vbal.
                wrk-cif.osttg = vbal * txb.crchis.rate[1].
            end.

    end.
end.

