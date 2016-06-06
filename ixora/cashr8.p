/* cashr8.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Общий отчет по непроведенным кассовым операциям
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
*/

def shared var g-ofc like ofc.ofc .
def shared var g-today as date.
def var m-crc like crc.crc.
def var m-sumd like aal.amt.
def var m-sumk like aal.amt.
def var m-amtd like aal.amt.
def var m-amtk like aal.amt.
def var m-diff like aal.amt.
def var m-beg like glbal.bal.
def var m-end like glbal.bal.
def var p-bal like pglbal.bal.
def var m-cashgl like jl.gl.
def var vprint as logical.
def var dest as char.
def var punum like point.point.
def var v-point like point.point.
def var prizn as logical init false.
def temp-table cashf
    field crc like crc.crc
    field dam like glbal.dam
    field cam like glbal.cam.


find ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then do :
   punum =  ofc.regno / 1000 - 0.5 .
end.

for each crc where crc.sts ne 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

dest = "prit".
{cashr8.f}
update vappend dest with frame image1.
if punum = 99 then do:
    update punum /*help " 0 - Visas grupas" */ with frame im1.
end.
/*for each point
where point.point eq (if punum eq 0 then point.point else punum)
    break by point:     */
hide frame image1.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then do:
m-cashgl = inval.

if vappend then output to rpt.img append.
else output to rpt.img.
{cashr81.f}
view frame a.



find first jl where jl.jdt = g-today  no-lock no-error.
if available jl then do:
    for each jl  where jl.jdt = g-today  no-lock
    break by jl.crc by jl.jh by jl.ln :
        if first-of(jl.crc) then do:
            find crc where crc.crc = jl.crc no-lock no-error.
            m-sumd = 0.
            m-sumk = 0.
        end.

        if jl.gl = m-cashgl then do :
        find jh where jh.jh = jl.jh no-lock no-error.
            if available jh then do:


                v-point = jh.point.


                m-amtd = 0.
                m-amtk = 0.
                if jl.dc eq "D" then do:
                    if v-point eq punum then do:
                        m-amtd = jl.dam.
                        m-sumd = m-sumd + m-amtd.
                    end.
                end.
                else do:
                    if v-point eq punum then do:
                        m-amtk = jl.cam.
                        m-sumk = m-sumk + m-amtk.
                    end.
                end.
            end.
        end.

        if last-of(jl.crc) then do:
            find first cashf where cashf.crc = jl.crc.
            cashf.dam = cashf.dam + m-sumd .
            cashf.cam = cashf.cam + m-sumk .
            m-diff = m-sumd - m-sumk.
        end.
    end.  /*each jl*/
end.

{casher08.f}

for each crc where crc.sts ne 9 no-lock:
for each pglbal where pglbal.point = punum and pglbal.gl = m-cashgl
    and pglbal.crc = crc.crc:
    p-bal = p-bal + pglbal.bal.
end.
find first cashf where cashf.crc = crc.crc no-lock no-error.
    if p-bal <> 0 or cashf.dam <> 0 or cashf.cam <> 0 then do:
    display crc.code
    p-bal
    format "z,zzz,zzz,zz9.99-"
    cashf.dam
    format "z,zzz,zzz,zz9.99-"
    cashf.cam
    format "z,zzz,zzz,zz9.99-"
    (p-bal + (cashf.dam - cashf.cam))
    format "z,zzz,zzz,zz9.99-" skip(1)
    with no-label no-box.
    end.
p-bal = 0.
end.
{casher18.f}

output close.
unix  value(dest)  rpt.img.
end.
else display "Not found CASHGL in sysc".
return.
