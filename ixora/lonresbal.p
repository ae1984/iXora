/* lonresbal.p
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
        12/04/2006 Natalya D. - аналогичная процедура что и lonbalcrc, только по lonres
 * CHANGES
*/

def shared var g-today as date.

define input  parameter p-sub like trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define input  parameter p-crc like crc.crc.
define output parameter res as decimal.


def var i as integer.

res = 0.

/*find lon where lon.lon = p-lon no-lock no-error.
if not available lon then return.*/

if p-dt > g-today then return.

if p-includetoday then do: /* за дату */
  if p-dt = g-today then do:
     for each trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc and trxbal.crc = p-crc no-lock:
         if lookup(string(trxbal.level), p-lvls) > 0 then res = res + (trxbal.dam - trxbal.cam).
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        for each lonres where lonres.lon = p-acc and lonres.lev = integer(entry(i, p-lvls))
                                  and lonres.jdt <= p-dt and lonres.crc = p-crc no-lock .
        /*if avail lonres then do:*/

           if lonres.dc = 'd' then res = res + lonres.amt.
           if lonres.dc = 'c' then res = res - lonres.amt.
        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       for each lonres where lonres.lon = p-acc and lonres.lev = integer(entry(i, p-lvls))
                                 and lonres.jdt < p-dt and lonres.crc = p-crc no-lock.
       /*if avail lonres then do:*/
          if lonres.dc = 'd' then res = res + lonres.amt.
          if lonres.dc = 'c' then res = res - lonres.amt.
       end.
   end.
end.

