/* delbxrepdat.p
 * MODULE
        Название модуля - Клиенты и счета
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
        Пункт меню - 1.4.1.20.3
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        24.05.2012 damir - вывод данных за указанный период.
*/

def input parameter p-bankinfo as char.

def shared temp-table t-temp
    field filname as char
    field dtspis  as date
    field crc     as char
    field cif     as char
    field name    as char
    field rem     as char
    field dtcreat as date
    field acc     as char
    field amount  as deci
    field sumkz   as deci
    field idmen   as char
    field idcon   as char
    index idx is primary dtspis ascending
                         cif ascending
                         acc ascending
                         amount ascending.

def shared var v-dtb as date.
def shared var v-dte as date.

for each txb.hisdelbxcif where txb.hisdelbxcif.dtdel >= v-dtb and txb.hisdelbxcif.dtdel <= v-dte no-lock:
    create t-temp.
    assign
    t-temp.filname = p-bankinfo
    t-temp.dtspis  = txb.hisdelbxcif.dtdel.
    find first txb.crc where txb.crc.crc = txb.hisdelbxcif.crc no-lock no-error.
    if avail txb.crc then t-temp.crc = txb.crc.code.
    assign
    t-temp.cif = txb.hisdelbxcif.cif.
    find first txb.cif where txb.cif.cif = txb.hisdelbxcif.cif no-lock no-error.
    if avail txb.cif then t-temp.name = trim(txb.cif.name) + " " + trim(txb.cif.prefix).
    assign
    t-temp.rem     = txb.hisdelbxcif.rem
    t-temp.dtcreat = txb.hisdelbxcif.whn
    t-temp.acc     = txb.hisdelbxcif.aaa
    t-temp.amount  = txb.hisdelbxcif.amount.
    if txb.hisdelbxcif.crc <> 1 then do:
        find last txb.crchis where txb.crchis.crc = txb.hisdelbxcif.crc and txb.crchis.rdt <= txb.hisdelbxcif.whn no-lock no-error.
        if avail txb.crchis then t-temp.sumkz = txb.hisdelbxcif.amount * txb.crchis.rate[1].
    end.
    else t-temp.sumkz = txb.hisdelbxcif.amount.
    assign
    t-temp.idmen = txb.hisdelbxcif.delchoose
    t-temp.idcon = txb.hisdelbxcif.delaccept.
end.