/* vc_blk.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        2P_ps.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        28.05.2012 aigul
 * BASES
        BANK TXB
 * CHANGES
*/

def input parameter v-acc as char.
def output parameter v-chk as logical initial no.
def output parameter v-sub as char.
find txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.acc = v-acc and txb.sub-cod.d-cod = "sproftcn" no-lock no-error.
if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-sub = txb.sub-cod.ccode.
else v-sub = "506".
find first txb.arp where txb.arp.arp = v-acc no-lock no-error.
if avail txb.arp and string(txb.arp.gl) begins "2237" then v-chk = yes.
