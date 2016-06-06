/* repoutdat.p
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
        BANK COMM TXB
 * CHANGES
        11.11.2011 damir - небольшие корректировки.
        22.11.2011 damir - убрал проверку на закрытые счета.
        26.01.2012 damir - включил платежи с типом <N> модуль 15.
        03.07.2012 Lyubov - добавила валюту ZAR
        10.08.2012 Lyubov - добавила валюту CAD
        02.11.2012 damir - Изменения, связанные с изменением шаблонов по конвертации. Добавил convgl.i,v-convGL,isConvGL.
*/
{convgl.i "txb"}

def input parameter p-bank as char.
def input parameter p-dtb  as date.
def input parameter p-dte  as date.

def shared temp-table t-platcif
    field bank    as char
    field cifname as char
    field sumkzt  as deci init 0
    field kolkzt  as inte init 0
    field sumusd  as deci init 0
    field kolusd  as inte init 0
    field sumeur  as deci init 0
    field koleur  as inte init 0
    field sumrub  as deci init 0
    field kolrub  as inte init 0
    field sumgbp  as deci init 0
    field kolgbp  as inte init 0
    field sumchf  as deci init 0
    field kolchf  as inte init 0
    field sumaud  as deci init 0
    field kolaud  as inte init 0
    field sumsek  as deci init 0
    field kolsek  as inte init 0
    field sumzar  as deci init 0
    field kolzar  as inte init 0
    field sumcad  as deci init 0
    field kolcad  as inte init 0.

def temp-table t-temp
    field name as char
    field crc  as inte
    field sum  as deci.

def shared var v-type      as char.
def shared var v-nametitle as char.

def buffer b-jl for txb.jl.
def buffer b-t-temp for t-temp.

def var v-cifname as char init "".

def var kzt as inte init 0.
def var usd as inte init 0.
def var eur as inte init 0.
def var rub as inte init 0.
def var gbp as inte init 0.
def var chf as inte init 0.
def var aud as inte init 0.
def var sek as inte init 0.
def var zar as inte init 0.
def var cad as inte init 0.
def var LN  as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i   as int init 1.
def var v-convGL as logi.

def var v-cifgl as char init "2203,2204,2205,2207,2215,2217,2219".

for each txb.aaa no-lock use-index aaa-idx5:
    if lookup( substr(trim(string(txb.aaa.gl)),1,4), v-cifgl) gt 0 then do:
        assign v-cifname = "".
        find first txb.cif where txb.cif.cif eq txb.aaa.cif  no-lock no-error.
        if avail txb.cif then do:
            v-cifname = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
            if v-type <> "IBH" then do:
                joudoc:
                for each txb.joudoc where (txb.joudoc.dracc eq txb.aaa.aaa or txb.joudoc.cracc eq txb.aaa.aaa) and
                txb.joudoc.whn ge p-dtb and txb.joudoc.whn le p-dte no-lock use-index whn:
                    find first txb.joudop where trim(txb.joudop.docnum) = trim(txb.joudoc.docnum) no-lock no-error. /*п.м. 15.1.1 (3)*/
                    if avail txb.joudop then do:
                        if trim(txb.joudop.type) = "CS3" then do:
                            if txb.joudoc.drcur = 0 then next joudoc.
                        end.
                    end.
                    for each txb.jl where txb.jl.jh eq txb.joudoc.jh and txb.jl.dc eq "D" and txb.jl.acc = txb.aaa.aaa and
                    txb.jl.subled = "CIF" no-lock use-index accdcjdt:
                        v-convGL = false.
                        find first b-jl where b-jl.jh eq txb.jl.jh and b-jl.dc eq "C" no-lock no-error.
                        if avail b-jl then do:
                            v-convGL = isConvGL(b-jl.gl).
                            if not ( substr(trim(string(b-jl.gl)), 1, 1) eq "4" or v-convGL or b-jl.gl eq 100100 or
                            (trim(b-jl.rem[1]) begins "Погашение отрицательного сальдо") or (trim(b-jl.rem[1]) begins "Перевод остатков") ) then do:
                                find last txb.crchis where txb.crchis.crc eq b-jl.crc and txb.crchis.regdt le b-jl.jdt no-lock no-error.
                                create t-temp.
                                assign
                                t-temp.name = v-cifname
                                t-temp.crc  = b-jl.crc
                                t-temp.sum  = b-jl.cam * txb.crchis.rate[1].
                            end.
                        end.
                    end.
                    hide message no-pause.
                    message "Сбор данных - " LN[i] " " p-bank " " aaa.aaa "JOUDOC - " v-type.
                    if i = 8 then i = 1.
                    else i = i + 1.
                end.
            end.
            remtrz:
            for each txb.remtrz where txb.remtrz.dracc = txb.aaa.aaa and txb.remtrz.rdt ge p-dtb and txb.remtrz.rdt le p-dte and
            ((txb.remtrz.ptype = "4" or txb.remtrz.ptype = "6") or (txb.remtrz.ptype = "3" or txb.remtrz.ptype = "7") or
            (txb.remtrz.ptype = "N")) no-lock use-index dracc:
                case v-type:
                    when "IBH" then if not (txb.remtrz.source = "IBH") then next remtrz.
                    when "EXCEPTIBH" then if txb.remtrz.source = "IBH" then next remtrz.
                end.
                v-convGL = false.
                v-convGL = isConvGL(txb.remtrz.crgl).
                if substr(trim(string(txb.remtrz.crgl)), 1, 1) eq "4" or v-convGL or txb.remtrz.crgl eq 100100 then next remtrz.
                find first txb.jl where txb.jl.jh = txb.remtrz.jh1 no-lock no-error.
                if avail txb.jl then do:
                    if txb.jl.rem[1] <> "" then if (trim(txb.jl.rem[1]) begins "Погашение отрицательного сальдо") or
                    (trim(txb.jl.rem[1]) begins "Перевод остатков") then next remtrz.
                    if txb.jl.rem[2] <> "" then if (trim(txb.jl.rem[2]) begins "Погашение отрицательного сальдо") or
                    (trim(txb.jl.rem[2]) begins "Перевод остатков") then next remtrz.
                    if txb.jl.rem[3] <> "" then if (trim(txb.jl.rem[3]) begins "Погашение отрицательного сальдо") or
                    (trim(txb.jl.rem[3]) begins "Перевод остатков") then next remtrz.
                    if txb.jl.rem[4] <> "" then if (trim(txb.jl.rem[4]) begins "Погашение отрицательного сальдо") or
                    (trim(txb.jl.rem[4]) begins "Перевод остатков") then next remtrz.
                    if txb.jl.rem[5] <> "" then if (trim(txb.jl.rem[5]) begins "Погашение отрицательного сальдо") or
                    (trim(txb.jl.rem[5]) begins "Перевод остатков") then next remtrz.
                end.
                find last txb.crchis where txb.crchis.crc eq txb.remtrz.fcrc and txb.crchis.regdt le txb.remtrz.rdt no-lock no-error.
                create t-temp.
                assign
                t-temp.name = v-cifname
                t-temp.crc  = txb.remtrz.fcrc
                t-temp.sum  = txb.remtrz.amt * txb.crchis.rate[1].
                hide message no-pause.
                message "Сбор данных - " LN[i] " " p-bank " " aaa.aaa "REMTRZ - " v-type.
                if i = 8 then i = 1.
                else i = i + 1.
            end.
        end.
    end.
