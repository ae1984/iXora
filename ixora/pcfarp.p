/* pcfarp.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        поиск транзитного счета АРП
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        27/07/2012 id00810
 * BASES
 		BANK COMM TXB
 * CHANGES
        23/11/2012 id00810 - ТЗ 1594 поиск счета ARP по sysc
*/

def input  param p-glarp   as int no-undo.
def input  param p-crc     as int no-undo.
def output param p-arp     as char no-undo.
def output param p-arpname as char no-undo.

find first txb.sysc where txb.sysc.sysc = 'pc' + string(p-glarp) no-lock no-error.
if not avail txb.sysc then return.

p-arp = txb.sysc.chval.
if num-entries(p-arp) >= p-crc then p-arp = entry(p-crc,p-arp).
find first txb.arp where txb.arp.arp = p-arp no-lock no-error.
if avail txb.arp then do:
    find first txb.sub-cod where txb.sub-cod.acc   = txb.arp.arp
                             and txb.sub-cod.sub   = "arp"
                             and txb.sub-cod.d-cod = "clsa"
                             no-lock no-error.
    if avail txb.sub-cod then if txb.sub-cod.ccode eq "msc" then assign p-arp     = txb.arp.arp
                                                                        p-arpname = txb.arp.des .
end.
