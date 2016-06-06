/* bkrent1.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Расчеты по филиалам для определенеия окупаемости БД
 * RUN
       
 * CALLER
       
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
         
 * AUTHOR
        03.03.2004 marinav
 * CHANGES
        05.04.2004 nadejda - добавлен параметр p-bank
*/  


def shared var g-ofc as char.
def shared var g-today as date.

          

{pk0.i}

def input parameter d1 as date.
def input parameter d2 as date.
def input parameter p-bank as char.

def shared var suma as decimal.

define shared var s-ourbank as char.
define shared var s-credtype as char.

def buffer b-crchis for txb.crchis.
def var rat as decimal.
def var long as int init 0.
def new shared var bilance   as decimal format "->,>>>,>>>,>>9.99".
def var bilancepl as decimal format "->,>>>,>>>,>>9.99".
def var dlong as date.
def var srok as deci.
def var v-sum as decimal format "->,>>>,>>>,>>9.99".
def var v-sumt as decimal format "->,>>>,>>>,>>9.99".
def var v-grp as inte.
def var i as inte init -1.
def var dat as date.
def var dat1 as date.  /*для будущих доходов*/
def var tempdt  as date.
def var tempost as deci.
def var dayc1 as inte.
def var dayc2 as inte.
def var v-am2 as decimal init 0. 
def var tempgrp as int.
def var n as integer.

def shared temp-table  wrk
    field bank   as char
    field datot  like txb.lon.rdt
    field cif    like txb.lon.cif
    field lon    like txb.lon.lon
    field name   like txb.cif.name
    field plan   like txb.lon.plan
    field balans as decimal 
    field balans1 as decimal 
    field balans3 as decimal 
    field duedt  as date
    field rez    as decimal 
    field rez1   as decimal 
    field peni   as decimal 
    field daymax as inte
    index main is primary datot desc bank cif lon.


/* 05.04.2004 nadejda */
s-ourbank = p-bank.
hide message no-pause.
message " Обработка " s-ourbank.
/**/


dat = d1.
repeat:

 for each pkanketa no-lock where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype use-index bankcred.
  find txb.lon where txb.lon.lon = pkanketa.lon no-lock no-error.
  if avail txb.lon  then do:

   run lon_txb (txb.lon.lon, dat - 1, output bilance). /* остаток  ОД*/                        
  
   if bilance > 0 then do:


   find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
   find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.

/**/
   find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "clnsts" no-lock no-error.
 
   create wrk.
   assign wrk.bank = s-ourbank
          wrk.datot = dat
          wrk.cif   = txb.lon.cif
          wrk.lon   = txb.lon.lon
          wrk.name  = txb.cif.name
          wrk.balans = bilance.

     bilancepl = 0.   /* На тек день по графику погашения */
     for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.stdat < dat no-lock:
        if txb.lnsch.flp = 0 and txb.lnsch.fpn = 0 and txb.lnsch.f0 > 0 then 
          bilancepl = bilancepl + txb.lnsch.stval.
     end.

     bilancepl = lon.opnamt - bilancepl. /* долг по графику , который должен остаться*/

  /*полученные %%*/
   for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat < dat no-lock:
      if txb.lnsci.flp > 0 then do:
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt < txb.lnsci.idat no-lock no-error.
            wrk.balans3 = wrk.balans3 + txb.lnsci.paid-iv * txb.crchis.rate[1].
      end.
   end.

    v-am2 = 0. 
    /* расчет начисленной суммы на заданную дату */
    /* остаток процентов на утро сегодня (без учета сегодняшних проводок) */
    for each txb.trxbal where txb.trxbal.sub eq "lon" and txb.trxbal.acc eq txb.lon.lon
        and txb.trxbal.crc eq txb.lon.crc no-lock :
      if txb.trxbal.lev eq 2 then v-am2 = v-am2 + txb.trxbal.pdam - txb.trxbal.pcam.
      else
      if txb.trxbal.lev eq 9 then v-am2 = v-am2 + txb.trxbal.pdam - txb.trxbal.pcam.
      else
      if txb.trxbal.lev eq 10 then v-am2 = v-am2 + txb.trxbal.pdam - txb.trxbal.pcam.
    end.

    /* плюс оплаченное за дни с заданной даты до сегодняшнего дня */
    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat > dat and txb.lnsci.idat < g-today
        no-lock by txb.lnsci.idat descending:
       if txb.lnsci.f0 eq 0 and txb.lnsci.fpn = 0 and txb.lnsci.flp > 0 then 
         v-am2 = v-am2 + txb.lnsci.paid.
    end.
 
    /* минус начисленное за дни с заданной даты до сегодняшнего дня */
    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat > dat and txb.lnsci.idat < g-today
             no-lock by txb.lnsci.idat descending:
        if txb.lnsci.f0 > 0 and txb.lnsci.fpn = 0 and txb.lnsci.flp = 0 then 
          v-am2 = v-am2 - txb.lnsci.iv-sc.
    end.
    /* минус то, что начислено вручную - не отразилось в графике*/
    for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 2 and dc = 'D' 
                              and txb.lonres.jdt > dat no-lock.
       v-am2 = v-am2 - txb.lonres.amt1.
    end.

