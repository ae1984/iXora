/* astbonzp1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет для отражения суммы удержания из заработной платы сотрудников для погашения займов по программе Астана-бонус
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-cods.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
       10/04/2013 sayat(id00143) ТЗ 1583 от 14/11/2012
 * BASES
	COMM, TXB
 * CHANGES
       27/06/2013 Sayat(id01143) ТЗ 1926 от 26/06/2013 доработано в части отражения займов выданных в течение отчетного месяца.
*/

def shared temp-table wrk
    field fil       as char
    field bank      as char
    field cif       as char
    field grp       as int
    field lon       as char
    field name      as char
    field crc       as int
    field lcnt      as char
    field rdt       as date
    field pdt       as date
    field opnamt    as decimal
    field amt       as decimal
    field od        as decimal
    field prc3      as deci
    field prc10     as deci
    field psum      as deci
    field csum      as deci.

def shared var v-date   as date.
def shared var v-dt     as date.
def shared var v-dt1    as date.
def var v-prc   as deci.
def var v-od    as deci.
def var v-pdt   as date.
def var v-bal   as deci.
def var v-balc  as deci.
def var v-aaa   as char.
def var v-dt2 as date.
def var v-dt3 as date.

find first txb.cmp no-lock no-error.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.

def shared var g-today as date.

v-dt2 = v-dt.
if v-dt2 > g-today then v-dt2 = g-today.

for each txb.lon where txb.lon.grp = 95 or txb.lon.grp = 96 no-lock:
    if txb.lon.rdt > v-dt then next.
    if txb.lon.opnamt <= 0 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,v-dt2,"1,7,2,9,49,50",yes,txb.lon.crc,output v-bal).
    if v-bal <= 0 then next.

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    find first txb.loncon where txb.loncon.lon = txb.lon.lon and txb.loncon.cif = txb.lon.cif no-lock no-error.
    v-od = 0. v-prc = 0. v-pdt = ?.
    for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= v-dt and txb.lnsch.stdat <= v-dt1 no-lock:
        v-od = v-od + txb.lnsch.stval.
        v-pdt = txb.lnsch.stdat.
    end.
    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat >= v-dt and txb.lnsci.idat <= v-dt1 no-lock:
        v-prc = v-prc + txb.lnsci.iv-sc.
        if v-pdt = ? then v-pdt = txb.lnsci.idat.
    end.

    if v-pdt <> ? then do:
        if v-pdt > v-dt2 then v-dt3 = v-dt2. else v-dt3 = v-pdt.
        run lonbalcrc_txb('lon',txb.lon.lon,v-dt3,"1,7",no,txb.lon.crc,output v-bal).
        run lonbalcrc_txb('cif',txb.lon.aaa,g-today,"1",yes,txb.lon.crc,output v-balc).
        create wrk.
        assign wrk.fil = txb.sysc.chval
                wrk.bank = txb.cmp.name
                wrk.cif = txb.lon.cif
                wrk.grp = txb.lon.grp
                wrk.lon = txb.lon.lon
                wrk.crc = txb.lon.crc
                wrk.rdt = txb.lon.rdt
                wrk.pdt = v-pdt
                wrk.opnamt = txb.lon.opnamt
                wrk.amt = v-bal
                wrk.od = v-od
                wrk.prc3 = round(v-prc * 3 / 13, 2)
                wrk.prc10 = v-prc - round(v-prc * 3 / 13, 2)
                wrk.csum = v-balc
                .
        if avail txb.loncon then wrk.lcnt = txb.loncon.lcnt. else wrk.lcnt = ''.
        if avail txb.cif then wrk.name = txb.cif.prefix + ' ' + txb.cif.name. else wrk.name = ''.
        wrk.psum = wrk.od + wrk.prc3 + wrk.prc10.
    end.
end.

