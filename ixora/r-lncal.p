/* r-lncal.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/*def new shared var p-lon like lon.lon.
p-lon = '000144630'.*/  /*для отладки */

define input parameter p-lon like lon.lon. 
define input parameter fl as int. 
define variable sm1 as decimal.
define variable i   as integer.
define variable v-dt as date.

define temp-table w-acr
       field  nr       as integer
       field  fdt      as date
       field  amt      as decimal.
define temp-table w-lni
       field  nr       as integer
       field  dt       as date
       field  amt      as decimal.
define shared temp-table w-amk
       field  nr       as integer
       field  dt       as date
       field  fdt      as date
       field    amt1 as decimal format '->>>,>>>,>>9.99'
       field    amt2 as decimal format '->>>,>>>,>>9.99'.

for each w-amk:
    delete w-amk.
end.

i = 1.
find first lon where lon.lon = p-lon.
v-dt = lon.rdt + 1.

/****************/
if fl = 1 then do:
for each lnsch where lnsch.lnn = p-lon and lnsch.fpn = 0 and lnsch.flp = 0 no-lock:
   create w-acr.
   i = i + 1.
   w-acr.nr = i.
   w-acr.fdt = lnsch.stdat.
   w-acr.amt = lnsch.stval.
end.

i = 1.
for each lnsch where lnsch.lnn = p-lon and lnsch.fpn = 0 and lnsch.flp > 0 no-lock:
    i = i + 1.
    if lnsch.stdat < v-dt
    then v-dt = lnsch.stdat.
    create w-lni.
    w-lni.nr = i.
    w-lni.dt = lnsch.stdat.
    w-lni.amt = lnsch.paid.
 end.
end.

if fl = 2 then do:
for each lnsci where lnsci.lni = p-lon and lnsci.fpn = 0 and lnsci.flp = 0 no-lock:
   create w-acr.
   i = i + 1.
   w-acr.nr = i.
   w-acr.fdt = lnsci.idat.
   w-acr.amt = lnsci.iv-sc.
end.

i = 1.
for each lnsci where lnsci.lni = p-lon and lnsci.fpn = 0 and lnsci.flp > 0 no-lock:
    i = i + 1.
    if lnsci.idat < v-dt
    then v-dt = lnsci.idat.
    create w-lni.
    w-lni.nr = i.
    w-lni.dt = lnsci.idat.
    w-lni.amt = lnsci.paid-iv.
 end.
end.
/************************/

i = 0.
sm1 = 0.
for each w-acr by w-acr.nr:
    i = i + 1.
    create w-amk.
    w-amk.nr = i.
    w-amk.fdt = w-acr.fdt.
    w-amk.amt1 = w-acr.amt.
    w-amk.amt2 = 0.
    sm1 = w-acr.amt.
    for each w-lni by w-lni.nr:
        if w-amk.amt2 <> 0 
        then do:
             i = i + 1.
             create w-amk.
             w-amk.nr = i.
             w-amk.fdt = ?.
             w-amk.amt1 = 0.
        end.
             w-amk.amt2 = w-lni.amt.
             w-amk.dt = w-lni.dt.
             delete w-lni.
             sm1 = sm1 - w-amk.amt2.
             /*if sm1 <= 0
             then*/ leave.
    end.
end.
find first w-amk no-error.
if not available w-amk then do:
         create w-amk.
         w-amk.nr = i.
         w-amk.fdt = ?.
         w-amk.amt1 = 0.
end.
for each w-lni by w-lni.nr:
    if w-amk.amt2 <> 0
    then do:
         i = i + 1.
         create w-amk.
         w-amk.nr = i.
         w-amk.fdt = ?.
         w-amk.amt1 = 0.
    end.
    w-amk.amt2 = w-lni.amt.
    w-amk.dt = w-lni.dt.
    delete w-lni.
end.
