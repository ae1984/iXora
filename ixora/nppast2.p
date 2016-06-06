/* nppast2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Отчет - "Начисленное и не полученное вознаграждение"
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
        28/02/2005 madiar - вынес расчетную часть из nppast.p
 * CHANGES
        27/07/2005 madiar - % текущего года выводятся в поквартальной разбивке
        15/09/2005 madiar - автоматическое формирование списка групп кредитов юр. лиц
*/

def input parameter dat as date.

def shared var num_col as integer.
def shared var rates as deci extent 2.
def shared var base_year as integer.
def shared var dates as date extent 10.

define var s-ourbank as char.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

def var nach_by_year as decimal extent 10.
def var pogasheno as decimal.
def var prc as decimal.
def var i as integer.
def var dn1 as integer.
def var dn2 as decimal.
def var cur_prc as decimal.
def var sum_prc_all as deci.
def var mesa as integer.

def var todate as date.

/* группы кредитов юридических лиц */
def var lst_ur as char init ''.
for each txb.longrp no-lock:
  if substr(string(txb.longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(txb.longrp.longrp).
  end.
end.

def shared temp-table wrk
  field bank as char
  field urfiz as char
  field cif like txb.cif.cif
  field name as char
  field lon like txb.lon.lon
  field opnamt as deci
  field crc as char
  field prc as deci extent 10
  field sum_prc as deci
  field sum_prc_kzt as deci
  field cur_prc as deci
  field cur_prc_kzt as deci
  index mind bank urfiz crc cif.


mesa = 0.
for each txb.lon no-lock:
  
  if txb.lon.opnamt = 0 then next.
  
  /* if dat = g-today then do:
    find trxbal where trxbal.acc = lon.lon and trxbal.subled = 'lon' and trxbal.level = 2 no-lock no-error.
    if avail trxbal then cur_prc = trxbal.dam - trxbal.cam.
    find trxbal where trxbal.acc = lon.lon and trxbal.subled = 'lon' and trxbal.level = 9 no-lock no-error.
    if avail trxbal then cur_prc = cur_prc + trxbal.dam - trxbal.cam.
  end.
  else do: */
    cur_prc = 0.
    find last txb.histrxbal where txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.subled = 'lon' and txb.histrxbal.level = 2
                        and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt <= dat no-lock no-error.
    if avail txb.histrxbal then cur_prc = txb.histrxbal.dam - txb.histrxbal.cam.
    find last txb.histrxbal where txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.subled = 'lon' and txb.histrxbal.level = 9
                        and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt <= dat no-lock no-error.
    if avail txb.histrxbal then cur_prc = cur_prc + txb.histrxbal.dam - txb.histrxbal.cam.
 /* end. */
  
  if cur_prc <= 0 then next.
  
  nach_by_year = 0.
  pogasheno = 0.
  
  for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.fpn = 0 and txb.lnsci.flp > 0 and txb.lnsci.idat <= dat no-lock:
    pogasheno = pogasheno + txb.lnsci.paid-iv.
  end.
  
  for each txb.acr where txb.acr.lon = txb.lon.lon and txb.acr.fdt <= dat no-lock:
    if txb.acr.tdt >= dat then todate = dat. else todate = txb.acr.tdt.
    run day-360(txb.acr.fdt,todate,txb.lon.basedy,output dn1,output dn2).
    if txb.lon.plan = 3 or txb.lon.plan = 4 then prc = round(txb.lon.opnamt * txb.acr.rate * dn1 / txb.lon.basedy / 100, 2).
    else prc = round(txb.acr.prn * txb.acr.rate * dn1 / txb.lon.basedy / 100, 2).
    do i = 1 to num_col:
      if todate < dates[i] then nach_by_year[i] = nach_by_year[i] + prc.
      /*
      if year(todate) <= base_year + i then nach_by_year[i] = nach_by_year[i] + prc.
      */
    end.
  end.
  
  /* + то, что начислено вручную */
  for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 2 and txb.lonres.dc = 'D' and txb.lonres.jdt <= dat no-lock:
    do i = 1 to num_col:
      if txb.lonres.jdt <= dates[i] then nach_by_year[i] = nach_by_year[i] + txb.lonres.amt1.
      /*
      if year(txb.lonres.jdt) <= base_year + i then nach_by_year[i] = nach_by_year[i] + txb.lonres.amt1.
      */
    end.
  end.
  
  /* коррекция - сверяем со 2 уровнем */
  if nach_by_year[num_col] - pogasheno > cur_prc then
    do i = 1 to num_col:
      nach_by_year[i] = nach_by_year[i] - ((nach_by_year[num_col] - pogasheno) - cur_prc).
      if nach_by_year[i] < 0 then nach_by_year[i] = 0.
    end.
  
  do i = 1 to num_col:
    if nach_by_year[i] - pogasheno > 0 then nach_by_year[i] = nach_by_year[i] - pogasheno.
    else nach_by_year[i] = 0.
  end.
  
  do i = num_col to 2 by -1:
    nach_by_year[i] = nach_by_year[i] - nach_by_year[i - 1].
  end.
  
  if cur_prc > 0 then do:
    find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    find txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
    create wrk.
    wrk.bank = s-ourbank.
    /*
    find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock.
    wrk.urfiz = sub-cod.ccode.
    */
    if lookup(trim(string(txb.lon.grp)),lst_ur) > 0 then wrk.urfiz = '0'. else wrk.urfiz = '1'.
    wrk.cif = txb.lon.cif.
    if avail txb.cif then wrk.name = txb.cif.name.
    wrk.lon = txb.lon.lon.
    wrk.opnamt = txb.lon.opnamt.
    wrk.crc = txb.crc.code.
    do i = 1 to num_col:
      wrk.prc[i] = nach_by_year[i].
      wrk.sum_prc = wrk.sum_prc + nach_by_year[i].
    end.
    wrk.cur_prc = cur_prc.
    case txb.lon.crc:
      when 1 then do: wrk.sum_prc_kzt = wrk.sum_prc. wrk.cur_prc_kzt = wrk.cur_prc. end.
      when 2 then do: wrk.sum_prc_kzt = wrk.sum_prc * rates[1]. wrk.cur_prc_kzt = wrk.cur_prc * rates[1]. end.
      when 11 then do: wrk.sum_prc_kzt = wrk.sum_prc * rates[2]. wrk.cur_prc_kzt = wrk.cur_prc * rates[2]. end.
    end.
    
    mesa = mesa + 1.
    if (mesa mod 20) = 0 then do:
       hide message no-pause.
       message ' ' + s-ourbank + ' - обработано ' + string(mesa) + ' кредитов '.
    end.
    
  end.
  
end. /* for each txb.lon */


