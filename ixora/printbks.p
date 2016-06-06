/* printbks.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/
{global.i}
{get-dep.i} /*Номер департамента*/
{comm-txb.i}
{ndssvi.i}

def input parameter s_payment as char no-undo.
def input parameter s_trx     as char no-undo.

def var d_bksnmb as char. /*Контрольный чек БКС №*/
def var s_nknmb  as char. /*Рег.номер в НК*/

def var s_depname       as char no-undo.
def var commonpl_rnnbn  as char no-undo.
def var commonls_bn     as char no-undo.
def var commonpl_rnn    as char no-undo.
def var commonpl_fioadr as char no-undo.
def var s_rnn           as char no-undo.
def var i_temp_dep      as inte no-undo.
def var v-bnkbin        as char no-undo.
def var v-ofcnam        as char no-undo.
def var v-city          as char no-undo.
def var v-cokname       as char no-undo.
def var v-depart        as inte no-undo.
def var v-naznplat      as char.
def var v-databks       as char format "x(20)".
def var v-databkskz     as char format "x(20)".
def var v-ifile         as char.
def var v-ofile         as char.
def var v-cash100500    as inte. /*100500*/
def var v-curs          as deci. /*Курс валюты БКС*/
def var v_doc           as char format "x(10)". /*Документ*/

def buffer bb-sysc for sysc.

def var v-str   as char.
def stream v-out.

/*Город*/
find first sysc where sysc.sysc eq "ourbnk" no-lock no-error.
if avail sysc then do:
    find first comm.txb where comm.txb.bank = trim(sysc.chval) no-lock no-error.
    if avail comm.txb then v-city = entry(2,comm.txb.info,".").
end.

/*Бин Банка*/
find first sysc where sysc.sysc eq "bnkbin" no-lock no-error.
if avail sysc then v-bnkbin = trim(sysc.chval).

find bb-sysc where bb-sysc.sysc = "CASHGL500" no-lock no-error. /*100500*/
if avail bb-sysc then v-cash100500 = bb-sysc.inval.
else v-cash100500 = 100500.

s_trx           = entry(1,s_trx,'#') no-error.
commonpl_rnnbn  = entry(2,s_trx,'#') no-error.
commonls_bn     = entry(3,s_trx,'#') no-error.
commonpl_rnn    = entry(4,s_trx,'#') no-error.
commonpl_fioadr = entry(5,s_trx,'#') no-error.

d_bksnmb = entry(1,entry(1, s_payment, '|'),'#').
i_temp_dep = inte(get-dep(g-ofc, g-today)).
find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
if avail depaccnt and depaccnt.rem <> '' then do:
    find first cmp no-lock no-error.
    find first ppoint where ppoint.depart = depaccnt.depart no-lock no-error.
    if avail ppoint then s_depname = cmp.name + " " + ppoint.name.
    else s_depname = '***'.
    s_nknmb = entry(1,depaccnt.rem,'$').
    if entry(4,depaccnt.rem,'$') = "" then do:
        find first cmp no-lock no-error.
        s_rnn = cmp.addr[2].
    end.
    else s_rnn = entry(4,depaccnt.rem,'$').
end.
else do:
    s_nknmb = '***'.
end.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then do:
    v-depart = int(get-dep(ofc.ofc,g-today)).
    find first ppoint where ppoint.depart = v-depart no-lock no-error.
    if avail ppoint then do:
        assign v-cokname = trim(ppoint.name).
        if v-cokname begins "ЦОК" then assign v-cokname = trim(substr(trim(v-cokname),4,length(v-cokname))).
    end.
end.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then v-ofcnam = ofc.name.
else v-ofcnam = "manager".

def var xin  as deci init 0.
def var xout as deci init 0.

for each jl where jl.jh = int(d_bksnmb) and (jl.gl = 100100 or jl.gl = 100200 or jl.gl = v-cash100500) no-lock:
    if jl.crc <> 1 then do:
        find last crchis where crchis.crc = jl.crc and crchis.rdt <= g-today no-lock no-error.
        v-curs = crchis.rate[1]. /*Курс НБРК*/
        if jl.dc = "D" and jl.dam <> 0 then xin = xin + jl.dam * crchis.rate[1].
        if jl.dc = "C" and jl.cam <> 0 then xout = xout + jl.cam * crchis.rate[1].
    end.
    else do:
        if jl.dc = "D" and jl.dam <> 0 then xin = xin + jl.dam.
        if jl.dc = "C" and jl.cam <> 0 then xout = xout + jl.cam.
    end.
    if jl.rem[1] <> "" then v-naznplat = jl.rem[1].
    else if jl.rem[2] <> "" then v-naznplat = jl.rem[2].
    else if jl.rem[3] <> "" then v-naznplat = jl.rem[3].
    else if jl.rem[4] <> "" then v-naznplat = jl.rem[4].
    else if jl.rem[5] <> "" then v-naznplat = jl.rem[5].
