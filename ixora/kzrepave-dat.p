/* kzrepave-dat.p
 * MODULE
        7.4.3.7.2 Операции с нал. ин. вал. в разрезе филиалов
 * DESCRIPTION
        Описание
 * RUN
        kzrepave
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        05.12.2011 aigul
 * BASES
        BANK TXB
 * CHANGES
*/

def shared var v-dt1 as date no-undo.
def shared var v-dt2 as date no-undo.
def shared temp-table wrk
    field bcode as char
    field bank as char
    field dt as date
    field fil as char
    field ubuymin as decimal
    field ubuymax as decimal
    field ubuyave as decimal
    field ubuysum as decimal
    field usellmin as decimal
    field usellmax as decimal
    field usellave as decimal
    field usellsum as decimal

    field ebuymin as decimal
    field ebuymax as decimal
    field ebuyave as decimal
    field ebuysum as decimal
    field esellmin as decimal
    field esellmax as decimal
    field esellave as decimal
    field esellsum as decimal

    field rbuymin as decimal
    field rbuymax as decimal
    field rbuyave as decimal
    field rbuysum as decimal
    field rsellmin as decimal
    field rsellmax as decimal
    field rsellave as decimal
    field rsellsum as decimal.

def shared temp-table wrk1
    field bcode as char
    field bank as char
    field ubuyave as decimal
    field ubuysum as decimal
    field usellave as decimal
    field usellsum as decimal
    field ebuyave as decimal
    field ebuysum as decimal
    field esellave as decimal
    field esellsum as decimal
    field rbuyave as decimal
    field rbuysum as decimal
    field rsellave as decimal
    field rsellsum as decimal.


def var u-buy as char.
def var e-buy as char.
def var r-buy as char.

def var u-sell as char.
def var e-sell as char.
def var r-sell as char.
def var buy-min as decimal.
def var buy-max as decimal.
def var sell-min as decimal.
def var sell-max as decimal.
def var upok as decimal.
def var uprod as decimal.
def var uave1 as decimal.
def var uave2 as decimal.
def var usave1 as decimal.
def var usave2 as decimal.
def var epok as decimal.
def var eprod as decimal.
def var eave1 as decimal.
def var eave2 as decimal.
def var esave1 as decimal.
def var esave2 as decimal.
def var rpok as decimal.
def var rprod as decimal.
def var rave1 as decimal.
def var rave2 as decimal.
def var rsave1 as decimal.
def var rsave2 as decimal.
def var v-bank as char.
def var v-bcode as char.

find txb.cmp no-lock no-error.
v-bank = txb.cmp.name.
v-bcode = substr(string(txb.cmp.code),1,2).

for each txb.crchis where txb.crchis.regdt >= v-dt1 and txb.crchis.regdt <= v-dt2
no-lock break by txb.crchis.regdt:
    if first-of(txb.crchis.regdt) then do:
        create wrk.
        wrk.dt = txb.crchis.regdt.
        wrk.fil = v-bank.
        wrk.bcode = v-bcode.
    end.
end.

