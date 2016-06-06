/* lndaysprf_txb.p
 * MODULE
        Кредитование
 * DESCRIPTION
        Фактических дней просрочки на дату (т.е. не учитываем переносы графиков)
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
        01/03/2006 madiyar - скопировал из lndayspr_txb.p с изменениями
 * BASES
        BANK COMM TXB
 * CHANGES
        07/09/2009 madiyar - подправил расчет дней просрочки
        15/10/2009 madiyar - при v-p=yes дни +1 даже если g-today
        28/10/2009 madiyar - если дата с v-till попадает на выходной - берем следующий рабочий день
        28/10/2009 madiyar - учет кредитов сдвинутых, но выпавших на просрочку в тот же день
        24/11/2009 madiyar - дописал пропущенные алиасы баз
*/

def shared var g-today as date.

define input parameter v-lon like txb.lon.lon no-undo.
define input parameter v-dt as date no-undo.
define input parameter v-p as logical no-undo.
define output parameter v-days_od as integer no-undo.
define output parameter v-days_prc as integer no-undo.

def var v-till as integer no-undo.
v-till = 4.

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

def buffer bt-lonres for t-lonres.

function restructured returns logical (input sublev as char, input subdt as date, input subdc as char, input subsum as deci).
    def var v-log as logical no-undo.
    v-log = no.
    /* Проверим, попадает ли граница в тот месяц на выходной. Если попадает - берем следующий рабочий день. */
    def var v-tilldt as date no-undo.
    v-tilldt = date(month(subdt),v-till,year(subdt)).
    if g-today > v-tilldt then do:
        find last txb.cls where txb.cls.whn = v-tilldt and txb.cls.del no-lock no-error.
        if not avail txb.cls then do:
            find first txb.cls where txb.cls.whn > v-tilldt and txb.cls.del no-lock no-error.
            if avail txb.cls then v-till = day(txb.cls.whn).
        end.
    end.
    def var subdt2 as date no-undo.
    def var subdec1 as deci no-undo.
    def var subdec2 as deci no-undo.
    if day(subdt) <= v-till then do:
        subdt2 = date(month(subdt),1,year(subdt)).
        find last txb.cls where txb.cls.whn < subdt2 and txb.cls.del no-lock no-error.
        if avail txb.cls then do:
            find first txb.lonres where txb.lonres.lon = v-lon and txb.lonres.jdt = txb.cls.whn and txb.lonres.lev = 7 and txb.lonres.dc= 'C' no-lock no-error.
            if avail txb.lonres and txb.lonres.who <> "bankadm" then do:
                run lonbalcrc_txb('lon',v-lon,txb.cls.whn,sublev,no,txb.lon.crc,output subdec1).
                run lonbalcrc_txb('lon',v-lon,txb.cls.whn,sublev,yes,txb.lon.crc,output subdec2).
                if subdec1 > 0 and subdec2 <= 0 then v-log = yes.
            end.
        end.
    end.
    else do:
        if subdc = 'D' then do:
            find first txb.cls where txb.cls.whn > subdt and txb.cls.del no-lock no-error.
            if avail txb.cls then do:
                if month(subdt) <> month(txb.cls.whn) then do:
                    find first bt-lonres where bt-lonres.jdt = subdt and bt-lonres.dc = 'C' /*and bt-lonres.sum = subsum*/ no-lock no-error.
                    if avail bt-lonres then v-log = yes.
                end.
            end.
        end.
    end.
    return v-log.
end function.

def var v-bal as deci no-undo extent 2.
def var tempost as deci no-undo.
def var v-cdt as date no-undo.
def var v-hisdt as date no-undo.

def var v-chk as logi no-undo.
def var dat as date no-undo.

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

v-chk = no.
if v-bal[1] <= 0 then v-chk = restructured('7',v-dt,'',0).
else v-chk = yes.

if v-chk then do:
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

        if not restructured('7',t-lonres.jdt,t-lonres.dc,t-lonres.sum) then do:
            v-days_od = v-dt - t-lonres.jdt.
            leave.
        end.

     end.
  end.
  if v-days_od > 0 then do:
    if v-p then v-days_od = v-days_od + 1.
  end.
end.

v-chk = no.
if v-bal[2] <= 0 then v-chk = restructured('9',v-dt,'',0).
else v-chk = yes.

if v-chk then do:
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

        if not restructured('9',t-lonres.jdt,t-lonres.dc,t-lonres.sum) then do:
            v-days_prc = v-dt - t-lonres.jdt.
            leave.
        end.

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

