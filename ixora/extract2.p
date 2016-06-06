/* extract2.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Выписки по счетам клиентов ЮЛ/ИП
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        17.07.2013 damir - Внедрено Т.З. № 1523.
*/
{global.i}
{deals.i "shared"}

def shared var v-dtb as date.
def shared var v-dte as date.
def shared var v-crc as inte.

def buffer b-aaa for aaa.
def buffer b-cif for cif.
def buffer b-jl for jl.
def buffer b-jh for jh.

def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

for each b-jl where b-jl.jdt >= v-dtb and b-jl.jdt <= v-dte and b-jl.who <> "" no-lock:
    find b-aaa where b-aaa.aaa = b-jl.acc no-lock no-error.
    find b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
    if not (avail b-aaa and avail b-cif and b-aaa.crc = v-crc and b-jl.lev = 1) then next.

    run add_deal(recid(b-jl),b-jl.acc,b-jl.jdt,b-jl.dam + b-jl.cam,b-jl.crc,string(b-jl.jh),b-cif.cif,b-jl.ln).

    hide message no-pause.
    message LN[i].
    if i = 8 then i = 1.
    else i = i + 1.
end.

procedure add_deal:
    DEFINE INPUT PARAMETER in_recid   AS RECID.
    DEFINE INPUT PARAMETER in_account AS CHARACTER.
    DEFINE INPUT PARAMETER in_d_date  AS DATE.
    DEFINE INPUT PARAMETER in_amount  AS DECIMAL.
    DEFINE INPUT PARAMETER in_crc     AS INTEGER.
    DEFINE INPUT PARAMETER in_trxtrn  AS CHARACTER.
    DEFINE INPUT PARAMETER cif        AS CHARACTER.
    DEFINE INPUT PARAMETER in_ln      AS INTEGER.

    def buffer b-trxcods for trxcods.
    def buffer c-jh for jh.
    def buffer c-jl for jl.
    def buffer b-deals for deals.

    def var v-nazn as char format 'x(80)'.
    def var v-ln as logi.
    def var v-tmp as char .

    define variable o_dealtrn as character initial ?.
    define variable o_custtrn as character initial ?.
    define variable o_ordins as character initial ?.
    define variable o_ordcust as character initial ?.
    define variable o_ordacc as character initial ?.
    define variable o_benfsr as character initial ?.
    define variable o_benacc as character initial ?.
    define variable o_benbank as character initial ?.
    define variable o_dealsdet as character initial ?.
    define variable o_trxcode as character initial ?.
    define variable o_bankinfo as character initial ?.

    find b-jh where b-jh.jh = b-jl.jh no-lock no-error.

    do transaction:
        create b-deals.
        b-deals.account = in_account.
        b-deals.crc = in_crc.
        b-deals.d_date = in_d_date.
        b-deals.amount = in_amount.
        b-deals.trxtrn = in_trxtrn.
        b-deals.cif = cif.
        b-deals.ln = in_ln.
        b-deals.ref = b-jh.ref.

        find b-trxcods where b-trxcods.trxh = b-jl.jh and b-trxcods.trxln = b-jl.ln and b-trxcods.trxt <> ? and b-trxcods.codfr = "stmt" no-lock no-error.
        if avail b-trxcods then b-deals.trxcode = trim(b-trxcods.code).
        else do:
            if b-jh.party begins "RMZ" then b-deals.trxcode = "TRF".
            else if trim(b-jh.party) begins "FX" then b-deals.trxcode = "FX".
            else b-deals.trxcode = "MSC".
        end.
        if b-jl.dam <> 0 then do:
            b-deals.dc = "D".
            b-deals.amount = b-jl.dam.
        end.
        if b-jl.cam <> 0 then do:
            b-deals.dc = "C".
            b-deals.amount = b-jl.cam.
        end.
        if b-deals.trxcode begins "CHG" then do:
            v-nazn = "" .
            v-ln = false.
            find trxcods where trxcods.trxh eq b-jl.jh and trxcods.trxln = b-jl.ln and trxcods.codfr eq "faktura" and trxcods.code begins "chg" no-lock no-error.
            if avail trxcods then do:
                v-tmp = trxcods.code.
                v-ln = false.
                def var v-sln as char.
                def var v-jlln as inte.
                v-sln = "". v-jlln = 0.
                for each trxcods where trxcods.trxh eq b-jl.jh and trxcods.codfr eq "faktura" and trxcods.trxt <> ? and trxcods.trxln <> 0 no-lock:
                    if not (trxcods.code = v-tmp) then next.
                    v-sln = v-sln + string(trxcods.trxln) + ",".
                end.
                if lookup(string(b-jl.ln),v-sln) modulo 2 eq 0 then v-jlln = inte(entry(lookup(string(b-jl.ln),v-sln) - 1, v-sln)) no-error.
                else v-jlln = inte(entry(lookup(string(b-jl.ln),v-sln) + 1, v-sln)) no-error.
                if error-status:error then v-jlln = 0.
                find c-jl where c-jl.jh = b-jl.jh and c-jl.ln = v-jlln no-lock no-error.
                if available c-jl then v-ln = true.
            end.
            if v-ln = true then do:
                find first fakturis where fakturis.jh eq c-jl.jh and fakturis.trx = c-jl.trx and fakturis.ln eq c-jl.ln no-lock no-error.
                if available fakturis then b-deals.custtrn = "Nr." + trim(string(fakturis.order)).

                find first c-jh where c-jh.jh = c-jl.jh no-lock .

                if trim(c-jl.rem[1]) begins "409 -" or trim(c-jl.rem[1]) begins "419 -" or trim(c-jl.rem[1]) begins "429 -" or trim(c-jl.rem[1]) begins "430 -" then do:
                    v-nazn = ": " + string(c-jl.rem[1],"x(37)").
                end.
                else if c-jh.sub = "JOU" then do:
                    find first joudoc where c-jh.ref = joudoc.docnum no-lock no-error .
                    if avail joudoc then find tarif2 where tarif2.str5 = joudoc.comcode and tarif2.kont = c-jl.gl and tarif2.stat = 'r' no-lock no-error.
                                         if not available tarif2 then v-nazn = string(c-jl.rem[5],"x(37)").
                                         else v-nazn = ": " + tarif2.str5 + " - " + string(tarif2.pakalp,"x(37)").
                end.
                else if c-jh.sub = "RMZ" then do:
                    find first remtrz where c-jh.ref = remtrz.remtrz no-lock no-error .
                    if avail remtrz then find tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.kont = c-jl.gl and tarif2.stat = 'r' no-lock no-error.
                                         if not available tarif2 then v-nazn = string(c-jl.rem[5],"x(37)").
                                         else v-nazn = ": " + tarif2.str5 + " - " + string(tarif2.pakalp,"x(37)").
                end.
                else do:
                    if c-jl.rem[1] ne '' then v-nazn = string(trim(c-jl.rem[1]) + ' ' + trim(c-jl.rem[2]),"x(37)").
                    else v-nazn = string(c-jl.rem[5],"x(70)").
                    if c-jl.rem[5] matches '*долг*' then v-nazn = substr(v-nazn,6).
                end.
                b-deals.dealsdet = string(v-nazn).
            end.
            else b-deals.dealsdet = "".
            if trim(b-jh.party) begins "RMZ" or trim(b-jh.party) begins "FX"  or trim(b-jh.party) begins "JOU" then b-deals.dealtrn = substring(trim(b-jh.party),1,10).
            else if b-jh.sub = "UJO" then do:
                find first ujo where ujo.docnum = b-jh.ref no-lock no-error.
                if avail ujo then b-deals.dealtrn = ujo.docnum.
            end.
            else b-deals.dealtrn = "".
            b-deals.who = b-jl.who.
        end.
        else do:
            b-deals.who = b-jl.who.
            find first prfxset where trim(b-jh.party) begins prfxset.oppr no-lock no-error.
            if not available prfxset then do:
                if b-jh.sub = "UJO" then do:
                    find first ujo where ujo.docnum = b-jh.ref no-lock no-error.
                    if avail ujo then do:
                        b-deals.dealtrn = ujo.docnum.
                        if trim(ujo.num) ne "" then b-deals.custtrn = "Nr." + trim(ujo.num).
                    end.
                end.
                b-deals.dealsdet =  trim(b-jl.rem[1]) + " " + trim(b-jl.rem[2]) + " " + trim(b-jl.rem[3]) + " " + trim(b-jl.rem[4]) + " " + trim(b-jl.rem[5]).
            end.
            else do:
                run value(prfxset.procsr)(in_recid, output o_dealtrn, output o_custtrn, output o_ordins, output o_ordcust, output o_ordacc, output o_benfsr, output o_benacc, output o_benbank, output o_dealsdet, output o_bankinfo).
                if return-value = "0" then do:
                    b-deals.dealtrn  = o_dealtrn.
                    b-deals.custtrn  = o_custtrn.
                    b-deals.ordins   = o_ordins.
                    b-deals.ordcust  = o_ordcust.
                    b-deals.ordacc   = o_ordacc.
                    b-deals.benfsr   = o_benfsr.
                    b-deals.benbank  = o_benbank.
                    b-deals.benacc   = o_benacc.
                    b-deals.dealsdet = o_dealsdet.
                    b-deals.bankinfo = o_bankinfo.
                end.
                else b-deals.dealsdet = trim(b-jl.rem[1]) + " " + trim(b-jl.rem[2]) + " " + trim(b-jl.rem[3]) + " " + trim(b-jl.rem[4]) + " " + trim(b-jl.rem[5]).
                if b-deals.dc = "C" then do:
                    find first sysc where sysc.sysc = "LINKJL" no-lock no-error.
                    if available sysc and ( sysc.chval matches( "*" + b-deals.account + "*" ) ) then do:
                        define variable add_detail as character.
                        if b-deals.dealtrn begins "RMZ" then do:
                            find first linkjl where b-deals.d_date = linkjl.jdt and linkjl.rem = b-deals.dealtrn no-lock no-error.
                            if available linkjl then add_detail = trim(atr[12]).
                        end.
                        else do:
                            find first linkjl where b-deals.d_date = linkjl.jdt and linkjl.jh = b-jl.jh and linkjl.ln = b-jl.ln no-lock no-error.
                            if available linkjl then add_detail = trim(atr[12]).
                            else do:
                                find first linkjl where b-deals.d_date = linkjl.jdt and linkjl.jh = b-jl.aah no-lock no-error.
                                if available linkjl then add_detail = trim(atr[12]).
                            end.
                        end.
                        if add_detail <> "" and add_detail <> ? then b-deals.dealsdet = b-deals.dealsdet + " Subkonts: " + add_detail.
                    end.
                end.
            end.
        end.
    end.
end procedure.

hide message no-pause.