for each wrk where wrk.fil = v-bank exclusive-lock:
    u-buy = "".
    e-buy = "".
    r-buy = "".
    u-sell = "".
    e-sell = "".
    r-sell = "".
    for each txb.crchis where txb.crchis.regdt = wrk.dt use-index crchis-idx1 no-lock :
        if txb.crchis.order = "" then next.
        if txb.crchis.crc = 2 then do:
            if u-buy = "" and txb.crchis.rate[2] <> 0 then u-buy = string(txb.crchis.rate[2]).
            if u-buy <> "" and txb.crchis.rate[2] <> 0 then u-buy = u-buy + "," + string(txb.crchis.rate[2]).
            if u-sell = "" and txb.crchis.rate[3] <> 0 then u-sell = string(txb.crchis.rate[3]).
            if u-sell <> "" and txb.crchis.rate[3] <> 0 then u-sell = u-sell + "," + string(txb.crchis.rate[3]).
        end.
        if txb.crchis.crc = 3 then do:
            if e-buy = "" and txb.crchis.rate[2] <> 0 then e-buy = string(txb.crchis.rate[2]).
            if e-buy <> "" and txb.crchis.rate[2] <> 0 then e-buy = e-buy + "," + string(txb.crchis.rate[2]).
            if e-sell = "" and txb.crchis.rate[3] <> 0 then e-sell = string(txb.crchis.rate[3]).
            if e-sell <> "" and txb.crchis.rate[3] <> 0 then e-sell = e-sell + "," + string(txb.crchis.rate[3]).
        end.
        if txb.crchis.crc = 4 then do:
            if r-buy = "" and txb.crchis.rate[2] <> 0 then r-buy = string(txb.crchis.rate[2]).
            if r-buy <> "" and txb.crchis.rate[2] <> 0 then r-buy = r-buy + "," + string(txb.crchis.rate[2]).
            if r-sell = "" and txb.crchis.rate[3] <> 0 then r-sell = string(txb.crchis.rate[3]).
            if r-sell <> "" and txb.crchis.rate[3] <> 0 then r-sell = r-sell + "," + string(txb.crchis.rate[3]).
        end.
    end.
    for each txb.crclg where txb.crclg.whn = wrk.dt  use-index whn_idx no-lock:
        if txb.crclg.sts <> "V" then next.
        if txb.crclg.crcpr = 2 then do:
            if u-buy = "" and txb.crclg.crcpok <> 0 then u-buy = string(txb.crclg.crcpok).
            if u-buy <> "" and txb.crclg.crcpok <> 0 then u-buy = u-buy + "," + string(txb.crclg.crcpok).
            if u-sell = "" and txb.crclg.crcprod<> 0 then u-sell = string(txb.crclg.crcprod).
            if u-sell <> "" and txb.crclg.crcprod <> 0 then u-sell = u-sell + "," + string(txb.crclg.crcprod).
        end.
        if txb.crclg.crcpr = 3 then do:
            if e-buy = "" and txb.crclg.crcpok <> 0 then e-buy = string(txb.crclg.crcpok).
            if e-buy <> "" and txb.crclg.crcpok <> 0 then e-buy = e-buy + "," + string(txb.crclg.crcpok).
            if e-sell = "" and txb.crclg.crcprod<> 0 then e-sell = string(txb.crclg.crcprod).
            if e-sell <> "" and txb.crclg.crcprod <> 0 then e-sell = e-sell + "," + string(txb.crclg.crcprod).
        end.
        if txb.crclg.crcpr = 4 then do:
            if r-buy = "" and txb.crclg.crcpok <> 0 then r-buy = string(txb.crclg.crcpok).
            if r-buy <> "" and txb.crclg.crcpok <> 0 then r-buy = r-buy + "," + string(txb.crclg.crcpok).
            if r-sell = "" and txb.crclg.crcprod<> 0 then r-sell = string(txb.crclg.crcprod).
            if r-sell <> "" and txb.crclg.crcprod <> 0 then r-sell = r-sell + "," + string(txb.crclg.crcprod).
        end.
    end.
    buy-min = 0.
    buy-max = 0.
    sell-min = 0.
    sell-max = 0.
    run kzrepave-dat1(u-buy, u-sell, output buy-min, output buy-max, output sell-min, output sell-max).
    wrk.ubuymin = buy-min.
    wrk.ubuymax = buy-max.
    wrk.usellmin = sell-min.
    wrk.usellmax = sell-max.

    buy-min = 0.
    buy-max = 0.
    sell-min = 0.
    sell-max = 0.
    run kzrepave-dat1(e-buy, e-sell, output buy-min, output buy-max, output sell-min, output sell-max).
    wrk.ebuymin = buy-min.
    wrk.ebuymax = buy-max.
    wrk.esellmin = sell-min.
    wrk.esellmax = sell-max.

    buy-min = 0.
    buy-max = 0.
    sell-min = 0.
    sell-max = 0.
    run kzrepave-dat1(r-buy, r-sell, output buy-min, output buy-max, output sell-min, output sell-max).
    wrk.rbuymin = buy-min.
    wrk.rbuymax = buy-max.
    wrk.rsellmin = sell-min.
    wrk.rsellmax = sell-max.
    /*find ave and sum buy*/
    upok = 0.
    uave1 = 0.
    uave2 = 0.
    epok = 0.
    eave1 = 0.
    eave2 = 0.
    rpok = 0.
    rave1 = 0.
    rave2 = 0.
    for each txb.jl where txb.jl.jdt = wrk.dt  no-lock:
        if substring(txb.jl.rem[1],1,5) <> "Обмен" then next.
        if not (txb.jl.dam <> 0 and txb.jl.ln = 1) then next.
        if txb.jl.gl <> 100100 and txb.jl.gl <> 100300 and txb.jl.gl <> 100200 then next.
        find first txb.joudoc where txb.joudoc.jh = txb.jl.jh no-lock no-error.
        if avail txb.joudoc then do:
            if jl.crc = 2 then do:
                uave1 = uave1 + (txb.jl.dam * txb.joudoc.brate).
                upok = upok + txb.jl.dam.
                if uave1 = 0 and upok = 0 then uave2 = 0.
                else uave2 = uave1 / upok.
            end.
            if jl.crc = 3 then do:
                eave1 = eave1 + (txb.jl.dam * txb.joudoc.brate).
                epok = epok + txb.jl.dam.
                if eave1 = 0 and epok = 0 then eave2 = 0.
                else eave2 = eave1 / epok.
            end.
            if jl.crc = 4 then do:
                rave1 = rave1 + (txb.jl.dam * txb.joudoc.brate).
                rpok = rpok + txb.jl.dam.
                if rave1 = 0 and rpok = 0 then rave2 = 0.
                else rave2 = rave1 / rpok.
            end.
        end.
    end.
    wrk.ubuyave = uave2.
    wrk.ubuysum = upok.
    wrk.ebuyave = eave2.
    wrk.ebuysum = epok.
    wrk.rbuyave = rave2.
    wrk.rbuysum = rpok.

    /*find ave and sum sell*/
    uprod = 0.
    usave1 = 0.
    usave2 = 0.
    eprod = 0.
    esave1 = 0.
    esave2 = 0.
    rprod = 0.
    rsave1 = 0.
    rsave2 = 0.
    for each txb.jl where txb.jl.jdt = wrk.dt  no-lock:
        if substring(txb.jl.rem[1],1,5) <> "Обмен" then next.
        if not (txb.jl.cam <> 0 and txb.jl.ln = 4) then next.
        if txb.jl.gl <> 100100 and txb.jl.gl <> 100300 and txb.jl.gl <> 100200 then next.
        find first txb.joudoc where txb.joudoc.jh = txb.jl.jh no-lock no-error.
        if avail txb.joudoc then do:
            if txb.jl.crc = 2 then do:
                usave1 = usave1 + (txb.jl.cam * txb.joudoc.srate).
                uprod = uprod + txb.jl.cam.
                if usave1 = 0 and uprod = 0 then usave2 = 0.
                else usave2 = usave1 / uprod.
            end.
            if txb.jl.crc = 3 then do:
                esave1 = esave1 + (txb.jl.cam * txb.joudoc.srate).
                eprod = eprod + txb.jl.cam.
                if esave1 = 0 and eprod = 0 then esave2 = 0.
                else esave2 = esave1 / eprod.
            end.
            if txb.jl.crc = 4 then do:
                rsave1 = rsave1 + (txb.jl.cam * txb.joudoc.srate).
                rprod = rprod + txb.jl.cam.
                if rsave1 = 0 and rprod = 0 then rsave2 = 0.
                else rsave2 = rsave1 / rprod.
            end.
        end.
    end.
    wrk.usellave = usave2.
    wrk.usellsum = uprod.
    wrk.esellave = esave2.
    wrk.esellsum = eprod.
    wrk.rsellave = rsave2.
    wrk.rsellsum = rprod.
