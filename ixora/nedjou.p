/* nedjou.p
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
        01/10/04 kanat
 * CHANGES
*/

def shared var g-today as date.
def shared var g-ofc like ofc.ofc.
def shared var s-jh like jh.jh.

def shared var dbcrc as integer.
def shared var crcrc as integer.

find first jh where jh.jh = s-jh.
if not avail jh then return.

find nmbr where nmbr.code eq "JOU" no-lock no-error.

create joudoc.
joudoc.docnum = 'jou' + string (next-value (journal), "999999") + nmbr.prefix.
joudoc.whn    = g-today.
joudoc.who    = g-ofc.
joudoc.tim    = time.
joudoc.drcur  = dbcrc.
joudoc.crcur  = crcrc.
joudoc.jh  = s-jh.
joudoc.bas_amt = "D".
find first sysc where sysc = 'cashgl' no-lock no-error.
find first jl where jl.jh = s-jh no-lock no-error.
if jl.cam ne 0 then do:
    if jl.gl = sysc.inval then joudoc.cracctype = '1'.
    else if can-find(first aaa where aaa.aaa = jl.acc no-lock) 
        then joudoc.cracctype = '2'.
    else if can-find(first arp where arp.arp = jl.acc no-lock)
        then joudoc.cracctype = '4'.
    joudoc.cracc  = jl.acc.
    joudoc.cramt  = jl.cam.
end.
else do:
    if jl.gl = sysc.inval then joudoc.dracctype = '1'.
    else if can-find(first aaa where aaa.aaa = jl.acc no-lock) 
        then joudoc.dracctype = '2'.
    else if can-find(first arp where arp.arp = jl.acc no-lock)
        then joudoc.dracctype = '4'.
    joudoc.dracc  = jl.acc.
    joudoc.dramt  = jl.dam.
end.
find next jl where jl.jh = s-jh no-lock no-error.
if jl.cam ne 0 then do:
    if jl.gl = sysc.inval then joudoc.cracctype = '1'.
    else if can-find(first aaa where aaa.aaa = jl.acc no-lock) 
        then joudoc.cracctype = '2'.
    else if can-find(first arp where arp.arp = jl.acc no-lock)
        then joudoc.cracctype = '4'.
    joudoc.cracc  = jl.acc.
    joudoc.cramt  = jl.cam.
end.
else do:
    if jl.gl = sysc.inval then joudoc.dracctype = '1'.
    else if can-find(first aaa where aaa.aaa = jl.acc no-lock) 
        then joudoc.dracctype = '2'.
    else if can-find(first arp where arp.arp = jl.acc no-lock)
        then joudoc.dracctype = '4'.
    joudoc.dracc  = jl.acc.
    joudoc.dramt  = jl.dam.
end.
joudoc.remark[1] = substring(jl.rem[1] + jl.rem[2], 1, 70).
joudoc.remark[2] = substring(jl.rem[1] + jl.rem[2] + jl.rem[3], 71).
jh.ref = joudoc.docnum.
jh.party = joudoc.docnum.
jh.sub = 'jou'.

run chgsts('jou', joudoc.docnum, 
    if joudoc.cracctype = '1' or joudoc.dracctype = '1' then 'cas' else 'rdy').
/*    
create cursts .
cursts.sub = 'jou'.
cursts.acc = joudoc.docnum.
cursts.sts = 'cas'.
cursts.rdt = g-today .
cursts.rtim = time .
cursts.who = g-ofc .
*/

return joudoc.docnum.
