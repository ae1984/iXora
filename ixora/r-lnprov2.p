/* r-lnprov2.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет по динамике изменения провизий
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
        28/03/2005 madiyar
 * CHANGES
        04/04/2005 madiyar - исправил ошибку - отсекались кредиты с rdt внутри периода
        12/04/2005 madiyar - изменил формирование данных по физ.лицам
        15/09/2005 madiyar - автоматическое формирование списка групп кредитов юр. лиц
        02/05/2006 madiyar - стандартизовал вывод отчета (на случай появления новых филиалов)
*/

def input parameter dt1 as date.
def input parameter dt2 as date.

def var s-bank as char.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause.
  return.
end.
else s-bank = txb.sysc.chval.

def shared temp-table wrk_ur
    field bank    as   char
    field city    as   char
    field klname  as   char
    field cif     like txb.lon.cif
    field lon     like txb.lon.lon
    field crc     like txb.lon.crc
    field ost     as   deci extent 2
    field ost_kzt as   deci extent 2
    field pr      as   deci extent 2
    field prov    as   deci extent 2
    index idx is primary bank crc cif.

def shared temp-table wrk_fiz
    field bank     as   char
    field city     as   char
    field ost_kzt  as   deci extent 2
    field prov     as   deci extent 2
    field prov_inc as   deci
    field prov_dec as   deci
    index idx is primary bank.

def shared var rates1 as deci extent 20.
def shared var rates2 as deci extent 20.

def var bilance as deci extent 2.
def var v-city as char.

find first txb.cmp no-lock no-error.
if avail txb.cmp then v-city = entry(1,txb.cmp.addr[1]).

/* группы кредитов юридических лиц */
def var lst_ur as char init ''.
for each txb.longrp no-lock:
  if substr(string(txb.longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(txb.longrp.longrp).
  end.
end.

def var v-bal as deci extent 2.
def var i as integer.

hide message no-pause.
message " Обработка " + s-bank + " ".


for each txb.lon no-lock:
  
  if txb.lon.opnamt <= 0 then next.
  if txb.lon.rdt >= dt2 then next.
  
  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"1,7",no,txb.lon.crc,output bilance[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"1,7",no,txb.lon.crc,output bilance[2]).
  
  if bilance[1] + bilance[2] <= 0 then next.
  
  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"6",no,1,output v-bal[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"6",no,1,output v-bal[2]).
  v-bal[1] = - v-bal[1].
  v-bal[2] = - v-bal[2].
  
  if v-bal[1] + v-bal[2] <= 0 then next.
  
  find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
  
  if lookup(string(lon.grp),lst_ur) > 0 then do:
    create wrk_ur.
    wrk_ur.bank = s-bank.
    wrk_ur.city = v-city.
    wrk_ur.cif = txb.lon.cif.
    if avail txb.cif then wrk_ur.klname = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name). else wrk_ur.klname = "--unknown--".
    wrk_ur.lon = txb.lon.lon.
    wrk_ur.crc = txb.lon.crc.
    do i = 1 to 2: wrk_ur.ost[i] = bilance[i]. end.
    wrk_ur.ost_kzt[1] = bilance[1] * rates1[txb.lon.crc].
    wrk_ur.ost_kzt[2] = bilance[2] * rates2[txb.lon.crc].
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < dt1 no-lock no-error.
    if avail txb.lonhar then do:
      find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
      if avail txb.lonstat then wrk_ur.pr[1]= txb.lonstat.prc.
    end.
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < dt2 no-lock no-error.
    if avail txb.lonhar then do:
      find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
      if avail txb.lonstat then wrk_ur.pr[2] = txb.lonstat.prc.
    end.
    wrk_ur.prov[1] = v-bal[1].
    wrk_ur.prov[2] = v-bal[2].
  end.
  else do:
    if lon.grp = 90 or lon.grp = 92 then do:
      find first wrk_fiz where wrk_fiz.bank = "zzz" no-error.
      if not avail wrk_fiz then do:
        create wrk_fiz.
        wrk_fiz.bank = "zzz".
        wrk_fiz.city = v-city.
      end.
    end.
    else do:
      find first wrk_fiz where wrk_fiz.bank = s-bank no-error.
      if not avail wrk_fiz then do:
        create wrk_fiz.
        wrk_fiz.bank = s-bank.
        wrk_fiz.city = v-city.
      end.
    end.
    if v-bal[1] > 0 then do:
      wrk_fiz.ost_kzt[1] = wrk_fiz.ost_kzt[1] + bilance[1] * rates1[txb.lon.crc].
      wrk_fiz.prov[1] = wrk_fiz.prov[1] + v-bal[1].
    end.
    if v-bal[2] > 0 then do:
      wrk_fiz.ost_kzt[2] = wrk_fiz.ost_kzt[2] + bilance[2] * rates2[txb.lon.crc].
      wrk_fiz.prov[2] = wrk_fiz.prov[2] + v-bal[2].
    end.
    if v-bal[2] - v-bal[1] > 0 then wrk_fiz.prov_inc = wrk_fiz.prov_inc + v-bal[2] - v-bal[1].
    else wrk_fiz.prov_dec = wrk_fiz.prov_dec + v-bal[2] - v-bal[1].
  end.
  
end. /* for each txb.lon */