end.

for each t-temp no-lock break by t-temp.name:
    if first-of(t-temp.name) then do:
        create t-platcif.
        assign
        t-platcif.bank    = p-bank
        t-platcif.cifname = t-temp.name.
        for each b-t-temp where b-t-temp.name = t-temp.name no-lock:
            if b-t-temp.crc = 1 then do:
                t-platcif.kolkzt = t-platcif.kolkzt + 1.
                t-platcif.sumkzt = t-platcif.sumkzt + b-t-temp.sum.
            end.
            if b-t-temp.crc = 2 then do:
                t-platcif.kolusd = t-platcif.kolusd + 1.
                t-platcif.sumusd = t-platcif.sumusd + b-t-temp.sum.
            end.
            if b-t-temp.crc = 3 then do:
                t-platcif.koleur = t-platcif.koleur + 1.
                t-platcif.sumeur = t-platcif.sumeur + b-t-temp.sum.
            end.
            if b-t-temp.crc = 4 then do:
                t-platcif.kolrub = t-platcif.kolrub + 1.
                t-platcif.sumrub = t-platcif.sumrub + b-t-temp.sum.
            end.
            if b-t-temp.crc = 6 then do:
                t-platcif.kolgbp = t-platcif.kolgbp + 1.
                t-platcif.sumgbp = t-platcif.sumgbp + b-t-temp.sum.
            end.
            if b-t-temp.crc = 7 then do:
                t-platcif.kolsek = t-platcif.kolsek + 1.
                t-platcif.sumsek = t-platcif.sumsek + b-t-temp.sum.
            end.
            if b-t-temp.crc = 8 then do:
                t-platcif.kolaud = t-platcif.kolaud + 1.
                t-platcif.sumaud = t-platcif.sumaud + b-t-temp.sum.
            end.
            if b-t-temp.crc = 9 then do:
                t-platcif.kolchf = t-platcif.kolchf + 1.
                t-platcif.sumchf = t-platcif.sumchf + b-t-temp.sum.
            end.
            if b-t-temp.crc = 10 then do:
                t-platcif.kolzar = t-platcif.kolzar + 1.
                t-platcif.sumzar = t-platcif.sumzar + b-t-temp.sum.
            end.
            if b-t-temp.crc = 11 then do:
                t-platcif.kolcad = t-platcif.kolcad + 1.
                t-platcif.sumcad = t-platcif.sumcad + b-t-temp.sum.
            end.
        end.
    end.
end.