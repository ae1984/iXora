/* r-f2p2.p
 * MODULE
        СБ
 * DESCRIPTION
        Отчет о покупке/продаже иностранной валюты банком и его клиентами. Раздел 2.
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
        05/09/2012 dmitriy - поиск обменных операций не по КНП, а по записям dealing_doc
        24/09/2012 dmitriy - перекомпиляция

*/


 def shared var vn-dt as date    no-undo.
 def shared var vn-dtbeg as date no-undo.
 def shared var tg1000 as int.

 def buffer b1 for txb.aaa.
 def buffer b2 for txb.aaa.
 def buffer bjl for txb.jl.

 def shared temp-table tmp-f2p2
     field nom  as integer
     field name as char
     field kod  as integer
     field summ as decimal decimals 2
     field tgrez   as decimal decimals 2
     field tgnorez  as decimal decimals 2
     field valrez  as decimal decimals 2
     field valnorez  as decimal decimals 2.

 def shared temp-table tmp-d
     field djh as integer.

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

def var v-rate as deci.

def buffer b-f2p2  for tmp-f2p2.
def buffer b1-f2p2 for tmp-f2p2.
def buffer b2-f2p2 for tmp-f2p2.
def buffer b3-f2p2 for tmp-f2p2.
def buffer b4-f2p2 for tmp-f2p2.
def buffer b5-f2p2 for tmp-f2p2.
def buffer b6-f2p2 for tmp-f2p2.

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

def var gl-list  as char init "2203,2204,2205,2206,2207,2208,2209,2210,2211,2213,2215,2217,2219,2221,2237".

def var kod as int.
def var kbe as int.
def var knp as int init 0.

find first txb.cmp no-lock no-error.
find first comm.txb where int(substr(comm.txb.bank, 4)) = cmp.code no-lock no-error.


for each txb.dealing_doc where txb.dealing_doc.whn_mod >= vn-dtbeg and txb.dealing_doc.whn_mod <= vn-dt no-lock:
    find first txb.aaa where txb.aaa.aaa = txb.dealing_doc.tclientaccno no-lock no-error.
    if avail txb.aaa then do:
        find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
        if avail txb.cif then do:
            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'secek' and txb.sub-cod.acc = txb.cif.cif no-lock no-error.

            find last txb.crchis where txb.crchis.rdt <= txb.dealing_doc.whn_mod and txb.crchis.crc = txb.dealing_doc.crc no-lock no-error.
            if avail txb.crchis then v-rate = txb.crchis.rate[1].


            /* 211000 ----------------------------------------*/
            if txb.sub-cod.ccod = '9' and txb.dealing_doc.TngToVal = true then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 211000 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    run create_wrk-shifr.
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2'  and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    run create_wrk-shifr.
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1'  and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    run create_wrk-shifr.
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2'  and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    run create_wrk-shifr.
                end.
            end.
            /* -----------------------------------------------*/

            /* 212000 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212000 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    run create_wrk-shifr.
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6   then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    run create_wrk-shifr.
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    run create_wrk-shifr.
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    run create_wrk-shifr.
                end.
            end.
            /* -----------------------------------------------*/

            /* 212409 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212409") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212409 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212411 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212411") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212411 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212412 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212412") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212412 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212413 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212413") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212413 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212414 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212414") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212414 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212415 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212415") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212415 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212416 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212416") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212416 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212417 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212417") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212417 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212421 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212421") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212421 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212422 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212422") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212422 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212423 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212423") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212423 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212424 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212424") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212424 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 212425 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = true and txb.dealing_doc.purpose begins ("212425") then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 212425 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6) then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 221000 ----------------------------------------*/
            if txb.sub-cod.ccod = '9' and txb.dealing_doc.TngToVal = false then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 221000 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    run create_wrk-shifr.
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2'  and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    run create_wrk-shifr.
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1'  and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    run create_wrk-shifr.
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2'  and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    run create_wrk-shifr.
                end.
            end.
            /* -----------------------------------------------*/

            /* 221400 ----------------------------------------*/
            if txb.sub-cod.ccod = '9' and txb.dealing_doc.TngToVal = false then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 221400 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2'  and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6  then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/

            /* 222000 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = false  then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 222000 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    run create_wrk-shifr.
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    run create_wrk-shifr.
                end.
                /*за валюту резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valrez = tmp-f2p2.valrez +  txb.dealing_doc.f_amount * v-rate.
                    run create_wrk-shifr.
                end.
                /*за валюту нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and (txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6)  then do:
                    tmp-f2p2.valnorez = tmp-f2p2.valnorez +  txb.dealing_doc.f_amount * v-rate.
                    run create_wrk-shifr.
                end.
            end.
            /* -----------------------------------------------*/

            /* 222400 ----------------------------------------*/
            if (txb.sub-cod.ccod = '6' or txb.sub-cod.ccod = '7' or txb.sub-cod.ccod = '8') and txb.dealing_doc.TngToVal = false  then do:
            find first tmp-f2p2 where tmp-f2p2.kod = 222000 exclusive-lock no-error.
                /*за тенге резиденты*/
                if substr(txb.cif.geo, 3, 1) = '1' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgrez = tmp-f2p2.tgrez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
                /*за тенге нерезиденты*/
                if substr(txb.cif.geo, 3, 1) = '2' and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then do:
                    tmp-f2p2.tgnorez = tmp-f2p2.tgnorez +  txb.dealing_doc.t_amount.
                    /*run create_wrk-shifr.*/
                end.
            end.
            /* -----------------------------------------------*/
        end.
    end.
