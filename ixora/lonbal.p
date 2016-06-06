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
        03/08/2004 madiar
 * CHANGES
        12/08/2004 madiar - добавил входной параметр p-includetoday - если "да" и дата = сегодня то остатки ищутся по trxbal,
                            "нет" - в любом случае по histrxbal.
                            распространил программку и на другие сабледжеры (добавились два входных параметра)
        16/08/2004 madiar - убрал пар-р p-crc (не находилась история уровней в валюте, отличной от валюты кредита)
        05/10/2004 madiar - p-includetoday - теперь действует не только на "сегодня"; "да" - за дату, "нет" - на дату
*/
def shared var g-today as date.

define input  parameter p-sub like trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def var i as integer.

res = 0.

/*find lon where lon.lon = p-lon no-lock no-error.
if not available lon then return.*/

if p-dt > g-today then return.

if p-includetoday then do: /* за дату */
  if p-dt = g-today then do:
     for each trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc no-lock:
         if lookup(string(trxbal.level), p-lvls) > 0 then res = res + (trxbal.dam - trxbal.cam).
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = integer(entry(i, p-lvls))
                                  and histrxbal.dt <= p-dt no-lock no-error.
        if avail histrxbal then res = res + (histrxbal.dam - histrxbal.cam).
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = integer(entry(i, p-lvls))
                                 and histrxbal.dt < p-dt no-lock no-error.
       if avail histrxbal then res = res + (histrxbal.dam - histrxbal.cam).
   end.
end.
