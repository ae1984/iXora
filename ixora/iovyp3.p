/* iovyp3.p
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
    for each txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.sta <> "C" no-lock:
        if length (txb.aaa.aaa) > 15 then do:
            v_ost = 0.
            if (txb.aaa.lgr = "138" or txb.aaa.lgr = "139" or txb.aaa.lgr = "140") and txb.aaa.gl = 220430 then next.
            find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
            if txb.lgr.led = "DDA" or txb.lgr.led = "SAV" /*or txb.lgr.led = "CDA"*/ then do:
                find last txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
                create t-accnt.
                t-accnt.numder = txb.aaa.aaa.
                t-accnt.currency = txb.crc.code.
                t-accnt.available_balance = string(txb.aaa.cbal -  txb.aaa.hbal,">>>>>>>>>>>9.99").
                t-accnt.total_balance = string(txb.aaa.cbal,">>>>>>>>>>>9.99").
                t-accnt.freeze = string(txb.aaa.hbal,">>>>>>>>>>>9.99").
                for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.jdt = d_gtday  no-lock :
                    v_ost = v_ost + abs(txb.jl.cam - txb.jl.dam).
                end.
                t-accnt.recent = string(v_ost,">>>>>>>>>>>9.99").
            end.
        end.
    end.
end.