end.


/*----------------------------------------------------------------------------------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------------------------------------------------------------------------*/

find last tmp-f2p2 where tmp-f2p2.kod = 210000.
find last b1-f2p2 where b1-f2p2.kod = 211000.
find last b2-f2p2 where b2-f2p2.kod = 212000.
tmp-f2p2.summ     = b1-f2p2.summ + b2-f2p2.summ.
tmp-f2p2.tgrez    = b1-f2p2.tgrez    + b2-f2p2.tgrez.
tmp-f2p2.tgnorez  = b1-f2p2.tgnorez  + b2-f2p2.tgnorez.
tmp-f2p2.valrez   = b1-f2p2.valrez   + b2-f2p2.valrez.
tmp-f2p2.valnorez = b1-f2p2.valnorez + b2-f2p2.valnorez.

find last tmp-f2p2 where tmp-f2p2.kod = 212400.
find last b1-f2p2 where b1-f2p2.kod = 212000.
tmp-f2p2.summ     = b1-f2p2.summ.
tmp-f2p2.tgrez    = b1-f2p2.tgrez.
tmp-f2p2.tgnorez  = b1-f2p2.tgnorez.
tmp-f2p2.valrez   = b1-f2p2.valrez .
tmp-f2p2.valnorez = b1-f2p2.valnorez.

find last tmp-f2p2 where tmp-f2p2.kod = 211400.
find last b1-f2p2 where b1-f2p2.kod = 211000.
tmp-f2p2.summ     = b1-f2p2.summ.
tmp-f2p2.tgrez    = b1-f2p2.tgrez.
tmp-f2p2.tgnorez  = b1-f2p2.tgnorez.
tmp-f2p2.valrez   = b1-f2p2.valrez .
tmp-f2p2.valnorez = b1-f2p2.valnorez.

find last tmp-f2p2 where tmp-f2p2.kod = 212410.
find last b-f2p2  where b-f2p2.kod = 212411.
find last b1-f2p2 where b1-f2p2.kod = 212412.
find last b2-f2p2 where b2-f2p2.kod = 212413.
find last b3-f2p2 where b3-f2p2.kod = 212414.
find last b4-f2p2 where b4-f2p2.kod = 212415.
find last b5-f2p2 where b5-f2p2.kod = 212416.
find last b6-f2p2 where b6-f2p2.kod = 212417.

