/* msforep2.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Прогноз провизий МСФО
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
        29/07/2011 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        29/11/2011 madiyar - с 5% СК сравниваем не остаток по одному кредиту, а сумму всех действующих займов клиента
        26/12/2011 madiyar - добавил колонку с наименованием
        31/01/2012 madiyar - используем историю привязки займов к пулам
*/

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

hide message no-pause.
message s-ourbank.

def shared temp-table wrk no-undo
    field bank as char
    field poolId as char
    field cif as char
    field cifn as char
    field lon as char
    field crc as integer
    field ost as deci extent 3
    field ost_kzt as deci extent 3
    field ost_pro as deci extent 3
    field msfo1 as deci extent 3
    field msfo1_kzt as deci extent 3
    field msfo2 as deci extent 3
    field msfo2_kzt as deci extent 3
    index idx is primary bank poolId cif.

def shared var g-today as date.
def shared var v-dt as date no-undo.
def shared var v-pool as char no-undo extent 9.
def shared var v-poolName as char no-undo extent 9.
def shared var v-poolId as char no-undo extent 9.

def shared var v-sum_msb as deci no-undo.

def var v-od as deci no-undo.
def var v-prc as deci no-undo.
def var v-pen as deci no-undo.
def var v-bal as deci no-undo.
def var v-bal_all as deci no-undo.
def var v-coeffr as deci no-undo.
def var i as integer no-undo.
def var j as integer no-undo.
def var poolIndex as integer no-undo.
def var v-grp as integer no-undo.
def var v-prov as deci no-undo extent 3.

def var v-poolId_lon as char no-undo.

def buffer b-lon for txb.lon.

function getConv returns deci (input p-crc as integer, input p-sum as deci).
    def var res as deci no-undo.
    res = 0.
    find first txb.crc where txb.crc.crc = p-crc no-lock no-error.
    if avail txb.crc then res = p-sum * txb.crc.rate[1].
    else message "CRC не найден для crc=" + string(p-crc) view-as alert-box error.
    return res.
end function.


for each txb.lon no-lock:

    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1,7",yes,txb.lon.crc,output v-od).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2,9",yes,txb.lon.crc,output v-prc).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"16",yes,1,output v-pen).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"6",yes,txb.lon.crc,output v-prov[1]).
    v-prov[1] = - v-prov[1].
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"36",yes,txb.lon.crc,output v-prov[2]).
    v-prov[2] = - v-prov[2].
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"37",yes,1,output v-prov[3]).
    v-prov[3] = - v-prov[3].

    if v-od + v-prc + v-pen <= 0 and v-prov[1] + v-prov[2] + v-prov[3] <= 0 then next.

    v-poolId_lon = ''.
    v-coeffr = 0.
    find last txb.lonpool where txb.lonpool.cif = txb.lon.cif and txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt <= v-dt no-lock no-error.
    if avail txb.lonpool then do:
        v-poolId_lon = txb.lonpool.poolId.
        find last msfoc where msfoc.poolId = v-poolId_lon and msfoc.dt <= v-dt no-lock no-error.
        if avail msfoc and msfoc.coeffr <> ? then v-coeffr = msfoc.coeffr.
    end.

    create wrk.
    assign wrk.bank = s-ourbank
           wrk.poolId = v-poolId_lon
           wrk.cif = txb.lon.cif
           wrk.lon = txb.lon.lon
           wrk.crc = txb.lon.crc
           wrk.ost[1] = v-od
           wrk.ost[2] = v-prc
           wrk.ost[3] = v-pen
           wrk.msfo1[1] = v-prov[1]
           wrk.msfo1[2] = v-prov[2]
           wrk.msfo1[3] = v-prov[3].

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then wrk.cifn = trim(txb.cif.name).

    if txb.lon.crc = 1 then do:
        wrk.ost_kzt[1] = wrk.ost[1].
        wrk.ost_kzt[2] = wrk.ost[2].
        wrk.msfo1_kzt[1] = wrk.msfo1[1].
        wrk.msfo1_kzt[2] = wrk.msfo1[2].
    end.
    else do:
        wrk.ost_kzt[1] = getConv(txb.lon.crc, wrk.ost[1]).
        wrk.ost_kzt[2] = getConv(txb.lon.crc, wrk.ost[2]).
        wrk.msfo1_kzt[1] = getConv(txb.lon.crc, wrk.msfo1[1]).
        wrk.msfo1_kzt[2] = getConv(txb.lon.crc, wrk.msfo1[2]).
    end.
    wrk.ost_kzt[3] = wrk.ost[3].
    wrk.msfo1_kzt[3] = wrk.msfo1[3].

    wrk.msfo2[1] = round(wrk.ost[1] * v-coeffr / 100,2).
    wrk.msfo2[2] = round(wrk.ost[2] * v-coeffr / 100,2).
    wrk.msfo2[3] = round(wrk.ost[3] * v-coeffr / 100,2).

    if txb.lon.crc = 1 then do:
        wrk.msfo2_kzt[1] = wrk.msfo2[1].
        wrk.msfo2_kzt[2] = wrk.msfo2[2].
    end.
    else do:
        wrk.msfo2_kzt[1] = getConv(txb.lon.crc, wrk.msfo2[1]).
        wrk.msfo2_kzt[2] = getConv(txb.lon.crc, wrk.msfo2[2]).
    end.
    wrk.msfo2_kzt[3] = wrk.msfo2[3].

end. /* for each txb.lon */