/* r-f2p1.p
 * MODULE
        СБ
 * DESCRIPTION
        Отчет о покупке/продаже иностранной валюты банком и его клиентами. Раздел 1.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-f2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-8-2
 * BASES
        BANK COMM TXB
 * AUTHOR
        29/08/2012 dmitriy
 * CHANGES
        05/09/2012 dmitriy - для операций ОП добавил счет 100500
        24/09/2012 dmitriy - перекомпиляция


*/


def shared var vn-dt as date    no-undo.
def shared var vn-dtbeg as date no-undo.
def shared var tg1000 as int.


def buffer b1 for txb.aaa.
def buffer b2 for txb.aaa.
def buffer bjl for txb.jl.
def buffer bjl2 for txb.jl.

def var gl-list as char.
gl-list = '2203,2204,2205,2206,2207,2208,2209,2210,2211,2213,2215,2217,2219,2221'.


function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
define buffer bcrc1 for txb.crchis.
define buffer bcrc2 for txb.crchis.
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.
end.

 def shared temp-table tmp-f2
     field strnum as int
     field nom  as char
     field name as char
     field kod  as integer
     field summ as decimal decimals 2
     field usd  as decimal decimals 2
     field eur  as decimal decimals 2
     field rur  as decimal decimals 2.

def shared temp-table wrk-shifr1
    field jh as int
    field jdt as date
    field trx as char
    field dr4gl as char
    field drgl-name as char
    field dr20aaa as char
    field dr_crc as char
    field cr4gl as char
    field crgl-name as char
    field cr20aaa as char
    field cr_crc as char
    field kod as int
    field kbe as int
    field knp as int
    field sum_crc as deci
    field sum_tng as deci
    field rem as char
    field buy_rate as deci
    field sell_rate as deci
    field buy_kod as int
    field sell_kod as int
    field buy_kod1 as int
    field sell_kod1 as int
    field txb as char
    field purpose as char.

def var kod as int.
def var kbe as int.
def var knp as int.

def var rate9 as deci.
def var rate1 as deci.

find first txb.cmp no-lock no-error.
find first comm.txb where int(substr(comm.txb.bank, 4)) = cmp.code no-lock no-error.

