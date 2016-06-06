/* iovyp2.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Формирование выписок для интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM TXB
 * AUTHOR
        09/10/09 id00004
 * CHANGES
        24/06/2010 id00004 добавил подстановку номера документа в выписку
        30.01.2011 id00004 добавил формирование выписки в DBF
        29/04/2011 id00004 добавил отображение выписки по входящим платежам
        29/06/2011 id00004 добавил отображение КНП если проводка по снятию комиссии
        27/07/2011 id00004 оптимизация запросов для больших периодов
        24/08/2011 id00004 поправил отображение корреспондента для внутренних переводов (jou)
        19/09/2011 id00004 добавил обработку ситуации если проводка сделана в вручную в шаблоне
        27/12/2011 id00004 добавил переменную для перехода на ИИН-БИН
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
        16.11.2012 berdibekov - КОд, КБЕ, РНН
        02.01.2013 damir - Переход на ИИН/БИН. Оптимизация кода.
        28.01.2013 damir - <Доработка выписок, выгружаемых в DBF - файл>. Оптимизация кода. Добавлена GetRnnRmz.i.
        01.02.2013 damir - Перекомпиляция в связи с изменением iovypfunc_txb.i. Подправил в процедуре SearchDt. По комиссиям КНП = 840.
        12.09.2013 k.gitalov ИБФЛ
*/
def input parameter pInbound as char no-undo.
def input parameter g_date as date no-undo.
def input parameter pAccount as char no-undo.
def input parameter pFromDate as date no-undo.
def input parameter pToDate as date no-undo.
def output parameter rdes as char no-undo.
def output parameter totalCount as inte no-undo.
def output parameter okpo as char no-undo.
def output parameter bankName as char no-undo.
def output parameter bankRNN as char no-undo.
def output parameter clientCode as char no-undo.
def output parameter clientName as char no-undo.
def output parameter clientRNN as char no-undo.
def output parameter sm as deci no-undo.
def output parameter sm1 as deci no-undo.

def var tmpName as char.
def var v-KOd as char.
def var v-KBe as char.
def var v-KNP as char.
def var v-storned as logi.
def var s-jh as inte.
def var v-RnnBnn as char.
def var v-bn as char.
def var v-ordcust as char.
def var v-bnkbin as char.
def var v-bnkrnn as char.
def var aaa as char.
def var namebank as char.
def var rnn as char.
def var v-ccode as char.
def var v-code as char.
def var v-deal_code as char.
def var s-ourbank as char no-undo.
def var v-rem as char no-undo.
def var i as integer no-undo.
def var vln as integer no-undo.
def var acctype as char no-undo.

def buffer b-jl for txb.jl.
def buffer t-jl for txb.jl.
def buffer b-aaa for txb.aaa.
def buffer bf-cif for txb.cif.
def buffer b-codfr for txb.codfr.
def buffer b-sub-cod for txb.sub-cod.

{replacebnk.i}
{nbankBik-txb.i}
{iovypshared.i}
{chbin_txb.i}
{iovypfunc_txb.i}
{GetRnnRmz.i}

function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
    define buffer bcrc1 for txb.crchis.
    define buffer bcrc2 for txb.crchis.

    if d1 = 10.01.08 or d1 = 12.01.08 then do:
        if c1 <> c2 then do:
            find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt < d1 no-lock no-error.
            find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt < d1 no-lock no-error.
            return sum * bcrc1.rate[1] / bcrc2.rate[1].
        end.
        else return sum.
    end.
    do:
        if c1 <> c2 then do:
            find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
            find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
            return sum * bcrc1.rate[1] / bcrc2.rate[1].
        end.
        else return sum.
    end.
end.
run lonbal3('cif',pAccount,pFromDate - 1,"1",yes,output sm).
run lonbal3('cif',pAccount,pToDate ,"1",yes,output sm1).

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then s-ourbank = trim(txb.sysc.chval).

find first txb.aaa where txb.aaa.aaa = pAccount no-lock no-error.
if not avail txb.aaa then do: rdes = 'Счет не найден'. return. end.

find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
if not avail txb.cif then do: rdes = 'Клиент не найден'. return. end.

clientCode = txb.cif.cif.
clientName = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
if v-bin then clientRNN = txb.cif.bin.
else clientRNN = txb.cif.jss.

find txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
find txb.cmp no-lock no-error.

okpo = trim(txb.cmp.addr[3]).
bankName = trim(txb.cmp.name).
v-bnkbin = trim(txb.sysc.chval).
v-bnkrnn = trim(txb.cmp.addr[2]).
if v-bin then bankRNN = trim(txb.sysc.chval).
else bankRNN = trim(txb.cmp.addr[2]).

totalCount = 0.
for each txb.jl where txb.jl.jdt >= pFromDate and txb.jl.jdt <= pToDate and txb.jl.acc = pAccount and txb.jl.lev = 1 no-lock:
    v-KOd = "". v-KBe = "". v-KNP = "". v-storned = false. s-jh = 0. v-bn = "". v-ordcust = "". aaa = "". namebank = "". rnn = "". v-deal_code = "-".
    v-code = "".

    v-storned = txb.jl.rem[1] matches "*Storn*" or txb.jl.rem[2] matches "*Storn*" or txb.jl.rem[3] matches "*Storn*" or
    txb.jl.rem[4] matches "*Storn*" or txb.jl.rem[5] matches "*Storn*".
    s-jh = txb.jl.jh.

    totalCount = totalCount + 1.
    create t-doc.
    t-doc.oper_code = txb.jl.jh.
    t-doc.date_doc = txb.jl.jdt.
    t-doc.dam = txb.jl.dam.
    t-doc.cam = txb.jl.cam.
    find last txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
    if avail txb.crc then do:
        t-doc.crc = txb.crc.code.
        t-doc.nominale = crc-crc-date(decimal(abs(txb.jl.dam - txb.jl.cam)), txb.jl.crc, 1, txb.jl.jdt - 1).
    end.
    v-rem = txb.jl.rem[1].
    do i = 2 to 5:
        if trim(txb.jl.rem[i]) <> '' then do:
            if v-rem <> '' then v-rem = v-rem + ' '.
            v-rem = v-rem + txb.jl.rem[i] + ' '.
        end.
    end.
    if txb.jl.trx = "cif0006" then do:
        find last txb.cmp no-lock no-error.
        t-doc.name = txb.cmp.name.
        t-doc.rnn = bankRNN.
        t-doc.des = "Услуги банка по тарифу:".
    end.
    t-doc.des = t-doc.des + " " + v-rem.
    find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
    if avail txb.jh then do:
        t-doc.tim = txb.jh.tim.
        find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.codfr = "stmt" no-lock no-error.
        if avail trxcods then t-doc.deal_type = trxcods.code.
        else do:
            if txb.jh.party begins "RMZ" then t-doc.deal_type = "TRF".
            else if trim(txb.jh.party) begins "FX" then t-doc.deal_type = "FX".
            else t-doc.deal_type = "MSC".
        end.
        case txb.jh.sub:
            when "RMZ" then do:
                find first txb.remtrz where txb.remtrz.remtrz = substr(trim(txb.jh.party),1,10) no-lock no-error.
                if avail txb.remtrz then do:
                    v-deal_code = substr(trim(txb.jh.party),1,10).
                    find last netbank where netbank.rmz = txb.remtrz.remtrz no-lock no-error.
                    if avail netbank and netbank.cif = txb.cif.cif then t-doc.num_doc = netbank.rem[2].
                    else t-doc.num_doc = string(trim( substring( remtrz.sqn,19,8 ))).

                    t-doc.name = ''.
                    if txb.jl.dam <> 0 then t-doc.name = trim(trim(txb.remtrz.bn[1]) + " " + trim(txb.remtrz.bn[2]) + " " + trim(txb.remtrz.bn[3])).
                    else t-doc.name = trim(txb.remtrz.ord).

                    t-doc.bank_name = ''.
                    if txb.remtrz.rbank begins "TXB" then do:
                        find first txb.bankl where txb.bankl.bank = txb.remtrz.rbank no-lock no-error.
                        if avail txb.bankl and txb.bankl.name <> "" then do:
                            t-doc.bank_name = trim(txb.bankl.name).
                            t-doc.bank_bic = v-clecod.
                        end.
                        else do:
                            t-doc.bank_name = trim(txb.remtrz.bb[1]) + " " + trim(txb.remtrz.bb[2]) + " " + trim(txb.remtrz.bb[3]).
                            find first comm.txb where comm.txb.bank = txb.remtrz.rbank and comm.txb.consolid no-lock no-error.
                            if avail comm.txb then t-doc.bank_bic = comm.txb.mfo.
                        end.
                    end.
                    else do:
                        t-doc.bank_bic = txb.remtrz.rbank.
                        if txb.remtrz.bb[1] = "NONE" then do:
                            find first txb.bankl where txb.bankl.bank = txb.remtrz.rbank no-lock no-error.
                            if avail txb.bankl and txb.bankl.name <> "" then t-doc.bank_name = trim(txb.bankl.name).
                        end.
                        else t-doc.bank_name = trim(txb.remtrz.bb[1]) + " " + trim(txb.remtrz.bb[2]) + " " + trim(txb.remtrz.bb[3]).
                    end.
                    t-doc.account = trim(replace((if txb.remtrz.sacc <> '' then txb.remtrz.sacc else txb.remtrz.dracc ),'/','')).
                    if t-doc.account <> pAccount then do:
                        if txb.remtrz.sbank begins "TXB" then do:
                            find first txb.bankl where txb.bankl.bank = txb.remtrz.sbank no-lock no-error.
                            if avail txb.bankl and txb.bankl.name <> "" then do:
                                t-doc.bank_name = trim(txb.bankl.name).
                                t-doc.bank_bic = v-clecod.
                            end.
                        end.
                        else do:
                            t-doc.bank_bic = txb.remtrz.sbank.
                            find first txb.bankl where txb.bankl.bank = txb.remtrz.sbank no-lock no-error.
                            if avail txb.bankl and txb.bankl.name <> "" then t-doc.bank_name = trim(txb.bankl.name).
                        end.
                    end.
                    else do:
                        if txb.remtrz.rbank begins "TXB" then do:
                            find first txb.bankl where txb.bankl.bank = txb.remtrz.rbank no-lock no-error.
                            if avail txb.bankl and txb.bankl.name <> "" then do:
                                t-doc.bank_name = trim(txb.bankl.name).
                                t-doc.bank_bic = v-clecod.
                            end.
                        end.
                        else do:
                            t-doc.bank_bic = txb.remtrz.rbank.
                            find first txb.bankl where txb.bankl.bank = txb.remtrz.rbank no-lock no-error.
                            if avail txb.bankl and txb.bankl.name <> "" then t-doc.bank_name = trim(txb.bankl.name).
                        end.
                    end.
                    if (txb.remtrz.detpay[1]) matches (txb.remtrz.ba + "*") or (txb.remtrz.detpay[1]) matches (substring(txb.remtrz.ba,2) + "*") then
                    v-rem = trim(substring(txb.remtrz.detpay[1], length(t-doc.account) + 1)) + " " + trim(txb.remtrz.detpay[2]) + " " +
                    trim(txb.remtrz.detpay[3]) + " " + trim(txb.remtrz.detpay[4]).
                    else v-rem = trim(txb.remtrz.detpay[1]) + " " + trim(txb.remtrz.detpay[2]) + " " + trim(txb.remtrz.detpay[3]) + " " +
                    trim(txb.remtrz.detpay[4]).

                    if txb.jl.trx <> "PSY0025" then t-doc.des = v-rem.

                    /*Дополнение*/
                    run Get_EKNP('rmz',substr(trim(txb.jh.party),1,10),'eknp',output v-KOd,output v-KBe,output v-KNP).

                    v-bn = txb.remtrz.bn[1] + txb.remtrz.bn[2] + txb.remtrz.bn[3].
                    v-ordcust = txb.remtrz.ord.

                    if not (trim(txb.jl.rem[1]) begins txb.remtrz.remtrz) then do:
                        v-bn = "".
                        v-ordcust = "".
                    end.

                    if txb.jl.dc = "D" then do:
                        v-code = "КБе:" + v-KBe.
                        if v-bn = "" then do:
                            run SearchDt.
                        end.
                        else do:
                            namebank = GetNameBenOrd(v-bn).
                            rnn = GetRnnBenOrd(v-bn).
                            aaa = txb.remtrz.ba.
                        end.
                    end.
                    else if txb.jl.dc = "C" then do:
                        v-code = "КОд:" + v-KOd.
                        if v-ordcust = "" then do:
                            run SearchCt.
                        end.
                        else do:
                            namebank = GetNameBenOrd(v-ordcust).
                            rnn = GetRnnBenOrd(v-ordcust).
                            aaa = txb.remtrz.sacc.
                        end.
                    end.
                end.
            end.
            when "JOU" then do:
                v-deal_code = substr(trim(txb.jh.party),1,10).
                find first txb.bankl where txb.bankl.bank = s-ourbank no-lock no-error.
                if avail txb.bankl then t-doc.bank_name = txb.bankl.name.
                t-doc.bank_bic = v-clecod.

                find first txb.joudoc where txb.joudoc.docnum = substr(trim(txb.jh.party),1,10) no-lock no-error.
                if avail txb.joudoc then do:
                    v-rem = trim(txb.joudoc.remark[1]) .
                    if (substring(txb.joudoc.remark[2],1,199)) <> ? then v-rem = v-rem + trim(substring(txb.joudoc.remark[2],1,199)) + " ".
                    if (txb.joudoc.info) <> ? then v-rem = v-rem + trim(txb.joudoc.info) + " ".
                    if (txb.joudoc.passp) <> ? then v-rem = v-rem + trim(txb.joudoc.passp) + " ".
                    if (txb.joudoc.perkod) <> ? then v-rem = v-rem + trim(txb.joudoc.perkod).

                    /*Дополнение*/
                    run Get_EKNP('jou',substr(trim(txb.jh.party),1,10),'eknp',output v-KOd,output v-KBe,output v-KNP).

                    if txb.jl.dc = "D" then do:
                        if v-KOd + v-KBe + v-KNP = "" then run GetCods_txb(v-storned,s-jh,txb.jl.dc,txb.jl.dam,txb.jl.acc,output v-KOd,output v-KBe,output v-KNP).

                        v-code = "КБе:" + v-KBe.

                        run SearchDt.
                    end.
                    else if txb.jl.dc = "C" then do:
                        if v-KOd + v-KBe + v-KNP = "" then run GetCods_txb(v-storned,s-jh,txb.jl.dc,txb.jl.cam,txb.jl.acc,output v-KOd,output v-KBe,output v-KNP).

                        run SearchCt.

                        v-code = "КОд:" + v-KOd.
                    end.
                end. /* if avail txb.joudoc */
            end. /*when "JOU"*/
            otherwise do:
                find last netbank where netbank.rmz = substr(trim(txb.jh.party),1,10) no-lock no-error.
                if avail netbank and netbank.cif = txb.cif.cif then t-doc.num_doc = netbank.rem[2].
                find first txb.bankl where txb.bankl.bank = s-ourbank no-lock no-error.
                if avail txb.bankl then t-doc.bank_name = txb.bankl.name.
                t-doc.bank_bic = v-clecod.

                if txb.jl.dc = "D" then do:
                    run GetCods_txb(v-storned,s-jh,txb.jl.dc,txb.jl.dam,txb.jl.acc,output v-KOd,output v-KBe,output v-KNP).

                    run SearchDt.

                    if v-KOd + v-KBe + v-KNP = "" then do:
                        find first t-jl where t-jl.jh = s-jh and t-jl.dc = txb.jl.dc and t-jl.acc = txb.jl.acc no-lock no-error.
                        if avail t-jl then run GetCods_txb(v-storned,s-jh,t-jl.dc,t-jl.dam,t-jl.acc,output v-KOd,output v-KBe,output v-KNP).
                    end.

                    if v-KOd + v-KBe + v-KNP = "" then do:
                        find first t-jl where t-jl.jh = s-jh and t-jl.dc = "C" and t-jl.acc = txb.jl.acc no-lock no-error.
                        if avail t-jl then run GetCods_txb(v-storned,s-jh,"C",t-jl.cam,t-jl.acc,output v-KOd,output v-KBe,output v-KNP).
                    end.

                    v-code = "КБе:" + v-KBe.
                end.
                else if txb.jl.dc = "C" then  do:
                    run GetCods_txb(v-storned,s-jh,txb.jl.dc,txb.jl.cam,txb.jl.acc,output v-KOd,output v-KBe,output v-KNP).

                    run SearchCt.

                    if v-KOd + v-KBe + v-KNP = "" then do:
                        find first t-jl where t-jl.jh = s-jh and t-jl.dc = txb.jl.dc and t-jl.acc = txb.jl.acc no-lock no-error.
                        if avail t-jl then run GetCods_txb(v-storned,s-jh,t-jl.dc,t-jl.cam,t-jl.acc,output v-KOd,output v-KBe,output v-KNP).
                    end.

                    if v-KOd + v-KBe + v-KNP = "" then do:
                        find first t-jl where t-jl.jh = s-jh and t-jl.dc = "D" and t-jl.acc = txb.jl.acc no-lock no-error.
                        if avail t-jl then run GetCods_txb(v-storned,s-jh,"D",t-jl.dam,t-jl.acc,output v-KOd,output v-KBe,output v-KNP).
                    end.

                    v-code = "КОд:" + v-KOd.
                end.
            end. /*otherwise do:*/
        end. /*case txb.jh.sub*/
    end. /* if avail txb.jh */
    if txb.jl.trx = "cif0006" then t-doc.bank_name = ''.

    if v-bin then do:
        if txb.jl.jdt ge v-bin_rnn_dt then v-RnnBnn = "ИИН/БИН".
        else v-RnnBnn = "РНН".
    end.
    else v-RnnBnn = "РНН".

    if trim(rnn) eq "" then rnn = "000000000000".

    t-doc.account = trim(aaa).
    t-doc.name = trim(namebank).
    t-doc.rnn = trim(v-RnnBnn + " " + rnn).
    t-doc.bank_name = replace(t-doc.bank_name,'/','').
    t-doc.kod = v-code.
    t-doc.kbe = v-KBe.
    t-doc.knp = v-KNP.
    t-doc.deal_code = v-deal_code.