end.

find jh where jh.jh eq int(d_bksnmb) no-lock no-error.
if avail jh then do:
    if jh.sub eq "jou" then do:
        v_doc = jh.ref.
        find joudoc where joudoc.docnum eq v_doc no-lock no-error.
        if avail joudoc then do:
            if joudoc.drcur <> 1 then assign v-curs = joudoc.brate.
            if joudoc.crcur <> 1 then assign v-curs = joudoc.srate.
        end.
    end.
end.

run pkdefdtstr(string(g-today,"99/99/9999"), output v-databks, output v-databkskz). /* День месяц(прописью) год */

v-ifile = "/data/export/bksord.htm". /*Шаблон контрольных чеков БКС*/
v-ofile = "Bks.htm".

output stream v-out to value(v-ofile).
input from value(v-ifile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*bksnumber*" then do:
            if d_bksnmb <> "" then v-str = replace (v-str,"bksnumber",trim(d_bksnmb)).
            else v-str = replace (v-str,"bksnumber","").
            next.
        end.
        if v-str matches "*dtbks*" then do:
            v-str = replace (v-str,"dtbks",entry(1,v-databks," ")).
            next.
        end.
        if v-str matches "*mhbks*" then do:
            v-str = replace (v-str,"mhbks",entry(2,v-databks," ")).
            next.
        end.
        if v-str matches "*yrbks*" then do:
            v-str = replace (v-str,"yrbks",entry(3,v-databks," ")).
            next.
        end.
        if v-str matches "*timebks*" then do:
            v-str = replace (v-str,"timebks",string(time,"HH:MM:SS")).
            next.
        end.
        if v-str matches "*regnumbks*" then do:
            if s_nknmb <> "" then v-str = replace (v-str,"regnumbks",trim(s_nknmb)).
            else v-str = replace (v-str,"regnumbks","").
            next.
        end.
        if v-str matches "*filialname*" then do:
            if v-city <> "" then v-str = replace (v-str,"filialname",v-city).
            else v-str = replace (v-str,"filialname","").
            next.
        end.
        if v-str matches "*cok*" then do:
            if v-cokname <> "" then v-str = replace (v-str,"cok",trim(v-cokname)).
            else v-str = replace (v-str,"cok","").
            next.
        end.
        if v-str matches "*binbnk*" then do:
            if v-bnkbin <> "" then v-str = replace (v-str,"binbnk",trim(v-bnkbin)).
            else v-str = replace (v-str,"binbnk","").
            next.
        end.
        if length(trim(v-naznplat)) < 103 then do:
            if v-str matches "*naznplat*" then do:
                if v-naznplat <> "" then v-str = replace (v-str,"naznplat",trim(v-naznplat)).
                else v-str = replace (v-str,"naznplat","").
                next.
            end.
        end.
        else do:
            if v-str matches "*naznplat*" then do:
                if v-naznplat <> "" then v-str = replace (v-str,"naznplat",substr(trim(v-naznplat),1,103)).
                else v-str = replace (v-str,"naznplat","").
                next.
            end.
        end.
        if v-str matches "*kassirfioname*" then do:
            if v-ofcnam <> "" then v-str = replace (v-str,"kassirfioname",v-ofcnam).
            else v-str = replace (v-str,"kassirfioname","").
            next.
        end.
        if v-str matches "*prihod*" then do:
            if xin <> 0 then v-str = replace (v-str,"prihod",string(xin, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + "KZT").
            else v-str = replace (v-str,"prihod","").
            next.
        end.
        if v-str matches "*rashod*" then do:
            if xout <> 0 then v-str = replace (v-str,"rashod",string(xout, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + "KZT").
            else v-str = replace (v-str,"rashod","").
            next.
        end.
        if v-str matches "*kursbks*" then do:
            if v-curs <> 0 then v-str = replace (v-str,"kursbks",string(v-curs, ">>>,>>>,>>>,>>>,>>>,>>9.99")).
            else v-str = replace (v-str,"kursbks","").
            next.
        end.
        leave.
    end.
    put stream v-out unformatted v-str skip.
end.
input close.
output stream v-out close.
unix silent cptwin value(v-ofile) winword.