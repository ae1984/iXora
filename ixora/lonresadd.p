/* lonresadd.p
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

def input parameter s-jh like jh.jh.
for each jl where jl.jh eq s-jh no-lock :
if jl.sub eq "lon" then do:
find lon where lon.lon eq jl.acc no-lock no-error.
if available lon then do:
create lonres.
lonres.lon = lon.lon.
lonres.mn = "LRES" + string(year(jl.jdt),"9999") 
+ string(month(jl.jdt),"99").
lonres.jh = s-jh.
lonres.dc = jl.dc.
lonres.gl = jl.gl.
lonres.amt = jl.dam + jl.cam.
lonres.who = jl.who.
lonres.whn = jl.jdt.
lonres.tim = jl.tim.
lonres.ln = jl.ln.
lonres.crc = jl.crc.
lonres.crc1 = 1.
lonres.jdt = jl.jdt.
lonres.lev = jl.lev.
lonres.trx = jl.trx.
if jl.crc eq 1 then do:
    lonres.amt1 = lonres.amt.
end.
else do:
    find crc where crc.crc eq jl.crc no-lock no-error.
    if available crc then do :
        lonres.amt1 = lonres.amt * crc.rate[1] / crc.rate[9].
    end.
end.
end. /* available lon */
end. /* sub eq "lon" */
end.
