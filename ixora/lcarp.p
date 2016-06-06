/* lcarp.p
 * MODULE
        Trade finance
 * DESCRIPTION
        поиск счета arp в филиале
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
        19/08/2011 id00810
 * BASES
        BANK TXB
 * CHANGES
*/

def input  param p-crc as int.
def output param p-arp as char.

find first txb.sysc where txb.sysc.sysc = 'LCARP' no-lock no-error.
if avail txb.sysc then
if num-entries(txb.sysc.chval) >= p-crc
then p-arp = entry(p-crc,txb.sysc.chval).
