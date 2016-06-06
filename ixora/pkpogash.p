/* pkpogash.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Погашения по кредитам средствами заемщиков
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        24/11/2009 galina
 * BASES
        BANK COMM TXB
 * CHANGES
        10/02/2010 galina - добавила дни просрчки по ОД и по %%
        12/02/2010 galina - добавила остаток ОД
*/

def input parameter v-dt1 as date.
def input parameter v-dt2 as date.
def var v-sumplat1 as deci no-undo.
def var v-sumplat2 as deci no-undo.
def var v-sumplat9 as deci no-undo.
def var v-sumplat16 as deci no-undo.
def var v-sumplat7 as deci no-undo.
def var v-sumplatcom as deci no-undo.
def var v-bank as char no-undo.
def buffer b-lon for txb.lon.
def buffer b-jl for txb.jl.
def var bilans as deci no-undo.
def var v-sumaaa  as deci no-undo.
def shared var g-today as date.
def var v-day_prc as integer no-undo.
def var v-day_od as integer no-undo.
def var v-dat7 as date no-undo.
def var v-dat9 as date no-undo.
def var v-datod as date no-undo.

def shared temp-table pk-lnpog
   field bank as char
   field cif like txb.cif.cif
   field name as char
   field crc as integer
   field rdt as date
   field expdt as date
   field daypog as integer
   field opnamt as deci
   field sum1 as deci /*сумма оплаты ОД*/
   field sum2 as deci /*сумма оплаты %% */
   field sum7 as deci /*сумма оплаты просроченного ОД*/
   field sum9 as deci /*сумма оплаты просроченных %% 9 и 4*/
   field sum16 as deci /*сумма оплаты пени 5 и 16*/
   field sumcom as deci /*сумма оплаты комиссии*/
   field sumaaa  as deci
   field day_od as integer
   field day_prc as integer
   field sumod as decimal
   
   index ind1 is primary bank crc.

find first txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
if avail txb.sysc then v-bank = txb.sysc.chval.

