/* dclspccom.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отнесение доходов по ПК на счет ГК 460813
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
        25/12/2012 id00810
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def var v-res      as deci no-undo.
def var v-gl       as char no-undo init '460813'.
def var v-rem      as char no-undo init 'Доходы по платежным картам'.
def var v-param    as char no-undo.
def var v-trx      as char no-undo.
def var vdel       as char no-undo initial "^".
def var v-jh       like jh.jh no-undo.
def var rcode      as int  no-undo.
def var rdes       as char no-undo.

for each arp where string(arp.gl) = '286013' no-lock:
    find first sub-cod where sub-cod.sub   = "arp"
                         and sub-cod.d-cod = "clsa"
                         and sub-cod.acc   = arp.arp
                         no-lock no-error.
    if avail sub-cod and sub-cod.ccode ne 'msc' then next.
    run lonbalcrc.p ('arp',arp.arp,g-today,'1',yes,arp.crc,output v-res).
    if v-res = 0 then next.

    if arp.crc = 1 then assign v-param = string(abs(v-res)) + vdel + string(arp.crc) + vdel + arp.arp + vdel + v-gl + vdel + v-rem
                               v-trx = 'vnb0001'.
    else assign v-param = string(abs(v-res)) + vdel + string(arp.crc) + vdel + arp.arp + vdel + v-rem + '1' + vdel + v-gl
                v-trx = 'vnb0060'.
    v-jh = 0.
    run trxgen (v-trx, vdel, v-param, "arp" , arp.arp , output rcode, output rdes, input-output v-jh).

    if rcode ne 0 then do:
        run savelog("pccom", "ERROR " + arp.arp + " " + rdes + " " + v-trx).
    end.
end.
