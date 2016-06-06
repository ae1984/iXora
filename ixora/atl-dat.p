/* atl-dat.p
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

define input  parameter p-lon like lon.lon.
define input  parameter p-dt  like jl.jdt.
define output parameter p-atl as decimal.
{lonlev.i}

define variable vacc like lon.lon.
define variable vgl  like lon.gl.

find lon where lon.lon = p-lon no-lock no-error.
if not available lon
then do:
     p-atl = 0.
     return.
end.
if lon.gua = "OD"
then do:
     find last aab where aab.aaa = lon.lcr and aab.fdt < p-dt no-lock no-error.
     if available aab
     then p-atl = - aab.bal.
     else p-atl = 0.
end.
else do:
     vacc = lon.lon.
     vgl = lon.gl.
     
     /*
     p-atl = lon.dam[1] - lon.cam[1].
     */

     p-atl = 0.
     for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
     no-lock :
        if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then
        p-atl = p-atl + (trxbal.dam - trxbal.cam).
     end.
     
     if p-atl eq 0 then p-atl = lon.dam[1] - lon.cam[1].
      
     for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > - 1 and
              lnsch.fpn = 0 and lnsch.flp > 0 and lnsch.stdat gt p-dt
              no-lock by lnsch.stdat descending:
         p-atl = p-atl + lnsch.paid.
     end.
     for each lnscg where lnscg.lng = lon.lon and
              lnscg.stdat gt p-dt and lnscg.f0 > - 1 and lnscg.flp > 0
              no-lock by lnscg.stdat descending:
         p-atl = p-atl - lnscg.paid.
     end.
     /*
     for each jl where jl.acc = vacc and jl.gl = vgl and jl.jdt >= p-dt no-lock:
         p-atl = p-atl - jl.dam + jl.cam.
     end.
     */
end.
/*------------------------------------------------------------------------------
  #3.
     1.izmai‡a - transakcijas ‡em nevis fail– jl, bet gan lnsch un lnscg
------------------------------------------------------------------------------*/
