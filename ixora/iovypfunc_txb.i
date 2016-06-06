/* iovypfunc_txb.i
 * MODULE
        Название модуля - Процесс Sonic - VIPISKA.
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - iovyp2.p,iovyp22.p,iovyp23.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        02.01.2013 damir - Переход на ИИН/БИН.
        28.01.2013 damir - <Доработка выписок, выгружаемых в DBF - файл>. Оптимизация кода.
        01.02.2013 damir - Подправил в процедуре SearchDt. По комиссиям КНП = 840.
*/

function GetBicBnk returns char(input p-txb as char).
    def var v-res as char.

    v-res = "".
    find first comm.txb where comm.txb.visible and comm.txb.bank = p-txb no-lock no-error.
    if avail comm.txb then v-res = comm.txb.mfo.
    else v-res = p-txb.

    return v-res.
end function.

procedure Get_EKNP:
    def input parameter p-sub as char.
    def input parameter p-acc as char.
    def input parameter p-d-cod as char.
    def output parameter p-KOd as char.
    def output parameter p-KBe as char.
    def output parameter p-KNP as char.

    find first txb.sub-cod where txb.sub-cod.sub = p-sub and txb.sub-cod.acc = p-acc and txb.sub-cod.d-cod = p-d-cod no-lock no-error.
    if avail txb.sub-cod then do:
        p-KOd = substr(txb.sub-cod.rcode,1,2).
        p-KBe = substr(txb.sub-cod.rcode,4,2).
        p-KNP = substr(txb.sub-cod.rcode,7,3).
    end.
end procedure.

procedure GetCcode:
    def input parameter p-sub as char.
    def input parameter p-acc as char.
    def input parameter p-d-cod as char.
    def output parameter p-ccode as char.

    find first txb.sub-cod where txb.sub-cod.sub = p-sub and txb.sub-cod.acc = p-acc and txb.sub-cod.d-cod = p-d-cod no-lock no-error.
    if avail txb.sub-cod then p-ccode = txb.sub-cod.ccode.
end procedure.

procedure SearchDt:
    def buffer b-jl for txb.jl.
    def buffer b2-jl for txb.jl.
    find first b-jl where b-jl.jh = s-jh and b-jl.acc = txb.jl.acc and b-jl.dc = "D" and round(b-jl.dam,2) = round(txb.jl.dam,2) no-lock no-error.
    if avail b-jl then do:
        find first b2-jl where b2-jl.jh = s-jh and b2-jl.dc = "C" and round(b2-jl.cam,2) = round(b-jl.dam,2) no-lock no-error.
        if avail b2-jl then do:
            if string(b2-jl.gl) begins "4" then v-KNP = "840".

            find first txb.arp where txb.arp.arp = b2-jl.acc no-lock no-error.
            if avail txb.arp then do:
                aaa = txb.arp.arp.
                namebank = replace_bnamebik(v-nbankru,txb.jl.whn).
                if v-bin then do:
                    if txb.jl.whn ge v-bin_rnn_dt then rnn = v-bnkbin.
                    else rnn = v-bnkrnn.
                end.
                else rnn = v-bnkrnn.
                run GetCcode('arp',txb.arp.arp,'secek',output v-ccode).
                v-code = "КБе:" + substr(trim(txb.arp.geo),3,1) + v-ccode.
                v-KBe = substr(trim(txb.arp.geo),3,1) + v-ccode.
            end.
            else do:
                find first txb.aaa where txb.aaa.aaa = b2-jl.acc no-lock no-error.
                if avail txb.aaa then do:
                    aaa = txb.aaa.aaa.
                    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                    if avail txb.cif then do:
                        if v-bin then do:
                            if txb.jl.whn ge v-bin_rnn_dt then rnn = txb.cif.bin.
                            else rnn = txb.cif.jss.
                        end.
                        else rnn = txb.cif.jss.
                        namebank = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
                        run GetCcode('cln',txb.cif.cif,'secek',output v-ccode).
                        v-code = "КБе:" + substr(trim(txb.cif.geo),3,1) + v-ccode.
                        v-KBe = substr(trim(txb.cif.geo),3,1) + v-ccode.
                    end.
                end.
                else do:
                    aaa = string(b2-jl.gl).
                    namebank = replace_bnamebik(v-nbankru,txb.jl.whn).
                    if v-bin then do:
                        if txb.jl.whn ge v-bin_rnn_dt then rnn = v-bnkbin.
                        else rnn = v-bnkrnn.
                    end.
                    else rnn = v-bnkrnn.
                end.
            end.
        end.
    end.
end procedure.

procedure SearchCt:
    def buffer b-jl for txb.jl.
    def buffer b2-jl for txb.jl.
    find first b-jl where b-jl.jh = s-jh and b-jl.acc = txb.jl.acc and b-jl.dc = "C" and round(b-jl.cam,2) = round(txb.jl.cam,2) no-lock no-error.
    if avail b-jl then do:
        find first b2-jl where b2-jl.jh = s-jh and b2-jl.dc = "D" and round(b2-jl.dam,2) = round(b-jl.cam,2) no-lock no-error.
        if avail b2-jl then do:
            find first txb.arp where txb.arp.arp = b2-jl.acc no-lock no-error.
            if avail txb.arp then do:
                aaa = txb.arp.arp.
                namebank = replace_bnamebik(v-nbankru,txb.jl.whn).
                if v-bin then do:
                    if txb.jl.whn ge v-bin_rnn_dt then rnn = v-bnkbin.
                    else rnn = v-bnkrnn.
                end.
                else rnn = v-bnkrnn.
                run GetCcode('arp',txb.arp.arp,'secek',output v-ccode).
                v-code = "КОд:" + substr(trim(txb.arp.geo),3,1) + v-ccode.
                v-KOd = substr(trim(txb.arp.geo),3,1) + v-ccode.
            end.
            else do:
                find first txb.aaa where txb.aaa.aaa = b2-jl.acc no-lock no-error.
                if avail txb.aaa then do:
                    aaa = txb.aaa.aaa.
                    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                    if avail txb.cif then do:
                        if v-bin then do:
                            if txb.jl.whn ge v-bin_rnn_dt then rnn = txb.cif.bin.
                            else rnn = txb.cif.jss.
                        end.
                        else rnn = txb.cif.jss.
                        namebank = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
                        run GetCcode('cln',txb.cif.cif,'secek',output v-ccode).
                        v-code = "КОд:" + substr(trim(txb.cif.geo),3,1) + v-ccode.
                        v-KOd = substr(trim(txb.cif.geo),3,1) + v-ccode.
                    end.
                end.
                else do:
                    aaa = string(b2-jl.gl).
                    namebank = replace_bnamebik(v-nbankru,txb.jl.whn).
                    if v-bin then do:
                        if txb.jl.whn ge v-bin_rnn_dt then rnn = v-bnkbin.
                        else rnn = v-bnkrnn.
                    end.
                    else rnn = v-bnkrnn.
                end.
            end.
        end.
    end.
end procedure.

function GetSubCodCode returns char(input p-sub as char,input p-acc as char,input p-d-cod as char).
    def var v-res as char.

    v-res = "".
    find first txb.sub-cod where txb.sub-cod.sub eq p-sub and txb.sub-cod.acc eq p-acc and txb.sub-cod.d-cod eq p-d-cod and trim(txb.sub-cod.ccode) ne "msc" no-lock no-error.
    if avail txb.sub-cod then v-res = trim(txb.sub-cod.ccode).

    return v-res.
end function.


