/* newbilanced.p
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
begin 07.11.94

   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{global.i}
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
def var i as int.
def var i1 as int.
def var j as int.
def var la as char.
def var m-key2 as log.
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


def stream m-out.
output stream m-out to nbdc.txt.

def stream m-outp.
output stream m-outp to nbdcp.txt.

output stream m-err to newbilanced.err.


def temp-table glf
    field gl like gl.gl.

def temp-table glfp
    field gl like gl.gl.


{nb0.f}
{nbd.f}
v-sum = 0.
v-sump = 0.


if v-col0 eq 0 then v-col0 = -1.
if v-row0 eq 0 then v-row0 = -1.
if v-colp0 eq 0 then v-colp0 = -1.
if v-rowp0 eq 0 then v-rowp0 = -1.


find sysc where sysc.sysc = "GLDATE" no-lock no-error.
dame = string(day(sysc.daval),"99") + string(month(sysc.daval),"99").
dames = sysc.daval.

find sysc where sysc.sysc = "BILEXT" no-lock no-error.
if available sysc then m-ext = "." + trim(sysc.chval). else m-ext = ".".

find sysc where sysc.sysc = "GLTD" no-lock no-error.
if available sysc then v-gltd = sysc.chval. else v-gltd = "".

if v-col0 gt 0 and v-row0 gt 0 then do:
    view stream m-out frame hfnbd.
    put stream m-out v-mess1 v-row0 v-mess2 v-col0 skip
    fill("-",131) format "x(131)" skip.
end.
if v-colp0 gt 0 and v-rowp0 gt 0 then do:
    view stream m-outp frame hfnbdp.
    put stream m-outp v-mess1 v-rowp0 v-mess2 v-colp0 skip
    fill("-",132) format "x(132)" skip.
end.



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

for each glfp :
    delete glfp.
end.

for each glbl where p-kodsp eq v-rowp0 no-lock :
    find first glfp where glfp.gl eq glbl.gl no-error.
    if not available glfp then do:
        create glfp.
        glfp.gl = glbl.gl.
    end.
end.




i = 0. j = 0.

m-lgr = ?.

for each lgr no-lock :

find first glf where glf.gl eq lgr.gl no-error.
find first glfp where glfp.gl eq lgr.gl no-error.

if  available glf or available glfp then do:
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
        put stream m-out
        "           " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(40)" " "
        aaa.aaa " " aaa.cif "     "
        crc.code " "
        aaa.gl " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * m-rate
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sum = v-sum +
        m-sum * m-rate.
    end.

    if v-colp eq v-colp0 and v-rowp eq v-rowp0 then do:
        put stream m-outp
        "           " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" " "
        aaa.aaa " " aaa.cif "     "
        crc.code " "
        aaa.gl " "
        m-srok " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * m-rate
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sump = v-sump +
        m-sum * m-rate.
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





i = 0. j = 0.

for each lon no-lock break by cif:

find first glf where glf.gl eq lon.gl no-error.
find first glfp where glfp.gl eq lon.gl no-error.


    if first-of(lon.cif) then do:
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
    end.

if  available glf or available glfp then do:

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
                /*
                find loncnt where loncnt.lon = lon.lon no-lock no-error.
                if available loncnt then do:
                    find lcnt where lcnt.lcnt = loncnt.lcnt no-lock no-error.
                    if available lcnt then
                    m-srok = lcnt.duedt - lcnt.rdt.
                end.
                */
                find first ln%his where ln%his.lon = lon.lon and
                     ln%his.opnamt > 0 and 
                     ln%his.rdt <> ? and 
                     ln%his.duedt <> ? no-lock no-error.
                if available ln%his 
                then m-srok = ln%his.duedt - ln%his.rdt.
                if m-sum <> 0 then do:
