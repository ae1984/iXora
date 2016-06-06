/* AMLfindoper.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Возвращает данные по операции
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
        29/06/2010 galina
 * BASES
        BANK COMM TXB
 * CHANGES
        30/06/2010 madiyar - перекомпиляция
        12/07/2010 galina - возврат данных по переводам метроэкспресс
        19/07/2010 galina - исправление по обменным операциям
        03/03/2011 madiyar - данные по операциям с залогами
        16/07/2013 yerganat - ТЗ1839, добавил property, propertynumber, sdp
*/

def input parameter p-donum as char.
def output parameter p-crccode as char.
def output parameter p-dacc as char.
def output parameter p-cacc as char.
def output parameter p-dgl as char.
def output parameter p-cgl as char.
def output parameter p-operdt as char.
def output parameter p-sumkzt as deci.
def output parameter p-sum as deci.
def output parameter p-knp as char.
def output parameter p-operinf as char.

def output parameter p-blagotvor as char.
def output parameter p-extcountry as char.

def output parameter p-property as char.
def output parameter p-propertynumber as char.
def output parameter p-sdp as char.

p-blagotvor = '0'.
p-extcountry = ''.

if substr(p-donum,1,3) = 'jou' then do:
    find first txb.joudoc where txb.joudoc.docnum = p-donum no-lock no-error.
    if avail txb.joudoc then do:
        find first txb.jh where txb.jh.jh = txb.joudoc.jh no-lock no-error.
        if avail txb.jh then do:
            p-operdt = replace(string(txb.jh.jdt,'99/99/9999'),'/','.') + ' ' + string(txb.jh.tim,'hh:mm:ss').

            if txb.joudoc.drcur <> txb.joudoc.crcur then do:
                if txb.joudoc.drcur > 1 then do:
                    find last txb.crchis where txb.crchis.crc = txb.joudoc.drcur and txb.crchis.rdt <= txb.jh.jdt no-lock no-error.
                    p-sum = txb.joudoc.dramt.
                    if txb.joudoc.dracctype = '1' and txb.joudoc.cracctype = '1' then p-sumkzt = txb.joudoc.cramt.
                    else p-sumkzt = txb.joudoc.dramt * txb.crchis.rate[1].
                end.
                if txb.joudoc.crcur > 1 then do:
                    find last txb.crchis where txb.crchis.crc = txb.joudoc.crcur and txb.crchis.rdt <= txb.jh.jdt no-lock no-error.
                    p-sum = txb.joudoc.cramt.
                    if txb.joudoc.dracctype = '1' and txb.joudoc.cracctype = '1' then p-sumkzt = txb.joudoc.dramt.
                    else p-sumkzt = txb.joudoc.cramt * txb.crchis.rate[1].
                end.
            end.
            if txb.joudoc.drcur = txb.joudoc.crcur then do:
                find last txb.crchis where txb.crchis.crc = txb.joudoc.drcur and txb.crchis.rdt <= txb.jh.jdt no-lock no-error.
                p-sum = txb.joudoc.dramt.
                p-sumkzt = txb.joudoc.cramt * txb.crchis.rate[1].
            end.
            if avail txb.crchis then p-crccode = txb.crchis.code.

            if txb.joudoc.dracctype = "2" then do:
                p-dacc = txb.joudoc.dracc.
                find first txb.aaa where txb.aaa.aaa = p-dacc no-lock no-error.
                if avail txb.aaa then do:
                    find first txb.sub-cod where txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" use-index dcod no-lock no-error.
                    if avail txb.sub-cod and txb.sub-cod.ccode = '8' then p-blagotvor = '1'.
                end.
            end.
            if txb.joudoc.cracctype = "2" then do:
                p-cacc = txb.joudoc.cracc.
                find first txb.aaa where txb.aaa.aaa = p-cacc no-lock no-error.
                if avail txb.aaa then do:
                    find first txb.sub-cod where txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" use-index dcod no-lock no-error.
                    if avail txb.sub-cod and txb.sub-cod.ccode = '8' then p-blagotvor = '1'.
                end.
            end.
            find first txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.dc = 'D' no-lock no-error.
            if avail txb.jl then p-dgl = string(txb.jl.gl,'999999').
            find first txb.jl where txb.jl.jh = txb.joudoc.jh and txb.jl.dc = 'C' no-lock no-error.
            if avail txb.jl then p-cgl = string(txb.jl.gl,'999999').

            find first txb.trxcods where txb.trxcods.trxh = txb.joudoc.jh and  txb.trxcods.codfr = "spnpl" no-lock no-error.
            if avail txb.trxcods then p-knp = txb.trxcods.code.

            p-operinf = txb.joudoc.remark[1] + ' ' + txb.joudoc.remark[2] + ' ' + joudoc.rescha[3].
            if joudoc.rescha[5] = 'ZK' then
                p-sdp = 'ЗОЛОТАЯ КОРОНА'.

        end.
    end.