for each txb.lon where txb.lon.grp = 90 or txb.lon.grp = 92 no-lock:
  run lonbal_txb("lon",txb.lon.lon,v-dt1,"1,7,2,9,16,4,5",no,output bilans).
  if bilans <= 0 then next.
  v-sumplat1 = 0.
  v-sumplat2 = 0.
  v-sumplat9 = 0.
  v-sumplat16 = 0.
  v-sumplat7 = 0.
  v-sumplatcom = 0.
  v-sumaaa = 0.
  for each txb.lonres where txb.lonres.lon = txb.lon.lon  and (txb.lonres.lev = 1 or txb.lonres.lev = 2 or txb.lonres.lev = 7 or txb.lonres.lev = 9 or txb.lonres.lev = 16) and txb.lonres.dc = 'C' and txb.lonres.jdt >= v-dt1 and txb.lonres.jdt <= v-dt2  no-lock:
      find first b-lon where b-lon.cif = txb.lon.cif and b-lon.lon <> txb.lon.lon and b-lon.rdt = txb.lonres.jdt no-lock no-error.
      if avail b-lon then next.
      if (txb.lon.crc = 1) or (txb.lonres.lev <> 16) then find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.acc = txb.lon.aaa and txb.jl.dc = 'D' no-lock no-error.
      else do:
          /* для учета погашения пени по валютным ссудным счетам */
          find first pkanketa where pkanketa.bank = v-bank and pkanketa.lon = txb.lon.lon no-lock no-error.
          if avail pkanketa then
              find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.acc = pkanketa.aaa and txb.jl.dc = 'D' no-lock no-error.
      end.
      if not avail txb.jl then next.
      if txb.lonres.lev = 1 then v-sumplat1 = v-sumplat1 + txb.lonres.amt.
      if txb.lonres.lev = 2 then v-sumplat2 = v-sumplat2 + txb.lonres.amt.
      if txb.lonres.lev = 7 then v-sumplat7 = v-sumplat7 + txb.lonres.amt.
      if txb.lonres.lev = 9 then v-sumplat9 = v-sumplat9 + txb.lonres.amt.
      if txb.lonres.lev = 16 then v-sumplat16 = v-sumplat16 + txb.lonres.amt.
  end.

  for each txb.jl where /*txb.jl.sub = 'cif' and*/ txb.jl.acc = txb.lon.aaa and txb.jl.dc = 'D' and txb.jl.jdt >= v-dt1 and txb.jl.jdt <= v-dt2  no-lock:
    find first txb.jh where txb.jh.jh = jl.jh no-lock no-error.
    if not avail txb.jh then next.
    if txb.jh.party begins 'Storn' then next.
    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
    if not avail b-jl then next.
    if b-jl.gl = 460712 then do:
      find first b-lon where b-lon.cif = txb.lon.cif and b-lon.lon <> txb.lon.lon and b-lon.rdt = b-jl.jdt no-lock no-error.
      if avail b-lon then next.
      v-sumplatcom = v-sumplatcom + txb.jl.dam.
    end.
  end.
  for each txb.jl where txb.jl.acc = txb.lon.aaa and txb.jl.jdt >= v-dt1 and txb.jl.jdt <= v-dt2 and txb.jl.lev = 1  and txb.jl.dc = 'C' no-lock:
     find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 and b-jl.sub <> 'LON' no-lock no-error.
     if avail b-jl then do:
       find first txb.aaa where txb.aaa.aaa = b-jl.acc no-lock no-error.
       if (avail txb.aaa and txb.aaa.lgr <> '236' and txb.aaa.lgr <> '237') or not avail txb.aaa then v-sumaaa = v-sumaaa + b-jl.dam.
     end.
  end.


 if v-sumplat1 + v-sumplat2 + v-sumplat9 + v-sumplat16 + v-sumplat7 + v-sumplatcom + v-sumaaa > 0 then do:
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if not avail txb.cif then next.
    /*какие дни и на какую дату?*/
    
    create pk-lnpog.
    assign pk-lnpog.cif = txb.lon.cif
     pk-lnpog.name = txb.cif.name
     pk-lnpog.crc = txb.lon.crc
     pk-lnpog.rdt = txb.lon.rdt
     pk-lnpog.expdt = txb.lon.duedt
     pk-lnpog.daypog = txb.lon.day
     pk-lnpog.opnamt = txb.lon.opnamt
     pk-lnpog.sum1 = v-sumplat1
     pk-lnpog.sum2 = v-sumplat2
     pk-lnpog.sum7 = v-sumplat7
     pk-lnpog.sum9 = v-sumplat9
     pk-lnpog.sum16 = v-sumplat16
     pk-lnpog.sumcom = v-sumplatcom
     pk-lnpog.bank = v-bank
     pk-lnpog.sumaaa = v-sumaaa.
     
    v-datod = g-today.  
    find last txb.lonres where txb.lonres.lon = txb.lon.lon and (txb.lonres.lev = 7 or txb.lonres.lev = 1) and txb.lonres.dc = 'C' and txb.lonres.jdt >= v-dt1 and txb.lonres.jdt <= v-dt2  no-lock no-error. 
    if avail txb.lonres then do:
      find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.acc = txb.lon.aaa and txb.jl.dc = 'D' no-lock no-error.
      if avail txb.jl then  v-datod = txb.lonres.jdt.
    end.  
    run lonbalcrc_txb('lon',txb.lon.lon,v-datod,"1,7",no,txb.lon.crc,output pk-lnpog.sumod).

     
    v-dat7 = g-today. 
    v-dat9 = g-today.
    
    find last txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 7 and txb.lonres.dc = 'C' and txb.lonres.jdt >= v-dt1 and txb.lonres.jdt <= v-dt2  no-lock no-error. 
    if avail txb.lonres then do:
      find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.acc = txb.lon.aaa and txb.jl.dc = 'D' no-lock no-error.
      if avail txb.jl then  v-dat7 = txb.lonres.jdt.
    end.  
    
    find last txb.lonres where txb.lonres.lon = txb.lon.lon  and txb.lonres.lev = 9 and txb.lonres.dc = 'C' and txb.lonres.jdt >= v-dt1 and txb.lonres.jdt <= v-dt2  no-lock no-error. 
    if avail txb.lonres then do:
      find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.acc = txb.lon.aaa and txb.jl.dc = 'D' no-lock no-error.
      if avail txb.jl then v-dat9 = txb.lonres.jdt.
    end.  

    run lndayspr_txb(txb.lon.lon,v-dat7,no,output pk-lnpog.day_od,output v-day_prc).
    run lndayspr_txb(txb.lon.lon,v-dat9,no,output v-day_od,output pk-lnpog.day_prc).
 end.

end.
