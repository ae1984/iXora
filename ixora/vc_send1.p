/* vc_send1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        vc_send
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
        BANK COMM TXB
 * CHANGES
*/


def input parameter v-chk as char.
def input parameter v-rmz as char.
def input parameter v-bank as char.
def input parameter v-dt as int.
def var v-bnk as char.
def temp-table wrk
    field typ as char
    field ofc as char.
for each txb.ofc where txb.ofc.exp[1] begins "p00126" or txb.ofc.exp[1] begins "p00006" no-lock:
    create wrk.
    wrk.typ = "2".
    wrk.ofc = txb.ofc.ofc.
end.
for each txb.ofc where txb.ofc.exp[1] begins "р00121" or txb.ofc.exp[1] begins "р00136" no-lock:
    create wrk.
    wrk.typ = "1".
    wrk.ofc = txb.ofc.ofc.
end.

if v-chk = "1" then do:
    for each wrk where wrk.typ = "1" no-lock:
        run mail(wrk.ofc + "@metrocombank.kz", "BANK <abpk@metrocombank.kz>",
        "УВЕДОМЛЕНИЕ ДВК (ГК223730)!", "В Вашем филиале есть платежи (филиал " + v-bank + "; " + string(v-dt) + " дней; "  + v-rmz + "), не идентифицированные в соответствии с валютным з/дательством в течение 180 дней! Возврат средств отправителю необходимо осуществить на 181 день!",
        "1", "","").
    end.
end.
else do:
    for each wrk where wrk.typ = "2" no-lock:
        run mail( wrk.ofc + "@metrocombank.kz", "BANK <abpk@metrocombank.kz>",
        "УВЕДОМЛЕНИЕ ДВК (ГК223730)!", "В Вашем филиале есть платежи (филиал " + v-bank + "; " + string(v-dt) + " дней; "  + v-rmz + "), не идентифицированные в соответствии с валютным з/дательством в течение 180 дней!
        Возврат средств отправителю необходимо осуществить на 181 день!",
        "1", "","").
        run mail("id00661"  + "@metrocombank.kz", "BANK <abpk@metrocombank.kz>",
        "УВЕДОМЛЕНИЕ ДВК (ГК223730)!", "В Вашем филиале есть платежи (филиал " + v-bank + "; " + string(v-dt) + " дней; "  + v-rmz + "), не идентифицированные в соответствии с валютным з/дательством в течение 180 дней! Возврат средств отправителю необходимо осуществить на 181 день!",
        "1", "","").
    end.
end.


