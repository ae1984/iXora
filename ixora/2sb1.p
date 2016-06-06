/* 2sb.p
 * MODULE
         2SB
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
        14/02/08 marina
 * CHANGES
        17/11/08 marinav - поиск crchis по rdt
        06/10/2010 madiyar - классифицируем как МСБ не по lneko, а по lnshifr
        04/11/2010 madiyar - нужны только МСБ ЮЛ
        03.12.10 marina - ecdivis заменили на secek
        04.08.2011 aigul - добавила 07,08 вид займа для ФЛ
        23/09/09 kapar - ТЗ1142
*/


def input parameter v-dt  as date no-undo.
def input parameter v-dtn as date no-undo.
def shared var g-ofc as char.
def shared var g-today as date.
def var v-ccode as char format "x(4)".
def var v-srok as int init 0.
def shared var summa as decimal format 'zzz,zzz,zzz,zz9.99'.

def shared temp-table vsb2
             field nn as int
             field name as char
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
             field sumvdp as decimal format 'z,zzz,zzz,zz9-'.


for each txb.lon where txb.lon.rdt <= g-today no-lock:
  find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
  if avail txb.cif then
  if substr(txb.cif.geo,3,1) <> '1' then next.
  find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.intrate > 0
         no-lock no-error.
  if avail txb.ln%his then
  v-srok = txb.ln%his.duedt - txb.ln%his.rdt.
  else
  v-srok = txb.lon.duedt - txb.lon.rdt.
  v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.

  /*run atl-dat1(lon.lon,v-dtn,3,output summa).*/
  run lonbal_txb('LON',txb.lon.lon,v-dtn,'1,7,8',yes,output summa).

  if summa > 0 then do:
     find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt le v-dtn no-error.
     if avail txb.crchis then  summa = summa * txb.crchis.rate[1].
     find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat <= v-dtn and txb.ln%his.intrate > 0
             no-lock no-error.
     if not avail txb.ln%his then message " 2.. " txb.lon.cif " " txb.lon.lon view-as alert-box buttons ok.
     run tablsb(summa,1,2).
     run tablsb1(summa,15,16,17,18,19,20).
  end.
  summa = 0.

/*4*/

  /*run atl-dat1(lon.lon,v-dt,3,output summa).*/
  run lonbal_txb('LON',txb.lon.lon,v-dt,'1,7,8',yes,output summa).
  if summa > 0 then do:

    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt le v-dt no-error.
    if avail txb.crchis then  summa = summa * txb.crchis.rate[1].

    find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat <= v-dt and txb.ln%his.intrate > 0
             no-lock no-error.
    run tablsb(summa,7,8).
    run tablsb1(summa,33,34,35,36,37,38).

      run lonbal_txb('LON',txb.lon.lon,v-dt,'7,8',yes,output summa).
      if summa > 0 then do:
            if avail txb.crchis then  summa = summa * txb.crchis.rate[1].
            run tablsb(summa,13,14).
            run tablsb1(summa,39,40,41,42,43,44).
      end.
    find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
  end.

end.

for each txb.lon no-lock,
    each txb.lonres of txb.lon  where txb.lonres.jdt > v-dtn and txb.lonres.jdt <= v-dt no-lock:

      find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
      if avail txb.cif then
        if substr(txb.cif.geo,3,1) <> '1' then next.

      summa = txb.lonres.amt.
      if summa = 0 then next.
      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt le txb.lonres.jdt no-error.
       if avail txb.crchis then  summa = summa * txb.crchis.rate[1].
      v-srok = txb.lon.duedt - txb.lon.rdt.
      v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
      find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat <= txb.lonres.jdt and txb.ln%his.intrate > 0
             no-lock no-error.
      if txb.lonres.lev = 1 and txb.lonres.dc = 'D' and txb.lonres.trx ne 'lon0023' and  txb.lonres.trx ne 'lon0024' then do:
        run tablsb(summa,3,4).
        run tablsb1(summa,21,22,23,24,25,26).
      end.
      if (txb.lonres.lev = 1 or txb.lonres.lev = 7 or txb.lonres.lev = 8 or txb.lonres.lev = 20 or txb.lonres.lev = 21) and txb.lonres.dc = 'C'
         and txb.lonres.trx ne 'lon0008' and txb.lonres.trx ne 'lon0009' and txb.lonres.trx ne 'lon0023' and  txb.lonres.trx ne 'lon0024' then do:
         run tablsb(summa,5,6).
         run tablsb1(summa,27,28,29,30,31,32).
      end.
end.



