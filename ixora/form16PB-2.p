/* form16PB-2.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет 16 ПБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-8-2
 * AUTHOR
        09.11.2012 dmitriy
 * BASES
        TXB COMM
 * CHANGES

*/

def shared temp-table wrk-br
    field code as int
    field jh as int
    field br_name as char
    field br_code as char
    field docnum as char
    field crc as int
    field gl_dr as int
    field gl_cr as int
    field kass_sim as char
    field rem as char
    field kbe as int
    field kod as int
    field knp as int
    field sum_nom as deci
    field sum_ekv as deci.

def shared temp-table wrk-ost
    field fil as char
    field gl  as int
    field crc as char
    field nom_beg as deci
    field nom_end as deci
    field ekv_beg as deci
    field ekv_end as deci.

def shared temp-table wrk-obr
    field fil as char
    field jh  as int
    field glD as int
    field glC as int
    field glDname as char
    field glCname as char
    field dacc as char
    field cacc as char
    field daccname as char
    field caccname as char
    field trx as char
    field crc as char
    field dr1 as deci
    field dr2 as deci
    field cr1 as deci
    field cr2 as deci
    field kas as int
    field kod as int
    field kbe as int
    field knp as int
    field country1 as char
    field country2 as char
    field code as int
    field rem  as char.

def buffer b-jl for txb.jl.

def shared var v-dt1 as date.
def shared var v-dt2 as date.

def var kod as int.
def var kbe as int.
def var knp as int.
def var sum as deci.
def var v-code as int.
def var v-country1 as char.
def var v-country2 as char.
def var v-glname as char.
def var v-aaaname as char.

find first txb.cmp no-lock no-error.

for each txb.crc where txb.crc.crc > 1 no-lock:
    /* 100 */
    find last txb.glday where txb.glday.gl = 100100 and txb.glday.gdt <= v-dt1 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        create wrk-obr.
        wrk-obr.code = 100.
        wrk-obr.crc = txb.crc.code.
        wrk-obr.cr1 = txb.glday.bal.
    end.
    find last txb.glday where txb.glday.gl = 100500 and txb.glday.gdt <= v-dt1 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        create wrk-obr.
        wrk-obr.code = 100.
        wrk-obr.crc = txb.crc.code.
        wrk-obr.cr1 = txb.glday.bal.
    end.
    find last txb.glday where txb.glday.gl = 100110 and txb.glday.gdt <= v-dt1 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        create wrk-obr.
        wrk-obr.code = 100.
        wrk-obr.crc = txb.crc.code.
        wrk-obr.cr1 = txb.glday.bal.
    end.
    find last txb.glday where txb.glday.gl = 100200 and txb.glday.gdt <= v-dt1 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        create wrk-obr.
        wrk-obr.code = 100.
        wrk-obr.crc = txb.crc.code.
        wrk-obr.cr1 = txb.glday.bal.
    end.

    /* 600 */
    find last txb.glday where txb.glday.gl = 100100 and txb.glday.gdt <= v-dt2 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        create wrk-obr.
        wrk-obr.code = 600.
        wrk-obr.crc = txb.crc.code.
        wrk-obr.cr1 = txb.glday.bal.
    end.
    find last txb.glday where txb.glday.gl = 100500 and txb.glday.gdt <= v-dt2 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        create wrk-obr.
        wrk-obr.code = 600.
        wrk-obr.crc = txb.crc.code.
        wrk-obr.cr1 = txb.glday.bal.
    end.
    find last txb.glday where txb.glday.gl = 100110 and txb.glday.gdt <= v-dt2 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        create wrk-obr.
        wrk-obr.code = 600.
        wrk-obr.crc = txb.crc.code.
        wrk-obr.cr1 = txb.glday.bal.
    end.
    find last txb.glday where txb.glday.gl = 100200 and txb.glday.gdt <= v-dt2 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        create wrk-obr.
        wrk-obr.code = 600.
        wrk-obr.crc = txb.crc.code.
        wrk-obr.cr1 = txb.glday.bal.
    end.
end.

/*Расшифровка по остаткам*/

