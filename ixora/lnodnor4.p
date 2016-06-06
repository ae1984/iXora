/* lnodnor4.p
 * MODULE
        Кредиты
 * DESCRIPTION
        t-proc = 1 - Расчет % резерва по однородным кредитам АФН (МСБ)  и  по прочим однородным кредитам АФН (МСБ)
        t-proc = 2 - Запись полученных значений в sysc
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
        28/04/2012 dmitriy
 * BASES
        BANK COMM TXB
 * CHANGES
        26/08/2013 Sayat(id01143) - ТЗ 1850 от 17/05/2013 "Изменения в расчет однородных кредитов по АФН"
*/
def input parameter t-proc as int.

def temp-table wrk
    field cif like txb.cif.cif
    field pooln as char.

def var i as integer no-undo.
def var n as integer no-undo.
def var v-days_od as int no-undo.
def var v-days_prc as int no-undo.
def var v-bal as deci.

def shared var v-od1 as deci extent 2 no-undo.
def shared var v-od7 as deci extent 2 no-undo.
def shared var v-od13 as deci extent 2 no-undo.

def shared var v-sum1 as deci extent 2 no-undo.
def shared var v-sum7 as deci extent 2 no-undo.
def shared var v-sum13 as deci extent 2 no-undo.

def shared var v-rezprc as deci extent 2 no-undo.
def shared var g-today as date.
def shared var s-lim as deci no-undo.
def shared var add_pr as integer no-undo.
def shared var v-dt as date.
def shared var v-%sk as deci no-undo. /* пороговое значение = 0,02% от СК */
def shared var v-today as date.

def var v-cifod as deci.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

hide message no-pause.
message s-ourbank.

if v-dt > g-today then v-dt = g-today.

if t-proc = 1 then do:
    /*однородные МСБ*/
    for each txb.lon where
        txb.lon.grp = 16 or
        txb.lon.grp = 26 or
        txb.lon.grp = 56 or
        txb.lon.grp = 66
    no-lock:
            if txb.lon.opnamt <= 0 then next.

            v-od1[1] = 0. v-od7[1] = 0. v-od13[1] = 0.

            run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"1,7",no,txb.lon.crc,output v-od1[1]).
            run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"13",no,txb.lon.crc,output v-od13[1]).

            v-od7[1] = 0.
            run lndayspr_txb(txb.lon.lon,v-dt,no,output v-days_od,output v-days_prc).
            if v-days_od >= 15 then run lonbalcrc_txb('lon',txb.lon.lon,/*g-today*/ v-dt,"1,7",no,txb.lon.crc,output v-od7[1]).

            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= v-dt no-lock no-error.
            if avail txb.crchis then do:
                v-od1[1] = v-od1[1] * txb.crchis.rate[1].
                v-od7[1] = v-od7[1] * txb.crchis.rate[1].
                v-od13[1] = v-od13[1] * txb.crchis.rate[1].
            end.

            v-sum1[1] = v-sum1[1] + v-od1[1].
            v-sum7[1] = v-sum7[1] + v-od7[1].
            v-sum13[1] = v-sum13[1] + v-od13[1].
    end.


    /*сбор "прочих однородных" по сумме ОД всех кредитов клиента*/
    for each txb.cif no-lock:
        if txb.cif.cif  = "A11401" then next. /* Пропускаем Фрайзстрой, т.к. влияет на процент резервирования по пулу "Прочие однородные МСБ" */

        v-cifod = 0.

        for each txb.lon where txb.lon.cif = txb.cif.cif and
           (txb.lon.grp = 10 or
            txb.lon.grp = 14 or
            txb.lon.grp = 15 or
            txb.lon.grp = 24 or
            txb.lon.grp = 25 or
            txb.lon.grp = 50 or
            txb.lon.grp = 54 or
            txb.lon.grp = 55 or
            txb.lon.grp = 64 or
            txb.lon.grp = 65 or
            txb.lon.grp = 13 or
            txb.lon.grp = 23 or
            txb.lon.grp = 53 or
            txb.lon.grp = 63
            )
        no-lock:
            v-bal = 0.
            run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"1,7",no,txb.lon.crc,output v-bal).
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= v-dt no-lock no-error.
            if avail txb.crchis then v-bal = v-bal * txb.crchis.rate[1].

            v-cifod = v-cifod + v-bal.
        end.

        create wrk.
        wrk.cif = txb.cif.cif.
        if v-cifod < v-%sk then wrk.pooln = "2".
        else wrk.pooln = "1".
    end.

    /*прочие однородные МСБ*/
    for each wrk where wrk.pooln = "2" no-lock:
        for each txb.lon where txb.lon.cif = wrk.cif and
           (txb.lon.grp = 10 or
            txb.lon.grp = 14 or
            txb.lon.grp = 15 or
            txb.lon.grp = 24 or
            txb.lon.grp = 25 or
            txb.lon.grp = 50 or
            txb.lon.grp = 54 or
            txb.lon.grp = 55 or
            txb.lon.grp = 64 or
            txb.lon.grp = 65 or
            txb.lon.grp = 13 or
            txb.lon.grp = 23 or
            txb.lon.grp = 53 or
            txb.lon.grp = 63
            )
        no-lock:
            if txb.lon.opnamt <= 0 then next.

            v-od1[2] = 0. v-od7[2] = 0. v-od13[2] = 0.

            run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"1,7",no,txb.lon.crc,output v-od1[2]).
            run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"13",no,txb.lon.crc,output v-od13[2]).

            v-od7[2] = 0.
            run lndayspr_txb(txb.lon.lon,/*g-today*/ v-dt,no,output v-days_od,output v-days_prc).
            if v-days_od >= 15 then run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"1,7",no,txb.lon.crc,output v-od7[2]).

            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= v-dt no-lock no-error.
            if avail txb.crchis then do:
                v-od1[2] = v-od1[2] * txb.crchis.rate[1].
                v-od7[2] = v-od7[2] * txb.crchis.rate[1].
                v-od13[2] = v-od13[2] * txb.crchis.rate[1].
            end.

            v-sum1[2] = v-sum1[2] + v-od1[2].
            v-sum7[2] = v-sum7[2] + v-od7[2].
            v-sum13[2] = v-sum13[2] + v-od13[2].
        end.
    end.

end.

/*запись полученных значений в sysc*/
if t-proc = 2 then do:
    do transaction:
        find first txb.sysc where txb.sysc.sysc = "MSB%REZ" exclusive-lock no-error.
        if avail txb.sysc then do:
        txb.sysc.sysc = "MSB%REZ".
        txb.sysc.des = "Процент резервирования по АФН для кредитов МСБ".
        txb.sysc.deval = v-%sk. /*0.02% от суммы СК*/
        txb.sysc.chval = string(v-rezprc[1]) + "|" + string(v-rezprc[2]). /* 1) % по однор.МСБ  2) % по проч.однор.МСБ */
        txb.sysc.daval = v-dt.
        end.
    end.
end. /* t-proc = 2 */