run newbl1d
(gl.gl,gl.type,crc.crc,crc.code,m-geo,m-cgr,lon.loncat,m-sum,m-srok).
    find loncon where loncon.lon eq lon.lon no-lock no-error.
    if gl.type eq "L" or gl.type eq "O" then m-sum = - m-sum.
    if v-col eq v-col0 and v-row eq v-row0 then do:
        put stream m-out
        loncon.lcnt " " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(40)" " "
        lon.lon " " lon.cif "     "
        crc.code " "
        lon.gl " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sum = v-sum +
        m-sum * crc.rate[1] / crc.rate[9].
    end.

    if v-colp eq v-colp0 and v-rowp eq v-rowp0 then do:
        put stream m-outp
        loncon.lcnt " " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" " "
        lon.lon " " lon.cif "     "
        crc.code " "
        lon.gl " "
        m-srok " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sump = v-sump +
        m-sum * crc.rate[1] / crc.rate[9].
    end.
    end.

                else m-okey = yes.
                if not m-okey then put stream m-err
                m-strerr0  " lon " lon.lon
                ", cif " lon.cif skip.
        end.
    end.
    end.
    if i = j then do:
        j = j + 100.
        display  m-mess2 i with frame l
        no-label row 10 centered.
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
        put stream m-out
        bank.name format "x(51)" " "
        dfb.dfb "            "
        crc.code " "
        m-gl " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sum = v-sum +
        m-sum * crc.rate[1] / crc.rate[9].
    end.

    if v-colp eq v-colp0 and v-rowp eq v-rowp0 then do:
        put stream m-outp
        bank.name format "x(41)" " "
        dfb.dfb "            "
        crc.code " "
        dfb.gl " "
        m-srok " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sump = v-sump +
        m-sum * crc.rate[1] / crc.rate[9].
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
        display  m-mess3 i with frame b
        no-label row 10 centered.
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
        put stream m-out
        bank.name format "x(51)" " "
        fun.fun " " fun.dfb " "
        crc.code " "
        fun.gl " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sum = v-sum +
        m-sum * crc.rate[1] / crc.rate[9].
    end.

    if v-colp eq v-colp0 and v-rowp eq v-rowp0 then do:
        put stream m-outp
        bank.name format "x(41)" " "
        fun.fun " " fun.dfb " "
        crc.code " "
        fun.gl " "
        m-srok " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sump = v-sump +
        m-sum * crc.rate[1] / crc.rate[9].
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
    end.  /*  dam ne cam */
    if i = j then do:
        j = j + 100.
        display  m-mess4 i with frame c
        no-label row 10 centered.
        pause 0.
    end.
        i = i + 1.
end. /* fun */
hide frame c.






i = 0. j = 0.
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
        put stream m-out
        fill(" ",74) format "x(74)"
        crc.code " "
        gl.gl " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sum = v-sum +
        m-sum * crc.rate[1] / crc.rate[9].
    end.

    if v-colp eq v-colp0 and v-rowp eq v-rowp0 then do:
        put stream m-outp
        fill(" ",64) format "x(64)"
        crc.code " "
        gl.gl " "
        m-srok " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
        v-sump = v-sump +
        m-sum * crc.rate[1] / crc.rate[9].
    end.


        end.    /* glbal */
        end.
        else put stream m-err m-strerr1  " glbal  " m-strerr2 " gl "
        gl.gl crc.code
        skip.
    end. /* crc */
    if i = j then do:
        j = j + 10.
        display  m-mess5 i with frame d
        no-label row 10 centered.
        pause 0.
    end.
        i = i + 1.
end.

hide frame d.

/*

i = 0. j = 0.
for each gl no-lock :
    find first glbl where glbl.gl = gl.gl and  glbl.stsPZ = yes
    no-lock no-error.
    if available glbl  then do:
        for each crc no-lock :
            find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock
            no-error.
            if available glbal then do:
                if glbal.bal <> 0 then do:
                    m-sum = glbal.bal.
                    if glbl.SignSum = true then m-sum = - m-sum.
                    find first MenBilPZ where
                    MenBilPZ.p-kodsPZ = glbl.p-kods and
                    MenBilPZ.stabs = glbl.stabs and
                    MenBilPZ.kod-val = crc.code
                    no-error.
                    if available MenBilPZ then
                    MenBilPZ.summa = MenBilPZ.summa + m-sum.
                    else do:
                        create MenBilPZ.
                        MenBilPZ.p-kodsPZ = glbl.p-kods.
                        MenBilPZ.stabs = glbl.stabs.
                        MenBilPZ.kod-val = crc.code.
                        MenBilPZ.summa = m-sum.
                    end.
                    m-okey = yes.
                end.
            end.
            else put stream m-err m-strerr1  " glbal " m-strerr2 " gl "
            gl.gl crc.code
            skip.
        end.
    end.
    else do:
        find first glbl where glbl.gl = gl.gl
        and glbl.stsPZ = no no-lock no-error.
        if available glbl then m-okey = yes.
        if not m-okey then
        put stream m-err "PZ -> " m-strerr1 " glbl " m-strerr2 " gl " gl.gl
         " " crc.code format "x(3)" skip.
    end.
    i = i + 1.
    display  m-mess5 i with frame d1 no-label row 10 centered.
    pause 0.
end.

hide frame d1.

*/


put stream m-out
fill("-",131) format "x(131)" skip
v-mess3 v-sum at 112 skip(3) .
put stream m-outp
fill("-",132) format "x(132)" skip
v-mess3 v-sump at 113 skip(3).
end.

output stream m-out close.
output stream m-outp close.
output stream m-err close.


{image1.i rpt.img}.

/*
if v-col0 gt 0 and v-row0 gt 0 then
unix silent value(dest) nbdc.txt.
pause 0.
if v-colp0 gt 0 and v-rowp0 gt 0 then
unix silent value(dest) nbdcp.txt.
pause 0.
*/

unix silent value(dest) nbdc.txt.
pause 0.
unix silent value(dest) nbdcp.txt.
pause 0.

return.
/*--------------------------------------------------------------------------
  #3.
     1.izmai‡a - kredЁta ilgums tiek aprё±in–ts pёc pirmatnёj–s izdoЅanas
       inform–cijas (ignorёjot pagarin–jumus) (J.O.)
--------------------------------------------------------------------------*/