for each txb.crc where txb.crc.crc > 1 no-lock:
    do transaction:
    create wrk-ost.
    find last txb.glday where txb.glday.gl = 100100 and txb.glday.gdt <= v-dt1 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        wrk-ost.gl = txb.glday.gl.
        wrk-ost.crc = txb.crc.code.
        wrk-ost.fil = txb.cmp.name.
        wrk-ost.nom_beg = txb.glday.bal.
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dt1 no-lock no-error.
        if avail txb.crchis then
        wrk-ost.ekv_beg = txb.glday.bal * txb.crchis.rate[1].
    end.
    find last txb.glday where txb.glday.gl = 100100 and txb.glday.gdt <= v-dt2 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        wrk-ost.gl = txb.glday.gl.
        wrk-ost.crc = txb.crc.code.
        wrk-ost.fil = txb.cmp.name.
        wrk-ost.nom_end = txb.glday.bal.
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dt2 no-lock no-error.
        if avail txb.crchis then
        wrk-ost.ekv_end = txb.glday.bal * txb.crchis.rate[1].
    end.
    end.

    do transaction:
    create wrk-ost.
    find last txb.glday where txb.glday.gl = 100500 and txb.glday.gdt <= v-dt1 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        wrk-ost.gl = txb.glday.gl.
        wrk-ost.crc = txb.crc.code.
        wrk-ost.fil = txb.cmp.name.
        wrk-ost.nom_beg = txb.glday.bal.
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dt1 no-lock no-error.
        if avail txb.crchis then
        wrk-ost.ekv_beg = txb.glday.bal * txb.crchis.rate[1].
    end.
    find last txb.glday where txb.glday.gl = 100500 and txb.glday.gdt <= v-dt2 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        wrk-ost.gl = txb.glday.gl.
        wrk-ost.crc = txb.crc.code.
        wrk-ost.fil = txb.cmp.name.
        wrk-ost.nom_end = txb.glday.bal.
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dt2 no-lock no-error.
        if avail txb.crchis then
        wrk-ost.ekv_end = txb.glday.bal * txb.crchis.rate[1].
    end.
    end.

    do transaction:
    create wrk-ost.
    find last txb.glday where txb.glday.gl = 100110 and txb.glday.gdt <= v-dt1 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        wrk-ost.gl = txb.glday.gl.
        wrk-ost.crc = txb.crc.code.
        wrk-ost.fil = txb.cmp.name.
        wrk-ost.nom_beg = txb.glday.bal.
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dt1 no-lock no-error.
        if avail txb.crchis then
        wrk-ost.ekv_beg = txb.glday.bal * txb.crchis.rate[1].
    end.
    find last txb.glday where txb.glday.gl = 100110 and txb.glday.gdt <= v-dt2 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        wrk-ost.gl = txb.glday.gl.
        wrk-ost.crc = txb.crc.code.
        wrk-ost.fil = txb.cmp.name.
        wrk-ost.nom_end = txb.glday.bal.
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dt2 no-lock no-error.
        if avail txb.crchis then
        wrk-ost.ekv_end = txb.glday.bal * txb.crchis.rate[1].
    end.
    end.

    do transaction:
    create wrk-ost.
    find last txb.glday where txb.glday.gl = 100200 and txb.glday.gdt <= v-dt1 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        wrk-ost.gl = txb.glday.gl.
        wrk-ost.crc = txb.crc.code.
        wrk-ost.fil = txb.cmp.name.
        wrk-ost.nom_beg = txb.glday.bal.
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dt1 no-lock no-error.
        if avail txb.crchis then
        wrk-ost.ekv_beg = txb.glday.bal * txb.crchis.rate[1].
    end.
    find last txb.glday where txb.glday.gl = 100200 and txb.glday.gdt <= v-dt2 and txb.glday.crc = txb.crc.crc no-lock no-error.
    if avail txb.glday then do:
        wrk-ost.gl = txb.glday.gl.
        wrk-ost.crc = txb.crc.code.
        wrk-ost.fil = txb.cmp.name.
        wrk-ost.nom_end = txb.glday.bal.
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dt2 no-lock no-error.
        if avail txb.crchis then
        wrk-ost.ekv_end = txb.glday.bal * txb.crchis.rate[1].
    end.
    end.
