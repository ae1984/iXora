/* izki.p
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
*/

/*
Vladimir Sushinin
begin 07.02.95
*/
/* 01.10.02 nadejda - наименование клиента заменено на форма собств + наименование */

{mainhead.i IZKI}
/*
{global.i}
*/
def new shared stream m-err.
def new shared var v-gltd as char.
def new shared var m-aaa like aaa.aaa.
def new shared var m-ind as int.
def var m-srok as int.
def var m-rate as deci.
def var m-sum like glbal.bal.
def var m-crc like crc.crc.
def var m-crccode like crc.code.
def var m-lgr like aaa.lgr.
def var m-rgl like gl.gl.
def var m-gl like gl.gl.
def var m-gltype like gl.type.
def new shared var m-hs like crchs.hs.
def new shared var m-hslat like crchs.hs.
def new shared var m-okey as log.
def var m-geo as int.
def var m-cgr like cgr.cgr.
def var m-host as char.

def var i1 as int.
def var la as char.
def var m-key2 as log.

def var j as int.
def var i as int.
def var dame as char.

def var dames as date.

def var m-ext as char.

def new shared var v-col as int.
def new shared var v-row as int.
def new shared var v-colp as int.
def new shared var v-rowp as int.

def var v-col0 as int initial 0 format "9" .
def var v-row0 as int initial 0 format "9999" .
def var v-colp0 as int initial 0 format "9" .
def var v-rowp0 as int initial 0 format "99999" .


def var v-sum like glbal.bal initial 0.
def var v-sump like glbal.bal initial 0.


define variable men-n  as character extent 12 format 'x(10)'
initial ['janv–ris', 'febru–ris', 'marts', 'aprЁlis', 'maijs', 'j­nijs',
'j­lijs', 'augusts', 'septembris', 'oktobris', 'novembris', 'decembris'] .

def var v-h1 as char extent 3 initial [
"              Latvijas val­t–",
"  …rzemju konvertёjam– val­t–",
"…rzemju nekonvertёjam– val­t–" ].


def stream m-out.
def stream m-out1.


def temp-table glf
    field gl like gl.gl.

def temp-table izki
    field name as char format "x(48)"
    field kods as char format "x(9)"
    field summa as decimal extent 7 .



{nb0.f}
{izki0.f}

output stream m-out to izki.txt page-size 44.
output stream m-err to izki.err.

find sysc where sysc.sysc = "GLDATE" no-lock no-error.
dame = string(day(sysc.daval),"99") + string(month(sysc.daval),"99").
dames = sysc.daval.

find sysc where sysc.sysc = "BILEXT" no-lock no-error.
if available sysc then m-ext = "." + trim(sysc.chval). else m-ext = ".".

find sysc where sysc.sysc = "GLTD" no-lock no-error.
if available sysc then v-gltd = sysc.chval. else v-gltd = "".


output stream m-out1 to value("IZKI" + dame + m-ext).

v-col0 = 1.
repeat while v-col0 ne 4 :

v-row0 = 321.
repeat while v-row0 ne 3125 :

display v-row0 v-col0 with frame rc00.
pause 0.

v-sum = 0.
v-sump = 0.



if v-col0 eq 0 then v-col0 = -1.
if v-row0 eq 0 then v-row0 = -1.
v-colp0 = -1.
v-rowp0 = -1.


m-hslat = "S".
/*  Внимание !!! Это "мягкость" лата. */

for each glf :
    delete glf.
end.

for each glbl where p-kods eq v-row0 no-lock :
    find first glf where glf.gl eq glbl.gl no-error.
    if not available glf then do:
        create glf.
        glf.gl = glbl.gl.
    end.
end.


i = 0.

m-lgr = ?.

for each lgr no-lock :

find first glf where glf.gl eq lgr.gl no-error.

if  available glf then do:
        i1 = 0.
        m-lgr = lgr.lgr.
        m-key1 = yes.
            find gl where gl.gl = lgr.gl no-lock no-error.
            if not available gl then do:
                m-key1 = no.
                put stream m-err m-strerr1  " gl " lgr.gl m-strerr2  " lgr "
                lgr.lgr skip.
            end.
            else do:
                m-gl = gl.gl.
                m-gltype = gl.type.
            end.

            find crc where crc.crc = lgr.crc no-lock no-error.
            if available crc then do:
                m-crc = crc.crc.
                m-crccode = crc.code.
                m-rate = crc.rate[1] / crc.rate[9].
            end.
            else put stream m-err m-strerr1  " crc " lgr.crc m-strerr2  "  "
                skip.
            m-hs = ?.
            find crchs where crchs.crc = crc.crc.
            if available crchs then m-hs = crchs.hs.


