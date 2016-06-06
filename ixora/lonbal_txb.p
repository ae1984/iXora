/* lonbal.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Расчет остатков по ссудным счетам на задаваемых уровнях
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
        12/08/2004 madiar - скопировал из lonbal.p с корректировкой для использования на базе txb
 * CHANGES
        16/08/2004 madiar - убрал пар-р p-crc (не находилась история уровней в валюте, отличной от валюты кредита)
        05/10/2004 madiar - p-includetoday - теперь действует не только на "сегодня"; "да" - за дату, "нет" - на дату
*/
def shared var g-today as date.

define input  parameter p-sub like txb.trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like txb.jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def var i as integer.

res = 0.

/*find txb.lon where txb.lon.lon = p-lon no-lock no-error.
if not available txb.lon then return.*/

if p-dt > g-today then return.

if p-includetoday then do: /* за дату */
  if p-dt = g-today then do:
     for each txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc no-lock:
         if lookup(string(txb.trxbal.level), p-lvls) > 0 then res = res + (txb.trxbal.dam - txb.trxbal.cam).
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc
                                and txb.histrxbal.level = integer(entry(i, p-lvls))
                                and txb.histrxbal.dt <= p-dt no-lock no-error.
        if avail txb.histrxbal then res = res + (txb.histrxbal.dam - txb.histrxbal.cam).
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc
                               and txb.histrxbal.level = integer(entry(i, p-lvls))
                               and txb.histrxbal.dt < p-dt no-lock no-error.
       if avail txb.histrxbal then res = res + (txb.histrxbal.dam - txb.histrxbal.cam).
   end.
end.