end.

def var v-dt as date no-undo.
def var v-tim as int no-undo.

find first txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = '' then return.


if substr(p-donum,1,3) = 'RMZ' then do:

    /*message "1..." view-as alert-box.*/

    find first txb.remtrz where txb.remtrz.remtrz = p-donum no-lock no-error.
    if avail txb.remtrz then do:
        /*message "2..." view-as alert-box.*/
        /*if txb.remtrz.sbank <> txb.sysc.chval and txb.remtrz.rbank <> txb.sysc.chval then return.*/

        /*message "3..." view-as alert-box.*/

        if txb.remtrz.sbank = txb.sysc.chval then do:
            /*message "4..." view-as alert-box.*/
            if txb.remtrz.outcode = 3 then do:
                find first txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
                if avail txb.aaa then p-dacc = txb.remtrz.sacc.
            end.
            p-cacc = txb.remtrz.racc.
        end.
        if txb.remtrz.rbank = txb.sysc.chval then do:
            /*message "5..." view-as alert-box.*/
            p-dacc = txb.remtrz.sacc.
            find first txb.aaa where txb.aaa.aaa = txb.remtrz.racc no-lock no-error.
            if avail txb.aaa then p-cacc = txb.remtrz.racc.
        end.

        if txb.remtrz.sbank <> txb.sysc.chval and txb.remtrz.rbank <> txb.sysc.chval then do:
            p-dacc = txb.remtrz.sacc.
            p-cacc = txb.remtrz.racc.
        end.

        v-dt = txb.remtrz.valdt2.
        find first txb.jh where txb.jh.jh = txb.remtrz.jh2 no-lock no-error.
        if avail txb.jh then v-tim = txb.jh.tim.

        p-operdt = replace(string(v-dt,'99/99/9999'),'/','.') + ' ' + string(v-tim,'hh:mm:ss').

        /*message "6..." + string(p-operdt) view-as alert-box.*/

        p-sum = txb.remtrz.amt.

        /*message "7..." + string(p-sum) view-as alert-box.*/

        find last txb.crchis where txb.crchis.crc = txb.remtrz.fcrc and txb.crchis.rdt <= v-dt no-lock no-error.
        if avail txb.crchis then do:
            p-crccode = txb.crchis.code.
            p-sumkzt = p-sum * txb.crchis.rate[1].
            /*message "8..." + string(p-sumkzt) view-as alert-box.*/
        end.
        find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
        if avail txb.sub-cod then do:
            if num-entries(txb.sub-cod.rcode) > 2 then p-knp = entry(3,txb.sub-cod.rcode).
            if (entry(1,txb.sub-cod.rcode) = '18') or ((num-entries(txb.sub-cod.rcode) > 1) and (entry(2,txb.sub-cod.rcode) = '18')) then p-blagotvor = '1'.
        end.

        find first txb.sub-cod where txb.sub-cod.acc = txb.remtrz.remtrz and txb.sub-cod.sub = "rmz" and txb.sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
        if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then do:
            p-extcountry = txb.sub-cod.ccode.
            find first code-st where code-st.code = p-extcountry no-lock no-error.
            if avail code-st then p-extcountry = code-st.cod-ch.
        end.

        if trim(txb.remtrz.detpay[1]) <> '' then p-operinf = trim(txb.remtrz.detpay[1]).
        if trim(txb.remtrz.detpay[2]) <> '' then p-operinf = p-operinf + ' ' + trim(txb.remtrz.detpay[2]).
        if trim(txb.remtrz.detpay[3]) <> '' then p-operinf = p-operinf + ' ' + trim(txb.remtrz.detpay[3]).
        if trim(txb.remtrz.detpay[4]) <> '' then p-operinf = p-operinf + ' ' + trim(txb.remtrz.detpay[4]).

        p-dgl = string(txb.remtrz.drgl,'999999').
        p-cgl = string(txb.remtrz.crgl,'999999').

    end.
end.
/* переводы метроэкспрес*/