for each aaa where aaa.lgr eq lgr.lgr no-lock  :


    if m-key1 then do:
            m-key2 = yes.
            m-geo = ? .
            find cif  where aaa.cif = cif.cif no-lock no-error.
            if available cif then do:
                if trim(cif.geo) = "" then do:
                    m-key2 = no.
                    put stream m-err m-strerr1  " geo " cif.geo m-strerr2
                    " cif " cif.cif skip.
                end.
                else do:
                    m-cgr = cif.cgr.
                    m-geo = integer(cif.geo).
                end.
            end.
            else do:
                m-key2 = no.
                put stream m-err m-strerr1  " cif " aaa.cif m-strerr2  " aaa "
                aaa.aaa skip.
            end.
        if m-key2 then do:
                m-sum = aaa.dr[1] - aaa.cr[1].
                m-srok = aaa.expdt - aaa.regdt.
if m-sum <> 0 then do:

run newbld (m-gl,m-gltype,m-crc,m-crccode,m-geo,m-cgr,m-sum,m-srok).


    if gl.type eq "L" or gl.type eq "O" then m-sum = - m-sum.

    if v-col eq v-col0 and v-row eq v-row0 then do:
        if cif.mother eq "" then put stream m-err
        m-strerr0 "CIF " cif.cif " aaa " aaa.aaa skip.

        find first izki where izki.kods eq cif.mother no-lock no-error.
        if not available izki then do :
            create izki.
            izki.kods = cif.mother.
            izki.name = trim(trim(cif.prefix) + " " + trim(cif.name)).
            izki.summa[v-colp] = m-sum * crc.rate[1] / crc.rate[9].
         end.
         else do:
            izki.summa[v-colp] = izki.summa[v-colp] +
            m-sum * crc.rate[1] / crc.rate[9].
         end.
    end.


end.
else m-okey = yes.
                if not m-okey then put stream m-err
                m-strerr0  " aaa " aaa.aaa
                ", cif " aaa.cif skip.
        end.
    end.
    if i = j then do:
        j = j + 100.
        display  m-mess1 i with frame a
        no-label row 10 centered.
        pause 0.
    end.
    i = i + 1.
    i1 = i1 + 1.
end.
end.
end.
m-hs = ? .
hide frame a.




/*      Временный  */

i = 0. j = 0.

for each lon no-lock break by cif:

if lon.dam[1] ne lon.cam[1] then do:

find first glf where glf.gl eq lon.gl no-error.

    /*
    if first-of(lon.cif) then do:
    */
        m-key1 = yes.
        m-geo = ? .
        find cif  where lon.cif = cif.cif no-lock no-error.
        if available cif then do:
            if trim(cif.geo) = "" then do:
                put stream m-err m-strerr1  " geo " cif.geo m-strerr2
                " cif " cif.cif skip.
                m-key1 = no.
            end.
            m-geo = integer(cif.geo).
            m-cgr = cif.cgr.
        end.
        else do:
            m-key1 = no.
            put stream m-err m-strerr1  " cif " lon.cif m-strerr2  " lon "
            lon.lon skip.
        end.

    /*
    end.
    */

if  available glf then do:

    if m-key1 then do:
        find gl where gl.gl = lon.gl no-lock no-error.
        if not available gl then do:
            put stream m-err m-strerr1  " gl " lon.gl m-strerr2  " lon "
            lon.lon skip.
        end.

        find crc where crc.crc = lon.crc no-lock no-error.
        if available crc then do:
                m-sum = lon.dam[1] - lon.cam[1].
                m-srok = lon.duedt - lon.rdt.
                find loncnt where loncnt.lon = lon.lon no-lock no-error.
                if available loncnt then do:
                    find lcnt where lcnt.lcnt = loncnt.lcnt no-lock no-error.
                    if available lcnt then
                    m-srok = lcnt.duedt - lcnt.rdt.
                end.
                if m-sum <> 0 then do:
