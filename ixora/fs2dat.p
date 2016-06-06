/* fs2dat.p
 * MODULE
        fs2
 * DESCRIPTION
         Сбор данных по филиалам
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
 * BASES
        BANK COMM TXB
 * AUTHOR
        21/10/08 marinav
 * CHANGES
        10/09/09 aigul - добавила вычисление суммы по кредитам МСБ
        19/10/10 aigul - поправила вывод ФЛ/ЮЛ МСБ
*/


def input parameter v-dt  as date no-undo.
def input parameter v-dtn as date no-undo.
def shared var g-ofc as char.
def shared var g-today as date.
def var v-ccode as char format "x(4)".
def var v-srok as int init 0.
def var s as char.
def shared var summa as decimal format 'zzz,zzz,zzz,zz9.99'.

def var v-sumnkm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumnkpm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumdkm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumdkpm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumvkm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumvkpm as decimal format 'z,zzz,zzz,zz9-'.

def var v-sumndm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumndpm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumddm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumddpm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumvdm as decimal format 'z,zzz,zzz,zz9-'.
def var v-sumvdpm as decimal format 'z,zzz,zzz,zz9-'.

def shared temp-table vsb2
             field nn as int
             field sumnk as decimal format 'z,zzz,zzz,zz9-'
             field sumnkp as decimal format 'z,zzz,zzz,zz9-'
             field sumdk as decimal format 'z,zzz,zzz,zz9-'
             field sumdkp as decimal format 'z,zzz,zzz,zz9-'
             field sumvk as decimal format 'z,zzz,zzz,zz9-'
             field sumvkp as decimal format 'z,zzz,zzz,zz9-'
             field sumnd as decimal format 'z,zzz,zzz,zz9-'
             field sumndp as decimal format 'z,zzz,zzz,zz9-'
             field sumdd as decimal format 'z,zzz,zzz,zz9-'
             field sumddp as decimal format 'z,zzz,zzz,zz9-'
             field sumvd as decimal format 'z,zzz,zzz,zz9-'
             field sumvdp as decimal format 'z,zzz,zzz,zz9-'
              /*MCБ*/
             field sumnkm as decimal format 'z,zzz,zzz,zz9-'
             field sumnkpm as decimal format 'z,zzz,zzz,zz9-'
             field sumdkm as decimal format 'z,zzz,zzz,zz9-'
             field sumdkpm as decimal format 'z,zzz,zzz,zz9-'
             field sumvkm as decimal format 'z,zzz,zzz,zz9-'
             field sumvkpm as decimal format 'z,zzz,zzz,zz9-'
             field sumndm as decimal format 'z,zzz,zzz,zz9-'
             field sumndpm as decimal format 'z,zzz,zzz,zz9-'
             field sumddm as decimal format 'z,zzz,zzz,zz9-'
             field sumddpm as decimal format 'z,zzz,zzz,zz9-'
             field sumvdm as decimal format 'z,zzz,zzz,zz9-'
             field sumvdpm as decimal format 'z,zzz,zzz,zz9-'.


for each txb.lon no-lock,
    each txb.lonres of txb.lon  where txb.lonres.jdt >= v-dtn and txb.lonres.jdt <= v-dt no-lock:
      /*
      find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
      if avail txb.cif then
        if substr(txb.cif.geo,3,1) <> '1' then next.
      */
      summa = txb.lonres.amt.
      if summa = 0 then next.
      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt le txb.lonres.jdt no-error.
       if avail txb.crchis then  summa = summa * txb.crchis.rate[1].
      v-srok = txb.lon.duedt - txb.lon.rdt.
      v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
      find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat <= txb.lonres.jdt
             no-lock no-error.
      if txb.lonres.lev = 1 and txb.lonres.dc = 'D' and txb.lonres.trx ne 'lon0023' and  txb.lonres.trx ne 'lon0024' then do:
        run tablsb1(summa,1,2,3,4,5,6,7,8,9).

      end.
end.


/*********по срокам погашения*************/

Procedure tablsb1.

def input parameter summa as decimal format 'zzz,zzz,zzz,zz9.99'.
def input parameter str1 as int.
def input parameter str2 as int.
def input parameter str3 as int.
def input parameter str4 as int.
def input parameter str5 as int.
def input parameter str6 as int.
def input parameter str7 as int.
def input parameter str8 as int.
def input parameter str9 as int.


/*  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
  if avail txb.sub-cod then  v-ccode = txb.sub-cod.ccode.*/

for each txb.longrp where txb.longrp.longrp = txb.lon.grp and substr(string(txb.longrp.stn),1,1) = '2' no-lock:
/*if v-ccode ne '98' then do:*/
      if txb.lon.crc = 1 then do:
         {fs2.i vsb2.sumnk vsb2.sumnkp}.
      end.
      if txb.lon.crc = 2 or txb.lon.crc = 3 then do:
         {fs2.i vsb2.sumdk vsb2.sumdkp}.
      end.
      if txb.lon.crc > 3 then do:
         {fs2.i vsb2.sumvk vsb2.sumvkp}.
      end.

 /*aigul - МСБ if txb.longrp.des matches '*МСБ*' then do:*/
    find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = 'lnshifr'
    and (txb.sub-cod.ccode = "03" or txb.sub-cod.ccode = "04" or txb.sub-cod.ccode = "11" or txb.sub-cod.ccode = "12") no-lock
    no-error.
    if avail txb.sub-cod then  do:
      if txb.lon.crc = 1 then do:
        {fs2.i vsb2.sumnkm vsb2.sumnkpm}.
      end.

      if txb.lon.crc = 2 or txb.lon.crc = 3 then do:
        {fs2.i vsb2.sumdkm vsb2.sumdkpm}.
      end.
      if txb.lon.crc > 3 then do:
        {fs2.i vsb2.sumvkm vsb2.sumvkpm}.
      end.
    end.
end.

for each txb.longrp where txb.longrp.longrp = txb.lon.grp and substr(string(txb.longrp.stn),1,1) = '1' no-lock:
    /*if v-ccode = '98' then do:*/
    if txb.lon.crc = 1 then do:
        {fs2.i vsb2.sumnd vsb2.sumndp}.
    end.
    if txb.lon.crc = 2 or txb.lon.crc = 3 then do:
     {fs2.i vsb2.sumdd vsb2.sumddp}.
    end.
    if txb.lon.crc > 3 then do:
     {fs2.i vsb2.sumvd vsb2.sumvdp}.
    end.

   /*aigul - МСБ if not txb.longrp.des matches '*МСБ*' then do:*/
    find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = 'lntgt'
    and (txb.sub-cod.ccode = "18" or txb.sub-cod.ccode = "19" or txb.sub-cod.ccode = "20"
    or txb.sub-cod.ccode = "11" or txb.sub-cod.ccode = "10") no-lock no-error.
    if avail txb.sub-cod then do:
      if txb.lon.crc = 1 then do:
        {fs2.i vsb2.sumndm vsb2.sumndpm}.
      end.
      if txb.lon.crc = 2 or txb.lon.crc = 3 then do:
        {fs2.i vsb2.sumddm vsb2.sumddpm}.
      end.
      if txb.lon.crc > 3 then do:
        {fs2.i vsb2.sumvdm vsb2.sumvdpm}.
      end.
    end.

end.
end procedure.



