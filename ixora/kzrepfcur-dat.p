/* kzrepfcur-dat.p
 * MODULE
        7.4.3.7.1 Операции с нал. ин. вал. в разрезе каждой операции
 * DESCRIPTION
        Описание
 * RUN
        kzrepfcur
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
        07.12.2011 aigul - коррекрировка времени
        18.04.2012 aigul - исправила вывод льготных курсов
*/
def shared var v-dt1 as date no-undo.
def shared var v-dt2 as date no-undo.
def shared var v-reptype as int no-undo.
def shared temp-table wrk
    field dt as date
    field fil as char
    field crc as int
    field sdelka as char
    field sum as decimal
    field kurs as decimal
    field tim as int
    field typ as char
    field order as char
    field ofc as char
    field rem as char
    field chk as char.
def var v-bank as char.
def var v-bcode as char.
find txb.cmp no-lock no-error.
v-bank = txb.cmp.name.
v-bcode = substr(string(txb.cmp.code),1,2).

for each txb.jl where txb.jl.jdt >= v-dt1 and txb.jl.jdt <= v-dt2 no-lock:
    if txb.jl.crc = 1 or substring(txb.jl.rem[1],1,5) <> "Обмен" then next.
    if txb.jl.gl <> 100100 and txb.jl.gl <> 100300 and txb.jl.gl <> 100200 then next.
    find first txb.joudoc where txb.joudoc.jh = txb.jl.jh no-lock no-error.
    if avail txb.joudoc then do:
        create wrk.
        wrk.dt = txb.jl.jdt.
        wrk.fil = v-bank.
        wrk.crc = txb.jl.crc.
        if (txb.jl.dam <> 0 and txb.jl.ln = 1) then do:
            if txb.jl.dc = "d" then assign wrk.sdelka = "покупка" wrk.sum = txb.jl.dam.
            if txb.jl.dc = "D" then wrk.kurs = txb.joudoc.brate.
        end.
        if (txb.jl.cam <> 0 and txb.jl.ln = 4) then do:
            if txb.jl.dc = "c" then assign wrk.sdelka = "продажа" wrk.sum = txb.jl.cam.
            if txb.jl.dc = "C" then wrk.kurs = txb.joudoc.srate.
        end.
        find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
        if avail txb.jh then do:
            wrk.tim = txb.jh.tim.
            /*if (v-bcode = "12" or v-bcode = "11" or v-bcode = "4" or v-bcode = "1") then
            wrk.tim  = txb.jh.tim + 3600.*/
        end.
        wrk.typ = "стандартный".
        find first txb.crchis where txb.crchis.rdt = txb.jl.jdt and txb.crchis.crc = txb.jl.crc
        and ((txb.jl.dc = "d" and crchis.rate[2] = wrk.kurs) or (txb.jl.dc = "c" and crchis.rate[3] = wrk.kurs)) no-lock no-error.
        if avail txb.crchis then wrk.order = txb.crchis.order.
        find first txb.crclg where txb.crclg.whn = txb.jl.jdt and txb.crclg.crcpr = txb.jl.crc
        and txb.jl.dc = "D" and crclg.sum = txb.jl.dam and txb.crclg.crcpok = wrk.kurs no-lock no-error.
        if avail txb.crclg
        then assign wrk.order = txb.crclg.order wrk.typ = "льготный".
        find first txb.crclg where txb.crclg.whn = txb.jl.jdt and txb.crclg.crcpr = txb.jl.crc
        and txb.jl.dc = "C" and crclg.sum = txb.jl.cam and txb.crclg.crcprod = wrk.kurs no-lock no-error.
        if avail txb.crclg
        then assign wrk.order = txb.crclg.order wrk.typ = "льготный".
        /*if not avail txb.crchis then wrk.chk = "no".*/
        find first txb.ofc where txb.ofc.ofc = txb.jl.who no-lock no-error.
        if avail txb.ofc then wrk.ofc = txb.jl.who + " " + txb.ofc.name.
    end.
end.

