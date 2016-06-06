/* atl-prcl.p
 * MODULE
          Кредитный модуль        
 * DESCRIPTION
        Расчет процентов на любую дату
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
        31/12/99 pragma
 * CHANGES
        25.09.03  marinav
        11/03/2007 madiyar - подправил для 4 и 5 схем
*/
{global.i}
define input parameter p-lon like lon.lon.
define input parameter p-dt as date no-undo.      /* за  */
define output parameter p-apr% as decimal no-undo. /* начисленные */
define output parameter p-bil% as decimal no-undo. /* в балансе */
define output parameter p-rec% as decimal no-undo. /* оплаченные */
def var p-arpb% as deci no-undo.
define variable ok as logical no-undo.
def var v-intbal as deci no-undo.
def var v-d as date no-undo.
def var dn1 as int no-undo.
def var dn2 as deci no-undo.
def var v-cnt as int no-undo.
def var i as int no-undo.
def var v-str as char no-undo.

def temp-table wt no-undo
    field fdt like acr.fdt
    field tdt like acr.tdt
    field jh like lonres.jh
    field jdt like lonres.jdt
    field amt like lonres.amt
    field crc like lonres.crc
    field rec as recid
    index rec rec.


find lon where lon.lon = p-lon no-lock no-error.

for each lonres where lonres.lon = p-lon  and lonres.lev = 2 no-lock:
    if lonres.dc = "d" and lonres.rem <> "" then do:
        v-cnt = num-entries(lonres.rem) / 2 - 1.
        v-intbal = 0.
        do i = 0 to v-cnt:
            create wt.
            v-str = entry(i + i + 1,lonres.rem).
            wt.fdt = date(
                integer(substring(v-str,5,2)),
                integer(substring(v-str,7,2)),
                integer(substring(v-str,1,4))).
            v-str = entry(i + i + 2,lonres.rem).
            wt.tdt = date(
                integer(substring(v-str,5,2)),
                integer(substring(v-str,7,2)),
                integer(substring(v-str,1,4))).
            wt.jh = lonres.jh.
            wt.jdt = lonres.jdt.
            wt.amt = 0.
            wt.crc = lonres.crc.
            find acr where acr.lon = p-lon and acr.fdt = wt.fdt and acr.tdt = wt.tdt no-lock no-error.
            if available acr then do:
                wt.rec = recid(acr).
                run day-360(wt.fdt, wt.tdt, lon.basedy, output dn1, output dn2).
                if lon.plan = 4 or lon.plan = 5 then wt.amt = dn1 * lon.opnamt * acr.rate / 100 / lon.basedy.
                else wt.amt = dn1 * acr.prn * acr.rate / 100 / lon.basedy.
                v-intbal = v-intbal + wt.amt.
            end.
            if i = v-cnt then do:
                if v-intbal <> lonres.amt then 
                wt.amt = wt.amt + (lonres.amt - v-intbal).
            end.
        end.    
    end.
end.


p-apr% = 0.
p-rec% = 0.
p-bil% = 0.
find lon where lon.lon = p-lon no-lock no-error.
if not available lon then return.

if p-dt < g-today then 
    for each trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.crc = lon.crc no-lock:
        if trxbal.lev = 2 then p-bil% = p-bil% + trxbal.dam - trxbal.cam.  /*if trxbal.lev eq 2 then p-bil% = p-bil% + trxbal.pdam - trxbal.pcam.*/
        else
        if trxbal.lev = 9 then p-bil% = p-bil% + trxbal.dam - trxbal.cam.
        else
        if trxbal.lev = 10 then p-bil% = p-bil% + trxbal.dam - trxbal.cam.
    end.
else 
for each trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.crc = lon.crc no-lock:
    if trxbal.lev = 2 then p-bil% = p-bil% + trxbal.dam - trxbal.cam.
    else
    if trxbal.lev = 9 then p-bil% = p-bil% + trxbal.dam - trxbal.cam.
    else
    if trxbal.lev = 10 then p-bil% = p-bil% + trxbal.dam - trxbal.cam.
