/* lngrfanu-zapis.p
 * MODULE
        3-1-2
 * DESCRIPTION
        запись аннуитетного графика в бд
 * RUN
        lngrfanu.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        06.01.2012 aigul
 * BASES
        BANK
 * CHANGES
        20.03.2012 aigul - добавила запуись в поле lnsch.schn
        30/09/2013 galina - ТЗ1337 пересчет комиссии для бывших сотрудников
*/

{global.i}
def shared var s-lon like lnsch.lnn.
def shared temp-table wrk
    field nn as int
    field nni as int
    field stdt as date
    field days as int
    field sumb as decimal
    field od as decimal
    field percent as decimal
    field sump as decimal
    field sume as decimal
    field ch as char.
def var v-nxt as int.
def var v-nxt1 as int.
find first lon where lon.lon = s-lon no-lock.
for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > -1.
 delete lnsch.
end.
for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > -1.
 delete lnsci.
end.

for each wrk no-lock:
    /*v-nxt = 0.
    v-nxt1 = 0.
    for each lnsch where lnsch.lnn = s-lon and lnsch.flp > 0 no-lock:
        if v-nxt < lnsch.flp then v-nxt = lnsch.flp.
    end.
    for each lnsci where lnsci.lni = s-lon and lnsci.flp > 0 no-lock:
        if v-nxt1 < lnsci.flp then v-nxt1 = lnsci.flp.
    end.*/
    create lnsch.
    create lnsci.
    assign
    lnsch.lnn   = lon.lon
    lnsch.stdat = wrk.stdt
    lnsch.stval = wrk.od
    lnsch.f0    = 1
    /*lnsch.flp = v-nxt + 1
    lnsch.schn = "   . ." + string(lnsch.flp,"zzzz")*/
    lnsci.lni   = lon.lon
    lnsci.idat  = wrk.stdt
    lnsci.iv-sc = wrk.percent
    lnsci.f0    = 1.
    run lnsch-ren(s-lon).
    /*lnsci.flp = v-nxt + 1
    lnsci.schn = "   . ." + string(lnsci.flp,"zzzz").*/
end.
for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > -1 no-lock:
    for each lnscs where lnscs.lon = lon.lon and lnscs.sch and lnscs.stdat >= g-today exclusive-lock:
        if (month(lnscs.stdat) = month(lnsch.stdat) and year(lnscs.stdat) = year(lnsch.stdat)) then update lnscs.stdat = lnsch.stdat.
    end.
end.

run lncomupda.
