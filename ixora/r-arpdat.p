/* r-arpdat.p
 * MODULE
        остаток на счетах ARP на заданную дату по счету главной книги
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
        19.02.2004 nadejda - не показывать закрытые счета
        03.03.2003 nataly  - был изменен обработчик для вывода счета ГК, а также наложено условие на дату закрытия arp
        06.04.2004 sasco   - был изменен обработчик для вывода счета ГК
*/

{mainhead.i}

def var v-bal as dec format "zz,zzz,zzz,zzz.99-".
define variable v-balrate as dec format "zz,zzz,zzz,zzz.99-".
def var v-asof as date.
define variable varp like arp.gl.

v-asof = g-today.

{image1.i rpt.img}

{a-arp.f}

if g-batch eq false then
    update varp v-asof with row 8 centered no-box side-label frame opt.

{image2.i}
{report1.i 63}

/*
for each crc:
    find last crchis where crchis.crc eq crc.crc and
        crchis.rdt le v-asof no-lock.
    display crc.crc crc.des crchis.rate[1] crchis.rate[9].
end.
*/

for each arp no-lock where arp.gl eq (if varp ne 0 then varp else arp.gl)
    break by arp.gl by arp.crc:

    find gl where gl.gl eq arp.gl no-lock.

    if first-of(arp.gl) then displ gl.gl gl.des with side-label frame gl.
 
    /* 19.02.2004 nadejda - не показывать закрытые счета */
    find sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.acc = arp.arp no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> "msc" and sub-cod.rdt <= v-asof then next.

    vtitle = {t-arp.f}.
    {report2.i 150}

    /* остаток на счету на текущий момент */
    if gl.type eq "A"
        then v-bal = arp.dam[1] - arp.cam[1].
    else
        v-bal = arp.cam[1] - arp.dam[1].

    /* остаток на счету на дату запроса */
    for each jl no-lock where jl.gl eq arp.gl and jl.acc eq arp.arp
        and jl.jdt gt v-asof by jl.jdt:

        if gl.type eq "A" or gl.type eq "E" then
            v-bal = v-bal - jl.dam + jl.cam.
        else
            v-bal = v-bal + jl.dam - jl.cam.
        end.

    if arp.crc ne 1 then do:
        find last crchis where crchis.crc eq arp.crc and crchis.rdt le v-asof
            no-lock.
        v-balrate = v-bal * crchis.rate[1] / crchis.rate[9].
    end.
    else
        v-balrate = v-bal.

    display
        arp.arp label "КАРТОЧ.Nr."
        arp.rdt label "   С    " format "99/99/9999"
        arp.duedt label "   ПО      "
        arp.type label "ТИП " format "999"
        arp.des label "ОПИСАНИЕ"
        arp.geo label "ГЕО" format "x(3)"
        arp.crc label "ВАЛ"
        v-bal (total by arp.gl by arp.crc) label "НОМИНАЛ " 
        format "z,zzz,zzz,zzz,zzz,zzz.99-" 
        v-balrate (total by arp.gl by arp.crc) label "НОМИНАЛ  Ls"
        format "z,zzz,zzz,zzz,zzz,zzz.99-" 
        with down width 150.
            
        /*{d-arp.f}*/
end.
{report3.i}
{image3.i}