end.
/*4*/
/*find ave and sum buy*/

upok = 0.
uave1 = 0.
uave2 = 0.
epok = 0.
eave1 = 0.
eave2 = 0.
rpok = 0.
rave1 = 0.
rave2 = 0.
for each txb.jl where txb.jl.jdt >= v-dt1 and  txb.jl.jdt <= v-dt2 no-lock:
    if substring(txb.jl.rem[1],1,5) <> "Обмен" then next.
    if not (txb.jl.dam <> 0 and txb.jl.ln = 1) then next.
    if txb.jl.gl <> 100100 and txb.jl.gl <> 100300 and txb.jl.gl <> 100200 then next.
    find first txb.joudoc where txb.joudoc.jh = txb.jl.jh no-lock no-error.
    if avail txb.joudoc then do:
        if jl.crc = 2 then do:
            uave1 = uave1 + (txb.jl.dam * txb.joudoc.brate).
            upok = upok + txb.jl.dam.
            if uave1 = 0 and upok = 0 then uave2 = 0.
            else uave2 = uave1 / upok.
        end.
        if jl.crc = 3 then do:
            eave1 = eave1 + (txb.jl.dam * txb.joudoc.brate).
            epok = epok + txb.jl.dam.
            if eave1 = 0 and epok = 0 then eave2 = 0.
            else eave2 = eave1 / epok.
        end.
        if jl.crc = 4 then do:
            rave1 = rave1 + (txb.jl.dam * txb.joudoc.brate).
            rpok = rpok + txb.jl.dam.
            if rave1 = 0 and rpok = 0 then rave2 = 0.
            else rave2 = rave1 / rpok.
        end.
    end.
