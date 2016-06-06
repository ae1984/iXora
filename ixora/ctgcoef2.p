/* ctgcoef2.p
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
        23/08/2012 kapar
 * BASES
        BANK COMM TXB
 * CHANGES
        29/12/2012 sayat (id01143) исправление при расчете суммы валютных займов
        23/04/2013 Sayat(id01143) - ТЗ 1753 от 07/03/2013 "Новый алгоритм рассчета провизий МСФО"
        27/06/2013 Sayat(id01143) - ТЗ 1882 от 05/06/2013 "Доработка алгоритма расчета провизий МСФО"
*/
{dates.i}
def shared var v-dt as date no-undo.
def shared var v-pool as char extent 10.
def shared var v-poolName as char extent 10.
def shared var v-poolId as char extent 10.
def shared var g-today as date.
def shared var g-ofc like txb.ofc.ofc.
def var t-dt as date.

def var poolIndex as integer no-undo.
def var poolDes as char no-undo.
def var i as integer no-undo.
def var j as integer no-undo.

def var v-od    as deci no-undo.
def var v-prc   as deci no-undo.
def var v-pen   as deci no-undo.
def var v-bal   as deci no-undo.


def var v-dayc_max  as integer.
def var v-dayc_od   as integer.
def var v-dayc_prc  as integer.
def var v-prosr_od  as deci.
def var v-prosr_prc  as deci.

def shared var v-sum_msb as deci no-undo.
def var v-bal_all as deci.
def var v-clmain as char.
def buffer b-lon for txb.lon.
def buffer c-lon for txb.lon.
def buffer b-ctgprov for ctgprov.
/*def shared var mindt as date.*/
def shared var v-mindt as date extent 10.
def var v-restr as logi.

def var v-bal1       as deci no-undo.
def var v-daymax1  as integer.
def var v-dayc_od1   as integer.
def var v-dayc_prc1  as integer.
def var v-prosr_od1  as deci.
def var v-prosr_prc1 as deci.
def var v-restr1     as logi.
def var v-ind as int.



def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

function getDate returns date (input f-dt as date).
    def var nm as integer no-undo.
    def var ny as integer no-undo.
    nm = month(f-dt) + 1. ny = year(f-dt).
    if nm = 13 then assign nm = 1 ny = ny + 1.
    return date(nm,1,ny).
end function.

def var rates as deci extent 3.
def var crates as char extent 3.
def shared stream m-out.
def var v-pool1 as char.
def var v-dsc as deci no-undo.
def var v-vkl as logi.


/*Категория*/
t-dt = v-dt.
if v-dt > g-today then t-dt = g-today.
v-vkl = no.
if t-dt < v-dt then v-vkl = yes.

rates[1] = 1. crates[1] = 'KZT'.
find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < t-dt no-lock no-error.
if avail txb.crchis then do: rates[2] = txb.crchis.rate[1]. crates[2] = txb.crchis.code. end.
find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < t-dt no-lock no-error.
if avail txb.crchis then do: rates[3] = txb.crchis.rate[1]. crates[3] = txb.crchis.code. end.