end. /*Расшифровка по остаткам*/

/*Расшифровка по оборотам*/
for each txb.jl where txb.jl.jdt >= v-dt1 and txb.jl.jdt <= v-dt2 and txb.jl.crc > 1 and (txb.jl.gl = 100100 or txb.jl.gl = 100500) no-lock:
    find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
    if avail crc then do:
        find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
        if avail txb.crchis then do:
            run GetEKNP(txb.jl.jh, txb.jl.ln, txb.jl.dc, input-output KOd, input-output KBe, input-output KNP).

            v-aaaname = "".
            find first txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
            if avail txb.aaa then v-aaaname = txb.aaa.name.

            v-glname = "".
            find first txb.gl where txb.gl.gl = txb.jl.gl no-lock no-error.
            if avail txb.gl then v-glname = txb.gl.des.

            create wrk-obr.
            wrk-obr.fil = txb.cmp.name.
            wrk-obr.jh = txb.jl.jh.
            wrk-obr.trx = txb.jl.trx.
            wrk-obr.crc = txb.crc.code.
            wrk-obr.rem = txb.jl.rem[1].

            if txb.jl.dc = "D" then do:
                wrk-obr.dr1 = txb.jl.dam.
                wrk-obr.dr2 = txb.jl.dam * txb.crchis.rate[1].
                wrk-obr.dacc = txb.jl.acc.
                wrk-obr.daccname = v-aaaname.
                wrk-obr.glD = txb.jl.gl.
                wrk-obr.glDname = v-glname.
                wrk-obr.kod = kod.
                wrk-obr.knp = knp.
                find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                if avail b-jl then do:
                    run GetEKNP(b-jl.jh, b-jl.ln, b-jl.dc, input-output KOd, input-output KBe, input-output KNP).
                    wrk-obr.kbe = kbe.
                    wrk-obr.glC = b-jl.gl.
                    wrk-obr.cacc = b-jl.acc.

                    find first txb.aaa where txb.aaa.aaa = b-jl.acc no-lock no-error.
                    if avail txb.aaa then wrk-obr.caccname = txb.aaa.name.

                    find first txb.gl where txb.gl.gl = b-jl.gl no-lock no-error.
                    if avail txb.gl then wrk-obr.glCname = txb.gl.des.
                end.
            end.

            if txb.jl.dc = "C" then do:
                wrk-obr.cr1 = txb.jl.cam.
                wrk-obr.cr2 = txb.jl.cam * txb.crchis.rate[1].
                wrk-obr.cacc = txb.jl.acc.
                wrk-obr.caccname = v-aaaname.
                wrk-obr.glC = txb.jl.gl.
                wrk-obr.glCname = v-glname.
                wrk-obr.kbe = kbe.
                find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                if avail b-jl then do:
                    run GetEKNP(b-jl.jh, b-jl.ln, b-jl.dc, input-output KOd, input-output KBe, input-output KNP).
                    wrk-obr.kod = kod.
                    wrk-obr.knp = knp.
                    wrk-obr.glD = b-jl.gl.
                    wrk-obr.dacc = b-jl.acc.

                    find first txb.aaa where txb.aaa.aaa = b-jl.acc no-lock no-error.
                    if avail txb.aaa then wrk-obr.daccname = txb.aaa.name.

                    find first txb.gl where txb.gl.gl = b-jl.gl no-lock no-error.
                    if avail txb.gl then wrk-obr.glDname = txb.gl.des.
                end.
            end.

            find first txb.jlsach where txb.jlsach.jh = txb.jl.jh and txb.jlsach.ln = txb.jl.ln no-lock no-error.
            if avail txb.jlsach then wrk-obr.kas = txb.jlsach.sim.


            find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
            if avail txb.jh and jh.sub = "jou" then do:
                find first txb.joudop where txb.joudop.docnum = txb.jh.ref no-lock no-error.
                if avail txb.joudop and num-entries(txb.joudop.fname,"^") >= 9 then do:
                    wrk-obr.country2 = entry(9,txb.joudop.fname,"^").
                    v-country2 = entry(9,txb.joudop.fname,"^").
                end.
            end.

            run FindCode. wrk-obr.code = v-code.
        end.
    end.
