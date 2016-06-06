/* lnanlz4k.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Подготовка временной таблицы для анализа кредитного портфеля БД+
 * RUN
       
 * CALLER
       lnanlz3k
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню 
 * AUTHOR
        02/10/2006 madiyar - скопировал из lnanlz4.p с изменениями
 * BASES
        bank, comm, txb
 * CHANGES
*/  


def shared var g-ofc as char.
def shared var g-today as date.

{pk0.i}

def shared var suma as decimal no-undo.

define var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

define shared var s-credtype as char no-undo.
define shared var krport as deci no-undo extent 4.
define shared var krportp as deci no-undo extent 4.
define shared var krprov as deci no-undo extent 4.
define shared var krprovp as deci no-undo extent 4.
define shared var dates as date no-undo extent 4.

/* группы кредитов юридических лиц */
def var lst_ur as char no-undo init ''.
for each txb.longrp no-lock:
  if substr(string(txb.longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(txb.longrp.longrp).
  end.
end.

function glsum returns decimal (input v-gl as integer, input v-dat as date, input v-crc as integer).
    def var v-sum as decimal no-undo init 0.
    find last txb.glday where txb.glday.gl = v-gl and txb.glday.crc = v-crc and txb.glday.gdt < v-dat no-lock no-error.
    if avail txb.glday then v-sum = txb.glday.dam - txb.glday.cam.
    return (v-sum).
end function.

function glsumallcrc returns decimal (input v-gl as integer, input v-dat as date).
    def var v-sum as decimal no-undo init 0.
    def var v-sum1 as decimal no-undo init 0.
    for each txb.crc no-lock:
      v-sum1 = 0.
      find last txb.glday where txb.glday.gl = v-gl and txb.glday.crc = crc.crc and txb.glday.gdt < v-dat no-lock no-error.
      if avail txb.glday then v-sum1 = txb.glday.dam - txb.glday.cam.
      if v-sum1 > 0 then do:
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.regdt < v-dat no-lock no-error.
        v-sum = v-sum + v-sum1 * txb.crchis.rate[1].
      end.
    end.
    return (v-sum).
end function.

def buffer b-crchis for txb.crchis.
def var rat as decimal no-undo.
def var long as int no-undo init 0.
def new shared var bilance as decimal format "->,>>>,>>>,>>9.99".
def var prosr_od as deci no-undo.
def var dlong as date no-undo.
def var srok as deci no-undo.
def var v-sum as decimal no-undo format "->,>>>,>>>,>>9.99".
def var v-sumt as decimal no-undo format "->,>>>,>>>,>>9.99".
def var v-grp as inte no-undo.
def var i as inte no-undo.
def var dat as date no-undo.
def var dat_wrk as date no-undo.
def var tempdt  as date no-undo.
def var tempost as deci no-undo.
def var dayc1 as inte no-undo.
def var dayc2 as inte no-undo.
def var v-am2 as decimal no-undo init 0. 
def var tempgrp as int no-undo.
def var n as integer no-undo.

def var v-rate as decimal no-undo.
def var msumma as decimal no-undo extent 10.
def var mcount as integer no-undo extent 5.
def var komiss as deci no-undo.
def var mprov as deci no-undo.
def var dat2 as date no-undo.

def var mval1 as decimal no-undo.
def var mnum1 as integer no-undo.
def var pogdt as date.
def var mval2 as decimal no-undo extent 6.
def var mnum2 as integer no-undo extent 4.
def var mval3 as decimal no-undo extent 7.
def var mesa as integer.

def var vyear as inte no-undo.
def var vmonth as inte no-undo.
def var vday as inte no-undo.
def var mdays as inte no-undo.

def var scom as deci no-undo.

def shared temp-table wrk no-undo
    field bank   as char
    field datot  like txb.lon.rdt
    field cif    like txb.lon.cif
    field lon    like txb.lon.lon
    field name   like txb.cif.name
    field plan   like txb.lon.plan
    field sts    as   char
    field grp    like txb.lon.grp
    field amoun  as decimal 
    field balans as decimal 
    field balans1 as decimal 
    field balans2 as decimal 
    field balans3 as decimal 
    field crc    as integer
    field prem   as decimal 
    field proc   as decimal 
    field duedt  as date
    field rez    as decimal 
    field rez1   as decimal 
    field rez2   as decimal 
    field srez   as decimal 
    field peni   as decimal 
    field penires  as decimal 
    field daymax as inte
    field zalog  as decimal 
    field srok   as deci
    index main is primary datot desc bank cif lon.

def shared temp-table wrkrep no-undo
    field m-table as integer
    field m-row as integer
    field m-values as deci extent 4
    index ind is primary m-table m-row.

def buffer b-jl for txb.jl.

hide message no-pause.
message " " s-ourbank.

do i = 1 to 4:
 
 dat = dates[i].
 
 message dat view-as alert-box.
 
 find last txb.cls where txb.cls.whn < dat and txb.cls.del no-lock no-error. /* последний рабочий день перед dat */
 dat_wrk = txb.cls.whn.
 
 krportp[i] = krportp[i] + glsumallcrc(141120,dat) + glsumallcrc(141720,dat) + glsumallcrc(142420,dat).
 krprovp[i] = krprovp[i] - glsum(146520,dat,1) - glsum(142820,dat,1).
 
 krport[i] = krport[i] + glsumallcrc(141120,dat) + glsumallcrc(141720,dat) + glsumallcrc(142420,dat) + glsumallcrc(141110,dat) + glsumallcrc(141710,dat) + glsumallcrc(142410,dat).
 krprov[i] = krprov[i] - glsum(146520,dat,1) - glsum(142820,dat,1) - glsum(146510,dat,1) - glsum(142810,dat,1).
 
 /*
 for each txb.lon no-lock:
   if txb.lon.opnamt = 0 then next.
   run lon_txb2 (txb.lon.lon, dat - 1, output bilance).
   if bilance <= 0 then next.
   else do:
     find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt < dat no-lock no-error.
     krport[i] = krport[i] + bilance * txb.crchis.rate[1].
     run lonbal_txb('lon',txb.lon.lon,dat,"3,6",no,output mprov).
     krprov[i] = krprov[i] - mprov.
     if lookup(trim(string(txb.lon.grp)),lst_ur) = 0 then do:
       krportp[i] = krportp[i] + bilance * txb.crchis.rate[1].
       krprovp[i] = krprovp[i] - mprov.
     end.
   end.
 end.
 */
 
 msumma = 0. mcount = 0.
 mval1 = 0. mnum1 = 0.
 mval2 = 0. mnum2 = 0.
 mval3 = 0.
 mesa = 0.
 
 vmonth = month(dat) - 1.
 vyear = year(dat).
 if vmonth = 0 then do: vmonth = 12. vyear = vyear - 1. end.
 dat2 = date(vmonth,1,vyear).
 
 for each pkanketa where pkanketa.id_org = "kazpost" and pkanketa.bank = s-ourbank and pkanketa.credtype = '6' no-lock:
    
    if pkanketa.lon = '' then next.
    find first txb.lon where txb.lon.lon = pkanketa.lon no-lock no-error.
    if not avail txb.lon then next.
    
    if txb.lon.opnamt <= 0 then next.
    if txb.lon.rdt >= dat then next.
    
    if pkanketa.docdt < dat then do:
        
        /* выдано кредитов */
        if pkanketa.crc = 1 then v-rate = 1.
        else do:
          find last txb.crchis where txb.crchis.crc = pkanketa.crc and txb.crchis.regdt <= pkanketa.docdt no-lock no-error.
          v-rate = txb.crchis.rate[1].
        end.
        msumma[1] = msumma[1] + pkanketa.summa * v-rate.
        mcount[1] = mcount[1] + 1.
        if pkanketa.docdt >= dat2 then do:
           msumma[2] = msumma[2] + pkanketa.summa * v-rate.
           mcount[2] = mcount[2] + 1.
        end.
        
        /* комиссии */
        /*
        msumma[3] = msumma[3] + komiss.
        msumma[4] = msumma[4] + pkanketa.summa - pkanketa.sumq - komiss.
        */
        msumma[4] = msumma[4] + pkanketa.summa * 0.025.
        if pkanketa.docdt >= dat2 then do:
              /*
              msumma[5] = msumma[5] + komiss.
              msumma[6] = msumma[6] + pkanketa.summa - pkanketa.sumq - komiss.
              */
              msumma[6] = msumma[6] + pkanketa.sumq * 0.025.
        end.
        
    end. /* if pkanketa.docdt < dat */
    
    /* Кредиты с законченным сроком действия договора */
    if pkanketa.duedt < dat then do:
        
        run lonbalcrc_txb('lon',pkanketa.lon,dat,"1,7",no,pkanketa.crc,output bilance). /* остаток ОД */
        if bilance > 0 then do:
          if pkanketa.crc = 1 then v-rate = 1.
          else do:
            find last txb.crchis where txb.crchis.crc = pkanketa.crc and txb.crchis.regdt <= pkanketa.docdt no-lock no-error.
            v-rate = txb.crchis.rate[1].
          end.
          mval1 = mval1 + bilance * v-rate.
          mnum1 = mnum1 + 1.
        end.
        
    end. /* if pkanketa.lon <> "" and pkanketa.duedt < dat */
    
    /* динамика роста погашенных кредитов */
    
    run lonbal_txb('lon',txb.lon.lon,dat,"14",no,output mprov).
    if mprov > 0 then do:
      mval2[5] = mval2[5] + mprov.
      run lonbal_txb('lon',txb.lon.lon,dat2,"14",no,output komiss).
      if mprov - komiss > 0 then mval2[6] = mval2[6] + mprov - komiss.
    end.
    
    run lonbal_txb('lon',txb.lon.lon,dat,"1,7",no,output bilance).
    if bilance <= 0 and pkanketa.docdt < dat then do:
      mnum2[1] = mnum2[1] + 1.
      mval2[1] = mval2[1] + pkanketa.summa.
      run lonbalcrc_txb('lon',txb.lon.lon,dat,"13",no,txb.lon.crc,output mprov).
      if mprov > 0 then do: mnum2[2] = mnum2[2] + 1. mval2[2] = mval2[2] + mprov. end.
      run lonbalcrc_txb('lon',txb.lon.lon,dat2,"1,7",no,txb.lon.crc,output bilance).
      if bilance > 0 or pkanketa.docdt >= dat2 then do:
        mnum2[3] = mnum2[3] + 1.
        mval2[3] = mval2[3] + pkanketa.summa. /* если нужен объем погашенного ОД за период - прибавляем bilance */
        run lonbalcrc_txb('lon',txb.lon.lon,dat,"13",no,txb.lon.crc,output komiss).
        if mprov - komiss > 0 then do: mnum2[4] = mnum2[4] + 1. mval2[4] = mval2[4] + mprov - komiss. end.
      end.
    end.
    
    /* Портфель по БД */
        
    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat < dat no-lock:
      if txb.lnsci.flp = 0 then do: /* начисленные %% */
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnsci.idat no-lock no-error.
        mval3[1] = mval3[1] + txb.lnsci.iv-sc * txb.crchis.rate[1].
        if txb.lnsci.idat >= dat2 then mval3[2] = mval3[2] + txb.lnsci.iv-sc * txb.crchis.rate[1].
      end.
      if txb.lnsci.flp > 0 then do: /* погашенные %% */
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnsci.idat no-lock no-error.
        mval3[3] = mval3[3] + txb.lnsci.paid-iv * txb.crchis.rate[1].
        if txb.lnsci.idat >= dat2 then mval3[4] = mval3[4] + txb.lnsci.paid-iv * txb.crchis.rate[1].
      end.
    end.
    
    /* штрафы начисленные и полученные на дату */
    /* начисленные штрафы */
    /*
    if dat < 01/07/04 then find last txb.hislon where txb.hislon.lon = pkanketa.lon and txb.hislon.fdt < 01/07/04 no-lock no-error.
    else find last txb.hislon where txb.hislon.lon = pkanketa.lon and txb.hislon.fdt < dat no-lock no-error.
    if avail txb.hislon then mval3[5] = mval3[5] + txb.hislon.tdam[3].
    */
    /* полученные штрафы - обороты по 16 уровню по кредиту до заданной даты */
    /*
    for each txb.lonres where txb.lonres.lon = pkanketa.lon and txb.lonres.lev = 16 and txb.lonres.dc = "c" and txb.lonres.jdt < dat no-lock:
      mval3[6] = mval3[6] + txb.lonres.amt.
      if txb.lonres.jdt >= dat2 then mval3[7] = mval3[7] + txb.lonres.amt.
    end.
    */
    
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"1,7",no,txb.lon.crc,output bilance). /* остаток  ОД*/
    
    if bilance > 0 then do:
      
      find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
      find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
      
      dlong = txb.lon.duedt.
      if txb.lon.ddt[5] <> ? and txb.lon.ddt[5] < dat then dlong = txb.lon.ddt[5].
      if txb.lon.cdt[5] <> ? and txb.lon.cdt[5] < dat then dlong = txb.lon.cdt[5].
      
      /**/
      find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "clnsts" no-lock no-error.
      
      create wrk.
      assign wrk.bank = s-ourbank
             wrk.datot = dat
             wrk.cif = txb.lon.cif
             wrk.lon = txb.lon.lon
             wrk.name = txb.cif.name
             wrk.plan = txb.lon.plan
             wrk.sts = txb.sub-cod.ccode
             wrk.grp = txb.lon.grp
             wrk.amoun = txb.lon.opnamt
             wrk.balans = bilance
             wrk.crc = txb.lon.crc
             wrk.duedt = dlong
             wrk.zalog = v-sum
             wrk.srok = dlong - dat
             wrk.rez = 0
             wrk.srez = 0.
      
      /* просрочка ОД */
      run lonbalcrc_txb('lon', txb.lon.lon, dat, "7", no, txb.lon.crc, output prosr_od).
      
      v-am2 = 0.
      
      /* расчет начисленной суммы на заданную дату */
      /* расчет просроченных процентов для 3 и 4 схем - разные */
      
      if txb.lon.plan = 3 and dat <= 03/31/2004 then do: 
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
          for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat >= dat and txb.lnsci.idat < g-today
                   no-lock by txb.lnsci.idat descending:
             if txb.lnsci.f0 eq 0 and txb.lnsci.fpn = 0 and txb.lnsci.flp > 0 then 
             v-am2 = v-am2 + txb.lnsci.paid.
          end.
          
          /* минус начисленное за дни с заданной даты до сегодняшнего дня */
          for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat >= dat and txb.lnsci.idat < g-today
                   no-lock by txb.lnsci.idat descending:
            if txb.lnsci.f0 > 0 and txb.lnsci.fpn = 0 and txb.lnsci.flp = 0 then v-am2 = v-am2 - txb.lnsci.iv-sc.
          end.
          
          /* минус то, что начислено вручную - не отразилось в графике */
          for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 2 and dc = 'D'
                   and txb.lonres.jdt >= dat and txb.lonres.jdt < g-today no-lock:
            v-am2 = v-am2 - txb.lonres.amt1.
          end.
      end. /* if txb.lon.plan = 3 and dat <= 03/31/2004 */
      else do: /* if txb.lon.plan = 4 or (txb.lon.plan = 3 and dat > 03/31/2004) */
        run lonbal_txb('lon',txb.lon.lon,dat,"9",no,output v-am2).
      end.
      
      /* дней просрочки */
      dayc1 = 0. dayc2 = 0.
      run lndayspr_txb(txb.lon.lon,dat,no,output dayc1,output dayc2).
      
      if dayc1 > dayc2 then wrk.daymax = dayc1.
                       else wrk.daymax = dayc2.
      
      find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < dat no-lock no-error.
      find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
      if avail txb.lonstat then wrk.rez1 = txb.lonstat.prc.
      
      find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat <= dat no-lock no-error.
      if avail txb.ln%his then wrk.prem = txb.ln%his.intrate.
      
      run lonbal_txb('lon', txb.lon.lon, dat, "3,6", no, output wrk.srez). /* фактически сформированные провизии */
      wrk.srez = - wrk.srez.
      
    end. /*bilance > 0 */
    
    mesa = mesa + 1.
    hide message no-pause.
    message " " s-ourbank " - " i " - " mesa " ".
    
 end. /* for each pkanketa */
 
 find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 1.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mcount[1].
 find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 2.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mcount[2].
 find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 3.
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[1].
 find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 4.
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[2].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 3. /* за выдачу на дату */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[3].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 4. /* за выдачу за период */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[5].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 1. /* фс */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[4].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 2. /* фс */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[6].
 
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 7. /* за ведение тек.счета */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[9].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 8. /* за ведение тек.счета */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[10].
 
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 9. /* обнал */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[7].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 10. /* обнал */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[8].
 
 find wrkrep where wrkrep.m-table = 6 and wrkrep.m-row = 1.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum1.
 find wrkrep where wrkrep.m-table = 6 and wrkrep.m-row = 2.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval1.
 
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 1.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum2[1].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 2.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum2[2].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 3.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum2[3].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 4.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mnum2[4].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 5.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[1].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 6.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[2].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 7.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[3].
 find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 8.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[4].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 15.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[5].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 16.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval2[6].
 
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 11.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[1].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 12.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[2].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 13.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[3].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 14.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[4].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 17.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[5].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 19.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[6].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 20.
 wrkrep.m-values[i] = wrkrep.m-values[i] + mval3[7].
 
 
 /* 
 msumma = 0. mcount = 0. mesa = 0.
 for each pkanketa where pkanketa.id_org = "kazpost" and pkanketa.bank = s-ourbank and pkanketa.credtype = '6' and pkanketa.rdt < dat no-lock:
    
    if pkanketa.rdt >= 05/11/2004 then do:
      
       if (pkanketa.bank = 'txb00' and pkanketa.rdt >= 09/26/2005) or (pkanketa.bank <> 'txb00' and pkanketa.rdt >= 10/26/2005) then do:
         msumma[1] = msumma[1] + 300.
         if pkanketa.rdt >= dat2 then msumma[2] = msumma[2] + 300.
       end.
       else do:
         msumma[1] = msumma[1] + 200.
         if pkanketa.rdt >= dat2 then msumma[2] = msumma[2] + 200.
       end.
       
       mesa = mesa + 1.
       hide message no-pause.
       message " " s-ourbank " - " i " - комиссия за рассм. заявок - " mesa " ".
       
    end.
 
 end. /* for each pkanketa */
 
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 5. /* за рассмотрение заявки */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[1].
 find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 6. /* за рассмотрение заявки */
 wrkrep.m-values[i] = wrkrep.m-values[i] + msumma[2].
 */

end. /* do i = 1 to 4 */

