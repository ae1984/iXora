/* lnclerr2.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Выявление кредитов, по которым не была проставлена или неверная классификация
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
        03/06/2005 madiyar
 * CHANGES
        05/09/2005 madiyar - в отчет не выводилось наименование клиента, исправил
*/

def input parameter dat as date.
def input parameter dt1 as date.
def input parameter dt2 as date.

define shared temp-table wrk
  field cif like txb.cif.cif
  field name as char
  field lon like txb.lon.lon
  field bilance1 as deci
  field bilance2 as deci
  field sts as integer
  index idx is primary cif lon.

define temp-table wrk2
  field cif like txb.cif.cif
  index idx is primary cif.

def var v-skip as logi init yes.
def var p-cif like txb.cif.cif init ''.
def var v-sts as integer.
def var bilance_per as deci extent 2.
def var bilance_spis as deci extent 2.

for each txb.lon no-lock break by txb.lon.cif:
  
  if (p-cif = txb.lon.cif) and (not(v-skip)) then next.
  if txb.lon.opnamt = 0 then next.
  if txb.lon.rdt >= dat then next.
  
  /*
  if lookup(string(txb.lon.grp),lst_ur) > 0 then v-urfiz = 0.
  else v-urfiz = 1.
  */
  
  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"1,7,13,14",no,txb.lon.crc,output bilance_per[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"1,7,13,14",yes,txb.lon.crc,output bilance_per[2]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"13,14",no,txb.lon.crc,output bilance_spis[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"13,14",yes,txb.lon.crc,output bilance_spis[2]).
  
  /* проверка на случай если были выдача и погашение внутри отчетного месяца */
  find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and (txb.lnscg.stdat >= dt1 and txb.lnscg.stdat <= dt2) and txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0 no-lock no-error.
  
  if bilance_per[1] + bilance_per[2] + bilance_spis[1] + bilance_spis[2] <= 0 and not avail txb.lnscg then next.
  
  if p-cif <> txb.lon.cif then do:
    p-cif = txb.lon.cif.
    v-skip = yes.
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
    if avail txb.lonhar then v-sts = txb.lonhar.lonstat.
    else do:
      v-sts = -1.
      v-skip = no.
    end.
  end.
  else do:
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
    if avail txb.lonhar then do:
      if v-sts <> txb.lonhar.lonstat then v-skip = no.
    end.
    else v-skip = no.
  end.
  
  if not(v-skip) then do:
    create wrk2.
    wrk2.cif = txb.lon.cif.
  end.
  
end. /* for each lon */


for each wrk2 no-lock:
for each txb.lon where txb.lon.cif = wrk2.cif no-lock:
  
  if txb.lon.opnamt = 0 then next.
  if txb.lon.rdt >= dat then next.
  
  /*
  if lookup(string(txb.lon.grp),lst_ur) > 0 then v-urfiz = 0.
  else v-urfiz = 1.
  */
  
  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"1,7",no,txb.lon.crc,output bilance_per[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"1,7",yes,txb.lon.crc,output bilance_per[2]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"13,14",no,txb.lon.crc,output bilance_spis[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"13,14",yes,txb.lon.crc,output bilance_spis[2]).
  
  /* проверка на случай если были выдача и погашение внутри отчетного месяца */
  find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and (txb.lnscg.stdat >= dt1 and txb.lnscg.stdat <= dt2) and txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0 no-lock no-error.
  
  if bilance_per[1] + bilance_per[2] + bilance_spis[1] + bilance_spis[2] <= 0 and not avail txb.lnscg then next.
  
  create wrk.
  wrk.cif = txb.lon.cif.
  find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
  if avail txb.cif then wrk.name = trim(txb.cif.name).
  wrk.lon = txb.lon.lon.
  find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
  if avail txb.lonhar then wrk.sts = txb.lonhar.lonstat.
  else wrk.sts = -1.
  wrk.bilance1 = bilance_per[1].
  wrk.bilance2 = bilance_per[2].
  
end. /* for each lon */
end. /* for each wrk2 */