/********посчитать дни просрочки*********/ 
  dayc1 = 0. dayc2 = 0.

       if  v-am2 > 0 then do:
          tempdt = dat.
          tempost = 0.
          repeat:
            find last  txb.lnsci where  txb.lnsci.lni =  txb.lon.lon and  txb.lnsci.idat <= tempdt and  txb.lnsci.f0 > 0 no-lock no-error.
            if avail txb.lnsci then do:
               tempost = tempost +  txb.lnsci.iv-sc.
               if v-am2 <= tempost then do:
                  dayc2 = dat - txb.lnsci.idat.
                  leave.
               end.   
               tempdt =  txb.lnsci.idat - 1.
            end.  
            else leave.
          end.  
       end.            

       if bilance - bilancepl > 0 then do:
          tempdt = dat.
          tempost = 0.
          repeat:
            find last  txb.lnsch where  txb.lnsch.lnn =  txb.lon.lon and  txb.lnsch.stdat <= tempdt and  txb.lnsch.f0 > 0 no-lock no-error.
            if avail  txb.lnsch then do:
               tempost = tempost +  txb.lnsch.stval.
               if bilance - bilancepl <= tempost then do:
                  dayc1 = dat -  txb.lnsch.stdat.
                  leave.
               end.   
               tempdt =  txb.lnsch.stdat - 1.
            end.  
            else leave.
          end.  
       end.            
        find last txb.cls where txb.cls.whn < dat no-lock no-error.
        tempgrp = dat - 1 - txb.cls.whn.
        /* надо учесть выходные - в понедельник для тех, у кого выпало погашение на субботу - dayc=2, на воскресенье - dayc=1 */
        if tempgrp > 0 and (dayc1 <= tempgrp) and (dayc2 <= tempgrp) then 
                                 assign dayc1 = 0 dayc2 = 0.

     if dayc1 = 0 and dayc2 = 0 then assign wrk.rez = 0 wrk.rez1 = 5.
     if dayc1 = 0 and dayc2 > 0 then assign wrk.rez = 5 wrk.rez1 = 50.
     if dayc1 > 0 and dayc2 > 0 then assign wrk.rez = 10 wrk.rez1 = 50.
     if dayc1 > 0 and dayc2 = 0 then assign wrk.rez = 10 wrk.rez1 = 50.
     if dayc1 >= 0 and dayc2 > 30 then assign wrk.rez = 20 wrk.rez1 = 100.
     if (dayc1 > 30 and dayc2 > 30) or dayc1 > 30 then assign wrk.rez = 25 wrk.rez1 = 100.
     if (dayc1 > 60 and dayc2 > 60) or dayc1 > 60 then assign wrk.rez = 50 wrk.rez1 = 100.
     if (dayc1 > 90 and dayc2 > 90) or dayc1 > 90 then assign wrk.rez = 100 wrk.rez1 = 100.
     if dayc1 > dayc2 then wrk.daymax = dayc1.
                      else wrk.daymax = dayc2.
      wrk.rez1 = 5.
      if bilance - bilancepl + v-am2 >= 100 and wrk.daymax > 0 then wrk.rez1 = 50.
      if bilance - bilancepl + v-am2 >= 100 and wrk.daymax > 30 then wrk.rez1 = 100.
/*
     if wrk.bank = "TXB00" and dat = d1 then 
            displ  wrk.cif " " wrk.name  " " bilance - bilancepl + v-am2 " " wrk.daymax " " wrk.rez1 skip.
*/
      /* полученные штрафы - обороты по 16 уровню по кредиту до заданной даты */
      for each txb.jl where txb.jl.jdt < dat and txb.jl.acc = txb.lon.lon 
                               and txb.jl.dc = "c" no-lock use-index accdcjdt:
             if txb.jl.lev <> 16 then next.
             wrk.peni = wrk.peni + txb.jl.cam.
      end.

/****************************/

  end. /*bilance > 0 */
 end. /*avail lon*/
end.  /*pkanketa*/                      

if dat = d1 and d1 ne d2 then dat = d2.
                         else leave.
end.  

