/* msfocoef2.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расчет коэффициентов по пулам для провизий МСФО
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
        30/07/2011 madiyar - подправил определение 5% СК
        23/09/2011 kapar - изменил расчете провизий
        25/10/2011 madiyar - фиксируем даты начала истории
        29/11/2011 madiyar - с 5% СК сравниваем не остаток по одному кредиту, а сумму всех действующих займов клиента
        31/01/2012 madiyar - записываем в историю привязку займов к пулам
        17/05/2012 madiyar - учет пени по валютным займам
        18/06/2012 kapar - ТЗ N1149 Новые группы
        25/07/2012 kapar - ТЗ N1149 изменение
        29/12/2012 sayat(id01143) - устранение ошибки при расчете суммы займов по валютным займам
*/

def shared var g-today as date.
def shared var g-ofc as char.

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

def shared temp-table wrk no-undo like msfoc
    field sk5 as deci.

def shared temp-table wrksk no-undo
    field dtrep as date
    field dt as date
    field sk as deci
    field sk5 as deci
    index idx is primary dtrep.

def shared var dt0rep as date no-undo.
def shared var v-sum_msb as deci no-undo.
def var v-dt as date no-undo.
def var dt_prev as date no-undo.
def var v-dt_rep as date no-undo.

def shared var v-pool as char no-undo extent 10.
def shared var v-poolName as char no-undo extent 10.
def shared var v-poolId as char no-undo extent 10.

def var i as integer no-undo.
def var j as integer no-undo.
def var poolIndex as integer no-undo.
def var v-grp as integer no-undo.

def var v-amtAll as deci no-undo.
def var v-amtPr as deci no-undo.
def var v-amtSpis as deci no-undo.
def var v-amtVosst as deci no-undo.
def var v-sum as deci no-undo.
def var v-bal as deci no-undo.
def var v-bal_all as deci no-undo.
def var v-bal_pr as deci no-undo.
def var v-bal_pen as deci no-undo.
def var v-bal_sp as deci no-undo.
def var v-bal_sp1 as deci no-undo.
def var v-bal_vosst as deci no-undo.
def var v-bal_vosst1 as deci no-undo.
def var v-days_od as int no-undo init 0.
def var v-days_prc as int no-undo init 0.
def var v-maxpr as int no-undo init 0.
def var v-clmain as char.

def buffer b-lon for txb.lon.
def buffer c-lon for txb.lon.

v-dt = g-today + 1.

function getConv returns deci (input p-crc as integer, input p-dt as date, input p-sum as deci).
    def var res as deci no-undo.
    res = 0.
    if p-dt = g-today then do:
        find first txb.crc where txb.crc.crc = p-crc no-lock no-error.
        if avail txb.crc then res = p-sum * txb.crc.rate[1].
        else message "CRC не найден для " + string(p-crc) + " " + string(p-dt) view-as alert-box error.
    end.
    else do:
        find last txb.crchis where txb.crchis.crc = p-crc and txb.crchis.rdt <= p-dt no-lock no-error.
        if avail txb.crchis then res = p-sum * txb.crchis.rate[1].
        else message "CRCHIS не найден для " + string(p-crc) + " " + string(p-dt) view-as alert-box error.
    end.
    return res.
end function.

