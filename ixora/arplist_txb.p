/* arplist_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Получение ссписка транзитных счетов по ГК 2151
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
        02/10/2013 galina ТЗ2104
 * BASES
        BANK TXB
 * CHANGES
*/

def input parameter p-crc as int.
def output parameter p-arplist as char.
p-arplist = ''.
for each txb.arp where string(txb.arp.gl) begins '2151' and txb.arp.crc = p-crc no-lock:
    find txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.acc = txb.arp.arp and txb.sub-cod.d-cod = "clsa" no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then next.
    p-arplist = p-arplist + txb.arp.arp + ' ' + txb.arp.des + '|'.
end.

