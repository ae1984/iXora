/* x-eomintl.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        30.12.2003 marinav теперь в проценты не прибавляется 13 уровень
        06/05/2005 madiyar убрал просроченную индексацию
        07/03/2007 madiyar внесистемные проценты не вычисляются по acr, а берутся с 4-го уровня
        28/08/2007 madiyar 4-й уровень здесь не нужен
        09/08/2012 kapar - ТЗ ASTANA-BONUS
*/

/* eomint.i
   CALCULATION EOM INTEREST
*/

vexpint = 0.
lastint = 0.

/* начисленные % и вынесенные в баланс */
find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon
and trxbal.lev eq 2 no-lock no-error.
if available trxbal then
vinttday = trxbal.dam - trxbal.cam.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon
and trxbal.lev eq 44 no-lock no-error.
if available trxbal then
damu_vinttday = trxbal.dam - trxbal.cam.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon
and trxbal.lev eq 49 no-lock no-error.
if available trxbal then
astana_vinttday = trxbal.dam - trxbal.cam.

/* просроченные %  */
find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon
and trxbal.lev eq 9 no-lock no-error.
if available trxbal then do:
vinttday = vinttday + trxbal.dam - trxbal.cam.
v-intod = trxbal.dam - trxbal.cam.
end.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon
and trxbal.lev eq 45 no-lock no-error.
if available trxbal then do:
damu_vinttday = damu_vinttday + trxbal.dam - trxbal.cam.
damu_v-intod = trxbal.dam - trxbal.cam.
end.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon
and trxbal.lev eq 50 no-lock no-error.
if available trxbal then do:
astana_vinttday = astana_vinttday + trxbal.dam - trxbal.cam.
astana_v-intod = trxbal.dam - trxbal.cam.
end.

/* предоплата  %  */
find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon
and trxbal.lev eq 10 no-lock no-error.
if available trxbal then
vinttday = vinttday + trxbal.dam - trxbal.cam.

/* списанные  %  */
/*find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon
and trxbal.lev eq 13 no-lock no-error.
if available trxbal then
vinttday = vinttday + trxbal.dam - trxbal.cam.
 */


define var v-amt20 as deci init 0.
/*define var v-amt21 as deci init 0.*/
define var v-amt22 as deci init 0.
/*define var v-amt23 as deci init 0.*/


v-bal = 0.
for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
and trxbal.crc eq lon.crc
no-lock :
    if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then
    v-bal = v-bal + (trxbal.dam - trxbal.cam).
    if lookup(string(trxbal.level) , v-prnodlev , ";") gt 0 then
    v-amtod = v-amtod + (trxbal.dam - trxbal.cam).
    if lookup(string(trxbal.level) , v-prnbllev , ";") gt 0 then
    v-amtbl = v-amtbl + (trxbal.dam - trxbal.cam).

    if lookup(string(trxbal.level) , v-prnindlev , ";") gt 0 then
    v-amt20 = v-amt20 + (trxbal.dam - trxbal.cam).
   /* if lookup(string(trxbal.level) , v-prnindlev2 , ";") gt 0 then
    v-amt21 = v-amt21 + (trxbal.dam - trxbal.cam). */
    if lookup(string(trxbal.level) , v-prnindlevp , ";") gt 0 then
    v-amt22 = v-amt22 + (trxbal.dam - trxbal.cam).
   /* if lookup(string(trxbal.level) , v-prnindlev2p , ";") gt 0 then
    v-amt23 = v-amt23 + (trxbal.dam - trxbal.cam). */
end.


/*
def var v-intoutbal like lon.accrued.
*/
def var v-rate like lon.prem.
def var v-int like lon.accrued.

/*
for each acr of lon where acr.sts = 0 no-lock:
    run day-360(acr.fdt,acr.tdt,lon.basedy,output dn1,output dn2).
    v-intoutbal = v-intoutbal + round((dn1 * acr.prn * acr.rate / 100 / lon.basedy) , 2).
end.
*/

/*
find first trxbal where trxbal.sub = "LON" and trxbal.acc = lon.lon and trxbal.lev = 4 no-lock no-error.
if available trxbal then v-intoutbal = trxbal.dam - trxbal.cam.

vinttday = vinttday + v-intoutbal.
*/

find last rate where rate.base eq lon.base and rate.cdt le g-today no-lock.
if available rate then v-rate = rate.rate + lon.prem.
else v-rate = lon.prem.
run day-360(g-today ,fdonm - 1,lon.basedy,output dn1,output dn2).
vexpint = vexpint + round((dn1 * (v-bal) * v-rate / 100 / lon.basedy) , 2).

for each acr of lon where year(acr.fdt) eq year(g-today) and
    month(acr.fdt) eq month(g-today) no-lock:
    run day-360(acr.fdt,acr.tdt,lon.basedy,output dn1,output dn2).
    v-int = v-int + truncate((dn1
     * acr.prn * acr.rate / 100 / lon.basedy) , 2).
end.

vint1mon = vinttday /*+ v-intoutbal*/ - v-int.
for each lnsci where lnsci.lni = lon.lon and lnsci.idat >=
date(month(g-today),1,year(g-today))
and lnsci.f0 eq 0 and
lnsci.fpn = 0 and lnsci.flp > 0
no-lock by lnsci.idat descending:
    vint1mon = vint1mon + lnsci.paid.
end.


for each acr of lon where year(acr.fdt) eq lastyr and
    month(acr.fdt) eq lastmo:
    run day-360(acr.fdt,acr.tdt,lon.basedy,output dn1,output dn2).
    v-int = v-int + truncate((dn1 * acr.prn * acr.rate / 100 / lon.basedy) , 2).
end.

vint2mon = vinttday - v-int.
for each lnsci where lnsci.lni = lon.lon
and lnsci.idat >= date(lastmo,1,lastyr)
and lnsci.f0 eq 0 and
lnsci.fpn = 0 and lnsci.flp > 0
no-lock by lnsci.idat descending:
    vint2mon = vint2mon + lnsci.paid.
end.


vintcmon = vinttday + vexpint.


/*
vsa = 0.
find lonsa where lonsa.lon = lon.lon no-lock no-error.
if available lonsa
then vsa = lonsa.dam - lonsa.cam.
*/
