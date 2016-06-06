/* r-trgl.p
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

/* печать оборотов по главной книге с конвертацией */

{mainhead.i}

define variable fdate as date.
define variable tdate as date.
define variable vledger like jl.gl.
define variable titl as character format "x(132)".
define variable conv as dec format "zz,zzz,zzz,zzz.99-".
define variable vconv as dec format "zz,zzz,zzz,zzz.99-".
define variable damount as dec format "zz,zzz,zzz,zzz.99-" initial 0.
define variable camount as dec format "zz,zzz,zzz,zzz.99-" initial 0.
define variable vglbal like glbal.bal init 0.
define variable vlglbal like glbal.bal.
define variable sdate as date.
define variable strokis as character.
def var sdam as dec format "zzz,zzz,zzz,zzz.99-" initial 0.
def var scam as dec format "zzz,zzz,zzz,zzz.99-" initial 0.

{p-trgl.f}

fdate = g-today.
tdate = g-today.

{image1.i rpt.img}
{a-trgl.f}

update vledger fdate tdate
    with row 8 centered no-box side-labels frame opt.

{image2.i}
{report1.i 63}

find gl where gl.gl eq vledger no-lock.

titl = {t-trgl.f}.
{report2.i 132 "titl"}

for each jl where jl.gl eq vledger and jl.jdt ge fdate and jl.jdt le tdate
    no-lock use-index gl break by jl.jdt by jl.crc:

    if first-of (jl.jdt) then do:
        put jl.jdt skip.
        sdate = jl.jdt.
    end.

    /* вход.остаток на дату начала периода с конвертацией */
    if first-of (jl.crc) then do:
        find last cls where cls.whn < sdate no-lock no-error.
            find last glday where glday.gdt le cls.whn 
            and glday.gl = jl.gl and
            glday.crc = jl.crc no-lock no-error.
            if available glday then do:
                if gl.type eq "A" or gl.type eq "E" then
                    vglbal = glday.dam - glday.cam.
                else
                    vglbal = glday.cam - glday.dam.
            end.
            else vglbal = 0.
        vlglbal = vglbal.
        find crc where crc.crc eq jl.crc.

        find last crchis where crchis.crc eq jl.crc and crchis.rdt le sdate
            no-lock.
        conv = crchis.rate[1] / crchis.rate[9].
        put jl.crc  "  " crc.des format "x(20)" skip
            array-a[1] format "x(30)" vglbal format "zz,zzz,zzz,zzz.99-"
            vglbal * conv format "zz,zzz,zzz,zzz.99-" skip
            space(13) array-a[3] format "x(67)" skip.
    end.

    /* обороты за период с конвертацией */
    strokis = trim (jl.rem[1]) + " " + trim (jl.rem[2]) + " " +
        trim (jl.rem[3]) + " " + jl.rem[4] + " " + jl.rem[5].

    put jl.dam jl.dam * conv format "zz,zzz,zzz,zzz.99-"
        jl.cam jl.cam * conv format "zz,zzz,zzz,zzz.99-" "   " jl.jh
        "   " jl.who " " substring (strokis, 1, 30) format "x(30)" skip.

    if length (trim (substring (strokis, 31, 30) )) ne 0 then
        put space(101) substring (strokis, 31, 30) format "x(30)" skip.

    if length (trim (substring (strokis, 61, 30) )) ne 0 then
        put space(101) substring (strokis, 61, 30) format "x(30)" skip.

    if length (trim (substring (strokis, 91, 30) )) ne 0 then
        put space(101) substring (strokis, 91, 30) format "x(30)" skip.

    if gl.type eq "A" or gl.type eq "E" then
        vlglbal = vlglbal + jl.dam - jl.cam.
    else
        vlglbal = vlglbal + jl.cam - jl.dam.

    damount = damount + jl.dam.
    camount = camount + jl.cam.

    if last-of (jl.crc) then do:
        put array-a[4] format "x(25)" damount format "zz,zzz,zzz,zzz.99-".
        put array-a[6] format "x(25)" camount format "zz,zzz,zzz,zzz.99-"
            skip.

        put array-a[5] format "x(25)" damount * conv
            format "zz,zzz,zzz,zzz.99-".
        put array-a[7] format "x(25)" camount * conv
            format "zz,zzz,zzz,zzz.99-" skip.

        put array-a[2] format "x(30)" vlglbal format "zz,zzz,zzz,zzz.99-"
            vlglbal * conv format "zz,zzz,zzz,zzz.99-" skip(1).
        sdam = sdam + damount * conv.
        scam = scam + camount * conv.

        damount = 0.   camount = 0.
    end.
end.
        put skip 'ИТОГО ' skip.
        put array-a[5] format "x(25)" sdam
            format "zzz,zzz,zzz,zzz.99-".
        put array-a[7] format "x(25)" scam
            format "zzz,zzz,zzz,zzz.99-" skip.

{report3.i}
{image3.i}
