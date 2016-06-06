/* r-eee.p
 * MODULE
        Бухгалтерская отчетность
 * DESCRIPTION
        Отчет ЕКНП - разбранчевка
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 8.8.6.7
 * AUTHOR
        01/05/2011 marinav
 * BASES
        BANK COMM TXB
 * CHANGES
        26.09.2011 damir - добавил if avail.
        11.01.2012 damir - добавил rmz,jou документы.
        17.01.2012 damir - вывел новые поля в отчете согласно доп.заданию от Ген.Бухг., функции GLRET,ACCNAM.
        25.01.2012 damir - доп.задание к т.з. № 1249 выполнено. (Шманова Актолкын)
        16.04.2012 damir - выполнено Т.З. № 1301 (Дополнение к отчету), изменен полносью алгоритм расчета курсовой разницы,
        с техническими заданиями можно ознакомится X:\IT\_doc\Damir. Отчет доработан полностью.
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
*/

def shared var v-dtb as date.
def shared var v-dte as date.
def shared var v-dt as date.

def var v-clecod as char no-undo.
def var v-rmzjou as char no-undo.
v-clecod = "".
find txb.sysc where txb.sysc.sysc = "clecod" no-lock no-error.
if avail txb.sysc then v-clecod = txb.sysc.chval.

def shared temp-table t-eknp
    field sr        as char
    field pr        as char
    field jdt       like txb.jl.jdt
    field acc       as char
    field gl        like txb.jl.gl
    field sbank     as char format "x(12)"
    field l_sbank   as char
    field sbank1    as char format "x(12)"
    field l_sbank1  as char
    field gl1       like txb.jl.gl
    field rbank     as char format "x(12)"
    field l_rbank   as char
    field rbank1    as char format "x(12)"
    field l_rbank1  as char
    field gl2       like txb.jl.gl
    field crc       like txb.crc.crc
    field crccode   as char format "x(3)" label "Вал"
    field jh        like txb.jl.jh
    field rmz       as char
    field sum       as deci format "zzz,zzz,zzz,zz9.99"
    field sumkzt    as deci format "zzz,zzz,zzz,zz9.99"
    field s_locat   as char
    field s_secek   as char
    field r_locat   as char
    field r_secek   as char
    field knp       as char format "999"
    field cnt1      as char format "x(2)"
    field cnt2      as char format "x(2)"
    field rem       like txb.jl.rem[1]
    field ptype     as char
    field drgl7     as char   /*п.м. 8.8.3.12*/
    field crgl7     as char   /*п.м. 8.8.3.12*/
    field dracc20   as char
    field cracc20   as char
    field draccname as char
    field craccname as char
    field prizplat  as char
    field trxcode   as char
    field namebnk   as char.