Procedure tablsb.

  def input parameter summ1 as decimal format 'zzz,zzz,zzz,zz9.99'.
  def input parameter str1 as int.
  def input parameter str2 as int.

  /* это с ФЛ
  def var codelist as char no-undo init "03,04,07,08,11,12,15,16,19,20,23,24".
  */

  def var codelist as char no-undo. /* init "03,04,11,12,19,20".*/

  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnshifr' no-lock no-error.
  if avail  txb.sub-cod then v-ccode = txb.sub-cod.ccode.

  find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek"
  and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.ccod = "9" no-lock no-error.
  if avail txb.sub-cod then do:
    codelist = "03,04,07,08,11,12,19,20".
  end.
  else do:
    codelist = "03,04,11,12,19,20".
  end.

  if v-srok ge 0 and v-srok le 360 and txb.lon.crc = 1 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumnk = vsb2.sumnk + summa.
     vsb2.sumnkp = vsb2.sumnkp + summa * txb.ln%his.intrate / 100.

     if lookup(v-ccode,codelist) > 0 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumnk = vsb2.sumnk + summa.
        vsb2.sumnkp = vsb2.sumnkp + summa * txb.ln%his.intrate / 100.
     end.

  end.

  if v-srok ge 0 and v-srok le 360 and (txb.lon.crc = 2 or txb.lon.crc = 3) then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumdk = vsb2.sumdk + summa.
     vsb2.sumdkp = vsb2.sumdkp + summa * txb.ln%his.intrate / 100.

     if lookup(v-ccode,codelist) > 0 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumdk = vsb2.sumdk + summa.
        vsb2.sumdkp = vsb2.sumdkp + summa * txb.ln%his.intrate / 100.
     end.

  end.

  if v-srok ge 0 and v-srok le 360 and txb.lon.crc > 3 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumvk = vsb2.sumvk + summa.
     vsb2.sumvkp = vsb2.sumvkp + summa * txb.ln%his.intrate / 100.

     if lookup(v-ccode,codelist) > 0 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumvk = vsb2.sumvk + summa.
        vsb2.sumvkp = vsb2.sumvkp + summa * txb.ln%his.intrate / 100.
     end.

  end.

/********************/


  if v-srok gt 360 and txb.lon.crc = 1 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumnd = vsb2.sumnd + summa.
     vsb2.sumndp = vsb2.sumndp + summa * txb.ln%his.intrate / 100.

     if lookup(v-ccode,codelist) > 0 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumnd = vsb2.sumnd + summa.
        vsb2.sumndp = vsb2.sumndp + summa * txb.ln%his.intrate / 100.
     end.

  end.

  if v-srok gt 360 and (txb.lon.crc = 2 or txb.lon.crc = 3) then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumdd = vsb2.sumdd + summa.
     vsb2.sumddp = vsb2.sumddp + summa * txb.ln%his.intrate / 100.

     if lookup(v-ccode,codelist) > 0 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumdd = vsb2.sumdd + summa.
        vsb2.sumddp = vsb2.sumddp + summa * txb.ln%his.intrate / 100.
     end.

  end.

  if v-srok gt 360 and txb.lon.crc > 3 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumvd = vsb2.sumvd + summa.
     vsb2.sumvdp = vsb2.sumvdp + summa * txb.ln%his.intrate / 100.

     if lookup(v-ccode,codelist) > 0 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumvd = vsb2.sumvd + summa.
        vsb2.sumvdp = vsb2.sumvdp + summa * txb.ln%his.intrate / 100.
     end.

  end.


end procedure.

/*********по срокам погашения*************/

Procedure tablsb1.

def input parameter summ1 as decimal format 'zzz,zzz,zzz,zz9.99'.
def input parameter str1 as int.
def input parameter str2 as int.
def input parameter str3 as int.
def input parameter str4 as int.
def input parameter str5 as int.
def input parameter str6 as int.


  find txb.sub-cod where txb.sub-cod.sub = 'CLN' and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = 'secek' no-lock no-error.
  if avail txb.sub-cod then  v-ccode = txb.sub-cod.ccode.


if v-ccode ne '9' then do:
  if txb.lon.crc = 1 then do:
     {2sb.i vsb2.sumnk vsb2.sumnkp}.
  end.
  if txb.lon.crc = 2 or txb.lon.crc = 3 then do:
     {2sb.i vsb2.sumdk vsb2.sumdkp}.
  end.
  if txb.lon.crc > 3 then do:
     {2sb.i vsb2.sumvk vsb2.sumvkp}.
  end.
end.

if v-ccode = '9' then do:
  if txb.lon.crc = 1 then do:
     {2sb.i vsb2.sumnd vsb2.sumndp}.
  end.
  if txb.lon.crc = 2 or txb.lon.crc = 3 then do:
     {2sb.i vsb2.sumdd vsb2.sumddp}.
  end.
  if txb.lon.crc > 3 then do:
     {2sb.i vsb2.sumvd vsb2.sumvdp}.
  end.
end.

end procedure.


