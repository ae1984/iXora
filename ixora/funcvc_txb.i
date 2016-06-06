/* funcvc_txb.i
 * MODULE
        Название модуля - Функции и процедуры, используемые в ВАЛКОНЕ для БАЗЫ TXB
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
        29.06.2012 damir.
*/


function konv2usd returns deci(p-sum as deci, p-crc as inte, p-date as date).
    def var vp-sum      as deci.
    def var v-kurs      as deci init 0.
    def var v-cursusd2  as deci.

    if p-crc = 2 then vp-sum = p-sum.
    else do:
        find last txb.ncrchis where txb.ncrchis.crc = p-crc and txb.ncrchis.rdt <= p-date no-lock no-error.
        if avail txb.ncrchis and txb.ncrchis.rate[1] <> 0 then do:
            v-kurs = txb.ncrchis.rate[1].
        end.
        else do:
            find last txb.ncrchis where txb.ncrchis.crc = p-crc and txb.ncrchis.rdt <= p-date and txb.ncrchis.rate[1] <> 0 no-lock no-error.
            if avail txb.ncrchis then do:
                v-kurs = txb.ncrchis.rate[1].
            end.
            else do:
                v-kurs = 1.
            end.
        end.
        find last txb.ncrchis where txb.ncrchis.crc = 2 and txb.ncrchis.rdt <= p-date no-lock no-error.
        if avail txb.ncrchis then v-cursusd2 = txb.ncrchis.rate[1].

        vp-sum = (p-sum * v-kurs) / v-cursusd2.
    end.
    return vp-sum.
end.

