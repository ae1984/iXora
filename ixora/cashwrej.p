/* cashwrej.p
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
        3.10.3
 * AUTHOR
        25.08.2004 tsoy
 * CHANGES
*/

def shared var g-ofc like ofc.ofc .
def shared var g-today as date.
def var m-aah like jh.jh.
def var m-who like aal.who.
def var m-ln  like aal.ln.
def var m-crc like crc.crc.
def var m-sumd like aal.amt.
def var m-sumk like aal.amt.
def var m-amtd like aal.amt.
def var m-amtk like aal.amt.
def var m-diff like aal.amt.
def var m-beg like glbal.bal.
def var m-end like glbal.bal.
def var m-att as log format "***/   ".
def var m-row as integer.
def var m-cashgl like jl.gl.
def var punum like point.point.
def var v-point like point.point.
def var vprint as logical.
def var dest as char.
def var m-first as logical.
def var m-firstout as logical.
def temp-table cashf
    field crc like crc.crc
    field dam like glbal.dam
    field cam like glbal.cam.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then do :
   punum =  ofc.regno / 1000 - 0.5 .
end.

for each crc no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

dest = "prit".
{cashwrej1.f}
update vappend dest with frame image1.
/*hide frame image1.*/
find sysc where sysc.sysc = "CASHW" no-lock no-error.
if available sysc then do:
m-cashgl = inval.
m-firstout = no.

if vappend then output to rpt.img append.
else output to rpt.img.
{cashwrej2.f}
view frame a.



find first jl where jl.jdt = g-today no-lock no-error.
if available jl then do:
    for each jl  where jl.jdt = g-today no-lock
    break by jl.crc by jl.jh by jl.ln :
        if first-of(jl.crc) then do:
            find crc where crc.crc = jl.crc no-lock no-error.
            m-sumd = 0.
            m-sumk = 0.
            m-first = false.
        end.

        if jl.gl = m-cashgl then do :
        find jh where jh.jh = jl.jh no-lock no-error.
            if available jh and sts < 6 then do:

  
                v-point = jl.point.


                if v-point eq punum then do:
                m-aah = jl.jh.
                m-who = jl.who.
                m-ln = jl.ln.
                m-amtd = 0.
                m-amtk = 0.
                if jl.dam > 0 then do:
                    m-amtd = jl.dam.
                    m-sumd = m-sumd + m-amtd.
                end.
                else do:
                    m-amtk = jl.cam.
                    m-sumk = m-sumk + m-amtk.
                end.

                 if not m-first then do:
                    view frame a86 .
                    m-first = true.
                 end.
                 {cashwrej6.f}
                 m-att =  jh.sts < 6 .
                 display m-aah m-who m-ln m-amtd m-amtk jh.sts m-att
                 with width 130 frame c no-box  no-hide overlay.
                end. /*v-point*/
            end.
        end.
        if last-of(jl.crc) and m-first then do:
            find first cashf where cashf.crc = jl.crc.
            cashf.dam = cashf.dam + m-sumd .
            cashf.cam = cashf.cam + m-sumk .
            m-diff = m-sumd - m-sumk.
            {cashwrej7.f}
            display m-sumd m-sumk m-diff crc.code
            with frame ba no-box no-label.
            hide frame ba.
            hide frame a.
            display skip(1).
        end.
    end.
end.

m-first = yes.
for each crc no-lock:
find first cashf where cashf.crc = crc.crc no-lock no-error.
    if cashf.dam <> 0 or cashf.cam <> 0 then do:
        if m-first then do:
            {cashwrej8.f}
            m-first = no.
        end.
        display crc.code
        cashf.dam format "z,zzz,zzz,zz9.99-"
        cashf.cam format "z,zzz,zzz,zz9.99-" skip(1)
        with no-label no-box.
    end.
end.
{cashwrej9.f}
output close.
unix  value(dest)  rpt.img.
end.
else do:
    {cashwrej10.f}
end.
return.
