/* finarp.p
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
        28/10/2013 galina - ТЗ1891 поиск ARP-счета
 * BASES
        BANK COMM TXB
 * CHANGES
*/
def input parameter i-aaa like txb.arp.arp no-undo.
def output parameter  o-isfindaaa as logical no-undo.
def output parameter  o-sta as char no-undo.
def output parameter o-bin as char no-undo.
def output parameter o-cifname as char no-undo.

{chbin_txb.i}
o-isfindaaa = false.
find first txb.arp where txb.arp.arp = i-aaa no-lock no-error.
if avail txb.arp then do:
    o-cifname = 'АО FORTEBANK'.
    find txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.acc = txb.arp.arp and txb.sub-cod.d-cod = "clsa" no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then o-sta = 'C'.
    o-isfindaaa = true.
    find txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
    o-bin = txb.sysc.chval.
end.