function GLRET returns char(input acc as char).
    def var v-gl7  as char init "".
    def var v-hs   as char.
    def var v-geoi as inte.
    def var v-cgr  as char.
    def var v-r    as char.

    find last txb.arp where txb.arp.arp eq acc use-index arp no-lock no-error.
    if avail txb.arp then do:
        find last txb.crchs where txb.crchs.crc eq txb.arp.crc no-lock no-error.
        if avail txb.crchs then do:
            if txb.crchs.hs eq "L" then v-hs = "1".
            else if txb.crchs.hs eq "H" then v-hs = "2".
            else if txb.crchs.hs eq "S" then v-hs = "3".
        end.
        find last txb.cif where txb.cif.cif eq txb.arp.cif use-index cif no-lock no-error.
        if available txb.cif then do:
            v-geoi = integer(txb.cif.geo).
            find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
            if avail txb.sub-cod then v-cgr = txb.sub-cod.ccode.
        end.
        else do:
            v-geoi = integer(txb.arp.geo).
            find last txb.sub-cod where txb.sub-cod.sub = 'arp' and txb.sub-cod.acc = txb.arp.arp and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
            if avail txb.sub-cod then v-cgr = txb.sub-cod.ccode.
        end.
        if substr(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        assign v-gl7 = string(truncate(txb.arp.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last txb.ast where txb.ast.ast eq acc use-index ast no-lock no-error.
    if avail txb.ast then do:
        assign v-gl7 = string(truncate(txb.ast.gl / 100, 0)) + "1" + "4" + "1".
    end.

    find last txb.aaa where txb.aaa.aaa eq acc use-index aaa no-lock no-error.
    if avail txb.aaa then do:
        find last txb.cif where txb.cif.cif eq txb.aaa.cif use-index cif no-lock no-error.
        find last txb.crchs where txb.crchs.crc eq txb.aaa.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
        else if txb.crchs.hs eq "S" then v-hs = "3".
        if avail txb.cif then do:
            if substring(string(integer(txb.cif.geo),"999"),3,1) eq "1" then v-r = "1".
            else v-r = "2".
            find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
            if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
        end.
        assign v-gl7 = string(truncate(txb.aaa.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last txb.dfb where txb.dfb.dfb eq acc use-index dfb no-lock no-error.
    if avail txb.dfb then do:
        find last txb.bankl where txb.bankl.bank eq txb.dfb.bank use-index bank no-lock no-error.
        if available txb.bankl then v-geoi = txb.bankl.stn.
        find last txb.crchs where txb.crchs.crc eq txb.dfb.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
        else if txb.crchs.hs eq "S" then v-hs = "3".
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        if txb.dfb.gl ge 105100 and txb.dfb.gl lt 105200 then v-cgr = '3'.
        else v-cgr = '4'.
        assign v-gl7 = string(truncate(txb.dfb.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last txb.fun where txb.fun.fun eq acc use-index fun no-lock no-error.
    if avail txb.fun then do:
        find last txb.bankl where txb.bankl.bank eq txb.fun.bank use-index bank no-lock no-error.
        if available txb.bankl then v-geoi = txb.bankl.stn.
        find last txb.crchs where txb.crchs.crc eq txb.fun.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
        else if txb.crchs.hs eq "S" then v-hs = "3".
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        find last txb.sub-cod where txb.sub-cod.sub = 'fun' and txb.sub-cod.acc = txb.fun.fun and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
        if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
        else v-cgr = '4'.
        assign v-gl7 = string(truncate(txb.fun.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last txb.scu where txb.scu.scu eq acc use-index scu no-lock no-error.
    if avail txb.scu then do:
        v-geoi = integer(txb.scu.geo) no-error.
        if error-status:error then v-geoi = 21.
        find last txb.crchs where txb.crchs.crc eq txb.scu.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
        else if txb.crchs.hs eq "S" then v-hs = "3".
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        v-cgr = txb.scu.type. /* сектор экономики */
        assign v-gl7 = string(truncate(txb.scu.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last txb.lon where txb.lon.lon eq acc use-index lon no-lock no-error.
    if avail txb.lon then do:
        find last txb.cif where txb.cif.cif eq txb.lon.cif use-index cif no-lock no-error.
        find last txb.crchs where txb.crchs.crc eq txb.lon.crc no-lock no-error.
        if txb.crchs.hs eq "L" then v-hs = "1".
        else if txb.crchs.hs eq "H" then v-hs = "2".
        else if txb.crchs.hs eq "S" then v-hs = "3".
        if substring(string(integer(txb.cif.geo),"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
        if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
        assign v-gl7 = string(truncate(txb.lon.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    return v-gl7.
end.

function ACCNAM returns char(input acc as char).
    def var v-name as char.

    find last txb.arp where txb.arp.arp eq acc use-index arp no-lock no-error.
    if avail txb.arp then do:
        v-name = txb.arp.des.
    end.
    find last txb.ast where txb.ast.ast eq acc use-index ast no-lock no-error.
    if avail txb.ast then do:
        v-name = txb.ast.name.
    end.
    find last txb.aaa where txb.aaa.aaa eq acc use-index aaa no-lock no-error.
    if avail txb.aaa then do:
        v-name = txb.aaa.name.
    end.
    find last txb.dfb where txb.dfb.dfb eq acc use-index dfb no-lock no-error.
    if avail txb.dfb then do:
        v-name = txb.dfb.name.
    end.
    find last txb.fun where txb.fun.fun eq acc use-index fun no-lock no-error.
    if avail txb.fun then do:
        v-name = txb.fun.cst.
    end.
    find last txb.scu where txb.scu.scu eq acc use-index scu no-lock no-error.
    if avail txb.scu then do:
    end.
    find last txb.lon where txb.lon.lon eq acc use-index lon no-lock no-error.
    if avail txb.lon then do:
        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        if avail txb.cif then v-name = txb.cif.name.
    end.
    return v-name.
end function.

def buffer bb-jl for txb.jl.
def var v-ourbnk as char.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then assign v-ourbnk = txb.sysc.chval.

do v-dt = v-dtb - 1 to v-dte:
    for each txb.jl where txb.jl.jdt = v-dt and txb.jl.lev = 1 no-lock:
        create t-eknp.
        find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
        if available txb.jh then do:
            v-rmzjou = txb.jh.sub.
            t-eknp.rmz  =  txb.jh.party.
            find first txb.sub-cod where txb.sub-cod.sub = v-rmzjou and txb.sub-cod.acc = txb.jh.party and
            txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
            if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
            if txb.jh.sub <> "rmz" and txb.jh.sub <> "jou" then do:
                if jl.viddoc matches "*pdoctng*" and NUM-ENTRIES(trim(jl.viddoc),",") = 2 then  t-eknp.prizplat = entry(2,trim(jl.viddoc)).
            end.
        end.
        if txb.jl.dc = 'D' then do:
            find txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
            if avail txb.aaa then do:
                for each bb-jl where bb-jl.jh = txb.jl.jh and bb-jl.lev = 1 and txb.jl.dam = bb-jl.cam no-lock:
                    if string(bb-jl.gl) begins '4' then do:
                        t-eknp.gl1  = txb.jl.gl.
                        t-eknp.gl2 = bb-jl.gl.
                        find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                        txb.trxcods.codfr = "locat" no-lock no-error.
                        if avail txb.trxcods then t-eknp.s_locat = txb.trxcods.code.
                        find first txb.trxcods where txb.trxcods.trxh = jl.jh and txb.trxcods.trxln = txb.jl.ln and
                        txb.trxcods.codfr = "secek" no-lock no-error.
                        if avail txb.trxcods then t-eknp.s_secek = txb.trxcods.code.
                        find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                        txb.trxcods.codfr = "locat" no-lock no-error.
                        if avail txb.trxcods then t-eknp.r_locat = txb.trxcods.code.
                        find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                        txb.trxcods.codfr = "secek" no-lock no-error.
                        if avail txb.trxcods then t-eknp.r_secek = txb.trxcods.code.
                        if (t-eknp.s_locat = '' or t-eknp.s_secek = '') then do:
                            find txb.cif where txb.cif.cif = aaa.cif no-lock no-error.
                            if avail txb.cif then assign t-eknp.s_locat = substr(txb.cif.geo,3,1).
                            t-eknp.s_secek = substr(txb.jl.acc,9,1).
                        end.
                        if (t-eknp.r_locat = '' or t-eknp.r_secek = '') and string(t-eknp.gl2) begins '4' then assign
                        t-eknp.r_locat = '1' t-eknp.r_secek = '4' t-eknp.knp = '840'.
                        assign
                        t-eknp.dracc20 = txb.jl.acc
                        t-eknp.cracc20 = bb-jl.acc
                        t-eknp.drgl7   = GLRET(t-eknp.dracc20)
                        t-eknp.crgl7   = GLRET(t-eknp.cracc20)
                        t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                        t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                    end.
                    else do:
                        find first txb.aaa where txb.aaa.aaa = bb-jl.acc no-lock no-error.
                        if avail txb.aaa and bb-jl.dc = 'C' then do:
                            t-eknp.gl1  = txb.jl.gl.
                            t-eknp.gl2 = bb-jl.gl.
                            find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                            if txb.jh.sub = "rmz" then do:
                                find txb.remtrz where txb.remtrz.remtrz = substr(txb.jh.party, 1, 10) no-lock no-error.
                                find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                                txb.sub-cod.d-cod = "eknp" no-lock no-error.
                                if avail txb.sub-cod and txb.sub-cod.ccode = "eknp" and num-entries(txb.sub-cod.rcode) = 3 then do:
                                    t-eknp.s_locat = substr(txb.sub-cod.rcode, 1, 1).
                                    t-eknp.s_secek = substr(txb.sub-cod.rcode, 2, 1).
                                    t-eknp.r_locat = substr(txb.sub-cod.rcode, 4, 1).
                                    t-eknp.r_secek = substr(txb.sub-cod.rcode, 5, 1).
                                    t-eknp.knp     = substr(txb.sub-cod.rcode, 7, 3).
                                end.
                                if avail txb.remtrz then do:
                                    assign
                                    t-eknp.rmz     = txb.remtrz.remtrz
                                    t-eknp.dracc20 = txb.remtrz.dracc
                                    t-eknp.cracc20 = txb.remtrz.cracc
                                    t-eknp.drgl7   = GLRET(t-eknp.dracc20)
                                    t-eknp.crgl7   = GLRET(t-eknp.cracc20)
                                    t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                                    t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                                end.
                                find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                                txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
                                if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
                            end.
                            else if txb.jh.sub = "jou" then do:
                                find txb.joudoc where txb.joudoc.docnum = substr(txb.jh.party, 1, 10) no-lock no-error.
                                find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and
                                txb.sub-cod.d-cod = "eknp" no-lock no-error.
                                if avail txb.sub-cod and txb.sub-cod.ccode = "eknp" and num-entries(txb.sub-cod.rcode) = 3 then do:
                                    t-eknp.s_locat = substr(txb.sub-cod.rcode, 1, 1).
                                    t-eknp.s_secek = substr(txb.sub-cod.rcode, 2, 1).
                                    t-eknp.r_locat = substr(txb.sub-cod.rcode, 4, 1).
                                    t-eknp.r_secek = substr(txb.sub-cod.rcode, 5, 1).
                                    t-eknp.knp     = substr(txb.sub-cod.rcode, 7, 3).
                                end.
                                else do:
                                    find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                                    txb.trxcods.codfr = "locat" no-lock no-error.
                                    if avail txb.trxcods then t-eknp.s_locat = txb.trxcods.code.
                                    find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                                    txb.trxcods.codfr = "secek" no-lock no-error.
                                    if avail txb.trxcods then t-eknp.s_secek = txb.trxcods.code.
                                    find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                                    txb.trxcods.codfr = "locat" no-lock no-error.
                                    if avail txb.trxcods then t-eknp.r_locat = txb.trxcods.code.
                                    find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                                    txb.trxcods.codfr = "secek" no-lock no-error.
                                    if avail txb.trxcods then t-eknp.r_secek = txb.trxcods.code.
                                end.
                                if avail txb.joudoc then do:
                                    assign
                                    t-eknp.rmz = txb.joudoc.docnum
                                    t-eknp.dracc20 = txb.joudoc.dracc
                                    t-eknp.cracc20 = txb.joudoc.cracc
                                    t-eknp.drgl7   = GLRET(t-eknp.dracc20)
                                    t-eknp.crgl7   = GLRET(t-eknp.cracc20)
                                    t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                                    t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                                end.
                                find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and
                                txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
                                if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
                            end.
                            else do:
                                find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                                txb.trxcods.codfr = "locat" no-lock no-error.
                                if avail txb.trxcods then t-eknp.s_locat = txb.trxcods.code.
                                find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                                txb.trxcods.codfr = "secek" no-lock no-error.
                                if avail txb.trxcods then t-eknp.s_secek = txb.trxcods.code.
                                find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                                txb.trxcods.codfr = "locat" no-lock no-error.
                                if avail txb.trxcods then t-eknp.r_locat = txb.trxcods.code.
                                find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                                txb.trxcods.codfr = "secek" no-lock no-error.
                                if avail txb.trxcods then t-eknp.r_secek = txb.trxcods.code.
                            end.
                        end.
                    end.
                end.
                assign t-eknp.trxcode = txb.jl.trx.
            end.
        end. /*if txb.jl.dc = 'D'*/
        if txb.jl.dc = 'C' then do:
            find txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
            if avail txb.aaa then do:
                for each bb-jl where bb-jl.jh = txb.jl.jh and bb-jl.lev = 1 and txb.jl.cam = bb-jl.dam no-lock:
                    find first txb.aaa where txb.aaa.aaa = bb-jl.acc no-lock no-error.
                    if not avail txb.aaa then do:
                        if bb-jl.dc = 'D' then do:
                            t-eknp.gl1 = bb-jl.gl.
                            t-eknp.gl2 = txb.jl.gl.
                            find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                            if txb.jh.sub = "rmz" then do:
                                find txb.remtrz where txb.remtrz.remtrz = substr(txb.jh.party, 1, 10) no-lock no-error.
                                find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                                txb.sub-cod.d-cod = "eknp" no-lock no-error.
                                if avail txb.sub-cod and txb.sub-cod.ccode = "eknp" and num-entries(txb.sub-cod.rcode) = 3 then do:
                                    t-eknp.s_locat = substr(txb.sub-cod.rcode, 1, 1).
                                    t-eknp.s_secek = substr(txb.sub-cod.rcode, 2, 1).
                                    t-eknp.r_locat = substr(txb.sub-cod.rcode, 4, 1).
                                    t-eknp.r_secek = substr(txb.sub-cod.rcode, 5, 1).
                                    t-eknp.knp     = substr(txb.sub-cod.rcode, 7, 3).
                                end.
                                if avail txb.remtrz then do:
                                    assign
                                    t-eknp.rmz     = txb.remtrz.remtrz
                                    t-eknp.dracc20 = txb.remtrz.dracc
                                    t-eknp.cracc20 = txb.remtrz.cracc
                                    t-eknp.drgl7   = GLRET(t-eknp.dracc20)
                                    t-eknp.crgl7   = GLRET(t-eknp.cracc20)
                                    t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                                    t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                                end.
                                find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                                txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
                                if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
                            end.
                            else if txb.jh.sub = "jou" then do:
                                find txb.joudoc where txb.joudoc.docnum = substr(txb.jh.party, 1, 10) no-lock no-error.
                                find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and
                                txb.sub-cod.d-cod = "eknp" no-lock no-error.
                                if avail txb.sub-cod and txb.sub-cod.ccode = "eknp" and num-entries(txb.sub-cod.rcode) = 3 then do:
                                    t-eknp.s_locat = substr(txb.sub-cod.rcode, 1, 1).
                                    t-eknp.s_secek = substr(txb.sub-cod.rcode, 2, 1).
                                    t-eknp.r_locat = substr(txb.sub-cod.rcode, 4, 1).
                                    t-eknp.r_secek = substr(txb.sub-cod.rcode, 5, 1).
                                    t-eknp.knp     = substr(txb.sub-cod.rcode, 7, 3).
                                end.
                                else do:
                                    find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                                    txb.trxcods.codfr = "locat" no-lock no-error.
                                    if avail txb.trxcods then t-eknp.s_locat = txb.trxcods.code.
                                    find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                                    txb.trxcods.codfr = "secek" no-lock no-error.
                                    if avail txb.trxcods then t-eknp.s_secek = txb.trxcods.code.
                                    find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                                    txb.trxcods.codfr = "locat" no-lock no-error.
                                    if avail txb.trxcods then t-eknp.r_locat = txb.trxcods.code.
                                    find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                                    txb.trxcods.codfr = "secek" no-lock no-error.
                                    if avail txb.trxcods then t-eknp.r_secek = txb.trxcods.code.
                                end.
                                if avail txb.joudoc then do:
                                    assign
                                    t-eknp.rmz = txb.joudoc.docnum
                                    t-eknp.dracc20 = txb.joudoc.dracc
                                    t-eknp.cracc20 = txb.joudoc.cracc
                                    t-eknp.drgl7   = GLRET(t-eknp.dracc20)
                                    t-eknp.crgl7   = GLRET(t-eknp.cracc20)
                                    t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                                    t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                                end.
                                find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and
                                txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
                                if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
                            end.
                            else do:
                                find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                                txb.trxcods.codfr = "locat" no-lock no-error.
                                if avail txb.trxcods then t-eknp.r_locat = txb.trxcods.code.
                                find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                                txb.trxcods.codfr = "secek" no-lock no-error.
                                if avail txb.trxcods then t-eknp.r_secek = txb.trxcods.code.
                                find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                                txb.trxcods.codfr = "locat" no-lock no-error.
                                if avail txb.trxcods then t-eknp.s_locat = txb.trxcods.code.
                                find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                                txb.trxcods.codfr = "secek" no-lock no-error.
                                if avail txb.trxcods then t-eknp.s_secek = txb.trxcods.code.
                            end.
                        end.
                    end.
                end.
                assign t-eknp.trxcode = txb.jl.trx.
            end.
        end. /*if txb.jl.dc = 'C'*/

        if t-eknp.gl1 = 0 and t-eknp.gl2 = 0 then delete t-eknp.
        else do:
            find first txb.sysc where txb.sysc.sysc = 'OURBNK' no-lock no-error.
            if avail txb.sysc then do:
                find first comm.txb where trim(comm.txb.bank) = trim(txb.sysc.chval) no-lock no-error.
                if avail comm.txb then assign t-eknp.namebnk = comm.txb.info.
            end.
            t-eknp.jdt = v-dt.
            t-eknp.crc = txb.jl.crc.
            t-eknp.sr = '08'.
            t-eknp.pr = '11'.
            t-eknp.sbank = v-clecod.
            t-eknp.rbank = v-clecod.
            t-eknp.sbank1 = v-clecod.
            t-eknp.rbank1 = v-clecod.

            find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
            t-eknp.crccode = txb.crc.code.
            t-eknp.jh = txb.jl.jh.
            t-eknp.sum = (txb.jl.dam + txb.jl.cam).
            find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < v-dt - 1 no-lock no-error.
            t-eknp.sumkzt = (txb.jl.dam + txb.jl.cam) * txb.crchis.rate[1].


            find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.codfr = "spnpl" no-lock no-error.
            if avail txb.trxcods then t-eknp.knp = txb.trxcods.code.
            if t-eknp.s_locat = "1" then t-eknp.cnt1 = 'KZ'.
            if t-eknp.r_locat = "1" then t-eknp.cnt2 = 'KZ'.
        end.
    end. /*for each txb.jl where txb.jl.jdt = v-dt*/
end.

/*Дополнение к Т.З. от Актолкын*/
do v-dt = v-dtb - 1 to v-dte:
    for each txb.jl where txb.jl.jdt = v-dt and (txb.jl.gl = 287033 or txb.jl.gl = 287034 or txb.jl.gl = 287035 or txb.jl.gl = 287036
    or txb.jl.gl = 287037) no-lock:
    create t-eknp.
    find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
    if available txb.jh then do:
        t-eknp.rmz  =  txb.jh.party.
        v-rmzjou = txb.jh.sub.
        find first txb.sub-cod where txb.sub-cod.sub = v-rmzjou and txb.sub-cod.acc = txb.jh.party and
        txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
        if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
        if jh.sub <> "rmz" and jh.sub <> "jou" then do:
            if jl.viddoc matches "*pdoctng*" and NUM-ENTRIES(trim(jl.viddoc),",") = 2 then  t-eknp.prizplat = entry(2,trim(jl.viddoc)).
        end.
    end.
        if txb.jl.dc = "D" then do:
            find first bb-jl where bb-jl.jh = txb.jl.jh and bb-jl.dc = "C" and bb-jl.gl = 100100 no-lock no-error.
            if avail bb-jl then do:
                t-eknp.gl1  = txb.jl.gl.
                t-eknp.gl2 = bb-jl.gl.
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                if txb.jh.sub = "rmz" then do:
                    find txb.remtrz where txb.remtrz.remtrz = substr(txb.jh.party, 1, 10) no-lock no-error.
                    find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                    txb.sub-cod.d-cod = "eknp" no-lock no-error.
                    if avail txb.sub-cod and txb.sub-cod.ccode = "eknp" and num-entries(txb.sub-cod.rcode) = 3 then do:
                        t-eknp.s_locat = substr(txb.sub-cod.rcode, 1, 1).
                        t-eknp.s_secek = substr(txb.sub-cod.rcode, 2, 1).
                        t-eknp.r_locat = substr(txb.sub-cod.rcode, 4, 1).
                        t-eknp.r_secek = substr(txb.sub-cod.rcode, 5, 1).
                        t-eknp.knp     = substr(txb.sub-cod.rcode, 7, 3).
                    end.
                    if avail txb.remtrz then do:
                        assign
                        t-eknp.rmz     = txb.remtrz.remtrz
                        t-eknp.dracc20 = txb.remtrz.dracc
                        t-eknp.cracc20 = txb.remtrz.cracc
                        t-eknp.drgl7   = GLRET(t-eknp.dracc20)
                        t-eknp.crgl7   = GLRET(t-eknp.cracc20)
                        t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                        t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                    end.
                    find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                    txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
                    if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
                end.
                else if txb.jh.sub = "jou" then do:
                    find txb.joudoc where txb.joudoc.docnum = substr(txb.jh.party, 1, 10) no-lock no-error.
                    find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and
                    txb.sub-cod.d-cod = "eknp" no-lock no-error.
                    if avail txb.sub-cod and txb.sub-cod.ccode = "eknp" and num-entries(txb.sub-cod.rcode) = 3 then do:
                        t-eknp.s_locat = substr(txb.sub-cod.rcode, 1, 1).
                        t-eknp.s_secek = substr(txb.sub-cod.rcode, 2, 1).
                        t-eknp.r_locat = substr(txb.sub-cod.rcode, 4, 1).
                        t-eknp.r_secek = substr(txb.sub-cod.rcode, 5, 1).
                        t-eknp.knp     = substr(txb.sub-cod.rcode, 7, 3).
                    end.
                    else do:
                        find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                        txb.trxcods.codfr = "locat" no-lock no-error.
                        if avail txb.trxcods then t-eknp.s_locat = txb.trxcods.code.
                        find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                        txb.trxcods.codfr = "secek" no-lock no-error.
                        if avail txb.trxcods then t-eknp.s_secek = txb.trxcods.code.
                        find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                        txb.trxcods.codfr = "locat" no-lock no-error.
                        if avail txb.trxcods then t-eknp.r_locat = txb.trxcods.code.
                        find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                        txb.trxcods.codfr = "secek" no-lock no-error.
                        if avail txb.trxcods then t-eknp.r_secek = txb.trxcods.code.
                    end.
                    if avail txb.joudoc then do:
                        assign
                        t-eknp.rmz = txb.joudoc.docnum
                        t-eknp.dracc20 = txb.joudoc.dracc
                        t-eknp.cracc20 = txb.joudoc.cracc
                        t-eknp.drgl7   = GLRET(t-eknp.dracc20)
                        t-eknp.crgl7   = GLRET(t-eknp.cracc20)
                        t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                        t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                    end.
                    find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and
                    txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
                    if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
                end.
                else do:
                    find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                    txb.trxcods.codfr = "locat" no-lock no-error.
                    if avail txb.trxcods then t-eknp.s_locat = txb.trxcods.code.
                    find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                    txb.trxcods.codfr = "secek" no-lock no-error.
                    if avail txb.trxcods then t-eknp.s_secek = txb.trxcods.code.
                    find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                    txb.trxcods.codfr = "locat" no-lock no-error.
                    if avail txb.trxcods then t-eknp.r_locat = txb.trxcods.code.
                    find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                    txb.trxcods.codfr = "secek" no-lock no-error.
                    if avail txb.trxcods then t-eknp.r_secek = txb.trxcods.code.
                end.
                assign t-eknp.trxcode = txb.jl.trx.
            end.
        end.
        if txb.jl.dc = "C" then do:
            find first bb-jl where bb-jl.jh = txb.jl.jh and bb-jl.dc = "D" and bb-jl.gl = 100100 no-lock no-error.
            if avail bb-jl then do:
                t-eknp.gl1 = bb-jl.gl.
                t-eknp.gl2 = txb.jl.gl.
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                if txb.jh.sub = "rmz" then do:
                    find txb.remtrz where txb.remtrz.remtrz = substr(txb.jh.party, 1, 10) no-lock no-error.
                    find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                    txb.sub-cod.d-cod = "eknp" no-lock no-error.
                    if avail txb.sub-cod and txb.sub-cod.ccode = "eknp" and num-entries(txb.sub-cod.rcode) = 3 then do:
                        t-eknp.s_locat = substr(txb.sub-cod.rcode, 1, 1).
                        t-eknp.s_secek = substr(txb.sub-cod.rcode, 2, 1).
                        t-eknp.r_locat = substr(txb.sub-cod.rcode, 4, 1).
                        t-eknp.r_secek = substr(txb.sub-cod.rcode, 5, 1).
                        t-eknp.knp     = substr(txb.sub-cod.rcode, 7, 3).
                    end.
                    if avail txb.remtrz then do:
                        assign
                        t-eknp.rmz     = txb.remtrz.remtrz
                        t-eknp.dracc20 = txb.remtrz.dracc
                        t-eknp.cracc20 = txb.remtrz.cracc
                        t-eknp.drgl7   = GLRET(t-eknp.dracc20)
                        t-eknp.crgl7   = GLRET(t-eknp.cracc20)
                        t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                        t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                    end.
                    find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = txb.remtrz.remtrz and
                    txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
                    if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
                end.
                else if txb.jh.sub = "jou" then do:
                    find txb.joudoc where txb.joudoc.docnum = substr(txb.jh.party, 1, 10) no-lock no-error.
                    find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and
                    txb.sub-cod.d-cod = "eknp" no-lock no-error.
                    if avail txb.sub-cod and txb.sub-cod.ccode = "eknp" and num-entries(txb.sub-cod.rcode) = 3 then do:
                        t-eknp.s_locat = substr(txb.sub-cod.rcode, 1, 1).
                        t-eknp.s_secek = substr(txb.sub-cod.rcode, 2, 1).
                        t-eknp.r_locat = substr(txb.sub-cod.rcode, 4, 1).
                        t-eknp.r_secek = substr(txb.sub-cod.rcode, 5, 1).
                        t-eknp.knp     = substr(txb.sub-cod.rcode, 7, 3).
                    end.
                    else do:
                        find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                        txb.trxcods.codfr = "locat" no-lock no-error.
                        if avail txb.trxcods then t-eknp.s_locat = txb.trxcods.code.
                        find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                        txb.trxcods.codfr = "secek" no-lock no-error.
                        if avail txb.trxcods then t-eknp.s_secek = txb.trxcods.code.
                        find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                        txb.trxcods.codfr = "locat" no-lock no-error.
                        if avail txb.trxcods then t-eknp.r_locat = txb.trxcods.code.
                        find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                        txb.trxcods.codfr = "secek" no-lock no-error.
                        if avail txb.trxcods then t-eknp.r_secek = txb.trxcods.code.
                    end.
                    if avail txb.joudoc then do:
                        assign
                        t-eknp.rmz = txb.joudoc.docnum
                        t-eknp.dracc20 = txb.joudoc.dracc
                        t-eknp.cracc20 = txb.joudoc.cracc
                        t-eknp.drgl7   = GLRET(t-eknp.dracc20)
                        t-eknp.crgl7   = GLRET(t-eknp.cracc20)
                        t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                        t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                    end.
                    find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = txb.joudoc.docnum and
                    txb.sub-cod.d-cod = "pdoctng" and txb.sub-cod.ccode <> "msc" no-lock no-error.
                    if avail txb.sub-cod then assign t-eknp.prizplat = txb.sub-cod.ccode.
                end.
                else do:
                    find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                    txb.trxcods.codfr = "locat" no-lock no-error.
                    if avail txb.trxcods then t-eknp.r_locat = txb.trxcods.code.
                    find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and
                    txb.trxcods.codfr = "secek" no-lock no-error.
                    if avail txb.trxcods then t-eknp.r_secek = txb.trxcods.code.
                    find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                    txb.trxcods.codfr = "locat" no-lock no-error.
                    if avail txb.trxcods then t-eknp.s_locat = txb.trxcods.code.
                    find first txb.trxcods where txb.trxcods.trxh = bb-jl.jh and txb.trxcods.trxln = bb-jl.ln and
                    txb.trxcods.codfr = "secek" no-lock no-error.
                    if avail txb.trxcods then t-eknp.s_secek = txb.trxcods.code.
                end.
                assign t-eknp.trxcode = txb.jl.trx.
            end.
        end.

        if t-eknp.gl1 = 0 and t-eknp.gl2 = 0 then delete t-eknp.
        else do:
            find first txb.sysc where txb.sysc.sysc = 'OURBNK' no-lock no-error.
            if avail txb.sysc then do:
                find first comm.txb where trim(comm.txb.bank) = trim(txb.sysc.chval) no-lock no-error.
                if avail comm.txb then assign t-eknp.namebnk = comm.txb.info.
            end.
            t-eknp.jdt = v-dt.
            t-eknp.crc = txb.jl.crc.
            t-eknp.sr = '08'.
            t-eknp.pr = '11'.
            t-eknp.sbank = v-clecod.
            t-eknp.rbank = v-clecod.
            t-eknp.sbank1 = v-clecod.
            t-eknp.rbank1 = v-clecod.

            find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
            t-eknp.crccode = txb.crc.code.
            t-eknp.jh = txb.jl.jh.
            t-eknp.sum = (txb.jl.dam + txb.jl.cam).
            find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < v-dt - 1 no-lock no-error.
            t-eknp.sumkzt = (txb.jl.dam + txb.jl.cam) * txb.crchis.rate[1].


            find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.codfr = "spnpl" no-lock no-error.
            if avail txb.trxcods then t-eknp.knp = txb.trxcods.code.
            if t-eknp.s_locat = "1" then t-eknp.cnt1 = 'KZ'.
            if t-eknp.r_locat = "1" then t-eknp.cnt2 = 'KZ'.
        end.
    end.
end.




