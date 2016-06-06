/* TRANS_ps2.p
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
        BANK TXB COMM
 * CHANGES
*/

def shared var v-aaa1    as char init "KZ11470172203A378716". /*Счет для списания*/
def shared var v-aaa2    as char init "KZ73470172203A360916". /*Счет для зачисления*/

def var v-pay     as deci.
def var vdel      as char init "^".
def var v-cif1    as char no-undo.
def var v-cif2    as char no-undo.
def var v-crc1    as inte no-undo.
def var v-crc2    as inte no-undo.
def var v-sts1    as char no-undo.
def var v-sts2    as char no-undo.
def var fname1    as char.
def var v-text    as char.
def var vparam    as char.
def var rcode     as inte.
def var rdes      as char.
def var v-jh      as inte.
def var v-true    as logi init no.

def stream m-out.
fname1 = "tranall" + string(year(today)) + string(month(today)) + string(day(today)) + ".txt".
output stream m-out to value(fname1).

find first txb.aaa where txb.aaa.aaa = v-aaa1 no-lock no-error.
if avail txb.aaa then do:
    v-cif1 = txb.aaa.cif.
    v-crc1 = txb.aaa.crc.
    v-sts1 = txb.aaa.sta.
end.
else do:
    v-text = "Счет " + v-aaa1 + " не найден !".
    put stream m-out unformatted v-text skip.
    v-true = yes.
end.
find first txb.aaa where txb.aaa.aaa = v-aaa2 no-lock no-error.
if avail txb.aaa then do:
    v-cif2 = txb.aaa.cif.
    v-crc2 = txb.aaa.crc.
    v-sts2 = txb.aaa.sta.
end.
else do:
    v-text = "Счет " + v-aaa2 + " не найден !".
    put stream m-out unformatted v-text skip.
    v-true = yes.
end.

if v-cif1 <> v-cif2 then do:
    v-text = " Счета " + v-aaa1 + " " + v-aaa2 + " не принадлежат одному и тому же клиенту ".
    put stream m-out unformatted v-text skip.
    v-true = yes.
end.
if v-crc1 <> v-crc2 then do:
    v-text = "Валюты счетов " + v-aaa1 + " " + v-aaa2 + " не совпадают ! ".
    put stream m-out unformatted v-text skip.
    v-true = yes.
end.
if v-sts1 = "C" then do:
    v-text = "Статус счета " + v-aaa1 + " для списания(Дт) закрытый ! ".
    put stream m-out unformatted v-text skip.
    v-true = yes.
end.
if v-sts2 = "C" then do:
    v-text = "Статус счета " + v-aaa2 + " для зачисления(Кт) закрытый ! ".
    put stream m-out unformatted v-text skip.
    v-true = yes.
end.

if v-true = no then do:
    v-jh = 0.
    run Transferbalans(input v-cif1, input v-aaa1, input v-aaa2, output rcode, output rdes, output v-jh).
    if rcode = 0 then do:
        v-text = "cif=" + v-cif1 + " aaa1=" + v-aaa1 + " aaa2=" + v-aaa2 + " trx=" + string(v-jh).
        put stream m-out unformatted v-text skip.
    end.
    else do:
        v-text = "Error " + string(rcode) + " - " + rdes + "." + " cif=" + v-cif1 + " aaa1=" + v-aaa1 + " aaa2=" + v-aaa2.
        put stream m-out unformatted v-text skip.
    end.
end.
output stream m-out close.

procedure Transferbalans:
    def input parameter p-cif as char.
    def input parameter p-aaacif1 as char.
    def input parameter p-aaacif2 as char.
    def output parameter rcode as inte.
    def output parameter rdes as char.
    def output parameter v-jh as inte.
    /* Только текущие счета клиентов (Юридических и физических лиц) */
    for each txb.aaa where txb.aaa.cif = p-cif and txb.aaa.aaa = p-aaacif1 no-lock:
        v-pay = txb.aaa.cbal - txb.aaa.hbal. /*сумма доступного остатка*/
        if v-pay > 0 then do transaction:
            vparam = string(v-pay) + vdel + "1" + vdel + p-aaacif1 + vdel + "1" + vdel + p-aaacif2 + vdel +
            "Перевод остатков".
            v-jh = 0.
            run trxgen("vnb0069", vdel, vparam, "CIF", txb.aaa.aaa, output rcode, output rdes, input-output v-jh).
            if rcode = 0 then do: /*Если значение 0, то успешно*/
                run trxsts(v-jh, 6, output rcode, output rdes). /*штампуем проводку*/
            end.
        end.
    end.
end. /*Transferbalans*/



