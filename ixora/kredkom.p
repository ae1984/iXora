/* kredkom.p
 * MODULE
        Кредитный Модуля
 * DESCRIPTION
        Анализ кредитного портфеля
 * RUN
        kredkom(d1)
 * CALLER
        r_krcom1.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        02.09.2003 marinav - добавление среднемесячной выручки
        26.11.2003 marinav - ищу признак lnsegm
        14.01.2004 marinav - добавила no-lock
        12.02.2004 nadejda - добавлен обслуживающий менеджер
        03/06/2004 madiar  - раскомментарил расчет среднемесячной выручки, но только для юр. лиц
        09/07/2004 madiar  - изменил сегментацию - объединил все потреб.кредиты кроме быстрых денег в один сегмент
        19/07/2004 madiar  - расчет основного долга - с учетом индексированных уровней
                             по запросу КД вернул прежнюю сегментацию
        04/11/2004 madiar  - добавил поле cif в wrk
        17/05/2005 madiar  - добавил поле tgt ("Объект кредитования") в wrk
        08/06/2005 madiar  - расчет среднемес. выручки - из баланса для кред. досье
        03/08/2005 madiar  - добавил поле wrk.balans_kzt - остаток долга в тенге
        16/09/2005 saltanat - вынесла определение переменных в i-шку.
        06/12/2005 madiar  - поменял поля в find'е, чтобы цеплялся индекс
        26/12/2005 madiar  - обработка ошибки при неверном коде залога в lonsec1.lonsec
*/

/* *** D E F I N I T I O N S *** */
{kredkom_def.i}

for each txb.lon no-lock.
  run lon_txb2 (txb.lon.lon,d1,output bilance). /* остаток  ОД*/
  v-prolon = 0.
  if bilance > 0 then do:
   dat1 = ?.
   dat2 = ?.
   dat3 = ?.

   find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.

   dlong = txb.lon.duedt.
   if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
   if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].

   if txb.lon.ddt[5] <> ? then v-prolon = v-prolon + 1.
   if txb.lon.cdt[5] <> ? then v-prolon = v-prolon + 1.

  /*выдача займа*/
   find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0 no-lock no-error.
   if avail txb.lnscg then dat1 = txb.lnscg.stdat.
                      else dat1 = ?.

  /*последнее погашение*/
   find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 = 0 no-lock no-error.
   if avail txb.lnsch then dat2 = txb.lnsch.stdat.
                      else dat2 = ?.

   find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 = 0 and txb.lnsci.fpn = 0 no-lock no-error.
   if avail txb.lnsci and (txb.lnsci.idat > dat2 or dat2 = ?) then dat2 = txb.lnsci.idat.

  /*следующее погашение по графику*/

   find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat > dat2 no-lock no-error.
   if avail txb.lnsch then dat3 = txb.lnsch.stdat.
                      else dat3 = ?.
   

   find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.fpn = 0 and txb.lnsci.idat > d1 no-lock no-error.
   if avail txb.lnsci and (txb.lnsci.idat < dat3 or dat3 = ?) then dat3 = txb.lnsci.idat.
   if dat3 = ? then do:
      find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0
                  and txb.lnsci.fpn = 0 no-lock no-error.
        if avail txb.lnsci then dat3 = txb.lnsci.idat.
   end.
/**/


   find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
   find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
 
   v-sum = 0.
    for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
      if txb.lonsec1.crc = 1 then do:
            find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.regdt le d1 no-lock no-error.
            v-sum = v-sum + txb.lonsec1.secamt / txb.crchis.rate[1].
      end.
      if txb.lonsec1.crc = 2 then do:
            v-sum = v-sum + txb.lonsec1.secamt.
      end.
      if txb.lonsec1.crc = 11 then do:
            find last txb.crchis where txb.crchis.crc = 11 and txb.crchis.regdt le d1 no-lock no-error.
            v-sumt = txb.lonsec1.secamt * txb.crchis.rate[1].
            find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.regdt le d1 no-lock no-error.
            v-sum  = v-sum + v-sumt / txb.crchis.rate[1].
      end.
    end.
  

   create wrk.
    wrk.lon   =  txb.lon.lon.
    wrk.grp   = txb.lon.grp.
    wrk.cif   = txb.lon.cif.
    wrk.name  = txb.cif.name.
    wrk.gua   = txb.lon.gua.
    wrk.amoun = txb.lon.opnamt.

