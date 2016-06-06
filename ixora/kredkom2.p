/* kredkom2.p
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
        12.02.2004 nadejda - добавлен обслуживающий менеджер
        22/07/2004 madiar - учет индексированных уровней
*/

def input parameter d1 as date.
def shared var g-ofc as char.
def shared var g-today as date.
def var rat as decimal.
def var v-obes1 as char.
def var long as int init 0.
def new shared var bilance   as decimal format '->,>>>,>>>,>>9.99'.
def var dlong as date.
def var srok as deci.
def var dat1 as date.
def var dat2 as date.
def var dat3 as date.
def var otrasl as char.
def var v-prolon as integer init 0.
def var v-rate as decimal.
def var v-dolg as decimal.
def var v-sum as decimal format '->,>>>,>>>,>>9.99'.
def var v-sumt as decimal format '->,>>>,>>>,>>9.99'.
def var i as integer.

/*для расчета риска*/
def  shared var v-otrasl as char.
def  shared var v-otrasl2 as decimal format 'zz9.9%'.
def  shared var v-obes as decimal format 'zz9.9%'.
def  shared var v-osenka as decimal format 'zz9.9%'.

def  shared var v-zalog as decimal.
def  shared var v-zalog2 as decimal.
def  shared var v-obor as decimal.
def  shared var v-obor2 as decimal.
def  shared var  koef_ust as decimal.

def  shared var v-prd as integer.
def  shared var v-srok as decimal.
def  shared var v-history as decimal.
def  shared var optimal as decimal extent 8 initial [80,90,80,80,80,60,70,80].
def  shared var weight as integer extent 8 initial [5,25,15,25,5,5,10,10].
def shared var prz as deci.
/* mygrps */
def shared var mygrp_names as char extent 5.
def shared var mygrps      as char extent 5.

def shared temp-table  wrk
    field mygrp  as int
    field lon    like txb.lon.lon
    field urfiz  as integer
    field pokaz  as decimal extent 10
    field grp   like  txb.lon.grp
    field name   like txb.cif.name
    field gua    like txb.lon.gua
    field amoun  like txb.lon.opnamt
    field balans like txb.lon.opnamt
    field akkr like txb.lon.opnamt
    field garan like txb.lon.opnamt
    field crc    like txb.lon.crc
    field prem   like txb.lon.prem
    field dt1    like txb.lon.rdt
    field dt2    like txb.lon.rdt
    field dt3    like txb.lon.rdt
    field duedt  like txb.lon.rdt
    field rez    like txb.lonstat.prc
    field srez   like txb.lon.opnamt
    field zalog  like txb.lon.opnamt
    field srok   as deci
    field num_dog like txb.loncon.lcnt  /* номер договора */
    field otrasl as char                 /* отрасль */
    field rate   as decimal        /* курс на день выдачи */
    field obes    as char                   /* вид обеспечения */
    field col_prolon as integer          /* кол-во пролонгаций */
    field sum_dolg as decimal            /* сумма просроченной задолженности */
    field ofc as char                    /* обслуживает менеджер */
    index main is primary crc desc balans desc mygrp urfiz.

def var v-urfiz as integer.

for each txb.lon where  /*txb.lon.cif = 't12035' or txb.lon.cif = 't25255'*/ no-lock.
  run lon_txb2 (txb.lon.lon,d1,output bilance). /* остаток  ОД*/                        
  v-prolon = 0. v-urfiz = 0.

  v-otrasl2 = 0 . koef_ust = 0. v-obes = 0. v-zalog2 = 0. v-zalog = 0.
  v-osenka = 0. v-srok = 0. v-history = 0.  v-prd = 0.
  v-obor2  = 0. v-otrasl2  = 0.


  if bilance > 0 then do:
   dat1 = ?.
   dat2 = ?.
   dat3 = ?.

   find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
   /* выберем юридические... */
   find first txb.sub-cod where 
    txb.sub-cod.d-cod = 'clnsts' and
    txb.sub-cod.ccode = '0'      and 
    txb.sub-cod.sub   = 'cln'    and
    txb.sub-cod.acc   = txb.cif.cif no-lock no-error.
 /*если кредит относится к ЮЛ, то расчитываем кредитный риск*/
    if not avail txb.sub-cod and prz = 3 then next.
    if avail txb.sub-cod   then do:
     if prz = 3 then  run r-risk2 (txb.lon.lon).
      v-urfiz = 0.
    end.
    else       v-urfiz = 1.

   dlong = txb.lon.duedt.
   if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
   if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].

   if txb.lon.ddt[5] <> ? then v-prolon = v-prolon + 1.
   if txb.lon.cdt[5] <> ? then v-prolon = v-prolon + 1.

  /*выдача займа*/
   find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and
             txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0
             no-lock no-error.
   if avail txb.lnscg then dat1 = txb.lnscg.stdat.
                      else dat1 = ?.

  /*последнее погашение*/
   find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 = 0
             no-lock no-error.
   if avail txb.lnsch then dat2 = txb.lnsch.stdat.
                      else dat2 = ?.

   find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 = 0
             and txb.lnsci.fpn = 0    
             no-lock no-error.
   if avail txb.lnsci and (txb.lnsci.idat > dat2 or dat2 = ?) then dat2 = txb.lnsci.idat.

  /*следующее погашение по графику*/  

   find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0
             and txb.lnsch.stdat > dat2 
             no-lock no-error.
   if avail txb.lnsch then dat3 = txb.lnsch.stdat.
                      else dat3 = ?.
   

   find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0
             and txb.lnsci.fpn = 0 and txb.lnsci.idat > d1   
             no-lock no-error.
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
    wrk.grp = txb.lon.grp.
    
    do i = 1 to 5:
      if lookup(string(txb.lon.grp),mygrps[i]) > 0 then wrk.mygrp = i.
    end.
    
    wrk.name  = txb.cif.name.
    wrk.gua   = txb.lon.gua.
    wrk.amoun = txb.lon.opnamt.
    wrk.urfiz = v-urfiz.
    pokaz[1] = v-otrasl2.  pokaz[2] =  koef_ust.   
    pokaz[3] = v-obes.  pokaz[4] =  v-zalog2.  pokaz[5] =  v-osenka. 
    pokaz[6] = v-srok.  pokaz[7] =  v-history.  pokaz[8] =  v-obor2. 