end.


/*
p-uzk = lon.cam[5] - lon.dam[5].
*/

p-arpb% = 0.

for each wt where wt.jdt > p-dt and wt.jdt < g-today no-lock:
    p-bil% = p-bil% - wt.amt. 
    if wt.tdt < p-dt then p-arpb% = p-arpb% + wt.amt.
    else
    if wt.fdt < p-dt then p-arpb% = p-arpb% + wt.amt * (p-dt - wt.fdt + 1) / (wt.tdt - wt.fdt + 1).
    /*
    message string(wt.fdt) " " string(wt.tdt) " " string(p-dt) 
    string(wt.amt) string(p-arpb%)
    view-as alert-box.
    */
end.


v-intbal = 0.
for each acr of lon where acr.sts = 9 and acr.tdt > p-dt no-lock:
    find wt where wt.rec = recid(acr) no-lock no-error.
    if available wt then if wt.jdt > p-dt then next.
    if acr.fdt <= p-dt then v-d = p-dt + 1. else v-d = acr.fdt . 
    run day-360(v-d,acr.tdt,lon.basedy,output dn1,output dn2).
    if lon.plan = 4 or lon.plan = 5 then v-intbal = v-intbal + dn1 * lon.opnamt * acr.rate / 100 / lon.basedy.
    else v-intbal = v-intbal + dn1 * acr.prn * acr.rate / 100 / lon.basedy.
end.

p-bil% = p-bil% - v-intbal.

v-intbal = 0.
for each acr of lon where acr.sts = 0 no-lock:
    if acr.fdt <= p-dt then do:
        if acr.tdt > p-dt then v-d = p-dt. else v-d = acr.tdt. 
        run day-360(acr.fdt,v-d,lon.basedy,output dn1,output dn2).
        if lon.plan = 4 or lon.plan = 5 then v-intbal = v-intbal + round((dn1 * lon.opnamt * acr.rate / 100 / lon.basedy) , 2).
        else v-intbal = v-intbal + round((dn1 * acr.prn * acr.rate / 100 / lon.basedy) , 2).
    end.
end.


for each lnsci where lnsci.lni = lon.lon and lnsci.idat > p-dt and lnsci.f0 = 0 and lnsci.fpn = 0 and lnsci.flp > 0 no-lock by lnsci.idat descending:
    p-bil% = p-bil% + lnsci.paid.
end.

p-apr% = p-bil% + v-intbal + p-arpb%.

/*
message " Balance " + string(p-bil%) 
+ " \n intbal " 
+ string(v-intbal) 
+ " \n вне баланса  "
+ string(p-arpb%) view-as alert-box.
*/

p-rec% = 0.
for each lnsci where lnsci.lni = lon.lon and lnsci.idat <= p-dt and lnsci.f0 = 0 and lnsci.fpn = 0 and lnsci.flp > 0 no-lock by lnsci.idat descending:
    p-rec% = p-rec% + lnsci.paid.
end.
 

/*
v-intbal = 0.
for each acr of lon where acr.sts = 9 and acr.tdt ge p-dt no-lock:
    if acr.fdt lt p-dt then v-d = p-dt. else v-d = acr.fdt. 
    run day-360(v-d,acr.tdt,lon.basedy,output dn1,output dn2).
    v-intbal = v-intbal + round((dn1
     * acr.prn * acr.rate / 100 / lon.basedy) , 2).
end.
*/


/*
for each lonres use-index lon where lonres.lon = p-lon and lonres.whn >=
p-dt no-lock:
    if lonres.gl = v-gl240
    then do:
         if lonres.dc = "D"
         then p-bil% = p-bil% - lonres.amt.
         else p-bil% = p-bil% + lonres.amt.
    end.
    else if lonres.gl = v-gl471
    then do:
         if lonres.dc = "C"
         then p-uzk = p-uzk - lonres.amt.
         else p-uzk = p-uzk + lonres.amt.
    end.
end.
*/
