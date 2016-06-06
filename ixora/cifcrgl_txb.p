/* cifcrgl_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - cifcrgl.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        11.04.2013 damir - Внедрено Т.З. № 1793.
*/

def shared var v-type as char no-undo.

def shared temp-table t-wrk
    field cif as char
    field cifname as char
    field ofc as char.

def var v-log as logi.

def buffer b-cif for txb.cif.
def buffer b-aaa for txb.aaa.

nextCIF:
for each b-cif no-lock:
    v-log = false.
    nextAAA:
    for each b-aaa where b-aaa.cif = b-cif.cif and (b-aaa.sta = "N" or b-aaa.sta = "A") and b-aaa.crc <> 0 no-lock:
        if string(b-aaa.gl) begins "1860" then next nextAAA.
        v-log = true.
    end.

    if not (b-cif.type eq v-type and v-log eq true and b-cif.crg eq "") then next nextCIF.

    create t-wrk.
    t-wrk.cif = b-cif.cif.
    t-wrk.cifname = trim(b-cif.prefix) + " " + trim(b-cif.name).
    t-wrk.ofc = b-cif.ofc.

    hide message no-pause.
    message "CIF - " b-cif.cif.
end.