run newbl1d
(gl.gl,gl.type,crc.crc,crc.code,m-geo,m-cgr,lon.loncat,m-sum,m-srok).

    if gl.type eq "L" or gl.type eq "O" then m-sum = - m-sum.
    if v-col eq v-col0 and v-row eq v-row0 then do:

        if cif.mother eq "" then put stream m-err
        m-strerr0 "CIF " cif.cif " lon " lon.lon skip.
        find first izki where izki.kods eq cif.mother no-lock no-error.
        if not available izki then do :
            create izki.
            izki.kods = cif.mother.
            izki.name = trim(trim(cif.prefix) + " " + trim(cif.name)).
            izki.summa[v-colp] = m-sum * crc.rate[1] / crc.rate[9].
         end.
         else do:
            izki.summa[v-colp] = izki.summa[v-colp] +
            m-sum * crc.rate[1] / crc.rate[9].
         end.
    end.

    end.

                else m-okey = yes.
                if not m-okey then put stream m-err
                m-strerr0  " lon " lon.lon
                ", cif " lon.cif skip.
        end.
    end.
    end.
end.  /*  dam ne cam */
    if i = j then do:
        j = j + 100.
        display  m-mess2 i with frame l no-label row 10 centered.
        pause 0.
    end.
    i = i + 1.
end.
hide frame l.





i = 0. j = 0.
for each dfb no-lock :
        m-key1 = yes.
        find gl where gl.gl = dfb.gl no-lock no-error.
        if not available gl then do:
            m-key1 = no.
            put stream m-err m-strerr1  " gl " dfb.gl m-strerr2  " dfb "
            dfb.dfb skip.

        end.
        else do:
            m-gl = gl.gl.
            m-gltype = gl.type.
        end.
    if m-key1 then do:
        find bank where bank.bank = dfb.dfb no-lock no-error .
        if available bank then do:

            find crc where crc.crc = dfb.crc no-lock no-error.
            if available crc then do:
                m-srok = 0.
                m-sum = dfb.dam[1] - dfb.cam[1].
                if gl.type <> "A" and gl.type <> "E" then m-sum = - m-sum.
                if m-sum < 0 then do:
                    if gl.type <> "A" and gl.type <> "E" then m-sum = - m-sum.
                    m-rgl = gl.revgl.
                    find gl where gl.gl = m-rgl no-lock no-error.
                    if not available gl then do:
                        m-key1 = no.
                        put stream m-err m-strerr1  " gl " m-rgl
                        m-strerr2  " dfb " dfb.dfb skip.
                    end.
                    else do:
                        m-gl = gl.gl.
                        m-gltype = gl.type.
                    end.
                end.
                else
                if gl.type <> "A" and gl.type <> "E" then m-sum = - m-sum.
                m-cgr = ?.
            if m-sum <> 0 and m-key1 then do:
run newbld (m-gl,m-gltype,crc.crc,crc.code,bank.stn,m-cgr,m-sum,m-srok).

    if gl.type <> "A" and gl.type <> "E" then m-sum = - m-sum.

    if v-col eq v-col0 and v-row eq v-row0 then do:
        if bank.frbno eq "" then put stream m-err
        m-strerr0 "Bank " bank.bank " DFB " dfb.dfb skip.
        find first izki where izki.kods eq bank.frbno no-lock no-error.
        if not available izki then do :
            create izki.
            izki.kods = bank.frbno.
            izki.name = bank.name.
            izki.summa[v-colp] = m-sum * crc.rate[1] / crc.rate[9].
         end.
         else do:
            izki.summa[v-colp] = izki.summa[v-colp] +
            m-sum * crc.rate[1] / crc.rate[9].
         end.
    end.



end.
            else m-okey = yes.
            if not m-okey then put stream m-err
            m-strerr0 + " dfb " dfb.dfb skip.

            end.
            else put stream m-err m-strerr1  " crc " dfb.crc m-strerr2  " dfb "
            dfb.dfb skip.
        end.  /* bank */
        else put stream m-err m-strerr1  " bank " dfb.dfb
        m-strerr2 " dfb " dfb.dfb skip.
    end.
    if i = j then do:
        j = j + 10.
        display  m-mess3 i with frame b no-label row 10 centered.
        pause 0.
    end.
        i = i + 1.
