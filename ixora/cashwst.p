/* cashwst.p
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
        3.10.2
 * AUTHOR
        23.08.2004 tsoy
 * CHANGES
*/

def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var m-crc like crc.crc.
def var m-sumd like aal.amt.
def var m-sumk like aal.amt.
def var m-amtd like aal.amt.
def var m-amtk like aal.amt.
def var m-diff like aal.amt.
def var m-beg like glbal.bal.
def var m-end like glbal.bal.
def var m-cashgl like jl.gl.
def var vprint as logical.
def var dest as char.
def temp-table cashf
    field crc like crc.crc
    field dam like glbal.dam
    field cam like glbal.cam.


for each crc where crc.sts ne 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

dest = "prit".
{cashwst.f}
update vappend dest with frame image1.

hide frame image1.
find sysc where sysc.sysc = "CASHW" no-lock no-error.
if available sysc then do:
m-cashgl = inval.

if vappend then output to rpt.img append.
else output to rpt.img.
{cashwst1.f}
view frame a.



find first jl where jl.jdt = g-today no-lock no-error.
if available jl then do:
    for each jl  where jl.jdt = g-today no-lock
    break by jl.crc by jl.jh by jl.ln :

    if first-of(jl.crc) then do:
        find crc where crc.crc = jl.crc no-lock no-error.
        m-sumd = 0.
        m-sumk = 0.
    end.

    if jl.gl = m-cashgl then do :
    find jh where jh.jh = jl.jh no-lock no-error.
        if available jh then do:
        m-amtd = 0.
        m-amtk = 0.
        if jl.dc eq "D" then do:
            m-amtd = jl.dam.
            m-sumd = m-sumd + m-amtd.
        end.
        else do:
            m-amtk = jl.cam.
            m-sumk = m-sumk + m-amtk.
        end.

        end.
    end.
    if last-of(jl.crc) then do:
        find first cashf where cashf.crc = jl.crc.
        cashf.dam = cashf.dam + m-sumd .
        cashf.cam = cashf.cam + m-sumk .
        m-diff = m-sumd - m-sumk.
    end.
    end.
end.

{cashwst2.f}

for each crc where crc.sts ne 9 no-lock:
find glbal where glbal.gl = m-cashgl and glbal.crc = crc.crc no-lock no-error.
find first cashf where cashf.crc = crc.crc no-lock no-error.
    display crc.code
    glbal.bal
    format "z,zzz,zzz,zz9.99-"
    cashf.dam
    format "z,zzz,zzz,zz9.99-"
    cashf.cam
    format "z,zzz,zzz,zz9.99-"
    (glbal.bal + (cashf.dam - cashf.cam))
    format "z,zzz,zzz,zz9.99-" skip(1)
    with no-label no-box.
end.

{cashwst3.f}

output close.
unix  value(dest)  rpt.img.
end.
else display "Not found CASHGL in sysc".
return.