tmp-f2p2.summ     = b-f2p2.summ     + b1-f2p2.summ     + b2-f2p2.summ     + b3-f2p2.summ     + b4-f2p2.summ     + b5-f2p2.summ     + b6-f2p2.summ     .
tmp-f2p2.tgrez    = b-f2p2.tgrez    + b1-f2p2.tgrez    + b2-f2p2.tgrez    + b3-f2p2.tgrez    + b4-f2p2.tgrez    + b5-f2p2.tgrez    + b6-f2p2.tgrez    .
tmp-f2p2.tgnorez  = b-f2p2.tgnorez  + b1-f2p2.tgnorez  + b2-f2p2.tgnorez  + b3-f2p2.tgnorez  + b4-f2p2.tgnorez  + b5-f2p2.tgnorez  + b6-f2p2.tgnorez  .
tmp-f2p2.valrez   = b-f2p2.valrez   + b1-f2p2.valrez   + b2-f2p2.valrez   + b3-f2p2.valrez   + b4-f2p2.valrez   + b5-f2p2.valrez   + b6-f2p2.valrez   .
tmp-f2p2.valnorez = b-f2p2.valnorez + b1-f2p2.valnorez + b2-f2p2.valnorez + b3-f2p2.valnorez + b4-f2p2.valnorez + b5-f2p2.valnorez + b6-f2p2.valnorez .

find last tmp-f2p2 where tmp-f2p2.kod = 212420.
find last b-f2p2  where b-f2p2.kod = 212421.
find last b1-f2p2 where b1-f2p2.kod = 212422.
find last b2-f2p2 where b2-f2p2.kod = 212423.
find last b3-f2p2 where b3-f2p2.kod = 212424.
find last b4-f2p2 where b4-f2p2.kod = 212425.
find last b5-f2p2 where b5-f2p2.kod = 212426.
find last b6-f2p2 where b6-f2p2.kod = 212427.

tmp-f2p2.summ     = b-f2p2.summ     + b1-f2p2.summ     + b2-f2p2.summ     + b3-f2p2.summ     + b4-f2p2.summ     + b5-f2p2.summ     + b6-f2p2.summ     .
tmp-f2p2.tgrez    = b-f2p2.tgrez    + b1-f2p2.tgrez    + b2-f2p2.tgrez    + b3-f2p2.tgrez    + b4-f2p2.tgrez    + b5-f2p2.tgrez    + b6-f2p2.tgrez    .
tmp-f2p2.tgnorez  = b-f2p2.tgnorez  + b1-f2p2.tgnorez  + b2-f2p2.tgnorez  + b3-f2p2.tgnorez  + b4-f2p2.tgnorez  + b5-f2p2.tgnorez  + b6-f2p2.tgnorez  .
tmp-f2p2.valrez   = b-f2p2.valrez   + b1-f2p2.valrez   + b2-f2p2.valrez   + b3-f2p2.valrez   + b4-f2p2.valrez   + b5-f2p2.valrez   + b6-f2p2.valrez   .
tmp-f2p2.valnorez = b-f2p2.valnorez + b1-f2p2.valnorez + b2-f2p2.valnorez + b3-f2p2.valnorez + b4-f2p2.valnorez + b5-f2p2.valnorez + b6-f2p2.valnorez .

find last tmp-f2p2 where tmp-f2p2.kod = 220000.
find last b1-f2p2 where b1-f2p2.kod = 221000.
find last b2-f2p2 where b2-f2p2.kod = 222000.
tmp-f2p2.summ     = b1-f2p2.summ + b2-f2p2.summ.
tmp-f2p2.tgrez    = b1-f2p2.tgrez    + b2-f2p2.tgrez.
tmp-f2p2.tgnorez  = b1-f2p2.tgnorez  + b2-f2p2.tgnorez.
tmp-f2p2.valrez   = b1-f2p2.valrez   + b2-f2p2.valrez.
tmp-f2p2.valnorez = b1-f2p2.valnorez + b2-f2p2.valnorez.



