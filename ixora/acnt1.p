/* acnt1.p
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

/* acnt1.p */

{mainhead.i}

define variable vtype like crcard.crdtstn.
define buffer bcrcard for crcard.
def buffer gll for gl.
def var kkost like aab.bal.
def var v-crcard like crcard.crcard.
define variable titl as character format "x(180)" initial
"   KLIENTA NOSAUKUMS            KONTS#           ATLIKUMS            IESALD.
       K/K IESALD.     PIEJAMAIS.ATL.     KRED§TA LIN.   K/K NUMURS     LIMITS".
def buffer b-aaa for aaa.
def temp-table kart
    field kname like cif.name
    field kaaa like aaa.aaa
    field kost like aab.bal
    field kcrcard like crcard.crcard
    field khbal like aaa.hbal
    /*Ozornins*/
    field kchkamt like aas.chkamt
    field kpieat like aab.bal /*piejamais. atl.*/
    field kredli like aab.bal /*kredЁta lin.*/
    field kfname like crcard.fname.
{image1.i rpt.img}
                                  /*
update vtype label "KARTES TIPS"
    help "1 - Classic,  2 - Business,  3 - Bankas darbinieki"
    validate (vtype le 3 and vtype gt 0, "WRONG ENTRY")
    with centered side-labels no-box.
                                    */
update v-crcard validate (length (v-crcard) eq 16, "Try again")
    label "CARD" with side-label centered row 3 frame aaa.
find crcard where crcard.crcard = v-crcard no-error.
{image2.i}
{report1.i 180}

vtitle = "INFORM…CIJA PAR KLIENTU KONTIEM UN KARTЁM".
find crcard where crcard.crcard = v-crcard no-lock no-error.

if available crcard then do:
    if crcard.crdtstn lt 3 then do:
        find aaa where aaa.aaa eq crcard.crdt no-lock no-error.
        if not available aaa then put "Konts ne eksistё" skip.
        if available aaa then do:
            find cif where cif.cif eq aaa.cif no-lock no-error.
            if available cif then do:
                for each aaa where aaa.cif eq cif.cif break by aaa.aaa:

                    for each crcard where crcard.crdt eq aaa.aaa
                        no-lock break by crcard.crcard:
                        {report2.i 180 "titl"}
                        find first kart where kart.kcrcard eq crcard.crcard
                            no-error.
                        if not available kart then do:
                            create kart.
                            kart.kcrcard = crcard.crcard.
                            kart.kfname = crcard.fname.
                        end.
                        IF first-of (crcard.crcard) then do:
                            kart.kaaa = crcard.crdt.

                            find gl where gl.gl eq aaa.gl no-lock no-error.
                            if gl.type eq "A" or gl.type eq "E" then
                                kart.kost = aaa.dr[1] - aaa.cr[1].
                            else
                                kart.kost = aaa.cr[1] - aaa.dr[1].

                        /* наличие/отсутствие hold balance */
                            for each aas where aas.aaa eq crcard.crdt no-lock:
                                if aas.chkno ne 999999 and aas.sic eq "HB" then
                                    kart.khbal = kart.khbal + aas.chkamt.
                                else
                                    kart.kchkamt = aas.chkamt.
                            end.
                        /*наличие/отсутствие ODA*/

                            if aaa.craccnt ne "" then do:
                                find first b-aaa where b-aaa.aaa = aaa.craccnt.
                                if available b-aaa then do:
                                    find gll where gll.gl eq b-aaa.gl
                                    no-lock no-error.
                                    if gll.type eq "A" or gll.type eq "E" then
                                        kkost = b-aaa.dr[1] - b-aaa.cr[1].
                                    else
                                        kkost = b-aaa.cr[1] - b-aaa.dr[1].
                                end.
                                    kart.kpieat = b-aaa.opnamt - kkost.
                                    kart.kredli = b-aaa.opnamt.

                            end.
                        /* карты с лимитами */
                            for each bcrcard where bcrcard.crdt eq crcard.crdt
                                break by bcrcard.crcard:

                                if first (bcrcard.crcard) then do:
                                    find cif where cif.cif eq aaa.cif
                                    no-lock no-error.
                                    kart.kname = trim(trim(cif.prefix) + " " + trim(cif.name)).
                                end.
                            end.
                        end.
                    end.
                end.
            end.
        end.
    end.
/*end.*/
    else do:
        find arp where arp.arp eq crcard.crdt no-lock no-error.
        if not available arp then put "Konts ne eksistё".
        else do:
            for each crcard where crcard.crdt eq arp.arp
                no-lock break by crcard.crcard:
                /*{report2.i 120 }*/
                find first kart where kart.kcrcard eq crcard.crcard
                    no-error.
                if not available kart then do:
                    create kart.
                    kart.kcrcard = crcard.crcard.
                    kart.kfname = crcard.fname.
                end.
                IF first-of (crcard.crcard) then do:
                    kart.kaaa = crcard.crdt.

                    find gl where gl.gl eq arp.gl no-lock no-error.
                    if gl.type eq "A" or gl.type eq "E" then
                            kart.kost = arp.dam[1] - arp.cam[1].
                    else
                            kart.kost = arp.cam[1] - arp.dam[1].
                end.
            end.
        end.
    end.
/*****************/
end.
put "INFORM…CIJA PAR KLIENTU KONTIEM UN KARTЁM" skip.
put fill("=",180) format "x(180)" skip.
put titl skip(1).
put fill("=",180) format "x(180)" skip.
for each kart no-lock break by kaaa by kcrcard :
        if first-of(kaaa) then do:
            put kname " " kaaa " " kost format "z,zzz,zzz,z99.99-" " "
            khbal format "z,zzz,zzz,z99.99-" " "
            kchkamt format "z,zzz,zzz,z99.99-" " "
            kpieat format "z,zzz,zzz,z99.99-" " "
            kredli format "z,zzz,zzz,z99.99-" " "
            kcrcard " " kfname skip.
        end.
        else
            put space (132) kcrcard " " kfname skip.
end.

{report3.i}
{image3.i}
