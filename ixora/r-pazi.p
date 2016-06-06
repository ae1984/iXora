/* r-pazi.p
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


/* r-arppaz.p
   остаток на счетах ARP на заданную дату по счету главной книги
*/

{mainhead.i ARPBAL}

def var v-bal as dec format "zz,zzz,zzz,zzz.99-".
define variable v-balrate as dec format "zz,zzz,zzz,zzz.99-".
def var v-asof as date label "DATE".
define variable varp like arp.gl.
def var sum-bal as dec format "zz,zzz,zzz,zzz.99-".
def var sum-balra as dec format "zz,zzz,zzz,zzz.99-".
def var gl-bal as dec format "zz,zzz,zzz,zzz.99-".
def var gl-balra as dec format "zz,zzz,zzz,zzz.99-".
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

    vtitle = {t-arp.f}.
    {report2.i 150}

    find gl where gl.gl eq arp.gl no-lock.
        if first-of(arp.gl) then do:
            display gl.gl gl.des v-asof with side-label frame gl.
            put fill("-",150) format "x(150)" skip.
            put "КАРТ.  Nr."
            "     С    " 
            "     ПО      "
            "ТИП "
            " РИСК"
            "       ОПИСАНИЕ "
            "              ГЕО" 
            " ВАЛ"
            "            НОМИНАЛ " 
            "             НОМИНАЛ  Ls" skip.
            put fill("-",150) format "x(150)" skip.
        end.

    /* остаток на счету на текущий момент */
    if gl.type eq "A"
        then v-bal = arp.dam[1] - arp.cam[1].
    else
        v-bal = arp.cam[1] - arp.dam[1].

    /* остаток на счету на дату запроса */
    for each jl no-lock where jl.acc eq arp.arp and jl.gl eq arp.gl
        and jl.jdt gt v-asof  use-index acc:

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

    if v-bal ne 0 then
    put
        arp.arp " "
        arp.rdt  format "99/99/9999" " "
        arp.duedt " "
        arp.type  format "999" " "
        arp.risk format "zz9" " "
        arp.des " "
        arp.geo  format "x(3)"
        " " arp.crc " "
        v-bal  
        format "z,zzz,zzz,zzz,zzz,zzz.99-" " "
        v-balrate 
        format "z,zzz,zzz,zzz,zzz,zzz.99-" skip.

     sum-bal = sum-bal + v-bal.
     sum-balra = sum-balra + v-balrate.
     gl-bal = gl-bal + v-bal.
     gl-balra = gl-balra + v-balrate.

    if last-of(arp.crc) and sum-bal ne 0 then do:
        put  fill(" ",50) format "x(50)"
        "Итого по валюте:             " sum-bal 
         format "z,zzz,zzz,zzz,zzz,zzz.99-" " "
        sum-balra  format "z,zzz,zzz,zzz,zzz,zzz.99-" skip.
        sum-bal = 0. sum-balra = 0.
    end.
    if last-of(arp.gl) and gl-bal ne 0 then do:
        put fill(" ",50) format "x(50)"
        "Итого по СчГлКН:                                    "
        /*gl-bal  format "z,zzz,zzz,zzz,zzz,zzz.99-" */
        gl-balra  format "z,zzz,zzz,zzz,zzz,zzz.99-" skip(2).

        gl-bal = 0. gl-balra = 0.
    end.
    


            
        /*{d-arp.f}*/
end.
{report3.i}
{image3.i}
