/* setcsymb.p
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

define input parameter s-jh  like jh.jh.
define input parameter s-sym like cashpl.sim.
def var s-gl like sysc.inval.

find first cashpl where sim = s-sym no-lock no-error.
if not avail cashpl then return "Symbol not found.".

find first sysc where sysc.sysc = "CASHGL" no-lock no-error.
s-gl = sysc.inval.

/*
find first cash where cash.sysc = "CASHPL" no-lock no-error.
if not cash.loval then return "Cash account nod found.".
*/

if can-find(first jlsach where jh = s-jh no-lock) then do:
    for each jlsach where jh = s-jh: 
        jlsach.sim = s-sym.
    end.    
    return "".
end.
   
find first jl where jl.jh = s-jh and jl.gl = s-gl no-lock no-error.
if not avail jl then return "Not cash transaction".

create jlsach.
jlsach.jh = s-jh. 
jlsach.amt = jl.dam + jl.cam. 
jlsach.ln = jl.ln. 
jlsach.lnln = 1. 
jlsach.sim = s-sym.  

return "".
          
