/* .p
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
        BANK COMM
 * CHANGES
        20.05.2011 - дата добавления в библиотеку
        24.05.2011 damir - исправлено назначение платежа
        25.05.2011 damir - исправлен код в цикле
        03.04.2012 damir - небольшие корректировки.
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
*/

define new shared var s-jh  like jh.jh.
define shared var g-today  as date.
define shared var s-target as date.
define shared var s-bday   as log init true.
define shared var s-intday as int .

def var v-pay  as decimal init 0.
def var v-aaa1 as char.
def var v-aaa2 as char.
def var v-nm   as integer.
def var vdel   as char init "^".
def var v-cif1    as char no-undo.
def var v-cif2    as char no-undo.
def var v-crc1    as inte no-undo.
def var v-crc2    as inte no-undo.
def var v-sts1 as char no-undo.
def var v-sts2 as char no-undo.
def var fname1 as char.
def var v-text as char.
def var vparam as char.
def var rcode  as inte.
def var rdes   as char.
def var v-jh   as inte.
def var v-control as date.

def stream m-out.
fname1 = "tranall2" + string(year(g-today)) + string(month(g-today)) + string(day(g-today)) + ".txt".
output stream m-out to value(fname1).

for each aaaperost where aaaperost.getcom = 1 no-lock: /* Перевод который уже был когда то осуществлен*/
    find first aaa where aaa.aaa = aaaperost.aaacif1 no-lock no-error.
    if avail aaa then do:
        v-cif1 = aaa.cif.
        v-crc1 = aaa.crc.
        v-sts1 = aaa.sta.
    end.
    else do:
        v-text = "Счет " + aaaperost.aaacif1 + " не найден !".
        put stream m-out unformatted v-text skip.
        next.
    end.
    find first aaa where aaa.aaa = aaaperost.aaacif2 no-lock no-error.
    if avail aaa then do:
        v-cif2 = aaa.cif.
        v-crc2 = aaa.crc.
        v-sts2 = aaa.sta.
    end.
    else do:
        v-text = "Счет " + aaaperost.aaacif2 + " не найден !".
        put stream m-out unformatted v-text skip.
        next.
    end.

    v-jh = 0.
    run Transferbalans(input aaaperost.cif, input aaaperost.aaacif1, input aaaperost.aaacif2, output rcode, output rdes, output v-jh).
    if rcode = 0 then do:
        v-text = "cif=" + aaaperost.cif + " aaa1=" + aaaperost.aaacif1 + " aaa2=" + aaaperost.aaacif2 + " trx=" + string(v-jh).
        put stream m-out unformatted v-text skip.
    end.
    else do:
        v-text = "Error " + string(rcode) + " - " + rdes + "." + " cif=" + aaaperost.cif + " aaa1=" + aaaperost.aaacif1 + " aaa2=" + aaaperost.aaacif2.
        put stream m-out unformatted v-text skip.
        next.
    end.
end.
output stream m-out close.

procedure Transferbalans:
    def input parameter p-cif as char.
    def input parameter p-aaacif1 as char.
    def input parameter p-aaacif2 as char.
    def output parameter rcode as inte.
    def output parameter rdes as char.
    def output parameter v-jh as int.
    find first aaa where aaa.cif = p-cif and aaa.aaa = p-aaacif1 no-lock no-error.
    if avail aaa then do:
        v-pay = aaa.cbal - aaa.hbal.
        if v-pay > 0 then do transaction:
            vparam = string(v-pay) + vdel + "1" + vdel + p-aaacif1 + vdel + "1" + vdel + p-aaacif2 + vdel + "Перевод остатков".
            v-jh = 0.
            run trxgen("vnb0069", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
            if rcode = 0 then do: /*Если значение 0, то успешно*/
                run trxsts(v-jh, 6, output rcode, output rdes). /*штампуем проводку*/
            end.
            for each jl where jl.jh = v-jh exclusive-lock.
                jl.viddoc = "pdoctng,01".
            end.
        end.
    end.
end. /*Transferbalans*/