i = 0.
repeat:

    i = i + 1.
    if i = 3 then leave.

    if v-dt = g-today + 1 then v-dt_rep = dt0rep.
    else v-dt_rep = v-dt.

    hide message no-pause.
    message s-ourbank + ' - ' + string(v-dt_rep).

    find first wrksk where wrksk.dtrep = v-dt_rep no-lock no-error.
    if avail wrksk then v-sum_msb = wrksk.sk5.

    dt_prev = date(month(v-dt - 1), 1, year(v-dt - 1)).

    do poolIndex = 1 to 10:

        v-amtAll = 0. v-amtPr = 0. v-amtSpis = 0. v-amtVosst = 0.
        do j = 1 to num-entries(v-pool[poolIndex]):
            v-grp = integer(entry(j,v-pool[poolIndex])).
            for each txb.lon where txb.lon.grp = v-grp no-lock:

                if txb.lon.rdt > v-dt - 1 then next.

                /* по пулам МСБ проверяем на пороговую сумму */
                if (poolIndex = 7) or (poolIndex = 8) then do:
                    v-bal_all = 0. v-clmain = ''.
                    /*
                    for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                        run lonbalcrc_txb('lon',b-lon.lon,v-dt - 1,"1,7",yes,b-lon.crc,output v-bal).
                        if v-bal > 0 then do:
                            if b-lon.crc <> 1 then v-bal = getConv(b-lon.crc, v-dt - 1, v-bal).
                            v-bal_all = v-bal_all + v-bal.
                        end.
                    end.
                    */
                    for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                        run lonbalcrc_txb('lon',b-lon.lon,v-dt - 1,"1,7",yes,b-lon.crc,output v-bal).
                        if v-bal > 0 then do:
                            if b-lon.clmain <> '' then do:
                                if lookup(b-lon.clmain,v-clmain) = 0 then do:
                                    v-clmain = v-clmain + string(b-lon.clmain) + ','.
                                    find last c-lon where c-lon.lon = b-lon.clmain no-lock no-error.
                                    if c-lon.opnamt > 0 then do:
                                        v-bal = c-lon.opnamt.
                                        if c-lon.crc <> 1 then v-bal = getConv(c-lon.crc, v-dt - 1, v-bal).
                                        v-bal_all = v-bal_all + v-bal.
                                    end.
                                end.
                            end.
                            else do:
                                if b-lon.gua <> 'CL' then do:
                                    if b-lon.opnamt > 0 then do:
                                        v-bal = b-lon.opnamt.
                                        if b-lon.crc <> 1 then  v-bal = getConv(b-lon.crc, v-dt - 1, v-bal).
                                        v-bal_all = v-bal_all + v-bal.
                                    end.
                                end.
                            end.
                        end.
                    end.

                    if poolIndex = 7 then do:
                        if v-bal_all >= v-sum_msb then next.
                    end.
                    if poolIndex = 8 then do:
                        if v-bal_all < v-sum_msb then next.
                        /* !!!!!!!!!!!!!!!!!!! ищем в списке исключений, если находим - тоже пропускаем */
                    end.
                end.

                if i = 1 then do:
                    do transaction:
                        find first txb.lonpool where txb.lonpool.cif = txb.lon.cif and txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt = dt0rep exclusive-lock no-error.
                        if not avail txb.lonpool then do:
                            create txb.lonpool.
                            assign txb.lonpool.cif = txb.lon.cif
                                   txb.lonpool.lon = txb.lon.lon
                                   txb.lonpool.rdt = dt0rep.
                        end.
                        txb.lonpool.poolId = v-poolId[poolIndex].
                        txb.lonpool.who = g-ofc.
                        txb.lonpool.whn = g-today.
                        find current txb.lonpool no-lock.
                    end.
                end.

                run lonbalcrc_txb('lon',txb.lon.lon,v-dt - 1,"1,2",yes,txb.lon.crc,output v-bal).
                run lonbalcrc_txb('lon',txb.lon.lon,v-dt - 1,"7,9",yes,txb.lon.crc,output v-bal_pr).
                run lonbalcrc_txb('lon',txb.lon.lon,v-dt - 1,"16",yes,1,output v-bal_pen).

                v-bal_sp = 0. v-bal_sp1 = 0.
                for each txb.jl where txb.jl.sub = "lon" and txb.jl.acc = txb.lon.lon and txb.jl.lev = 13 and txb.jl.dc = 'D' and txb.jl.jdt >= dt_prev and txb.jl.jdt <= v-dt - 1 no-lock:
                    v-bal_sp1 = v-bal_sp1 + txb.jl.dam.
                end.
                for each txb.jl where txb.jl.sub = "lon" and txb.jl.acc = txb.lon.lon and txb.jl.lev = 14 and txb.jl.dc = 'D' and txb.jl.jdt >= dt_prev and txb.jl.jdt <= v-dt - 1 no-lock:
                    v-bal_sp1 = v-bal_sp1 + txb.jl.dam.
                end.
                for each txb.jl where txb.jl.sub = "lon" and txb.jl.acc = txb.lon.lon and txb.jl.lev = 30 and txb.jl.dc = 'D' and txb.jl.jdt >= dt_prev and txb.jl.jdt <= v-dt - 1 no-lock:
                    v-bal_sp = v-bal_sp + txb.jl.dam.
                end.

                v-bal_vosst = 0. v-bal_vosst1 = 0.
                for each txb.jl where txb.jl.sub = "lon" and txb.jl.acc = txb.lon.lon and txb.jl.lev = 13 and txb.jl.dc = 'C' and txb.jl.jdt >= dt_prev and txb.jl.jdt <= v-dt - 1 no-lock:
                    if txb.jl.trx = "LON0094" then v-bal_vosst1 = v-bal_vosst1 + txb.jl.cam.
                end.
                for each txb.jl where txb.jl.sub = "lon" and txb.jl.acc = txb.lon.lon and txb.jl.lev = 14 and txb.jl.dc = 'C' and txb.jl.jdt >= dt_prev and txb.jl.jdt <= v-dt - 1 no-lock:
                    if txb.jl.trx = "LON0095" then v-bal_vosst1 = v-bal_vosst1 + txb.jl.cam.
                end.
                for each txb.jl where txb.jl.sub = "lon" and txb.jl.acc = txb.lon.lon and txb.jl.lev = 30 and txb.jl.dc = 'C' and txb.jl.jdt >= dt_prev and txb.jl.jdt <= v-dt - 1 no-lock:
                    if txb.jl.trx = "LON0101" then v-bal_vosst = v-bal_vosst + txb.jl.cam.
                end.

                if txb.lon.crc = 1 then do:
                    v-sum = v-bal + v-bal_pr + v-bal_pen.
                    v-bal_sp = v-bal_sp + v-bal_sp1.
                    v-bal_vosst = v-bal_vosst + v-bal_vosst1.
                end.
                else do:
                    v-sum = getConv(txb.lon.crc, v-dt - 1, v-bal + v-bal_pr) + v-bal_pen.
                    v-bal_sp = v-bal_sp + getConv(txb.lon.crc, v-dt - 1, v-bal_sp1).
                    v-bal_vosst = v-bal_vosst + getConv(txb.lon.crc, v-dt - 1, v-bal_sp1).
                end.

                v-amtAll = v-amtAll + v-sum.
                /*
                if v-bal_pr > 0 then v-amtPr = v-amtPr + v-sum.
                */
                v-maxpr = 0.
                if v-bal_pr > 0 then do:
                    run lndayspr_txb(txb.lon.lon,v-dt - 1,yes,output v-days_od,output v-days_prc).
                    if v-days_od > v-days_prc then v-maxpr = v-days_od. else v-maxpr = v-days_prc.
                    if v-maxpr > 30 then v-amtPr = v-amtPr + v-sum.
                end.

                v-amtSpis = v-amtSpis + v-bal_sp.
                v-amtVosst = v-amtVosst + v-bal_vosst.

            end. /* for each txb.lon */
        end. /* do j = 1 to num-entries(v-pool[poolIndex]) */


        find first wrk where wrk.poolId = v-poolId[poolIndex] and wrk.dt = v-dt_rep no-error.
        if not avail wrk then do:
            create wrk.
            assign wrk.dt = v-dt_rep
                   wrk.poolId = v-poolId[poolIndex]
                   wrk.poolName = v-poolName[poolIndex].
            if poolIndex = 7 or poolIndex = 8 then wrk.sk5 = v-sum_msb.
        end.
        wrk.amtAll = wrk.amtAll + v-amtAll.
        wrk.amtPr = wrk.amtPr + v-amtPr.
        wrk.amtSp = wrk.amtSp + v-amtSpis.
        wrk.amtVosst = wrk.amtVosst + v-amtVosst.

    end. /* do poolIndex = 1 to 9 */

    v-dt = date(month(v-dt - 1), 1, year(v-dt - 1)).

end. /* repeat: */

