/* lncomupda.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Автоматический пересчет комиссии для бывших сотрудников
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
        30/09/2013 galina - ТЗ1337
 * BASES
        BANK
 * CHANGES
*/

{global.i}
def var dt1 as date no-undo.
def var v-ost as deci no-undo.
def var nach as deci no-undo.
define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def shared var s-lon like lnsch.lnn.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then return.

find first lons where lons.lon = lon.lon no-lock no-error.
if not avail lons then return.


for each lnscs where lnscs.lon = lon.lon and lnscs.sch and lnscs.stdat > g-today exclusive-lock:
    delete lnscs.
end.

dt1 = lon.rdt.
v-ost = lon.opnamt.
for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat <= g-today no-lock:
    v-ost = v-ost - lnsch.stval.
    dt1 = lnsch.stdat.
end.

if dt1 < lons.rdt then dt1 = lons.rdt.

for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > g-today no-lock:
    run day-360(dt1,lnsch.stdat - 1,lon.basedy,output dn1,output dn2).
    nach = round(dn1 * v-ost * lons.prem / 100 / lon.basedy,2).
    if nach > 0 then do:
        create lnscs.
        assign lnscs.lon = lon.lon
               lnscs.sch = yes
               lnscs.stdat = lnsch.stdat
               lnscs.stval = nach.
    end.
    if lnsch.stdat >= dt1 then dt1 = lnsch.stdat.
    v-ost = v-ost - lnsch.stval.
end.