end.

procedure lonbal3.
    define input  parameter p-sub like txb.trxbal.subled.
    define input  parameter p-acc as char.
    define input  parameter p-dt like txb.jl.jdt.
    define input  parameter p-lvls as char.
    define input  parameter p-includetoday as logi.
    define output parameter res as decimal.

    def var i as integer.

    res = 0.

    if p-dt > g_date then p-dt = g_date. /*return.*/

    if p-includetoday then do: /* за дату */
        if p-dt = g_date then do:
            for each txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc no-lock:
                if lookup(string(txb.trxbal.level), p-lvls) > 0 then do:
                    find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
                    if not avail b-aaa then return.
                    find txb.trxlevgl where txb.trxlevgl.gl eq b-aaa.gl and txb.trxlevgl.subled eq p-sub and
                    lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
                    if not avail txb.trxlevgl then return.

                    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
                    if not avail txb.gl then return.

                    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.trxbal.dam - txb.trxbal.cam.
                    else res = res + txb.trxbal.cam - txb.trxbal.dam.

                    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic" and
                    txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
                    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.
                end.
            end.
        end.
        else do:
            do i = 1 to num-entries(p-lvls):
                find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and
                txb.histrxbal.level = integer(entry(i, p-lvls)) and txb.histrxbal.dt <= p-dt no-lock no-error.
                if avail txb.histrxbal then do:
                    find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
                    if not avail b-aaa then return.

                    find txb.trxlevgl where txb.trxlevgl.gl eq b-aaa.gl and txb.trxlevgl.subled eq p-sub and
                    lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
                    if not avail txb.trxlevgl then return.

                    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
                    if not avail txb.gl then return.

                    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
                    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

                    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic" and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
                    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.
                end.
            end.
        end.
    end. /* if p-includetoday */
    else do: /* на дату */
        do i = 1 to num-entries(p-lvls):
            find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = integer(entry(i, p-lvls))
            and txb.histrxbal.dt < p-dt no-lock no-error.
            if avail txb.histrxbal then do:
                find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
                if not avail b-aaa then return.

                find txb.trxlevgl where txb.trxlevgl.gl eq b-aaa.gl and txb.trxlevgl.subled eq p-sub and
                lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
                if not avail txb.trxlevgl then return.

                find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
                if not avail txb.gl then return.

                if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
                else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

                find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic" and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
                if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.
            end.
        end.
    end.
end.
