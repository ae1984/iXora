/* pkrepan.p
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
        17.12.2003 nadejda - добавила pk0.i для перекомпиляции
        08.09.2006 Natalya D. - оптимизация.
*/

def input parameter d1 as date.
def input parameter p-bank as char.

def shared var g-ofc as char.
def shared var g-today as date.
def shared var s-credtype as char.

{pk0.i}

def var rat as decimal.
def var long as int init 0.
def new shared var bilance   as decimal format '->,>>>,>>>,>>9.99'.
def var dlong as date.
def var srok as deci.
def var dat1 as date.
def var dat2 as date.
def var dat3 as date.
def var v-sum as decimal format '->,>>>,>>>,>>9.99'.
def var v-sumt as decimal format '->,>>>,>>>,>>9.99'.

def shared temp-table  wrk
    field cif    like txb.lon.cif
    field lon    like txb.lon.lon
    field name   like txb.cif.name
    field sts    as   char
    field gua    like txb.lon.gua
    field amoun  like txb.lon.opnamt
    field balans like txb.lon.opnamt
    field crc    like txb.crc.crc
    field prem   like txb.lon.prem
    field dt1    like txb.lon.rdt
    field dt2    like txb.lon.rdt
    field dt3    like txb.lon.rdt
    field duedt  like txb.lon.rdt
    field rez    like txb.lonstat.prc
    field srez   like txb.lon.opnamt
    field zalog  like txb.lon.opnamt
    field srok   as deci.

def temp-table t-longrp 
  field longrp as integer 
  index longrp is primary unique longrp. 

for each pksysc where pksysc.credtype = s-credtype and pksysc.sysc begins "longr" no-lock:
  find t-longrp where t-longrp.longrp = pksysc.inval no-error.
  if not avail t-longrp then do:
    create t-longrp.
    t-longrp.longrp = pksysc.inval.
  end.
end.

for each t-longrp:

  for each txb.lon, each pkanketa where txb.lon.grp = t-longrp.longrp and txb.lon.lon = pkanketa.lon 
                                    and pkanketa.bank = p-bank no-lock:

    /*run lon_txb (txb.lon.lon,d1,output bilance).*/ /* остаток  ОД*/                        

    if lon.sts ne "C" then do:

      run lon_txb (txb.lon.lon,d1,output bilance).
      dat1 = ?.
      dat2 = ?.
      dat3 = ?.

      find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.

      dlong = txb.lon.duedt.
      if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
      if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].

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
      
      if avail txb.lnsci then
      if (txb.lnsci.idat > dat2 or dat2 = ?) then dat2 = txb.lnsci.idat.

     /*следующее погашение по графику*/  
      find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0
                and txb.lnsch.stdat > dat2 
                no-lock no-error.

      if avail txb.lnsch then dat3 = txb.lnsch.stdat.
                         else dat3 = ?.
      
      find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0
                and txb.lnsci.fpn = 0 and txb.lnsci.idat > d1   
                no-lock no-error.
      
      if avail txb.lnsci then 
      if (txb.lnsci.idat < dat3 or dat3 = ?) then dat3 = txb.lnsci.idat.

      if dat3 = ? then do: 
         find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0
                     and txb.lnsci.fpn = 0 no-lock no-error.
            dat3 = txb.lnsci.idat.
      end.
   /**/
      find first txb.sub-cod where  txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = 'clnsts' no-lock no-error.

      find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
      find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
           
      create wrk.
      wrk.cif   =  txb.lon.cif.
      wrk.lon   =  txb.lon.lon.
      wrk.name  = txb.cif.name.
      wrk.sts   = txb.sub-cod.ccode.
      wrk.gua   = txb.lon.gua.
      wrk.amoun = txb.lon.opnamt.
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
      wrk.srok  = (round((dlong - d1) * 12 / 365 , 0)) * 30.
    end.
  end.                       
end.