/* Учет выданных аккредитивов и гарантий*/
for each txb.lnakkred where txb.lnakkred.lon = txb.lon.lon and txb.lnakkred.uno = 1 no-lock:
   if txb.lnakkred.crc ne txb.lon.crc then do:
       if txb.lon.crc = 1 then do:
          find last txb.crc where txb.crc.crc = txb.lnakkred.crc no-lock no-error.
          wrk.akkr = wrk.akkr + txb.lnakkred.amount * txb.crc.rate[1].
       end.
       if txb.lon.crc ne 1 then do:
          find last txb.crc where txb.crc.crc = txb.lnakkred.crc no-lock no-error.
          v-gar = txb.lnakkred.amount * txb.crc.rate[1].

          find last txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
          wrk.akkr = wrk.akkr + v-gar / txb.crc.rate[1].
       end.
   end.
   else do:
       wrk.akkr = wrk.akkr + txb.lnakkred.amount.
   end.
end.
for each txb.lnakkred where txb.lnakkred.lon = txb.lon.lon and txb.lnakkred.uno = 2 no-lock:
   if txb.lnakkred.crc ne txb.lon.crc then do:
       if txb.lon.crc = 1 then do:
          find last txb.crc where txb.crc.crc = txb.lnakkred.crc no-lock no-error.
          wrk.garan = wrk.garan + txb.lnakkred.amount * txb.crc.rate[1].
       end.
       if txb.lon.crc ne 1 then do:
          find last txb.crc where txb.crc.crc = txb.lnakkred.crc no-lock no-error.
          v-gar = txb.lnakkred.amount * txb.crc.rate[1].

          find last txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
          wrk.garan = wrk.garan + v-gar / txb.crc.rate[1].
       end.
   end.
   else do:
       wrk.garan = wrk.garan + txb.lnakkred.amount.
   end.
end.

 /* ---------------  22/01/03 nataly  ---------------*/

   find txb.loncon where txb.loncon.lon = txb.lon.lon  no-lock no-error.
   
  /* отрасль экономики */
   find  txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
   if available txb.sub-cod then do:
    find txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
    if available txb.codfr then otrasl = txb.codfr.name[1].
    else  otrasl =  "не задана ".
   end.
   if not available txb.sub-cod then otrasl =  " не задана ".

/*  курс на день выдачи  */
   find last txb.crchis where txb.crchis.rdt <= txb.lon.rdt and
    txb.crchis.crc = txb.lon.crc no-lock no-error.
   if available txb.crchis then v-rate = txb.crchis.rate[1].
   else v-rate = 0.

  /* вид обеспечения */
  find txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock no-error.
  if available txb.lonsec1 then do:
    find txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
    if avail txb.lonsec then v-obes = lonsec.des.
    else v-obes = " неверный код ".
  end.

 /* просроченная задолженность  */
   find txb.trxbal where txb.trxbal.subled = 'lon' and
    txb.trxbal.acc = txb.lon.lon and txb.trxbal.lev = 7 no-lock no-error.
   if available txb.trxbal then v-dolg = txb.trxbal.dam - txb.trxbal.cam.

 /* ---------------  22/01/03 nataly  ---------------*/

/*********** остатки на счетах *******************/

for each txb.lgr where txb.lgr.led eq "DDA",
    each txb.aaa of txb.lgr where txb.aaa.cif eq txb.lon.cif and txb.aaa.sta ne "C"
    and txb.aaa.crc = 1:
        vbal = aaa.cr[1] - aaa.dr[1].
        find baaa where baaa.aaa = aaa.craccnt no-lock no-error.
        if available baaa then  vbal = vbal + baaa.cbal.
        wrk.aaa1 = wrk.aaa1 + vbal.
