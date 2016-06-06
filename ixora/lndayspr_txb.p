/* lndayspr_txb.p
 * MODULE
        Кредитование
 * DESCRIPTION
        Дней просрочки на дату
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
        01/03/2006 madiyar - скопировал из lndayspr.p с поправкой на алиас базы
 * BASES
        BANK TXB
 * CHANGES
        17/03/2006 madiyar - обработка случая, когда % на просрочку не переносились, но 9 уровень не пустой (начисление на 7)
        07/09/2009 madiyar - подправил расчет дней просрочки
        15/10/2009 madiyar - при v-p=yes дни +1 даже если g-today
*/

def shared var g-today as date.

define input parameter v-lon like txb.lon.lon no-undo.
define input parameter v-dt as date no-undo.
define input parameter v-p as logical no-undo.
define output parameter v-days_od as integer no-undo.
define output parameter v-days_prc as integer no-undo.

v-days_od = 0.
v-days_prc = 0.

find first txb.lon where txb.lon.lon = v-lon no-lock no-error.
if not avail txb.lon then return.

if v-dt > g-today then return.

def temp-table t-lonres no-undo
  field jdt as date
  field dc as char
  field sum as deci
  index idx is primary jdt descending.

def var v-bal as deci no-undo extent 2.
def var tempost as deci no-undo.
def var v-cdt as date no-undo.
def var v-hisdt as date no-undo.

if v-p then do:
  run lonbalcrc_txb('lon',v-lon,v-dt,"7",yes,txb.lon.crc,output v-bal[1]).
  run lonbalcrc_txb('lon',v-lon,v-dt,"9",yes,txb.lon.crc,output v-bal[2]).
  v-cdt = v-dt.
end.
else do:
  run lonbalcrc_txb('lon',v-lon,v-dt,"7",no,txb.lon.crc,output v-bal[1]).
  run lonbalcrc_txb('lon',v-lon,v-dt,"9",no,txb.lon.crc,output v-bal[2]).
  v-cdt = v-dt - 1.
end.

if v-bal[1] > 0 then do:
  for each txb.lonres where txb.lonres.lon = v-lon and txb.lonres.jdt <= v-cdt and txb.lonres.lev = 7 no-lock:
     create t-lonres.
     t-lonres.jdt = txb.lonres.jdt.
     t-lonres.dc = txb.lonres.dc.
     t-lonres.sum = txb.lonres.amt.
  end.
  tempost = v-bal[1].
  for each t-lonres no-lock:
     if t-lonres.dc = 'D' then tempost = tempost - t-lonres.sum.
     else tempost = tempost + t-lonres.sum.
     if tempost <= 0 then do:
        v-days_od = v-dt - t-lonres.jdt.
        leave.
     end.
  end.
  if v-days_od > 0 then do:
    if v-p then v-days_od = v-days_od + 1.
  end.
end.

if v-bal[2] > 0 then do:
  for each t-lonres: delete t-lonres. end.
  for each txb.lonres where txb.lonres.lon = v-lon and txb.lonres.jdt <= v-cdt and txb.lonres.lev = 9 no-lock:
     create t-lonres.
     t-lonres.jdt = txb.lonres.jdt.
     t-lonres.dc = txb.lonres.dc.
     t-lonres.sum = txb.lonres.amt.
  end.
  tempost = v-bal[2].
  for each t-lonres no-lock:
     if t-lonres.dc = 'D' then tempost = tempost - t-lonres.sum.
     else tempost = tempost + t-lonres.sum.
     if tempost <= 0 then do:
        v-days_prc = v-dt - t-lonres.jdt.
        leave.
     end.
  end.
  if v-days_prc = 0 then do:
    find last txb.histrxbal where txb.histrxbal.subled = "lon" and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 9
                            and txb.histrxbal.dt <= v-cdt and txb.histrxbal.dam - txb.histrxbal.cam <= 0 no-lock no-error.
    if avail txb.histrxbal then v-hisdt = txb.histrxbal.dt.
    else v-hisdt = 01/01/1000.
    find first txb.histrxbal where txb.histrxbal.subled = "lon" and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 9
                             and txb.histrxbal.dt > v-hisdt no-lock no-error.
    if avail txb.histrxbal then v-days_prc = v-dt - txb.histrxbal.dt.
  end.
  if v-days_prc > 0 then do:
    if v-p then v-days_prc = v-days_prc + 1.
  end.
end.

