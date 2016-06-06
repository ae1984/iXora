/* iovyp5.p
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

def var bilance as deci.
def var v_ost as decimal.

find last txb.cif where txb.cif.cif = pExtid no-lock no-error.
if avail txb.cif then do:
    v_ost = 0.

    for each txb.lon where txb.lon.sts = "A" and txb.lon.cif =  txb.cif.cif no-lock:
        find last txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
        create t-accnt-depo.
        t-accnt-depo.numder = txb.lon.lon.
        t-accnt-depo.aux_acc = txb.lon.aaa.
        t-accnt-depo.currency = txb.crc.code.

        if txb.lon.prem = 0 then do:
            if txb.lon.prem1 = 0 then do:
                find last txb.ln%his where txb.ln%his.lon = txb.lon.lon no-lock.
                if avail txb.ln%his then t-accnt-depo.intrate = string(txb.ln%his.intrate).
                t-accnt-depo.intrate = "0.00".
            end.
            else t-accnt-depo.intrate = string(txb.lon.prem1).
        end.
        else t-accnt-depo.intrate = string(txb.lon.prem).
        /*номер контракта*/
        find last txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
        if avail txb.loncon then t-accnt-depo.available_balance = txb.loncon.lcnt.
        /*сумма кредита*/
        t-accnt-depo.freeze = string(txb.lon.opnamt,">>>>>>>>>>>9.99").
        /*остаток к погашению*/
        run lonbalcrc1('lon',txb.lon.lon,d_gtday,"1,7",yes,lon.crc,output bilance).
        t-accnt-depo.total_balance = string(bilance,">>>>>>>>>>>9.99").
        /*дата начала*/
        t-accnt-depo.accrate = string(txb.lon.rdt).
        /*дата окончания*/
        t-accnt-depo.intpaid = string(txb.lon.duedt).
    end.
end.
procedure lonbalcrc1.
    define input parameter p-sub like txb.trxbal.subled.
    define input parameter p-acc as char.
    define input parameter p-dt like txb.jl.jdt.
    define input parameter p-lvls as char.
    define input parameter p-includetoday as logi.
    define input parameter p-crc like txb.crc.crc.
    define output parameter res as decimal.

    def var i as integer.

    res = 0.
    if p-dt > d_gtday then return.

    if p-includetoday then do: /* за дату */
        if p-dt = d_gtday then do:
            for each txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc and txb.trxbal.crc = p-crc no-lock:
                if lookup(string(txb.trxbal.level), p-lvls) > 0 then res = res + (txb.trxbal.dam - txb.trxbal.cam).
            end.
        end.
        else do:
            do i = 1 to num-entries(p-lvls):
                find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = integer(entry(i, p-lvls))
                and txb.histrxbal.dt <= p-dt and txb.histrxbal.crc = p-crc no-lock no-error.
                if avail txb.histrxbal then res = res + (txb.histrxbal.dam - txb.histrxbal.cam).
            end.
        end.
    end. /* if p-includetoday */
    else do: /* на дату */
        do i = 1 to num-entries(p-lvls):
            find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = integer(entry(i, p-lvls))
            and txb.histrxbal.dt < p-dt and txb.histrxbal.crc = p-crc no-lock no-error.
            if avail txb.histrxbal then res = res + (txb.histrxbal.dam - txb.histrxbal.cam).
        end.
    end.
end.




