/* iovyp4.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Формирование выписок для интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM TXB
 * AUTHOR
        09/10/09 id00004
 * CHANGES
        02.01.2013 damir - Переход на ИИН/БИН. Оптимизация кода.
        28.01.2013 damir - <Доработка выписок, выгружаемых в DBF - файл>. Оптимизация кода.
        12/09/2013 k.gitalov внедрение ИБФЛ
*/
{iovypshared.i}

def input parameter pExtid as char no-undo.

def var v_ost as decimal.
find last txb.cif where txb.cif.cif = pExtid no-lock no-error.
if avail txb.cif then do:
    for each txb.aaa where txb.aaa.cif = txb.cif.cif  no-lock:
        if length(txb.aaa.aaa) >  15 then do:
            v_ost = 0.
            find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
            if  (txb.lgr.led = "CDA" or  txb.lgr.led = "TDA")  and txb.aaa.sta <> "C" then do:
                find last txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
                create t-accnt-depo.
                t-accnt-depo.numder = txb.aaa.aaa.
                t-accnt-depo.currency = txb.crc.code.
                t-accnt-depo.available_balance = string(txb.aaa.cbal -  txb.aaa.hbal,">>>>>>>>>>>9.99").
                t-accnt-depo.total_balance = string(txb.aaa.cbal,">>>>>>>>>>>9.99").
                t-accnt-depo.freeze = string(txb.aaa.hbal,">>>>>>>>>>>9.99").
                t-accnt-depo.intrate = string(txb.aaa.rate).
                t-accnt-depo.accrate = string(txb.aaa.accrued,">>>>>>>>>>>9.99").
                t-accnt-depo.intpaid = string(txb.aaa.cbal -  txb.aaa.hbal,">>>>>>>>>>>9.99").
            end.
        end.
    end.
end.