end. /* dfb */

hide frame b.

i = 0. j = 0.
for each fun no-lock :
    if fun.dam[1] ne fun.cam[1] then do:

    m-key1 = yes.
    find gl where gl.gl = fun.gl no-lock no-error.
    if not available gl then do:
        m-key1 = no.
        put stream m-err m-strerr1  " gl " fun.gl m-strerr2  " fun "
        fun.fun skip.
    end.
    if m-key1 then do:
        find bank where bank.bank = fun.bank no-lock no-error .
        if available bank then do:
            find crc where crc.crc = fun.crc no-lock no-error.
            if available crc then do:
                m-sum = fun.dam[1] - fun.cam[1].
                m-srok = fun.trm.
                m-cgr = ?.
if m-sum <> 0 then do:
run newbld (gl.gl,gl.type,crc.crc,crc.code,bank.stn,m-cgr,m-sum,m-srok).

    if gl.type eq "L" or gl.type eq "O" then m-sum = - m-sum.
    if v-col eq v-col0 and v-row eq v-row0 then do:

        if bank.frbno eq "" then put stream m-err
        m-strerr0 "Bank " bank.bank " FUN " fun.fun skip.
        find first izki where izki.kods eq bank.frbno no-lock no-error.
        if not available izki then do :
            create izki.
            izki.kods = bank.frbno.
            izki.name = bank.name.
            izki.summa[v-colp] = m-sum * crc.rate[1] / crc.rate[9].
         end.
         else do:
            izki.summa[v-colp] = izki.summa[v-colp] +
            m-sum * crc.rate[1] / crc.rate[9].
         end.
    end.


    end.
            else m-okey = yes.
                if not m-okey then put stream m-err
                m-strerr0  " FUN " fun.fun
                ",bank " fun.bank skip.
            end.
            else put stream m-err m-strerr1  " crc " fun.crc m-strerr2  " fun "
            fun.fun skip.
        end.  /* bank */
        else put stream m-err m-strerr1  " bank " fun.bank m-strerr2 " FUN "
        fun.fun skip.
    end.
    end. /* dam ne cam */
    if i = j then do:
        j = j + 100.
        display  m-mess4 i with frame c no-label row 10 centered.
        pause 0.
    end.
        i = i + 1.
end. /* fun */

hide frame c.




/*

i = 0.
for each gl no-lock :
    if not (gl.subled = "cif" or gl.subled = "lon" or gl.subled = "dfb" or
    gl.subled = "fun" ) then
    for each crc no-lock :
        find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock
        no-error.
        if available glbal then do:
        if glbal.bal <> 0 then do:
            m-hs = ? .
            if
            gl.type = "L" or gl.type = "O" then m-sum = - glbal.bal.
            else m-sum = glbal.bal.
            /* glbal.dam - glbal.cam. */
            m-srok = 0.
            run newbld (gl.gl,gl.type,crc.crc,crc.code,?,?,m-sum,m-srok).

    if gl.type eq "L" or gl.type eq "O" then m-sum = - m-sum.

    if v-col eq v-col0 and v-row eq v-row0 then do:
        put stream m-out "                      "
        crc.code " "
        gl.gl " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sum = v-sum +
        m-sum * crc.rate[1] / crc.rate[9].
    end.



        end.    /* glbal */
        end.
        else put stream m-err m-strerr1  " glbal  " m-strerr2 " gl "
        gl.gl crc.code
        skip.
    end. /* crc */
        i = i + 1.
        display  m-mess5 i with frame d no-label row 10 centered.
        pause 0.
end.

hide frame d.
*/

/* Временный */

v-row0 = v-row0 + 1.
if v-row0 eq 325 then do:
i1 = v-col0.
i = v-col0.
{izki01.f}

