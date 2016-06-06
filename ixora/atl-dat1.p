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
           1-Остаток на 1-оом уровне, чистая сумма, без просрочек
           2-Остаток на 7,8-ом уровне, просрочка и блокир. суммы
           3-Реальный остаок основного долга
           24.02.2004 marinav - 4 остаток на 1,7,8,20,21 уровнях ВЕСЬ основной долг
*/

define input  parameter p-lon like lon.lon.
define input  parameter p-dt  like jl.jdt.
define input  parameter p-sb  as inte.
define output parameter p-atl as decimal.

define variable vacc like lon.lon.
define variable vgl  like lon.gl.

{lonlev.i}

find lon where lon.lon = p-lon no-lock no-error.
if not available lon
then do:
     p-atl = 0.
     return.
end.

     vacc = lon.lon.
if p-sb = 1 then do:
     vgl = lon.gl.
     p-atl = lon.dam[1] - lon.cam[1].
     for each jl where jl.acc = vacc and jl.gl = vgl and jl.jdt > p-dt no-lock:
         p-atl = p-atl - jl.dam + jl.cam.
     end.
     
end.
if p-sb = 2 then do:
     for each jl where jl.acc = vacc and (jl.lev = 7 or jl.lev = 8) and jl.jdt <= p-dt no-lock:
         p-atl = p-atl + jl.dam - jl.cam.
     end.
end.
if p-sb = 3 then do:
p-atl = 0.
     for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
     no-lock :
        if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then
        p-atl = p-atl + (trxbal.dam - trxbal.cam).
     end.
     
     if p-atl eq 0 then p-atl = lon.dam[1] - lon.cam[1].

     for each jl where jl.acc = vacc  and jl.jdt gt p-dt no-lock:
        if lookup(string(jl.lev) , v-lonprnlev , ";") gt 0 then
         p-atl = p-atl - jl.dam + jl.cam.
     end.
     
end.
if p-sb = 4 then do:
p-atl = 0.
     for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
     no-lock :
        if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then
        p-atl = p-atl + (trxbal.dam - trxbal.cam).
     end.
     
     if p-atl eq 0 then p-atl = lon.dam[1] - lon.cam[1].

     for each jl where jl.acc = vacc  and jl.jdt gt p-dt no-lock:
        if lookup(string(jl.lev) , v-lonprnlev , ";") gt 0 then
         p-atl = p-atl - jl.dam + jl.cam.
     end.

    find last hislon where hislon.lon eq lon.lon and hislon.fdt <= p-dt 
                    no-lock no-error.
    if avail hislon then p-atl = p-atl + (hislon.tdam[4] - hislon.tcam[4]) 
                                       + (hislon.tdam[5] - hislon.tcam[5]).
     
end.
