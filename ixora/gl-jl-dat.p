/* gl-jl-dat.p
 * MODULE
        Вал контроль
 * DESCRIPTION
        Сверка текущего счета клиента и платежей ВК
 * RUN
        vccomp.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        24.02.2012 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        27.02.2012 aigul - добавила индексы
*/

def shared var v-dt1 as date no-undo.
def shared var v-dt2 as date no-undo.
def shared temp-table wrk
    field fil as char
    field dgl as int
    field dtype as char
    field cgl as int
    field ctype as char
    field ln as int
    field jh as int
    field dt as date
    field des as char
    field fio as char
    field uid as char
    field usr as char
    field amt as decimal
    field amt_kzt as decimal
    index main is primary ln.
def buffer b-wrk for wrk.
def var v-bank as char.
def var v-ln as int.
def var v-jh as int.
def buffer b-jl for txb.jl.

find txb.cmp no-lock no-error.
v-bank = txb.cmp.name.
for each txb.jl where txb.jl.jdt >= v-dt1 and txb.jl.jdt <= v-dt2 no-lock use-index jdt break by txb.jl.jh by txb.jl.ln:
    if txb.jl.jh = v-jh and txb.jl.ln = v-ln then next.
    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
    if avail b-jl then do:
        create wrk.
        wrk.fil = v-bank.
        wrk.ln = txb.jl.ln.
        wrk.dgl = txb.jl.gl.
        if substr(string(wrk.dgl),1,1) = "1" or substr(string(wrk.dgl),1,1) = "2" or substr(string(wrk.dgl),1,1) = "3"
        then wrk.dtype = "BS".
        if substr(string(wrk.dgl),1,1) = "4" or substr(string(wrk.dgl),1,1) = "5"
        then wrk.dtype = "PL".
        wrk.cgl = /*txb.jl.gl.*/ b-jl.gl.
        if substr(string(wrk.cgl),1,1) = "1" or substr(string(wrk.cgl),1,1) = "2" or substr(string(wrk.cgl),1,1) = "3"
        then wrk.ctype = "BS".
        if substr(string(wrk.cgl),1,1) = "4" or substr(string(wrk.cgl),1,1) = "5"
        then wrk.ctype = "PL".
        wrk.jh = txb.jl.jh.
        wrk.dt = txb.jl.jdt.
        wrk.des = txb.jl.rem[1].
        find first txb.ofc where txb.ofc.ofc = txb.jl.who no-lock no-error.
        if avail txb.ofc then wrk.fio = txb.ofc.name.
        wrk.uid = txb.jl.who.
        if not substr(txb.jl.who,1,2) matches  "id*" then wrk.usr = "System".
        else wrk.usr = "User".
        if txb.jl.cam <> 0 then wrk.amt = txb.jl.cam.
        if txb.jl.dam <> 0 then wrk.amt = txb.jl.dam.
        if txb.jl.crc <> 1 then do:
            find last txb.crchis where txb.crchis.rdt <= txb.jl.jdt and txb.crchis.crc = txb.jl.crc no-lock no-error.
            if avail txb.crchis then wrk.amt_kzt = wrk.amt * crchis.rate[1].
        end.
        else wrk.amt_kzt = wrk.amt.
        v-ln = b-jl.ln.
        v-jh = b-jl.jh.
    end.
end.
/*for each wrk use-index main break by wrk.ln.
    if wrk.ln = v-ln then delete wrk.
    find first b-wrk where b-wrk.jh = wrk.jh and b-wrk.ln = 1 + wrk.ln no-lock no-error.
    if avail b-wrk then do:
        wrk.cgl = b-wrk.cgl.
        wrk.ctype = b-wrk.ctype.
        if wrk.ln = v-ln then delete wrk.
        v-ln = b-wrk.ln.
    end.
end.*/
