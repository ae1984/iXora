/* atl-dat1.p
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


/* Остаток только на 1 уровне*/
/* p-sb
1-Остаток на 1-оом уровне, чистая сумма, без просрочек
2-Остаток на 7,8-ом уровне, просрочка и блокир. суммы
3-Реальный остаок основного долга
*/

define input  parameter p-lon like txb.lon.lon.
define input  parameter p-dt  like txb.jl.jdt.
define input  parameter p-sb  as inte.
define output parameter p-atl as decimal.

define variable vacc like txb.lon.lon.
define variable vgl  like txb.lon.gl.

{lonlev.i}

find txb.lon where txb.lon.lon = p-lon no-lock no-error.
if not available txb.lon
then do:
     p-atl = 0.
     return.
end.

     vacc = txb.lon.lon.
if p-sb = 1 then do:
     vgl = txb.lon.gl.
     p-atl = txb.lon.dam[1] - txb.lon.cam[1].
     for each txb.jl where txb.jl.acc = vacc /*and txb.jl.gl = vgl*/ and txb.jl.jdt > p-dt no-lock:
         if txb.jl.lev = 1 then p-atl = p-atl - txb.jl.dam + txb.jl.cam.
     end.
     
end.
if p-sb = 2 then do:
     for each txb.jl where txb.jl.acc = vacc and /*(txb.jl.lev = 7 or txb.jl.lev = 8) and*/ txb.jl.jdt <= p-dt no-lock:
         if txb.jl.lev = 7 or txb.jl.lev = 8 then p-atl = p-atl + txb.jl.dam - txb.jl.cam.
     end.
end.
if p-sb = 3 then do:
p-atl = 0.
     for each txb.trxbal where txb.trxbal.subled eq "LON" and txb.trxbal.acc eq txb.lon.lon
     no-lock :
        if lookup(string(txb.trxbal.level) , v-lonprnlev , ";") gt 0 then
        p-atl = p-atl + (txb.trxbal.dam - txb.trxbal.cam).
     end.
     
     if p-atl eq 0 then p-atl = txb.lon.dam[1] - txb.lon.cam[1].

     for each txb.jl where txb.jl.acc = vacc  and txb.jl.jdt gt p-dt no-lock:
        if lookup(string(txb.jl.lev) , v-lonprnlev , ";") gt 0 then
         p-atl = p-atl - txb.jl.dam + txb.jl.cam.
     end.
     
end.
if p-sb = 4 then do:
p-atl = 0.
     for each txb.trxbal where txb.trxbal.subled eq "LON" and txb.trxbal.acc eq txb.lon.lon
     no-lock :
        if lookup(string(txb.trxbal.level) , v-lonprnlev , ";") gt 0 then
        p-atl = p-atl + (txb.trxbal.dam - txb.trxbal.cam).
     end.
     
     if p-atl eq 0 then p-atl = txb.lon.dam[1] - txb.lon.cam[1].

     for each txb.jl where txb.jl.acc = vacc  and txb.jl.jdt gt p-dt no-lock:
        if lookup(string(txb.jl.lev) , v-lonprnlev , ";") gt 0 then
         p-atl = p-atl - txb.jl.dam + txb.jl.cam.
     end.

    find last txb.hislon where txb.hislon.lon eq txb.lon.lon and txb.hislon.fdt <= p-dt 
                    no-lock no-error.
    if avail txb.hislon then p-atl = p-atl + (txb.hislon.tdam[4] - txb.hislon.tcam[4]) 
                                           + (txb.hislon.tdam[5] - txb.hislon.tcam[5]).
     
end.
