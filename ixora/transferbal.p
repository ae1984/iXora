/* transferbal.p
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
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        03.04.2012 damir...
*/

{global.i}

def var v-aaa1 as char init "KZ11470172203A378716". /*Счет для списания*/
def var v-aaa2 as char init "KZ73470172203A360916". /*Счет для зачисления*/
def var v-time as char.
def var v-pay  as deci init 0.
def var vdel   as char init "^".
def var v-cif1 as char no-undo.
def var v-cif2 as char no-undo.
def var v-crc1 as inte no-undo.
def var v-crc2 as inte no-undo.
def var v-sts1 as char no-undo.
def var v-sts2 as char no-undo.
def var fname1 as char no-undo.
def var v-text as char no-undo.
def var vparam as char no-undo.
def var rcode  as inte no-undo.
def var rdes   as char no-undo.
def var v-jh   as inte no-undo.

def stream m-out.
fname1 = "tranall" + string(year(today)) + string(month(today)) + string(day(today)) + ".txt".
output stream m-out to value(fname1).

v-time = string(time, "HH:MM:SS").
/*message v-time view-as alert-box.*/

if v-time >= "15:59:00" and v-time <= "16:00:30" then do:
    find first aaa where aaa.aaa = v-aaa1 no-lock no-error.
    if avail aaa then do:
        v-cif1 = aaa.cif.
        v-crc1 = aaa.crc.
        v-sts1 = aaa.sta.
    end.
    else do:
        v-text = "Счет " + v-aaa1 + " не найден !".
        put stream m-out unformatted v-text skip.
    end.
    find first aaa where aaa.aaa = v-aaa2 no-lock no-error.
    if avail aaa then do:
        v-cif2 = aaa.cif.
        v-crc2 = aaa.crc.
        v-sts2 = aaa.sta.
    end.
    else do:
        v-text = "Счет " + v-aaa2 + " не найден !".
        put stream m-out unformatted v-text skip.
    end.
    if v-cif1 <> v-cif2 then do:
        v-text = " Счета " + v-aaa1 + " " + v-aaa2 + " не принадлежат одному и тому же клиенту ".
        put stream m-out unformatted v-text skip.
    end.
    if v-crc1 <> v-crc2 then do:
        v-text = "Валюты счетов " + v-aaa1 + " " + v-aaa2 + " не совпадают ! ".
        put stream m-out unformatted v-text skip.
    end.
    if v-sts1 = "C" then do:
        v-text = "Статус счета " + v-aaa1 + " для списания(Дт) закрытый ! ".
        put stream m-out unformatted v-text skip.
    end.
    if v-sts2 = "C" then do:
        v-text = "Статус счета " + v-aaa2 + " для зачисления(Кт) закрытый ! ".
        put stream m-out unformatted v-text skip.
    end.

    v-jh = 0.
    /*message v-cif1 v-aaa1 v-aaa2 view-as alert-box.*/
    run Transferbalans(input v-cif1, input v-aaa1, input v-aaa2, output rcode, output rdes, output v-jh).
    if rcode = 0 then do:
        v-text = "cif=" + v-cif1 + " aaa1=" + v-aaa1 + " aaa2=" + v-aaa2 + " trx=" + string(v-jh).
        put stream m-out unformatted v-text skip.
    end.
    else do:
        v-text = "Error " + string(rcode) + " - " + rdes + "." + " cif=" + v-cif1 + " aaa1=" + v-aaa1 + " aaa2=" + v-aaa2.
        put stream m-out unformatted v-text skip.
    end.
    output stream m-out close.
end.
procedure Transferbalans:
    def input parameter p-cif as char.
    def input parameter p-aaacif1 as char.
    def input parameter p-aaacif2 as char.
    def output parameter rcode as inte.
    def output parameter rdes as char.
    def output parameter v-jh as inte.
    find first aaa where aaa.cif = p-cif and aaa.aaa = p-aaacif1 no-lock no-error.
    if avail aaa then do:
        v-pay = aaa.cbal - aaa.hbal. /*сумма доступного остатка*/
        if v-pay > 0 then do transaction:
            vparam = string(v-pay) + vdel + "1" + vdel + p-aaacif1 + vdel + "1" + vdel + p-aaacif2 + vdel + "Перевод остатков".
            v-jh = 0.
            run trxgen("vnb0069", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
            /*message v-jh view-as alert-box.*/
            if rcode = 0 then do: /*Если значение 0, то успешно*/
                run trxsts(v-jh, 6, output rcode, output rdes). /*штампуем проводку*/
            end.
        end.
    end.
end. /*Transferbalans*/


