/* 2sbpr_b.p
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
 * BASES
        COMM TXB
 * AUTHOR
        21/05/08 marinav - консолидация
 * CHANGES
*/
  

def var summa as decimal format 'zzz,zzz,zzz,zz9.99'.
def var v-ccode as char format "x(4)".
def var v-srok as int init 0.
    
def shared  variable v-dt     as date format "99/99/9999".
def shared  variable v-dtn    as date format "99/99/9999".

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

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
hide message no-pause.
message "Обрабатывается филиал  - " trim(txb.sysc.chval) .

for each txb.lon, 
    each txb.lonres of txb.lon where txb.lonres.lev = 1 and txb.lonres.jdt > v-dtn and txb.lonres.jdt <= v-dt and txb.lonres.dc = 'D' 
         and txb.lonres.trx ne 'lon0023' and  txb.lonres.trx ne 'lon0024' no-lock:
      summa = txb.lonres.amt.
      if summa = 0 then next.
      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt le txb.lonres.jdt no-error.
       if avail txb.crchis then  summa = summa * txb.crchis.rate[1].
      v-srok = txb.lon.duedt - txb.lon.rdt.      
      v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
      find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat <= txb.lonres.jdt
             no-lock no-error.
      run tablsb(summa,1,2,3).
end.

for each txb.lon:  
  run lonbal_txb('lon',txb.lon.lon,v-dt,'1,7,8',yes,output summa). /* ОД */
  /*run atl-dat1(lon.lon,v-dt,3,output summa).*/
  if summa = 0 then next.
  find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt le v-dt no-error.
    if avail txb.crchis then  summa = summa * txb.crchis.rate[1].
  find last txb.ln%his where txb.ln%his.lon = txb.lon.lon no-lock no-error.
  v-srok = txb.ln%his.duedt - txb.ln%his.rdt.
  v-srok = (round((v-srok) * 12 / 365 , 0)) * 30.
  find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat <= v-dt
             no-lock no-error.
  run tablsb(summa,4,5,6).
end.






Procedure tablsb.

def input parameter summ1 as decimal format 'zzz,zzz,zzz,zz9.99'.
def input parameter str1 as int.
def input parameter str2 as int.
def input parameter str3 as int.

  
  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lneko'.
       v-ccode = txb.sub-cod.ccode.
                 
  if v-ccode ne '92' and txb.lon.crc = 2 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumnk = vsb2.sumnk + summa.
     vsb2.sumnkp = vsb2.sumnkp + summa * txb.ln%his.intrate / 100.
     
     if v-srok ge 0 and v-srok le 360 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumnk = vsb2.sumnk + summa.
        vsb2.sumnkp = vsb2.sumnkp + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok gt 360 then do:
        find first vsb2 where nn = str3 no-lock no-error.
        vsb2.sumnk = vsb2.sumnk + summa.
        vsb2.sumnkp = vsb2.sumnkp + summa * txb.ln%his.intrate / 100.
     end.
  end.
  
  if v-ccode ne '92' and txb.lon.crc = 3 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumdk = vsb2.sumdk + summa.
     vsb2.sumdkp = vsb2.sumdkp + summa * txb.ln%his.intrate / 100.
     
     if v-srok ge 0 and v-srok le 360 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumdk = vsb2.sumdk + summa.
        vsb2.sumdkp = vsb2.sumdkp + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok gt 360 then do:
        find first vsb2 where nn = str3 no-lock no-error.
        vsb2.sumdk = vsb2.sumdk + summa.
        vsb2.sumdkp = vsb2.sumdkp + summa * txb.ln%his.intrate / 100.
     end.
  end.
  
  if v-ccode ne '92' and txb.lon.crc > 3 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumvk = vsb2.sumvk + summa.
     vsb2.sumvkp = vsb2.sumvkp + summa * txb.ln%his.intrate / 100.
     
     if v-srok ge 0 and v-srok le 360 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumvk = vsb2.sumvk + summa.
        vsb2.sumvkp = vsb2.sumvkp + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok gt 360 then do:
        find first vsb2 where nn = str3 no-lock no-error.
        vsb2.sumvk = vsb2.sumvk + summa.
        vsb2.sumvkp = vsb2.sumvkp + summa * txb.ln%his.intrate / 100.
     end.
  end.
  
/************/

  if v-ccode = '92' and lon.crc = 2 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumnd = vsb2.sumnd + summa.
     vsb2.sumndp = vsb2.sumndp + summa * txb.ln%his.intrate / 100.
     
     if v-srok ge 0 and v-srok le 360 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumnd = vsb2.sumnd + summa.
        vsb2.sumndp = vsb2.sumndp + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok gt 360 then do:
        find first vsb2 where nn = str3 no-lock no-error.
        vsb2.sumnd = vsb2.sumnd + summa.
        vsb2.sumndp = vsb2.sumndp + summa * txb.ln%his.intrate / 100.
     end.
  end.
  
  if v-ccode = '92' and lon.crc = 3 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumdd = vsb2.sumdd + summa.
     vsb2.sumddp = vsb2.sumddp + summa * txb.ln%his.intrate / 100.
     
     if v-srok ge 0 and v-srok le 360 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumdd = vsb2.sumdd + summa.
        vsb2.sumddp = vsb2.sumddp + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok gt 360 then do:
        find first vsb2 where nn = str3 no-lock no-error.
        vsb2.sumdd = vsb2.sumdd + summa.
        vsb2.sumddp = vsb2.sumddp + summa * txb.ln%his.intrate / 100.
     end.
  end.
  
  if v-ccode = '92' and lon.crc > 3 then do:
     find first vsb2 where nn = str1 no-lock no-error.
     vsb2.sumvd = vsb2.sumvd + summa.
     vsb2.sumvdp = vsb2.sumvdp + summa * txb.ln%his.intrate / 100.
     
     if v-srok ge 0 and v-srok le 360 then do:
        find first vsb2 where nn = str2 no-lock no-error.
        vsb2.sumvd = vsb2.sumvd + summa.
        vsb2.sumvdp = vsb2.sumvdp + summa * txb.ln%his.intrate / 100.
     end.
     if v-srok gt 360 then do:
        find first vsb2 where nn = str3 no-lock no-error.
        vsb2.sumvd = vsb2.sumvd + summa.
        vsb2.sumvdp = vsb2.sumvdp + summa * txb.ln%his.intrate / 100.
     end.
  end.
  


end procedure.

