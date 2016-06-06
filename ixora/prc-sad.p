/* prc-sad.p
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
       31/05/2004 madiyar - добавил обработку схемы 4
       22.06.2004 nadejda - таблица w-amk изменена для совместимости
       09/12/2005 madiyar - добавил поля trx (номер транзакции) и who (исполнитель), корректирующая сумма - учел ручные проводки
       26/02/2009 madiyar - экспресс-кредиты - схемы 4 и 5
       04.07.2011 aigul - добавилa для совместимости поля в шаренной таблице w-amk
       11/10/2012 kapar - ТЗ ASTANA-BONUS(исправление)
*/

/* prc-sad.p
   30.10.2000 */

/*def new shared var p-lon like lon.lon.
p-lon = '000144630'.*/  /*для отладки */

define input parameter p-lon like lon.lon.
define input parameter vans as integer.
define input parameter v-lev as integer.
define variable dn1 as integer.
define variable dn2 as decimal.
define variable sm1 as decimal.
define variable sm2 as decimal.
define variable i   as integer.
define variable v-dt as date.

def var v-prem  as deci.
def var v-dprem as deci.

define temp-table w-acr
       field  nr       as integer
       field  fdt      as date
       field  tdt      as date
       field  prn      as decimal
       field  rate     as decimal
       field  amt      as decimal.
define temp-table w-lni
       field  nr       as integer
       field  dt       as date
       field  amt      as decimal
       field  amt1     as decimal
       field  amt2     as decimal
       field  trx      as char
       field  who      as char.


define shared temp-table w-amk
       field    nr   as integer
       field    dt   as date
       field    fdt  as date
       field    tdt  as date
       field    prn  as decimal
       field    rate as decimal
       field    amt1 as decimal
       field    amt2 as decimal
       field    amt3 as decimal
       field    amt4 as decimal
       field    dc   as char /* --date-- madiyar */
       field    trx  as char
       field    who  as char
       field    acc as int /*aigul - corr acc*/
       field    note as char. /*aigul - note*/

define buffer a for lonres.

find lon where lon.lon = p-lon no-lock.
find crc where crc.crc = lon.crc no-lock.

for each w-amk:
    delete w-amk.
end.

if lon.grp = 95 then do:
  if lon.prem = 0 then v-prem = lon.prem1. else v-prem = lon.prem.
  if v-prem = 0 then v-prem = 1.
  if lon.dprem = 0 then v-dprem = lon.dprem1. else v-dprem = lon.dprem.
end.
else do:
  v-prem = 1.
  v-dprem = 0.
end.

i = 1.
v-dt = lon.rdt + 1.
for each acr where acr.lon = p-lon no-lock:
    i = i + 1.
    if acr.fdt < v-dt
    then v-dt = acr.fdt.
    run day-360(acr.fdt,acr.tdt,lon.basedy,output dn1,output dn2).
    create w-acr.
    w-acr.nr = i.
    w-acr.fdt = acr.fdt.
    w-acr.tdt = acr.tdt.
    w-acr.prn = acr.prn.
    if vans = 9 then do:
      w-acr.rate = acr.rate - v-dprem.
      if lon.plan = 4 or lon.plan = 5 then
         w-acr.amt = round(lon.opnamt * (acr.rate - v-dprem) * dn1 / lon.basedy / 100,0).
      else
         w-acr.amt = round(acr.prn * (acr.rate - v-dprem) * dn1 / lon.basedy / 100, crc.decpnt).
    end.
    else do:
      w-acr.rate = v-dprem.
      if lon.plan = 4 or lon.plan = 5 then
         w-acr.amt = round(lon.opnamt * v-dprem * dn1 / lon.basedy / 100,0).
      else
         w-acr.amt = round(acr.prn * v-dprem * dn1 / lon.basedy / 100, crc.decpnt).
    end.
    if acr.sts = 9 then sm1 = sm1 + w-acr.amt.
end.

if lon.grp <> 95 then
if sm1 < lon.dam[2]
then do:
     for each lonres where lonres.lon = lon.lon and lonres.lev = v-lev no-lock:
       if lonres.dc = "d" then do:
         sm1 = sm1 + lonres.amt.
       end.
     end.
     if sm1 < lon.dam[2] then do:
       create w-acr.
       w-acr.nr = 1.
       w-acr.fdt = v-dt - 1.
       w-acr.tdt = v-dt - 1.
       w-acr.prn = 0.
       w-acr.rate = 0.
       w-acr.amt = lon.dam[2] - sm1.
     end.
end.

i = 1.
sm2 = 0.
for each lnsci where lnsci.lni = p-lon and lnsci.fpn = 0 and lnsci.flp > 0 no-lock:
    i = i + 1.
    if lnsci.idat < v-dt
    then v-dt = lnsci.idat.
    create w-lni.
    w-lni.nr = i.
    w-lni.dt = lnsci.idat.
    w-lni.trx = string(lnsci.jh).
    w-lni.who = lnsci.who.
    sm2 = sm2 + w-lni.amt.
    if vans = 9 then
      w-lni.amt = (lnsci.paid-iv / v-prem) * (v-prem - v-dprem).
    else
      w-lni.amt = (lnsci.paid-iv / v-prem) * v-dprem.
end.

i = 0.
sm1 = 0.
sm2 = 0.

for each w-acr by w-acr.nr:
    i = i + 1.
    create w-amk.
    w-amk.nr = i.
    w-amk.fdt = w-acr.fdt.
    w-amk.tdt = w-acr.tdt.
    w-amk.prn = w-acr.prn.
    w-amk.rate = w-acr.rate.
    w-amk.amt1 = w-acr.amt.
    w-amk.amt2 = 0.
    sm1 = w-acr.amt.
    for each w-lni by w-lni.nr:
        if w-amk.amt2 <> 0 or w-lni.amt1 <> 0 or w-lni.amt2 <> 0
        then do:
             i = i + 1.
             create w-amk.
             w-amk.nr = i.
             w-amk.fdt = ?.
             w-amk.tdt = ?.
             w-acr.prn = 0.
             w-acr.rate = 0.
             w-amk.amt1 = 0.
        end.
/*        if sm1 < w-lni.amt
        then do:
             w-amk.amt2 = sm1.
             w-amk.dt = w-lni.dt.
             w-lni.amt = w-lni.amt - sm1.
             sm1 = 0.
             leave.
        end.
        else do:  */
             w-amk.amt2 = w-lni.amt.
             w-amk.dt = w-lni.dt.
             w-amk.trx = w-lni.trx.
             w-amk.who = w-lni.who.
             w-amk.amt3 = w-lni.amt1.
             w-amk.amt4 = w-lni.amt2.
             delete w-lni.
             sm1 = sm1 - w-amk.amt2.
             if sm1 <= 0
             then leave.
       /* end. */
    end.
end.
find first w-amk no-error.
if not available w-amk then do:
         create w-amk.
         w-amk.nr = i.
         w-amk.fdt = ?.
         w-amk.tdt = ?.
         w-amk.prn = 0.
         w-amk.rate = 0.
         w-amk.amt1 = 0.
end.
for each w-lni by w-lni.nr:
    if w-amk.amt2 <> 0
    then do:
         i = i + 1.
         create w-amk.
         w-amk.nr = i.
         w-amk.fdt = ?.
         w-amk.tdt = ?.
         w-amk.prn = 0.
         w-amk.rate = 0.
         w-amk.amt1 = 0.
    end.
    w-amk.amt2 = w-lni.amt.
    w-amk.dt = w-lni.dt.
    delete w-lni.
end.

