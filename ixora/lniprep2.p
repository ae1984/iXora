/* lniprep2.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Консолидированный отчет по ипотечным займам
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
        13/09/2006 madiyar
 * BASES
        bank, comm, txb
 * CHANGES
*/

def input parameter dt as date no-undo.

define shared var v-od as deci extent 6.
define shared var v-prc as deci extent 6.
define shared var v-prov as deci extent 6.
define shared var v-rates as deci extent 20.

def var v-bal as deci no-undo.
def var v-nprc as deci no-undo.
def var v-nprov as deci no-undo.
def var v-obesp as deci no-undo.
def var v-ratio as deci no-undo.

find first txb.cmp no-lock no-error.
hide message no-pause.
message " Обработка " + txb.cmp.name.

for each txb.lon where txb.lon.grp = 27 or txb.lon.grp = 67 no-lock:
  
  if txb.lon.opnamt <= 0 then next.
  
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"1,7",yes,txb.lon.crc,output v-bal).
  if v-bal <= 0 then next. else v-bal = v-bal * v-rates[txb.lon.crc].
  
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"2,9",yes,txb.lon.crc,output v-nprc).
  v-nprc = v-nprc * v-rates[txb.lon.crc].
  
  run lonbalcrc_txb('lon',txb.lon.lon,dt,"3,6",yes,1,output v-nprov).
  v-nprov = - v-nprov.
  
  v-obesp = 0.
  for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
    v-obesp = v-obesp + txb.lonsec1.secamt * v-rates[txb.lonsec1.crc].
  end.
  
  find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
  if avail loncon and loncon.lcnt matches "*ГП*" then do:
    v-od[5] = v-od[5] + v-bal.
    v-prc[5] = v-prc[5] + v-nprc.
    v-prov[5] = v-prov[5] + v-nprov.
    next.
  end.
  
  v-ratio = v-bal / v-obesp * 100.
  
  if v-ratio <= 50 then do:
    v-od[1] = v-od[1] + v-bal.
    v-prc[1] = v-prc[1] + v-nprc.
    v-prov[1] = v-prov[1] + v-nprov.
  end.
  else
  if v-ratio <= 60 then do:
    v-od[2] = v-od[2] + v-bal.
    v-prc[2] = v-prc[2] + v-nprc.
    v-prov[2] = v-prov[2] + v-nprov.
  end.
  else
  if v-ratio <= 70 then do:
    v-od[3] = v-od[3] + v-bal.
    v-prc[3] = v-prc[3] + v-nprc.
    v-prov[3] = v-prov[3] + v-nprov.
  end.
  else
  if v-ratio <= 85 then do:
    v-od[4] = v-od[4] + v-bal.
    v-prc[4] = v-prc[4] + v-nprc.
    v-prov[4] = v-prov[4] + v-nprov.
  end.
  else do: /* прочие */
    v-od[6] = v-od[6] + v-bal.
    v-prc[6] = v-prc[6] + v-nprc.
    v-prov[6] = v-prov[6] + v-nprov.
  end.
  
end.