for each tmp-f2 break by /*nom*/ strnum:
    if tmp-f2.kod = 110001 then do:
        for each txb.jl where txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt and index(gl-list, substring(string(txb.jl.gl), 1, 4)) > 0
                              and txb.jl.crc <> 1 and txb.jl.dc = 'D'
        no-lock:
            kod = 0. kbe = 0. knp = 0.
            if txb.jl.crc > 4 then next.
            run GetEKNP(txb.jl.jh, txb.jl.ln, txb.jl.dc, input-output KOd, input-output KBe, input-output KNP).
            if knp = 213 then do:
                if txb.jl.crc = 2  then tmp-f2.usd = tmp-f2.usd + round(txb.jl.dam / tg1000, 0). else
                if txb.jl.crc = 3  then tmp-f2.eur = tmp-f2.eur + round(txb.jl.dam / tg1000, 0). else
                if txb.jl.crc = 4  then tmp-f2.rur = tmp-f2.rur + round(txb.jl.dam / tg1000, 0).

                find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
                if avail txb.crchis then
                tmp-f2.summ = tmp-f2.summ + round((txb.jl.dam * txb.crchis.rate[1]) / tg1000, 0).

                create wrk-shifr1.

                wrk-shifr1.txb =  comm.txb.info.
                wrk-shifr1.jh = txb.jl.jh.
                wrk-shifr1.jdt = txb.jl.jdt.
                wrk-shifr1.trx = txb.jl.trx.
                wrk-shifr1.dr4gl = substr(string(txb.jl.gl), 1, 4).
                wrk-shifr1.dr20aaa = txb.jl.acc.

                find first bjl2 where bjl2.jh = txb.jl.jh and bjl2.ln = txb.jl.ln + 1 no-lock no-error.
                if avail bjl2 then do:
                    wrk-shifr1.cr4gl = substr(string(bjl2.gl), 1, 4).
                    wrk-shifr1.cr20aaa = bjl2.acc.
                end.

                find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
                if avail txb.crc then
                wrk-shifr1.dr_crc = txb.crc.code.
                wrk-shifr1.kod = kod.
                wrk-shifr1.kbe = kbe.
                wrk-shifr1.knp = knp.
                wrk-shifr1.sum_crc = txb.jl.dam.
                wrk-shifr1.sum_tng = txb.jl.dam * txb.crchis.rate[3].

                find first txb.dealing_doc where txb.dealing_doc.jh = txb.jl.jh no-lock no-error.
                if avail txb.dealing_doc then
                wrk-shifr1.purpose = txb.dealing_doc.purpose.

                wrk-shifr1.rem = txb.jl.rem[1].
                wrk-shifr1.buy_rate = txb.crchis.rate[3].
                wrk-shifr1.sell_rate = txb.crchis.rate[1].
                if tmp-f2.kod <  120000 then wrk-shifr1.buy_kod  = tmp-f2.kod.
                if tmp-f2.kod >= 120000 then wrk-shifr1.sell_kod = tmp-f2.kod.
            end.
        end.
    end.


    if tmp-f2.kod = 110002 then do:
        for each txb.jl where txb.jl.acc = "000076371" and txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt no-lock use-index acc by txb.jl.jh:
            if txb.jl.dam = 0 then do:
                tmp-f2.usd = tmp-f2.usd + round(txb.jl.cam / tg1000, 0).
                tmp-f2.summ = tmp-f2.summ + round(crc-crc-date(txb.jl.cam, txb.jl.crc, 1, txb.jl.jdt) / tg1000, 0).
            end.
        end.
    end.

    if tmp-f2.kod = 110004 then do:
        for each txb.jl where (txb.jl.gl = 100100 or txb.jl.gl = 100500) and txb.jl.dc = "D" and jl.crc <> 1
                              and txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt
        no-lock:
            if txb.jl.gl = 100500 and txb.jl.rem[1] <> "Обмен валюты" then next.

            /*if txb.jl.gl = 100500 then do:
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.joudop where txb.joudop.docnum = txb.jh.ref and txb.joudop.type = 'BOM' no-lock no-error.
                if not avail txb.joudop then next.
            end.*/

            kod = 0. kbe = 0. knp = 0.
            find first bjl where bjl.jh = txb.jl.jh and bjl.gl = 185800  and bjl.crc = jl.crc and bjl.ln = jl.ln + 1 no-lock no-error.
            if avail bjl then do:
                if txb.jl.crc = 2  then tmp-f2.usd = tmp-f2.usd + round(txb.jl.dam / tg1000, 0). else
                if txb.jl.crc = 3  then tmp-f2.eur = tmp-f2.eur + round(txb.jl.dam / tg1000, 0). else
                if txb.jl.crc = 4  then tmp-f2.rur = tmp-f2.rur + round(txb.jl.dam / tg1000, 0).
                find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
                if avail txb.crchis then
                tmp-f2.summ = tmp-f2.summ + round((txb.jl.dam * crchis.rate[1]) / tg1000, 0).

                run GetEKNP(txb.jl.jh, txb.jl.ln, txb.jl.dc, input-output KOd, input-output KBe, input-output KNP).

                create wrk-shifr1.

                wrk-shifr1.txb =  comm.txb.info.
                wrk-shifr1.jh = txb.jl.jh.
                wrk-shifr1.jdt = txb.jl.jdt.
                wrk-shifr1.trx = txb.jl.trx.
                wrk-shifr1.dr4gl = substr(string(txb.jl.gl), 1, 4).
                wrk-shifr1.dr20aaa = txb.jl.acc.

                find first bjl2 where bjl2.jh = txb.jl.jh and bjl2.ln = txb.jl.ln + 1 no-lock no-error.
                if avail bjl2 then do:
                    wrk-shifr1.cr4gl = substr(string(bjl2.gl), 1, 4).
                    wrk-shifr1.cr20aaa = bjl2.acc.
                end.

                find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
                if avail txb.crc then
                wrk-shifr1.dr_crc = txb.crc.code.
                wrk-shifr1.kod = kod.
                wrk-shifr1.kbe = kbe.
                wrk-shifr1.knp = knp.
                wrk-shifr1.sum_crc = txb.jl.dam.
                wrk-shifr1.sum_tng = txb.jl.dam * txb.crchis.rate[3].
                wrk-shifr1.rem = txb.jl.rem[1].
                wrk-shifr1.buy_rate = txb.crchis.rate[3].
                wrk-shifr1.sell_rate = txb.crchis.rate[1].
                if tmp-f2.kod <  120000 then wrk-shifr1.buy_kod  = tmp-f2.kod.
                if tmp-f2.kod >= 120000 then wrk-shifr1.sell_kod = tmp-f2.kod.
            end.
        end.
    end.

    if tmp-f2.kod = 120001 then do:
        for each txb.jl where txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt and index(gl-list, substring(string(txb.jl.gl), 1, 4)) > 0
                              and txb.jl.crc <> 1 and txb.jl.dc = 'C'
        no-lock:
            kod = 0. kbe = 0. knp = 0.
            if txb.jl.crc > 4 then next.
            run GetEKNP(txb.jl.jh, txb.jl.ln, txb.jl.dc, input-output KOd, input-output KBe, input-output KNP).
            if knp = 223 then do:
                if txb.jl.crc = 2  then tmp-f2.usd = tmp-f2.usd + round(txb.jl.cam / tg1000, 0). else
                if txb.jl.crc = 3  then tmp-f2.eur = tmp-f2.eur + round(txb.jl.cam / tg1000, 0). else
                if txb.jl.crc = 4  then tmp-f2.rur = tmp-f2.rur + round(txb.jl.cam / tg1000, 0).

                find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
                if avail txb.crchis then
                tmp-f2.summ = tmp-f2.summ + round((txb.jl.cam * txb.crchis.rate[1]) / tg1000, 0).

                create wrk-shifr1.

                wrk-shifr1.txb =  comm.txb.info.
                wrk-shifr1.jh = txb.jl.jh.
                wrk-shifr1.jdt = txb.jl.jdt.
                wrk-shifr1.trx = txb.jl.trx.
                wrk-shifr1.cr4gl = substr(string(txb.jl.gl), 1, 4).
                wrk-shifr1.cr20aaa = txb.jl.acc.

                find first bjl2 where bjl2.jh = txb.jl.jh and bjl2.ln = txb.jl.ln - 1 no-lock no-error.
                if avail bjl2 then do:
                    wrk-shifr1.dr4gl = substr(string(bjl2.gl), 1, 4).
                    wrk-shifr1.dr20aaa = bjl2.acc.
                end.

                find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
                if avail txb.crc then
                wrk-shifr1.cr_crc = txb.crc.code.
                wrk-shifr1.kod = kod.
                wrk-shifr1.kbe = kbe.
                wrk-shifr1.knp = knp.
                wrk-shifr1.sum_crc = txb.jl.cam.
                wrk-shifr1.sum_tng = txb.jl.cam * txb.crchis.rate[2].
                wrk-shifr1.rem = txb.jl.rem[1].
                wrk-shifr1.buy_rate = txb.crchis.rate[2].
                wrk-shifr1.sell_rate = txb.crchis.rate[1].
                if tmp-f2.kod <  120000 then wrk-shifr1.buy_kod  = tmp-f2.kod.
                if tmp-f2.kod >= 120000 then wrk-shifr1.sell_kod = tmp-f2.kod.
            end.
        end.
    end.

    if tmp-f2.kod = 120004 then do:
        for each txb.jl where (txb.jl.gl = 100100 or txb.jl.gl = 100500) and txb.jl.dc = "D" and jl.crc = 1
                              and txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt
        no-lock:
            if txb.jl.gl = 100500 then do:
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.joudop where txb.joudop.docnum = txb.jh.ref and txb.joudop.type = 'BOM' no-lock no-error.
                if not avail txb.joudop then next.
            end.

            kod = 0. kbe = 0. knp = 0.
            find first bjl where bjl.jh = txb.jl.jh and bjl.gl = 185800  and bjl.crc = jl.crc and bjl.ln = jl.ln + 1 no-lock no-error.
            if avail bjl then do:
                if txb.jl.crc = 2  then tmp-f2.usd = tmp-f2.usd + round(txb.jl.dam / tg1000, 0). else
                if txb.jl.crc = 3  then tmp-f2.eur = tmp-f2.eur + round(txb.jl.dam / tg1000, 0). else
                if txb.jl.crc = 4  then tmp-f2.rur = tmp-f2.rur + round(txb.jl.dam / tg1000, 0).
                find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
                if avail txb.crchis then
                tmp-f2.summ = tmp-f2.summ + round((txb.jl.dam * crchis.rate[1]) / tg1000, 0).

                run GetEKNP(txb.jl.jh, txb.jl.ln, txb.jl.dc, input-output KOd, input-output KBe, input-output KNP).

                create wrk-shifr1.

                wrk-shifr1.txb =  comm.txb.info.
                wrk-shifr1.jh = txb.jl.jh.
                wrk-shifr1.jdt = txb.jl.jdt.
                wrk-shifr1.trx = txb.jl.trx.
                wrk-shifr1.dr4gl = substr(string(txb.jl.gl), 1, 4).
                wrk-shifr1.dr20aaa = txb.jl.acc.

                find first bjl2 where bjl2.jh = txb.jl.jh and bjl2.ln = txb.jl.ln + 1 no-lock no-error.
                if avail bjl2 then do:
                    wrk-shifr1.cr4gl = substr(string(bjl2.gl), 1, 4).
                    wrk-shifr1.cr20aaa = bjl2.acc.
                end.

                find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
                if avail txb.crc then
                wrk-shifr1.dr_crc = txb.crc.code.
                wrk-shifr1.kod = kod.
                wrk-shifr1.kbe = kbe.
                wrk-shifr1.knp = knp.
                wrk-shifr1.sum_crc = txb.jl.dam.
                wrk-shifr1.sum_tng = txb.jl.dam * txb.crchis.rate[3].
                wrk-shifr1.rem = txb.jl.rem[1].
                wrk-shifr1.buy_rate = txb.crchis.rate[3].
                wrk-shifr1.sell_rate = txb.crchis.rate[1].
                if tmp-f2.kod <  120000 then wrk-shifr1.buy_kod  = tmp-f2.kod.
                if tmp-f2.kod >= 120000 then wrk-shifr1.sell_kod = tmp-f2.kod.
            end.
        end.
    end.
end.