end.

for each txb.lgr where txb.lgr.led eq "DDA",
    each txb.aaa of txb.lgr where txb.aaa.cif eq txb.lon.cif and txb.aaa.sta ne "C"
    and txb.aaa.crc = 2:
        vbal = aaa.cr[1] - aaa.dr[1].
        find baaa where baaa.aaa = aaa.craccnt no-lock no-error.
        if available baaa then vbal = vbal + baaa.cbal.
        wrk.aaa2 = wrk.aaa2 + vbal.
end.

for each txb.lgr where txb.lgr.led eq "DDA",
    each txb.aaa of txb.lgr where txb.aaa.cif eq txb.lon.cif and txb.aaa.sta ne "C"
    and txb.aaa.crc = 11:
        vbal = aaa.cr[1] - aaa.dr[1].
        find baaa where baaa.aaa = aaa.craccnt no-lock no-error.
        if available baaa then vbal = vbal + baaa.cbal.
        wrk.aaa3 = wrk.aaa3 + vbal.
end.

/***** Сегментация *****/
  find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnsegm' no-lock no-error.
  if avail txb.sub-cod then wrk.segm = txb.sub-cod.ccode.

/***** Объект кредитования *****/
  find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lntgt' no-lock no-error.
  if avail txb.sub-cod then do:
    find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
    if avail txb.codfr then wrk.tgt = trim(txb.codfr.name[1]).
  end.

/**** Для юр. лиц - расчет среднемесячной выручки ****/

find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = txb.lon.cif and sub-cod.d-cod = "clnsts" no-lock.
if sub-cod.ccode = "0" then do:
  find last txb.bal_cif where txb.bal_cif.cif = txb.lon.cif and txb.bal_cif.nom = 'z01' use-index rdt no-lock no-error.
      if avail txb.bal_cif then do:
           if month(txb.bal_cif.rdt) = 1
           then wrk.sum_dox = txb.bal_cif.amount / 12.
           else wrk.sum_dox = txb.bal_cif.amount / (month(txb.bal_cif.rdt) - 1).
      end.
end.
    
/**********************/
    wrk.balans = bilance.
    
    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= d1 no-lock no-error.
    wrk.balans_kzt = bilance * txb.crchis.rate[1].
    
/* + wrk.akkr + wrk.garan.*/
    wrk.crc = txb.lon.crc.
    wrk.prem = txb.lon.prem.
    wrk.dt1 =  dat1.
    wrk.dt2 = dat2.
    wrk.dt3 = dat3.
    wrk.duedt = dlong.
    wrk.rez = txb.lonstat.prc.

    /* wrk.srez = bilance * txb.lonstat.prc / 100. */
    run lonbalcrc_txb('lon',txb.lon.lon,d1,"3,6",yes,1,output wrk.srez).
    wrk.srez = - wrk.srez.

    wrk.zalog = v-sum.
    wrk.srok  = dlong - d1.
    wrk.num_dog = txb.loncon.lcnt.
    wrk.otrasl = otrasl.
    wrk.rate = v-rate.
    wrk.obes = v-obes.
    wrk.col_prolon = v-prolon.
    wrk.sum_dolg = v-dolg.

    find txb.ofc where txb.ofc.ofc = txb.loncon.pase-pier no-lock no-error.
    if avail txb.ofc then wrk.ofc = txb.ofc.name.
                     else wrk.ofc = txb.loncon.pase-pier.
  
  find first txb.longrp where txb.longrp.longrp = txb.lon.grp no-lock no-error.
   if integer(substr(string(txb.longrp.stn), 2, 1)) = 1 then
      wrk.sr = 'Краткосрочный'.
   if integer(substr(string(txb.longrp.stn), 2, 1)) = 2 then
      wrk.sr = 'Долгосрочный'.
   if integer(substr(string(txb.longrp.stn), 2, 1)) = 3 then
      wrk.sr = 'Овердрафт'.
end.   /* bilance > 0 */
end.  /* txb.lon */