for each txb.lon no-lock:

    run lonbalcrc_txb('lon',txb.lon.lon,t-dt,"1,7",v-vkl,txb.lon.crc,output v-od).
    v-od = v-od * rates[txb.lon.crc].
    run lonbalcrc_txb('lon',txb.lon.lon,t-dt,"2,9,49,50",v-vkl,txb.lon.crc,output v-prc).
    v-prc = v-prc * rates[txb.lon.crc].
    run lonbalcrc_txb('lon',txb.lon.lon,t-dt,"16",v-vkl,1,output v-pen).
    run lonbalcrc_txb('lon',txb.lon.lon,t-dt,"42",v-vkl,txb.lon.crc,output v-dsc).
    v-dsc = v-dsc * rates[txb.lon.crc].

    if  v-od <= 0 and v-prc <= 0 and v-pen <= 0 /*and abs(v-dsc) <= 0*/ then next.

    poolIndex = 0.
    do j = 1 to 10:
        if lookup(string(txb.lon.grp),v-pool[j]) > 0 then poolIndex = j.
    end.
    v-pool1 = ''.
    find last txb.lonpool where txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt = v-dt no-lock no-error.
    if avail txb.lonpool then do:
        do j = 1 to 10 :
            if txb.lonpool.poolid = v-poolId[j] then do: poolIndex = j. v-pool1 = v-poolId[poolIndex]. end.
        end.
    end.
    v-bal_all = 0.
    if ((poolIndex = 7) or (poolIndex = 8)) /*and not avail txb.lonpool*/ then do:
         v-bal_all = 0. v-clmain = ''.
         for each b-lon where b-lon.cif = txb.lon.cif no-lock:
            run lonbalcrc_txb('lon',b-lon.lon,t-dt,"1,7",v-vkl,b-lon.crc,output v-bal).
            if v-bal > 0 then do:
                if b-lon.clmain <> '' then do:
                    if lookup(b-lon.clmain,v-clmain) = 0 then do:
                        v-clmain = v-clmain + string(b-lon.clmain) + ','.
                        find last c-lon where c-lon.lon = b-lon.clmain no-lock no-error.
                        if c-lon.opnamt > 0 then do:
                            v-bal = c-lon.opnamt.
                            if c-lon.crc <> 1 then v-bal = v-bal * rates[c-lon.crc].
                            v-bal_all = v-bal_all + v-bal.
                        end.
                    end.
                end.
                else do:
                    if b-lon.gua <> 'CL' then do:
                        if b-lon.opnamt > 0 then do:
                            v-bal = b-lon.opnamt.
                            if b-lon.crc <> 1 then v-bal = v-bal * rates[b-lon.crc].
                            v-bal_all = v-bal_all + v-bal.
                        end.
                    end.
                end.
            end.
         end.
         if v-bal_all < v-sum_msb then do: poolDes = v-poolId[7]. poolIndex = 7. end. else do: poolDes = v-poolId[8]. poolIndex = 8. end.
    end.
    else poolDes = v-poolId[poolIndex].

    if t-dt <> v-dt then
        do transaction:
            find first txb.lonpool where txb.lonpool.cif = txb.lon.cif and txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt = v-dt exclusive-lock no-error.
                if not avail txb.lonpool then do:
                    create txb.lonpool.
                    assign txb.lonpool.cif = txb.lon.cif
                           txb.lonpool.lon = txb.lon.lon
                           txb.lonpool.rdt = v-dt.
                end.
                txb.lonpool.poolId = poolDes. /*v-poolId[poolIndex].*/
                txb.lonpool.who = g-ofc.
                txb.lonpool.whn = g-today.
                find current txb.lonpool no-lock.
        end.

    if t-dt < v-mindt[poolIndex] then next.

    v-daymax1 = 0. v-restr1 = false. v-ind = 0.

    for each b-lon where b-lon.cif = txb.lon.cif no-lock:
        run lonbalcrc_txb('lon',b-lon.lon,t-dt,"1,7",v-vkl,b-lon.crc,output v-bal).
        v-restr =  false. v-dayc_prc = 0. v-dayc_od = 0. v-dayc_max = 0.
        if v-bal > 0 then do:
            run lonbalcrc_txb('lon',b-lon.lon,t-dt,"7",v-vkl,b-lon.crc,output v-prosr_od).
            run lonbalcrc_txb('lon',b-lon.lon,t-dt,"9,50",v-vkl,b-lon.crc,output v-prosr_prc).
            if v-prosr_od > 0 or v-prosr_prc > 0 then
                run lndayspr_txb(b-lon.lon,t-dt,v-vkl,output v-dayc_od,output v-dayc_prc).
            if v-dayc_od < v-dayc_prc then v-dayc_max = v-dayc_prc. else v-dayc_max = v-dayc_od.
            find first txb.hissc where txb.hissc.acc = b-lon.lon and txb.hissc.sub = 'lon' and txb.hissc.d-cod = 'lnrestr' and txb.hissc.rdt < v-dt no-lock no-error.
            if avail txb.hissc and txb.hissc.ccode = '01' then v-restr = true.
            else do:
                find first txb.sub-cod where txb.sub-cod.acc = b-lon.lon and txb.sub-cod.sub = 'lon' and txb.sub-cod.d-cod = 'lnrestr' and txb.sub-cod.rdt < v-dt no-lock no-error.
                if avail txb.sub-cod and txb.sub-cod.ccode = '01' then v-restr = true.
                else v-restr = false.
            end.
            if v-dayc_max > v-daymax1 then v-daymax1 = v-dayc_max.
            if v-restr then v-restr1 = true.
        end.
    end.

    run lonbalcrc_txb('lon',txb.lon.lon,t-dt,"7",v-vkl,txb.lon.crc,output v-prosr_od).
    run lonbalcrc_txb('lon',txb.lon.lon,t-dt,"9,50",v-vkl,txb.lon.crc,output v-prosr_prc).

    v-restr =  false.
    find first txb.hissc where txb.hissc.acc = txb.lon.lon and txb.hissc.sub = 'lon' and txb.hissc.d-cod = 'lnrestr' and txb.hissc.rdt < v-dt no-lock no-error.
    if avail txb.hissc and txb.hissc.ccode = '01' then v-restr = true.
    else do:
        find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = 'lon' and txb.sub-cod.d-cod = 'lnrestr' and txb.sub-cod.rdt < v-dt no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode = '01' then v-restr = true.
        else v-restr = false.
    end.

    v-dayc_prc = 0. v-dayc_od = 0.
    if v-prosr_od > 0 or v-prosr_prc > 0 then
        run lndayspr_txb(txb.lon.lon,t-dt,v-vkl,output v-dayc_od,output v-dayc_prc).

    if v-dayc_od < v-dayc_prc then v-dayc_max = v-dayc_prc. else v-dayc_max = v-dayc_od.

    find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "ctg" and ctgprov.poolId = poolDes no-error.
    if not avail ctgprov then do:
        create ctgprov.
        assign ctgprov.dt = v-dt.
               ctgprov.tp = "ctg".
               ctgprov.poolId = poolDes.
               ctgprov.n1 = 0. ctgprov.n2 = 0. ctgprov.n3 = 0. ctgprov.n4 = 0.
               ctgprov.n5 = 0. ctgprov.n6 = 0. ctgprov.n7 = 0. ctgprov.n8 = 0.
               ctgprov.n9 = 0. ctgprov.n10 = 0. ctgprov.n11 = 0. ctgprov.n12 = 0.
    end.

    if v-daymax1 > 180 then v-dayc_max = v-daymax1.
    /*if v-restr1 then v-restr = true.*/

    if not(v-restr1) then do:


        if v-dayc_max <= 0 then ctgprov.n1 = ctgprov.n1 + v-od + v-prc + v-pen + v-dsc.
        if v-dayc_max > 0 and v-dayc_max <= 30 then ctgprov.n2 = ctgprov.n2 + v-od + v-prc + v-pen + v-dsc.
        if v-dayc_max > 30 and v-dayc_max <= 60 then ctgprov.n3 = ctgprov.n3 + v-od + v-prc + v-pen + v-dsc.
        if v-dayc_max > 60 and v-dayc_max <= 90 then  ctgprov.n4 = ctgprov.n4 + v-od + v-prc + v-pen + v-dsc.
        if v-dayc_max > 90 and v-dayc_max <= 120 then  ctgprov.n5 = ctgprov.n5 + v-od + v-prc + v-pen + v-dsc.
        if v-dayc_max > 120 and v-dayc_max <= 150 then  ctgprov.n6 = ctgprov.n6 + v-od + v-prc + v-pen + v-dsc.
        if v-dayc_max > 150 and v-dayc_max <= 180 then  ctgprov.n7 = ctgprov.n7 + v-od + v-prc + v-pen + v-dsc.
        if v-dayc_max > 180 then do:
            ctgprov.n9 = ctgprov.n9 + v-od + v-prc + v-pen + v-dsc.
            find first txb.indprov where txb.indprov.dt = v-dt and txb.indprov.cif = txb.lon.cif and txb.indprov.lon = txb.lon.lon no-lock no-error.
            if not avail txb.indprov or txb.indprov.provsum = 0 then ctgprov.n11 = ctgprov.n11 + v-od + v-prc + v-pen + v-dsc.
            else do:
                find first txb.indprov where txb.indprov.dt = v-dt and txb.indprov.cif = txb.lon.cif and txb.indprov.lon = txb.lon.lon no-lock no-error.
                if not avail txb.indprov or txb.indprov.provsum = 0 then ctgprov.n11 = ctgprov.n11 + v-od + v-prc + v-pen + v-dsc.
                else do:
                    find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "rzr" and ctgprov.poolId = poolDes no-error.
                    if not avail ctgprov then do:
                        create  ctgprov.
                        assign  ctgprov.dt = v-dt.
                                ctgprov.tp = "rzr".
                                ctgprov.poolId = poolDes.
                    end.
                    ctgprov.n9 = ctgprov.n9 + txb.indprov.provsum * rates[txb.lon.crc].
                    find current ctgprov no-lock.
                    v-ind = 1.
                end.
            end.
        end.
    end.
    else do:
        ctgprov.n10 = ctgprov.n10 + v-od + v-prc + v-pen + v-dsc.
        find first txb.indprov where txb.indprov.dt = v-dt and txb.indprov.cif = txb.lon.cif and txb.indprov.lon = txb.lon.lon no-lock no-error.
        if not avail txb.indprov or txb.indprov.provsum = 0 then ctgprov.n11 = ctgprov.n11 + v-od + v-prc + v-pen + v-dsc.
        else do:
            find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "rzr" and ctgprov.poolId = poolDes no-error.
            if not avail ctgprov then do:
                create  ctgprov.
                assign  ctgprov.dt = v-dt.
                        ctgprov.tp = "rzr".
                        ctgprov.poolId = poolDes.
            end.
            ctgprov.n10 = ctgprov.n10 + txb.indprov.provsum * rates[txb.lon.crc].
            find current ctgprov no-lock.
            v-ind = 1.
        end.
    end.

    put stream m-out unformatted '<tr>' skip
        '<td>' s-ourbank '</td>' skip
        '<td>' txb.lon.lon '</td>' skip
        '<td>' txb.lon.cif '</td>' skip
        '<td>' replace(string(v-od ,"->>>>>>>>>>>>>>>>>>9.99<<<<<<<<<"),'.',',') '</td>' skip
        '<td>' replace(string(v-prc,"->>>>>>>>>>>>>>>>>>9.99<<<<<<<<<"),'.',',') '</td>' skip
        '<td>' replace(string(v-pen,"->>>>>>>>>>>>>>>>>>9.99<<<<<<<<<"),'.',',') '</td>' skip
        '<td>' replace(string(v-dsc,"->>>>>>>>>>>>>>>>>>9.99<<<<<<<<<"),'.',',') '</td>' skip
        '<td>' replace(string(v-od + v-prc + v-pen + v-dsc,"->>>>>>>>>>>>>>>>>>9.99<<<<<<<<<"),'.',',') '</td>' skip
        '<td>' replace(string(v-bal_all,"->>>>>>>>>>>>>>>>>>9.99<<<<<<<<<"),'.',',') '</td>' '</td>' skip
        '<td>' txb.lon.grp '</td>' skip
        '<td>' v-pool1 '</td>' skip
        '<td>' poolDes '</td>' skip
        '<td>' v-dayc_od '</td>' skip
        '<td>' v-dayc_prc '</td>' skip
        '<td>' maximum(v-dayc_od,v-dayc_prc) '</td>' skip
        '<td>' v-daymax1 '</td>' skip
        '<td>' v-restr '</td>' skip
        '<td>' v-restr1 '</td>' skip
        '<td>' txb.lon.crc '</td>' skip.
   if v-ind = 1 then put stream m-out unformatted '<td>Да</td>' skip.
   else put stream m-out unformatted '<td>Нет</td>' skip.

   put stream m-out unformatted '</tr>' skip.
end. /* for each txb.lon */
