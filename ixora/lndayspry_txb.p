/* lndayspry_txb.p
 * MODULE
        Кредитование
 * DESCRIPTION
        Дней просрочки на дату (с количеством дней макс. просрочки, допущенной за 12 месяцев до указанной даты)
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
        30/09/2009 madiyar - скопировал из lndayspry.p с поправкой на алиас базы
 * BASES
        BANK TXB
 * CHANGES
        15/10/2009 madiyar - при v-p=yes дни +1 даже если g-today
        19/05/2010 madiyar - подправил расчет
*/

def shared var g-today as date.

define input parameter v-lon like txb.lon.lon no-undo.
define input parameter v-dt as date no-undo.
define input parameter v-p as logical no-undo.
define output parameter v-days_od as integer no-undo.
define output parameter v-days_prc as integer no-undo.
define output parameter v-days_max as integer no-undo.

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
def var v-stdt as date no-undo.
def var dd as integer no-undo.

def var v-dt_cut as date no-undo.
if day(v-dt) = 29 and month(v-dt) = 2 then v-dt_cut = date(2,28,year(v-dt) - 1).
else v-dt_cut = date(month(v-dt),day(v-dt),year(v-dt) - 1).

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

for each txb.lonres where txb.lonres.lon = v-lon and txb.lonres.jdt <= v-cdt and txb.lonres.lev = 7 no-lock:
    create t-lonres.
    t-lonres.jdt = txb.lonres.jdt.
    t-lonres.dc = txb.lonres.dc.
    t-lonres.sum = txb.lonres.amt.
end.

if v-bal[1] > 0 then do:
  tempost = v-bal[1].
  for each t-lonres no-lock:
     if t-lonres.dc = 'D' then tempost = tempost - t-lonres.sum.
     else tempost = tempost + t-lonres.sum.
     if tempost <= 0 then do:
        v-days_od = v-dt - t-lonres.jdt.
        leave.
     end.
  end.
end.

if v-days_od > 0 and v-p then v-days_od = v-days_od + 1.
v-days_max = v-days_od.

if v-bal[1] > 0 then v-stdt = v-dt.
else v-stdt = ?.
tempost = v-bal[1].

for each t-lonres no-lock:
    if (v-stdt <> ?) and (v-stdt < v-dt_cut) then leave.
    if (v-stdt = ?) and (t-lonres.jdt < v-dt_cut) then leave.
    if t-lonres.dc = 'D' then tempost = tempost - t-lonres.sum.
    else do:
        if v-stdt = ? then v-stdt = t-lonres.jdt.
        tempost = tempost + t-lonres.sum.
    end.
    if tempost <= 0 then do:
        dd = v-stdt - t-lonres.jdt.
        if dd > v-days_max then v-days_max = dd.
        tempost = 0. v-stdt = ?.
        if t-lonres.jdt < v-dt_cut then leave.
    end.
end.

if (v-stdt <> ?) and (v-stdt < v-dt_cut) then do:
    find last t-lonres no-lock no-error.
    if avail t-lonres then do:
        dd = v-stdt - t-lonres.jdt.
        if dd > v-days_max then v-days_max = dd.
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
end.

if v-days_prc > 0 and v-p then v-days_prc = v-days_prc + 1.

if v-days_prc > v-days_max then v-days_max = v-days_prc.

if v-bal[2] > 0 then v-stdt = v-dt.
else v-stdt = ?.
tempost = v-bal[2].

for each t-lonres no-lock:
    if (v-stdt <> ?) and (v-stdt < v-dt_cut) then leave.
    if (v-stdt = ?) and (t-lonres.jdt < v-dt_cut) then leave.
    if t-lonres.dc = 'D' then tempost = tempost - t-lonres.sum.
    else do:
        if v-stdt = ? then v-stdt = t-lonres.jdt.
        tempost = tempost + t-lonres.sum.
    end.
    if tempost <= 0 then do:
        dd = v-stdt - t-lonres.jdt.
        if dd > v-days_max then v-days_max = dd.
        tempost = 0. v-stdt = ?.
        if t-lonres.jdt < v-dt_cut then leave.
    end.
end.

if (v-stdt <> ?) and (v-stdt < v-dt_cut) then do:
    find last t-lonres no-lock no-error.
    if avail t-lonres then do:
        dd = v-stdt - t-lonres.jdt.
        if dd > v-days_max then v-days_max = dd.
    end.
end.



