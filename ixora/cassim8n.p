/* cassim8n.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       02.02.2012 lyubov - добавила в выборку сим.касспл. условие "cashpl.act"
*/

def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var m-today as date.
def var m-aah like jh.jh.
def var m-who like aal.who.
def var m-ln  like aal.ln.
def var m-crc like crc.crc.
def var drcr as cha .
def var m-sumd like aal.amt.
def var m-sumk like aal.amt.
def var m-acc like aaa.aaa .
def var m-amtd like aal.amt.
def var m-amtk like aal.amt.
def var m-diff like aal.amt.
def var m-beg like glbal.bal.
def buffer bjl for jl .
def var m-end like glbal.bal.
def var m-att as log format "***/   ".
def var m-row as integer.
def var m-cashgl like jl.gl.
def var vprint as logical.
def var dest as char.
def var m-first as logical.
def var m-firstout as logical.
def temp-table cashf
    field crc like crc.crc
    field dam like glbal.dam
    field cam like glbal.cam.

for each crc where crc.sts <> 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

dest = "prit".

{cassim8.f}
m-today = g-today .
update vappend dest m-today with frame image1.

hide frame image1.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then do:
m-cashgl = inval.
m-firstout = no.

if vappend then output to rpt.img append.
else output to rpt.img.
{cassim81.f}
view frame a.



find first jl where jl.jdt = m-today no-lock no-error.
if available jl then do:
    for each jl  where jl.jdt = m-today no-lock ,
    each jlsach where
    jlsach.jh = jl.jh and jlsach.ln = jl.ln no-lock , each cashpl where
    cashpl.sim = jlsach.sim and cashpl.act no-lock break by jl.crc by jl.jh by jl.ln :
        if first-of(jl.crc) then do:
            find crc where crc.crc = jl.crc no-lock no-error.
            m-sumd = 0.
            m-sumk = 0.
            m-first = false.
        end.
        if jl.gl = m-cashgl then do :
        find jh where jh.jh = jl.jh no-lock no-error.
            if available jh then do:
                m-aah = jl.jh.
                m-who = jl.who.
                m-ln = jl.ln.
                m-amtd = 0.
                m-amtk = 0.
                m-acc = "" .
                if jl.dc eq "D" then do:
                    m-amtd = jlsach.amt.
                    m-sumd = m-sumd + m-amtd.
                    drcr = "DR" .
                find first  bjl where bjl.jh = jl.jh and bjl.cam = jl.dam and
                 bjl.crc = jl.crc no-lock no-error .
                if avail bjl then do: if bjl.acc ne "" then m-acc = bjl.acc .                    else m-acc = string(bjl.gl).
                   end.
                end.
                else do:
                    m-amtd = jlsach.amt .
                    m-sumk = m-sumk + m-amtd.
                    drcr = "  CR" .
       find first  bjl where bjl.jh = jl.jh and bjl.dam = jl.cam and
              bjl.crc = jl.crc no-lock no-error .
              if avail bjl then do: if bjl.acc ne "" then m-acc = bjl.acc .
                 else m-acc = string(bjl.gl).
               end.
             end.
                 if not m-first then do:
                    view frame a86 .
                    m-first = true.
                 end.
                 {cassim83.f}
                 m-att =  jh.sts < 6 .
                 display m-aah jlsach.sim m-who  m-amtd drcr jl.teller
                 jh.sts m-att m-acc cashpl.des format "x(40)"
                 with width 130 frame c no-box  no-hide overlay.
            end.
        end.
        if last-of(jl.crc) and m-first then do:
            find first cashf where cashf.crc = jl.crc.
            cashf.dam = cashf.dam + m-sumd .
            cashf.cam = cashf.cam + m-sumk .
            m-diff = m-sumd - m-sumk.
            {cassim82a.f}

            display m-sumd  m-sumk m-diff crc.code
                          with frame ba no-box no-label .
            hide frame ba.
            hide frame a.
            display skip(1).
        end.
    end.
end.

output close.
unix  value(dest)  rpt.img.
end.
else do:
    {casher85b.f}
end.
return.


