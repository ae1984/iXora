/* str_strx_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - str-strx.p,r-knsf.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        28.11.2012 damir - Внедрено Т.З. № 1588.
        10/04/2013 Luiza - ТЗ 1709 исключение из СФ межфилиальные комисси оплаченные по 100100 или 100500.
*/

{Inter-Branch.i} /*shared parameters*/

def var v-ourbnk as char.
def var cashisk as logic.
def var comisk as logic.
def var countln as int.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-ourbnk = txb.sysc.chval.
else do:
    message "Не найдена запись в sysc!" view-as alert-box.
    return.
end.

find txb.cmp no-lock no-error.

for each t-work where t-work.txb = v-ourbnk no-lock:
    if t-work.jh ne 0 or t-work.jh ne ? then do:
        cashisk = no.
        comisk = no.
        countln = 0.
        for each txb.jl where txb.jl.jh = t-work.jh no-lock.
            if txb.jl.gl = 100100 or txb.jl.gl = 100500 then cashisk = yes.
            if string(txb.jl.gl) begins "4" then comisk = yes.
            countln = countln + 1.
        end.
        if countln = 2 and cashisk = yes and comisk = yes then next.
        find last txb.jl where txb.jl.jh = t-work.jh no-lock no-error.
        find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
        find first txb.remtrz where txb.remtrz.remtrz = txb.jh.ref no-lock no-error .

        create t-InterBrh.
        t-InterBrh.txb = v-ourbnk.

        if t-work.docnum ne "" then do:
            find txb.joudoc where txb.joudoc.docnum = t-work.docnum no-lock no-error.
            if avail txb.joudoc then do:
                t-InterBrh.docnum = txb.joudoc.docnum.
                t-InterBrh.comcode = txb.joudoc.comcode.
                t-InterBrh.whn = txb.joudoc.whn.
            end.
            else do:
                /*message "Не найдена запись в joudoc для " t-work.docnum ". Проводка " t-work.jh ". " txb.cmp.name view-as alert-box.*/
                /*return.*/
            end.
        end.
        if avail txb.jl then do:
            t-InterBrh.jdt = txb.jl.jdt.
            t-InterBrh.who = txb.jl.who.
            t-InterBrh.gl = txb.jl.gl.
            t-InterBrh.trx = txb.jl.trx.
            t-InterBrh.ln = txb.jl.ln.
            t-InterBrh.crc = txb.jl.crc.
            t-InterBrh.rem[1] = txb.jl.rem[1].
            t-InterBrh.rem[2] = txb.jl.rem[2].
            t-InterBrh.rem[3] = txb.jl.rem[3].
            t-InterBrh.rem[4] = txb.jl.rem[4].
            t-InterBrh.rem[5] = txb.jl.rem[5].
        end.
        else do:
            /*message "Не найдена запись в jl для " t-work.jh ". Проводка " t-work.jh ". " txb.cmp.name view-as alert-box.*/
            /*return.*/
        end.

        if avail txb.jh then do:
            t-InterBrh.jh = txb.jh.jh.
            t-InterBrh.party = txb.jh.party.
            t-InterBrh.sub = txb.jh.sub.
            t-InterBrh.ref = txb.jh.ref.
        end.
        else do:
            /*message "Не найдена запись в jh для " t-work.jh ". Проводка " t-work.jh ". " txb.cmp.name view-as alert-box.*/
            /*return.*/
        end.

        if avail remtrz then do:
            t-InterBrh.svccgr = txb.remtrz.svccgr.
            t-InterBrh.remtrz = txb.remtrz.remtrz.
        end.

    end.
end.


