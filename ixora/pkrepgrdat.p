/* pkrepgrdat.p
 * MODULE
        ПотребКредиты
 * DESCRIPTION
        Кредиты, по которым наступил срок погашения на указанную дату
        Сборка данных во временную таблицу
 * RUN
        
 * CALLER
        pkrepgr.p, pksvod1.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        25.01.2004 nadejda - вынесла сбор данных в отдельную программу для использования в сводном отчете 
 * CHANGES
        30.01.2003 nadejda - добавлены сведения об остатке на тек.счете на дату отчета, на 14-00 и 20-00 даты отчета
        13.02.2004 nadejda - добавлены суммы просрочек и пеня
        24.02.2004 nadejda - добавлена предоплата
        19.04.2004 nadejda - добавлены фактически начисленные проценты
        13/07/2004 madiar  - в отчет добавлена дата выдачи кредита
        31/08/2006 Natalya D. - оптимизация: одинаковые повторяющиеся запросы вывела в один.
*/

{global.i}

def input parameter p-dt as date.

def shared temp-table  wrk
    field lon    like lon.lon
    field aaa    like aaa.aaa
    field cif    like lon.cif
    field name   like cif.name
    field rdt    like lon.rdt
    field duedt  like lon.rdt
    field opnamt like lon.opnamt
    field balans like lon.opnamt
    field balans1 like lon.opnamt
    field balans2 like lon.opnamt
    field balacc like lon.opnamt
    field baltim like lon.opnamt
    field baleven like lon.opnamt
    field crc    like crc.code
    field prem   like lon.prem
    field dolg1  as decimal
    field dolg2  as decimal
    field pena   as decimal
    field predopl as decimal
    field ballev2 as decimal
    index main opnamt desc
    index bal balans balans1.

def var tempgrp as int  no-undo.
def var bilance   as decimal format "->,>>>,>>>,>>9.99"  no-undo.
def var v-baltim as decimal  no-undo.
def var v-balans as decimal  no-undo.
def var v-balans1 as decimal  no-undo.

/* 14-00 - время отсечки для определения, сколько было клиентов без денег на счете на день погашения */
def var v-tim as integer init 50400. 
def var v-timeven as integer init 72000. 
find sysc where sysc.sysc = "pktim" no-lock no-error.
if avail sysc then v-tim = sysc.inval.
{comm-txb.i}
define new shared var s-ourbank as char.
s-ourbank = comm-txb().


for each pkanketa no-lock where pkanketa.bank = s-ourbank :

  if pkanketa.lon = "" then next.

  find first lon where lon.lon = pkanketa.lon no-lock no-error.

  if lon.dam[1] = 0   then next.

  run atl-dat1 (lon.lon, p-dt, 3, output bilance). /* остаток  ОД*/  

  if bilance = 0 then next.

  v-balans = 0.
  find last lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and lnsch.fpn = 0 
     and lnsch.f0 > 0 and lnsch.stdat = p-dt no-lock no-error.
  if avail lnsch then v-balans = lnsch.stval.

  v-balans1 = 0.
  find last lnsci where  lnsci.lni =  lon.lon and  lnsci.idat = p-dt and  lnsci.f0 > 0 
           no-lock no-error.
  if avail  lnsci then v-balans1 = lnsci.iv-sc. 

  /* показываем только тех, у кого этот день по графику */  
  if v-balans + v-balans1 = 0 then next.


  find  cif where  cif.cif =  lon.cif no-lock no-error.
  find  crc where  crc.crc =  lon.crc no-lock no-error.

  create wrk.
  assign wrk.lon = lon.lon
         wrk.cif = lon.cif
         wrk.name = cif.name
         wrk.rdt = lon.rdt
         wrk.opnamt = bilance
         wrk.crc = crc.code
         wrk.prem = lon.prem
         wrk.aaa = if pkanketa.crc = 1 then pkanketa.aaa else pkanketa.aaaval
         wrk.balans = v-balans
         wrk.balans1 = v-balans1.
          

  /* if p-dt ge g-today then do:
      find last aaa where aaa.aaa = pkanketa.aaa no-lock no-error.
      if avail aaa then wrk.balans2 = aaa.cr[1] - aaa.dr[1].
   end.
   else do:
      find last aab where aab.aaa = pkanketa.aaa and aab.fdt <= p-dt no-lock no-error.
      if avail aab then wrk.balans2 = aab.bal.
   end. 
  */

  /* найти долги и штрафы */
  for each trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon no-lock:
    if trxbal.lev = 2 then wrk.ballev2 = wrk.ballev2 + trxbal.dam - trxbal.cam.
    if trxbal.lev = 7 then wrk.dolg1 = wrk.dolg1 + trxbal.dam - trxbal.cam.
    if trxbal.lev = 9 then wrk.dolg2 = wrk.dolg2 + trxbal.dam - trxbal.cam.
    if trxbal.lev = 16 then wrk.pena = wrk.pena + trxbal.dam - trxbal.cam.
    if trxbal.lev = 10 then wrk.predopl = wrk.predopl + trxbal.cam - trxbal.dam.
  end.

  if pkanketa.crc = 1 then
    find aaa where aaa.aaa = pkanketa.aaa no-lock no-error.
  else 
    find aaa where aaa.aaa = pkanketa.aaaval no-lock no-error.
  if avail aaa then do:
    wrk.balans2 = aaa.cr[1] - aaa.dr[1].

    wrk.balacc = wrk.balans2.
    find last aab where aab.aaa = aaa.aaa and aab.fdt < p-dt no-lock no-error.
    if avail aab then wrk.balacc = aab.bal.
                 else wrk.balacc = 0.

    wrk.baltim = wrk.balacc.
    wrk.baleven = wrk.balacc.

    if p-dt < g-today then do:
      for each jl where jl.jdt = p-dt and jl.acc = aaa.aaa no-lock:
        if jl.lev <> 1 then next.
        find jh where jh.jh = jl.jh no-lock no-error.
        if (jh.whn = p-dt and jh.tim < v-tim) then wrk.baltim = wrk.baltim + jl.cam - jl.dam.
        if (jh.whn = p-dt and jh.tim < v-timeven) then wrk.baleven = wrk.baleven + jl.cam - jl.dam.
      end.
    end.
    else do:
      for each jl where jl.jdt = g-today and jl.acc = aaa.aaa no-lock:
        if jl.lev <> 1 then next.
        find jh where jh.jh = jl.jh no-lock no-error.
        if (jh.whn = g-today and jh.tim < v-tim) then wrk.baltim = wrk.baltim + jl.cam - jl.dam.
        if (jh.whn = g-today and jh.tim < v-timeven) then wrk.baleven = wrk.baleven + jl.cam - jl.dam.
      end.
    end.

    /*wrk.baleven = wrk.balacc.
    if p-dt < g-today then do:
      for each jl where jl.jdt = p-dt and jl.acc = aaa.aaa no-lock:
        if jl.lev <> 1 then next.
        find jh where jh.jh = jl.jh no-lock no-error.
        if (jh.whn = p-dt and jh.tim < v-timeven) then wrk.baleven = wrk.baleven + jl.cam - jl.dam.
      end.
    end.
    else do:
      for each jl where jl.jdt = g-today and jl.acc = aaa.aaa no-lock:
        if jl.lev <> 1 then next.
        find jh where jh.jh = jl.jh no-lock no-error.
        if (jh.whn = g-today and jh.tim < v-timeven) then wrk.baleven = wrk.baleven + jl.cam - jl.dam.
      end.
    end.*/

  end.
end.                       