/* Учет выданных аккредитивов и гарантий*/
for each txb.lnakkred where txb.lnakkred.lon = txb.lon.lon and txb.lnakkred.uno = 1 no-lock:
   if txb.lnakkred.crc ne txb.lon.crc then  do:  
       if txb.lon.crc = 1 then do:
          find last txb.crc where txb.crc.crc = txb.lnakkred.crc no-lock no-error.
          wrk.akkr = wrk.akkr + txb.lnakkred.amount * txb.crc.rate[1].
       end.
       if txb.lon.crc ne 1 then do:
          find last txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
          wrk.akkr = wrk.akkr + txb.lnakkred.amount / txb.crc.rate[1].
       end.
   end.
   else do:
       wrk.akkr = wrk.akkr + txb.lnakkred.amount.
   end.
end. 
for each txb.lnakkred where txb.lnakkred.lon = txb.lon.lon and txb.lnakkred.uno = 2 no-lock:
   if txb.lnakkred.crc ne txb.lon.crc then  do:  
       if txb.lon.crc = 1 then do:
          find last txb.crc where txb.crc.crc = txb.lnakkred.crc no-lock no-error.
          wrk.garan = wrk.garan + txb.lnakkred.amount * txb.crc.rate[1].
       end.
       if txb.lon.crc ne 1 then do:
          find last txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
          wrk.garan = wrk.garan + txb.lnakkred.amount / txb.crc.rate[1].
       end.
   end.
   else do:
       wrk.garan = wrk.garan + txb.lnakkred.amount.
   end.
end. 

 /* ---------------  22/01/03 nataly  ---------------*/

   find txb.loncon where txb.loncon.lon = txb.lon.lon  no-lock no-error.
   
  /* отрасль экономики */
   find  txb.sub-cod where txb.sub-cod.acc = txb.lon.lon  
     and txb.sub-cod.sub = 'lon' and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
   if available txb.sub-cod then do:
    find txb.codfr where txb.codfr.codfr = 'ecdivis' 
     and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
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
  v-obes1 = ''.
  find txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock no-error.
  if available txb.lonsec1 then do:
    find txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
    v-obes1 = lonsec.des.
  end.

 /* просроченная задолженность  */
   v-dolg = 0.
   find txb.trxbal where txb.trxbal.subled = 'lon' and  
    txb.trxbal.acc = txb.lon.lon and txb.trxbal.lev = 7 no-lock no-error.
   if available txb.trxbal then v-dolg = txb.trxbal.dam - txb.trxbal.cam.

 /* ---------------  22/01/03 nataly  ---------------*/

    wrk.balans = bilance.
    wrk.crc = txb.lon.crc.
    wrk.prem = txb.lon.prem.
    wrk.dt1 =  dat1.
    wrk.dt2 = dat2.
    wrk.dt3 = dat3.
    wrk.duedt = dlong.
    wrk.rez = txb.lonstat.prc.
    wrk.srez = bilance * txb.lonstat.prc / 100 .
    wrk.zalog = v-sum.
    wrk.srok  = dlong - d1.
    wrk.num_dog = txb.loncon.lcnt.
    wrk.otrasl = otrasl.
    wrk.rate = v-rate.
    wrk.obes = v-obes1.
    wrk.col_prolon = v-prolon.
    wrk.sum_dolg = v-dolg.

    find txb.ofc where txb.ofc.ofc = txb.loncon.pase-pier no-lock no-error.
    if avail txb.ofc then wrk.ofc = txb.ofc.name.
                     else wrk.ofc = txb.loncon.pase-pier.


end.   /* bilance > 0 */
end.  /* txb.lon */                      