view stream m-out frame a11head.
for each izki break by kods:
    if izki.kods eq "310101784" then izki.name = g-comp.
    if izki.kods eq "" then izki.name = "".
    repeat j = 1 to 6 :
        izki.summa[7] = izki.summa[7] + izki.summa[j].
    end.
    {izki011.f}
    view stream m-out frame a11h.
    view stream m-out frame a11t.
    display stream m-out izki with frame a11.

    export stream m-out1 "A1" v-col0 izki.name izki.kods
    izki.summa[1]
    izki.summa[2]
    izki.summa[3]
    izki.summa[4]
    izki.summa[5]
    izki.summa[6]
    izki.summa[7].

    /*
    repeat while index(izki.name,"'") ne 0 :
        substring(izki.name,index(izki.name,"'"),1) = '"'.
    end.
    put stream m-out1 unformatted
    "'A1' '" v-col0 "' '"
    izki.name "' '"
    izki.kods "' '"
    izki.summa[1] "' '"
    izki.summa[2] "' '"
    izki.summa[3] "' '"
    izki.summa[4] "' '"
    izki.summa[5] "' '"
    izki.summa[6] "' '"
    izki.summa[7] "'"
    skip.
    */

    accumulate izki.summa[1] (total).
    accumulate izki.summa[2] (total).
    accumulate izki.summa[3] (total).
    accumulate izki.summa[4] (total).
    accumulate izki.summa[5] (total).
    accumulate izki.summa[6] (total).
    accumulate izki.summa[7] (total).

    if last(kods) then do:
        display stream m-out
        accum total summa[1] @ izki.summa[1]
        accum total summa[2] @ izki.summa[2]
        accum total summa[3] @ izki.summa[3]
        accum total summa[4] @ izki.summa[4]
        accum total summa[5] @ izki.summa[5]
        accum total summa[6] @ izki.summa[6]
        accum total summa[7] @ izki.summa[7]
        with frame a11a.
        view stream m-out frame a11e.
    end.


    delete izki.
end.

page stream m-out.

v-row0 = 3121.
end.

/*
put stream m-out
fill("-",78) format "x(78)" skip
v-mess3 v-sum at 60 skip(3) .
put stream m-outp
fill("-",78) format "x(78)" skip
v-mess3 v-sump at 71 skip(3).
*/


end.

i1 = v-col0.
i = v-col0.
{izki02.f}

view stream m-out frame a21head.
for each izki break by kods:
    if izki.kods eq "" then izki.name = "".
    if izki.kods eq "310101784" then izki.name = g-comp.
    repeat j = 1 to 6 :
        izki.summa[7] = izki.summa[7] + izki.summa[j].
    end.
    {izki021.f}

    view stream m-out frame a21h.

    view stream m-out frame a21t.
    display stream m-out izki with frame a21.

    export stream m-out1 "A2" v-col0 izki.name izki.kods
    izki.summa[1]
    izki.summa[2]
    izki.summa[3]
    izki.summa[4]
    izki.summa[5]
    izki.summa[6]
    izki.summa[7].


    /*
    repeat while index(izki.name,"'") ne 0 :
        substring(izki.name,index(izki.name,"'"),1) = '"'.
    end.
    put stream m-out1 unformatted
    "'A2' '" v-col0 "' '"
    izki.name "' '"
    izki.kods "' '"
    izki.summa[1] "' '"
    izki.summa[2] "' '"
    izki.summa[3] "' '"
    izki.summa[4] "' '"
    izki.summa[5] "' '"
    izki.summa[6] "' '"
    izki.summa[7] "'"
    skip.
    */


    accumulate izki.summa[1] (total).
    accumulate izki.summa[2] (total).
    accumulate izki.summa[3] (total).
    accumulate izki.summa[4] (total).
    accumulate izki.summa[5] (total).
    accumulate izki.summa[6] (total).
    accumulate izki.summa[7] (total).

    if last(kods) then do:
        display stream m-out
        accum total summa[1] @ izki.summa[1]
        accum total summa[2] @ izki.summa[2]
        accum total summa[3] @ izki.summa[3]
        accum total summa[4] @ izki.summa[4]
        accum total summa[5] @ izki.summa[5]
        accum total summa[6] @ izki.summa[6]
        accum total summa[7] @ izki.summa[7]
        with frame a21a.
        view stream m-out frame a21e.
    end.
    delete izki.
end.
    page stream m-out.

/*
put stream m-out "Pozicija " v-row0 " aile " v-col0 skip.
for each izki :
    display stream m-out izki.
    delete izki.
end.
*/


v-col0 = v-col0 + 1.

end.



output stream m-out close.
output stream m-out1 close.
output stream m-err close.


{image1.i rpt.img}.


unix silent value(dest) izki.txt.
pause 0.

return.