end. /*Расшифровка по оборотам*/

procedure FindCode:
        v-code = 0.
        /* 230 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and (substr(string(kod),1,1) = "1" or kod = 0) and
        (string(b-jl.gl) begins "2203" or
         string(b-jl.gl) begins "2211" or
         string(b-jl.gl) begins "2215" or
         string(b-jl.gl) begins "2217" or
         string(b-jl.gl) begins "2219" or
         string(b-jl.gl) begins "2223" or
         string(b-jl.gl) begins "2240" ) then v-code = 230.

        /* 240 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and substr(string(kod),1,1) = "2" and
        (string(b-jl.gl) begins "2203" or
         string(b-jl.gl) begins "2211" or
         string(b-jl.gl) begins "2215" or
         string(b-jl.gl) begins "2217" or
         string(b-jl.gl) begins "2219" or
         string(b-jl.gl) begins "2223" or
         string(b-jl.gl) begins "2240" ) then v-code = 240.

        /* 250 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and b-jl.gl = 185800 then v-code = 250.

        /* 260 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and (substr(string(kod),1,1) = "1" or kod = 0)  and
        (string(b-jl.gl) begins "2204" or
         string(b-jl.gl) begins "2205" or
         string(b-jl.gl) begins "2206" or
         string(b-jl.gl) begins "2207" or
         string(b-jl.gl) begins "2208" or
         string(b-jl.gl) begins "2209" or
         string(b-jl.gl) begins "2213" ) then v-code = 260.

        /* 270 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and substr(string(kod),1,1) = "2" and
        (string(b-jl.gl) begins "2204" or
         string(b-jl.gl) begins "2205" or
         string(b-jl.gl) begins "2206" or
         string(b-jl.gl) begins "2207" or
         string(b-jl.gl) begins "2208" or
         string(b-jl.gl) begins "2209" or
         string(b-jl.gl) begins "2213" ) then v-code = 270.

        /* 280 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and (substr(string(kod),1,1) = "1" or kod = 0) and string(b-jl.gl) begins "2870" and
           (v-country2 = "kz") then v-code = 280.

        /* 290 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and (substr(string(kod),1,1) = "1" or kod = 0) and string(b-jl.gl) begins "2870" and
           (v-country2 <> "" or v-country2 <> "kz") then v-code = 290.

        /* 291 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and string(b-jl.gl) begins "2870" and (knp = 111 or knp = 112) and
           (v-country2 <> "" or v-country2 <> "kz") then v-code = 291.

        /* 300 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and (substr(string(kod),1,1) = "2") and string(b-jl.gl) begins "2870" and
           (v-country2 = "kz") then v-code = 300.

        /* 310 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and (substr(string(kod),1,1) = "2") and string(b-jl.gl) begins "2870" and
           (v-country2 <> "" or v-country2 <> "kz") then v-code = 310.

        /* 9999 - Кассовые операции исключаются из оборотов, к коду 320 не относятся */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and
        (b-jl.gl = 100100 or b-jl.gl = 100110 or b-jl.gl = 100200 or b-jl.gl = 100500) then v-code = 9999.

        /* 320 */
        if txb.jl.dc = "D" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and v-code = 0 then v-code = 320.

        /* 431 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "1" or substr(string(kbe),1,1) = "0") and knp = 311 and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and
        (string(b-jl.gl) begins "2203" or
        string(b-jl.gl) begins "2211" or
        string(b-jl.gl) begins "2215" or
        string(b-jl.gl) begins "2217" or
        string(b-jl.gl) begins "2219" or
        string(b-jl.gl) begins "2223" or
        string(b-jl.gl) begins "2240" )  then v-code = 431.

        /* 432 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "1" or substr(string(kbe),1,1) = "0") and knp = 870 and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and
        (string(b-jl.gl) begins "2203" or
        string(b-jl.gl) begins "2211" or
        string(b-jl.gl) begins "2215" or
        string(b-jl.gl) begins "2217" or
        string(b-jl.gl) begins "2219" or
        string(b-jl.gl) begins "2223" or
        string(b-jl.gl) begins "2240" )  then v-code = 432.

        /* 433 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "1" or substr(string(kbe),1,1) = "0") and (knp <> 311 and knp <> 870) and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and
        (string(b-jl.gl) begins "2203" or
        string(b-jl.gl) begins "2211" or
        string(b-jl.gl) begins "2215" or
        string(b-jl.gl) begins "2217" or
        string(b-jl.gl) begins "2219" or
        string(b-jl.gl) begins "2223" or
        string(b-jl.gl) begins "2240" )  then v-code = 433.

        /* 441 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "2") and knp = 311 and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and
        (string(b-jl.gl) begins "2203" or
        string(b-jl.gl) begins "2211" or
        string(b-jl.gl) begins "2215" or
        string(b-jl.gl) begins "2217" or
        string(b-jl.gl) begins "2219" or
        string(b-jl.gl) begins "2223" or
        string(b-jl.gl) begins "2240" )  then v-code = 441.

        /* 442 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "2") and knp = 870 and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and
        (string(b-jl.gl) begins "2203" or
        string(b-jl.gl) begins "2211" or
        string(b-jl.gl) begins "2215" or
        string(b-jl.gl) begins "2217" or
        string(b-jl.gl) begins "2219" or
        string(b-jl.gl) begins "2223" or
        string(b-jl.gl) begins "2240" )  then v-code = 442.

        /* 443 */
        if txb.jl.dc = "C" and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and (knp <> 311 and knp <> 870) and
        (string(b-jl.gl) begins "2203" or
        string(b-jl.gl) begins "2211" or
        string(b-jl.gl) begins "2215" or
        string(b-jl.gl) begins "2217" or
        string(b-jl.gl) begins "2219" or
        string(b-jl.gl) begins "2223" or
        string(b-jl.gl) begins "2240" )  then v-code = 443.

        /* 450 */
        if txb.jl.dc = "C" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and b-jl.gl = 185800 then v-code = 450.

        /* 460 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "1" or substr(string(kbe),1,1) = "0") and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and
        (string(b-jl.gl) begins "2204" or
        string(b-jl.gl) begins "2205" or
        string(b-jl.gl) begins "2206" or
        string(b-jl.gl) begins "2207" or
        string(b-jl.gl) begins "2208" or
        string(b-jl.gl) begins "2209" or
        string(b-jl.gl) begins "2213" )  then v-code = 460.

        /* 470 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "2") and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and
        (string(b-jl.gl) begins "2204" or
        string(b-jl.gl) begins "2205" or
        string(b-jl.gl) begins "2206" or
        string(b-jl.gl) begins "2207" or
        string(b-jl.gl) begins "2208" or
        string(b-jl.gl) begins "2209" or
        string(b-jl.gl) begins "2213" )  then v-code = 470.

        /* 480 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "1" or substr(string(kbe),1,1) = "0") and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and string(b-jl.gl) begins "2870" and v-country2 = "kz"  then
        v-code = 480.

        /* 490 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "1" or substr(string(kbe),1,1) = "0") and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and string(b-jl.gl) begins "2870" and (v-country2 <> "kz" and v-country2 <> "" ) then
        v-code = 490.

        /* 491 */
        if txb.jl.dc = "C" and (knp = 111 or knp = 112) and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and string(b-jl.gl) begins "2870" and (v-country2 <> "kz" and v-country2 <> "" ) then
        v-code = 491.

        /* 500 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "2") and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and string(b-jl.gl) begins "2870" and v-country2 = "kz"  then
        v-code = 500.

        /* 510 */
        if txb.jl.dc = "C" and (substr(string(kbe),1,1) = "2") and
        (txb.jl.gl = 100100 or txb.jl.gl = 100500) and string(b-jl.gl) begins "2870" and (v-country2 <> "kz" and v-country2 <> "") then
        v-code = 510.

        /* 9999 - Кассовые операции исключаются из оборотов, к коду 520 не относятся */
        if txb.jl.dc = "C" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and
        (b-jl.gl = 100100 or b-jl.gl = 100110 or b-jl.gl = 100200 or b-jl.gl = 100500) then v-code = 9999.

        /* 520 */
        if txb.jl.dc = "C" and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and v-code = 0 then v-code = 520.
end procedure.
