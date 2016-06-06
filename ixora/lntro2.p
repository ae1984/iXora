/* lntro2.p
 * MODULE
        Кредитование
 * DESCRIPTION
        Отчет по проблемным и условно-проблемным кредитам
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
        31/10/2005 madiyar - вынес заполнение временной таблицы из lntro.p
 * BASES
        bank,txb
 * CHANGES
        17/01/2006 madiyar - кредитные линии показывать даже если ОД = 0
        06/05/2006 madiyar - подправил расчет задолженности
*/

def input parameter dat as date.
def shared var g-today as date.

/* группы кредитов юридических лиц */
def var lst_ur as char init ''.
for each txb.longrp no-lock:
  if substr(string(txb.longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(txb.longrp.longrp).
  end.
end.

define shared temp-table wrk
  field cif like txb.cif.cif
  field clname as char
  field lon like txb.lon.lon
  field tro as char
  field crc as integer
  field rdt as date
  field duedt as date
  field prem as deci
  field opnamt as deci
  field opnamt_kzt as deci
  field od as deci
  field od_kzt as deci
  field prc_kzt as deci
  field com_kzt as deci
  field prosr_kzt as deci
  field nprolong as integer
  field penalty as deci
  field dolg_kzt as deci
  field sts as deci
  field prov as deci
  field zalog_kzt as deci
  field zalog_des as char
  index idx is primary tro cif lon.


def var bilance as deci.
def var v-bal as deci.
def var itog as deci extent 9.
def var usrnm as char.
def var coun as integer.

def shared var rates as deci extent 20.

for each txb.lon no-lock:
  
  if lookup(string(txb.lon.grp),lst_ur) = 0 then next.
  if txb.lon.opnamt <= 0 then next.
  
  find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = "LON" and txb.sub-cod.d-cod = "lntro" no-lock no-error.
  if not avail txb.sub-cod or txb.sub-cod.ccode = 'msc' then next.
  else do:
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"1,7,13",no,txb.lon.crc,output bilance).

    if lon.gua <> "CL" then if bilance <= 0 then next.
    else if lon.duedt < g-today and bilance <= 0 then next.

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    create wrk.
    wrk.cif = txb.lon.cif.
    wrk.clname = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
    wrk.lon = txb.lon.lon.
    wrk.tro = txb.sub-cod.ccode.
    wrk.crc = txb.lon.crc.
    wrk.rdt = txb.lon.rdt.
    wrk.duedt = txb.lon.duedt.
    wrk.prem = txb.lon.prem.
    wrk.opnamt = txb.lon.opnamt.
    wrk.opnamt_kzt = txb.lon.opnamt * rates[txb.lon.crc].
    wrk.od = bilance.
    wrk.od_kzt = bilance * rates[txb.lon.crc].
    
    /*
    run lonbalcrc('lon',lon.lon,dat,"11",no,lon.crc,output wrk.prc_kzt).
    wrk.prc_kzt = - wrk.prc_kzt.
    */
    
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"25,28,29",no,txb.lon.crc,output v-bal).
    wrk.com_kzt = wrk.com_kzt * rates[txb.lon.crc].
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"27",no,1,output v-bal).
    wrk.com_kzt = wrk.com_kzt + v-bal.
    
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"7,9,13,14",no,txb.lon.crc,output v-bal).
    wrk.prosr_kzt = v-bal * rates[txb.lon.crc].
    
    if txb.lon.ddt[5] <> ? then wrk.nprolong = 1.
    if txb.lon.cdt[5] <> ? then wrk.nprolong = 2.
    
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"16,30",no,1,output wrk.penalty).
    
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"2,9,14",no,txb.lon.crc,output v-bal).
    wrk.prc_kzt = v-bal * rates[txb.lon.crc].
    wrk.dolg_kzt = (bilance + v-bal) * rates[txb.lon.crc] + wrk.penalty.
    
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < dat no-lock no-error.
    find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    if avail txb.lonstat then wrk.sts = txb.lonstat.prc.
    
    run lonbalcrc_txb('lon',txb.lon.lon,dat,"3,6",no,1,output wrk.prov).
    wrk.prov = - wrk.prov.
    
    for each txb.crc no-lock:
      run lonbalcrc_txb('lon',txb.lon.lon,dat,"19",no,txb.crc.crc,output v-bal).
      if v-bal > 0 then wrk.zalog_kzt = wrk.zalog_kzt + v-bal * rates[txb.crc.crc].
    end.
    
    for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
      find first txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
      /*wrk.zalog_kzt = wrk.zalog_kzt + lonsec1.secamt * rates[lon.crc].*/
      if trim(wrk.zalog_des) <> '' then wrk.zalog_des = wrk.zalog_des + ','.
      wrk.zalog_des = wrk.zalog_des + txb.lonsec.des1.
    end.
    
  end.
  
end. /* for each lon */