end.
/*find ave and sum sell*/
uprod = 0.
usave1 = 0.
usave2 = 0.
eprod = 0.
esave1 = 0.
esave2 = 0.
rprod = 0.
rsave1 = 0.
rsave2 = 0.
for each txb.jl where txb.jl.jdt >= v-dt1 and  txb.jl.jdt <= v-dt2  no-lock:
    if substring(txb.jl.rem[1],1,5) <> "Обмен" then next.
    if not (txb.jl.cam <> 0 and txb.jl.ln = 4) then next.
    if txb.jl.gl <> 100100 and txb.jl.gl <> 100300 and txb.jl.gl <> 100200 then next.
    find first txb.joudoc where txb.joudoc.jh = txb.jl.jh no-lock no-error.
    if avail txb.joudoc then do:
        if txb.jl.crc = 2 then do:
            usave1 = usave1 + (txb.jl.cam * txb.joudoc.srate).
            uprod = uprod + txb.jl.cam.
            if usave1 = 0 and uprod = 0 then usave2 = 0.
            else usave2 = usave1 / uprod.
        end.
        if txb.jl.crc = 3 then do:
            esave1 = esave1 + (txb.jl.cam * txb.joudoc.srate).
            eprod = eprod + txb.jl.cam.
            if esave1 = 0 and eprod = 0 then esave2 = 0.
            else esave2 = esave1 / eprod.
        end.
        if txb.jl.crc = 4 then do:
            rsave1 = rsave1 + (txb.jl.cam * txb.joudoc.srate).
            rprod = rprod + txb.jl.cam.
            if rsave1 = 0 and rprod = 0 then rsave2 = 0.
            else rsave2 = rsave1 / rprod.
        end.
    end.
end.
create wrk1.
wrk1.bcode = v-bcode.
wrk1.bank = v-bank.
wrk1.ubuyave = uave2.
wrk1.ubuysum = upok.
wrk1.ebuyave = eave2.
wrk1.ebuysum = epok.
wrk1.rbuyave = rave2.
wrk1.rbuysum = rpok.
wrk1.usellave = usave2.
wrk1.usellsum = uprod.
wrk1.esellave = esave2.
wrk1.esellsum = eprod.
wrk1.rsellave = rsave2.
wrk1.rsellsum = rprod.

