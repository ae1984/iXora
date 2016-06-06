/* lon_txb.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
*/

/*______________________________________________

Получение остатка по кредиту из базы с алиасом txb
(учитываются индексированные уровни)
05/07/04 madiar - скопировал из lon_txb.p с небольшой редакцией
_______________________________________________*/

define input  parameter p-lon like txb.lon.lon.
define input  parameter p-dt  like txb.jl.jdt.
define output parameter p-atl as decimal.
{lonlev.i}

define variable vacc like txb.lon.lon.
define variable vgl  like txb.lon.gl.

find txb.lon where txb.lon.lon = p-lon no-lock no-error.
if not available txb.lon
then do:
     p-atl = 0.
     return.
end.
if txb.lon.gua = "OD"
then do:
     find last txb.aab where txb.aab.aaa = txb.lon.lcr and txb.aab.fdt < p-dt no-lock no-error.
     if available txb.aab
     then p-atl = - txb.aab.bal.
     else p-atl = 0.
end.
else do:
     vacc = txb.lon.lon.
     vgl = txb.lon.gl.
     
     p-atl = 0.
     for each txb.trxbal where txb.trxbal.subled eq "LON" and txb.trxbal.acc eq txb.lon.lon
     no-lock :
        if lookup(string(txb.trxbal.level) , v-lonprnlevi , ";") gt 0 then
        p-atl = p-atl + (txb.trxbal.dam - txb.trxbal.cam).
     end.
     
     if p-atl eq 0 then p-atl = txb.lon.dam[1] - txb.lon.cam[1].
      
     for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > - 1 and
              txb.lnsch.fpn = 0 and txb.lnsch.flp > 0 and txb.lnsch.stdat gt p-dt
              no-lock by txb.lnsch.stdat descending:
         p-atl = p-atl + txb.lnsch.paid.
     end.
     for each txb.lnscg where txb.lnscg.lng = txb.lon.lon and
              txb.lnscg.stdat gt p-dt and txb.lnscg.f0 > - 1 and txb.lnscg.flp > 0
              no-lock by txb.lnscg.stdat descending:
         p-atl = p-atl - txb.lnscg.paid.
     end.
end.