procedure create_wrk-shifr:
    find first txb.jl where txb.jl.jh = txb.dealing_doc.jh and txb.jl.crc = txb.dealing_doc.crc no-lock no-error.
    if avail txb.jl and txb.jl.dc = 'D' then find first bjl where bjl.jh = txb.dealing_doc.jh and bjl.ln = txb.jl.ln + 1 no-lock no-error.
    if avail txb.jl and txb.jl.dc = 'C' then find first bjl where bjl.jh = txb.dealing_doc.jh and bjl.ln = txb.jl.ln - 1 no-lock no-error.
    if not avail txb.jl then leave.

    find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.

    kod = 0. kbe = 0. knp = 0.
    run GetEKNP(txb.jl.jh, txb.jl.ln, txb.jl.dc, input-output KOd, input-output KBe, input-output KNP).

    create wrk-shifr1.

    wrk-shifr1.txb =  comm.txb.info.
    wrk-shifr1.jh = txb.dealing_doc.jh.
    wrk-shifr1.jdt = txb.dealing_doc.whn_mod.
    wrk-shifr1.trx = txb.jl.trx.

    if txb.jl.dc = 'D' then do:
        wrk-shifr1.dr4gl = substr(string(txb.jl.gl), 1, 4).
        wrk-shifr1.dr20aaa = txb.jl.acc.

        find first txb.gl where txb.gl.gl = txb.jl.gl no-lock no-error.
        if avail txb.gl then wrk-shifr1.drgl-name = txb.gl.des.

        find first bjl where bjl.jh = txb.jl.jh and bjl.ln = txb.jl.ln + 1 no-lock no-error.
        if avail bjl then do:
            wrk-shifr1.cr4gl = substr(string(bjl.gl), 1, 4).
            wrk-shifr1.cr20aaa = bjl.acc.
            find first txb.gl where txb.gl.gl = bjl.gl no-lock no-error.
            if avail txb.gl then wrk-shifr1.crgl-name = txb.gl.des.
        end.
    end.

    if txb.jl.dc = 'C' then do:
        wrk-shifr1.cr4gl = substr(string(txb.jl.gl), 1, 4).
        wrk-shifr1.cr20aaa = txb.jl.acc.

        find first txb.gl where txb.gl.gl = txb.jl.gl no-lock no-error.
        if avail txb.gl then wrk-shifr1.crgl-name = txb.gl.des.

        find first bjl where bjl.jh = txb.jl.jh and bjl.ln = txb.jl.ln - 1 no-lock no-error.
        if avail bjl then do:
            wrk-shifr1.dr4gl = substr(string(bjl.gl), 1, 4).
            wrk-shifr1.dr20aaa = bjl.acc.
            find first txb.gl where txb.gl.gl = bjl.gl no-lock no-error.
            if avail txb.gl then wrk-shifr1.drgl-name = txb.gl.des.
        end.
    end.

    find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
    if avail txb.crc then
    wrk-shifr1.dr_crc = txb.crc.code.
    wrk-shifr1.kod = kod.
    wrk-shifr1.kbe = kbe.
    wrk-shifr1.knp = knp.
    wrk-shifr1.sum_crc = txb.dealing_doc.f_amount.

    if txb.dealing_doc.f_amount <> txb.dealing_doc.t_amount and txb.dealing_doc.doctype <> 5 and txb.dealing_doc.doctype <> 6 then
        wrk-shifr1.sum_tng = txb.dealing_doc.t_amount.  /* в некоторых записях dealing_doc t_amount = f_amount, при курсе валюты <> 1 */
    else
        wrk-shifr1.sum_tng = txb.dealing_doc.f_amount * txb.dealing_doc.rate.

    if txb.dealing_doc.doctype = 5 or txb.dealing_doc.doctype = 6 then
        wrk-shifr1.sum_tng = txb.dealing_doc.f_amount * v-rate.

    wrk-shifr1.purpose = txb.dealing_doc.purpose.
    wrk-shifr1.rem = txb.jl.rem[1].
    if txb.dealing_doc.TngToVal = true  then wrk-shifr1.buy_rate = txb.dealing_doc.rate.
    if txb.dealing_doc.TngToVal = false then wrk-shifr1.sell_rate = txb.dealing_doc.rate.

    if tmp-f2p2.kod <  220000 then wrk-shifr1.buy_kod1  = tmp-f2p2.kod.
    if tmp-f2p2.kod >= 220000 then wrk-shifr1.sell_kod1 = tmp-f2p2.kod.
end procedure.