/*исходящие*/
if substr(p-donum,1,2) = 'МК' then do:
    find first translat where translat.nomer = p-donum and translat.jh > 0 no-lock no-error.
    if translat.jh-voz > 0 then return.
    find first txb.jh where txb.jh.jh = translat.jh no-lock no-error.
    if not avail txb.jh then return.
    find first txb.jl where txb.jl.jh = translat.jh no-lock no-error.
    if not avail txb.jl then return.
    p-operdt = replace(string(txb.jh.jdt,'99/99/9999'),'/','.') + ' ' + string(txb.jh.tim,'hh:mm:ss').
    p-sum = translat.summa.
    v-dt = txb.jh.jdt.
    find last txb.crchis where txb.crchis.crc = translat.crc and txb.crchis.rdt <= v-dt no-lock no-error.
    if avail txb.crchis then do:
        p-crccode = txb.crchis.code.
        p-sumkzt = p-sum * txb.crchis.rate[1].
    end.
    find first txb.jl where txb.jl.jh = translat.jh and txb.jl.dc = 'D' no-lock no-error.
    if avail txb.jl then p-dgl = string(txb.jl.gl).
    find first txb.jl where txb.jl.jh = translat.jh and txb.jl.dc = 'C' no-lock no-error.
    if avail txb.jl then p-cgl = string(txb.jl.gl).


    find first txb.sub-cod where txb.sub-cod.acc = translat.nomer and txb.sub-cod.sub = "trl" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
    if avail txb.sub-cod then do:
        if num-entries(txb.sub-cod.rcode) > 2 then p-knp = entry(3,txb.sub-cod.rcode).
    end.
    p-extcountry = 'RU'.
end.

/*входящие*/
if substr(p-donum,1,3) = 'МБГ' then do:

    find first r-translat where r-translat.nomer = p-donum and r-translat.jh > 0 no-lock no-error.
    /*if r-translat.jh-voz > 0 then return.*/
    find first txb.jh where txb.jh.jh = r-translat.jh no-lock no-error.
    if not avail txb.jh then return.
    find first txb.jl where txb.jl.jh = r-translat.jh no-lock no-error.
    if not avail txb.jl then return.
    p-operdt = replace(string(txb.jh.jdt,'99/99/9999'),'/','.') + ' ' + string(txb.jh.tim,'hh:mm:ss').
    p-sum = r-translat.summa.
    v-dt = txb.jh.jdt.
    find last txb.crchis where txb.crchis.crc = r-translat.crc and txb.crchis.rdt <= v-dt no-lock no-error.
    if avail txb.crchis then do:
        p-crccode = txb.crchis.code.
        p-sumkzt = p-sum * txb.crchis.rate[1].
    end.

    find first txb.jl where txb.jl.jh = translat.jh and txb.jl.dc = 'D' no-lock no-error.
    if avail txb.jl then p-dgl = string(txb.jl.gl).
    find first txb.jl where txb.jl.jh = translat.jh and txb.jl.dc = 'C' no-lock no-error.
    if avail txb.jl then p-cgl = string(txb.jl.gl).

    find first txb.sub-cod where txb.sub-cod.acc = r-translat.nomer and txb.sub-cod.sub = "trl" and txb.sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
    if avail txb.sub-cod then do:
        if num-entries(txb.sub-cod.rcode) > 2 then p-knp = entry(3,txb.sub-cod.rcode).
    end.
    p-extcountry = 'RU'.

end.
/*********/

if (caps(p-donum) begins "D") and (length(p-donum) = 9) then do:
    find first txb.doch where txb.doch.docid = p-donum no-lock no-error.
    if avail txb.doch then do:
        p-operinf = txb.doch.info[3].
        find first txb.jl where txb.jl.jh = txb.doch.jh and txb.jl.dc = 'D' no-lock no-error.
        if avail txb.jl then do:
            find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
            if avail txb.jh then p-operdt = replace(string(txb.jh.jdt,'99/99/9999'),'/','.') + ' ' + string(txb.jh.tim,'hh:mm:ss').
            if p-operinf <> '' then p-operinf = p-operinf + ', '.
            p-operinf = trim(p-operinf + trim(txb.jl.rem[1]) + ' ' + trim(txb.jl.rem[2]) + ' ' + trim(txb.jl.rem[3]) + ' ' + trim(txb.jl.rem[5]) + ' ' + trim(txb.jl.rem[5])).
            p-sum = txb.jl.dam.
            find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
            if avail txb.crchis then do:
                p-crccode = txb.crchis.code.
                p-sumkzt = p-sum * txb.crchis.rate[1].
            end.
            p-dacc = txb.jl.acc.
            p-dgl = string(txb.jl.gl).
        end.
        find first txb.jl where txb.jl.jh = txb.doch.jh and txb.jl.dc = 'C' no-lock no-error.
        if avail txb.jl then do:
            p-cacc = txb.jl.acc.
            p-cgl = string(txb.jl.gl).
        end.

        find first txb.lonsec1 where txb.lonsec1.lon = txb.doch.acc no-lock no-error.
        if avail txb.lonsec1 then do:
            p-propertynumber = txb.lonsec1.prm.
            find first txb.lonsec where txb.lonsec.lonsec = txb.lonsec1.lonsec no-lock no-error.
            if avail txb.lonsec then do:
               if txb.lonsec.lonsec = 2 then p-property = "3".
               else p-property = "4".
            end.
        end.
    end.
end.