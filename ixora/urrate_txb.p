/* urrate_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        синхронизация изменений по депозитным ставкам в п.м. 5.2.7
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
       12/10/2013 Luiza
 * BASES
        BANK TXB
 * CHANGES
    16/10/2013 - перекомпиляция
*/

def shared temp-table wrk like txb.rtur.
def shared temp-table wrkdel like txb.rtur.
def shared var ll-ourbank as char no-undo.


def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
 display " There is no record OURBNK in bank.sysc file !!".
 pause.
 return.
end.
s-ourbank = trim(txb.sysc.chval).
find first txb.cmp no-lock.
if s-ourbank <> ll-ourbank then displ txb.cmp.name format "x(70)" label "Филиал" with row 30 width 85 frame ff.
pause 0.
if s-ourbank = "TXB16" then hide frame ff.
if s-ourbank = ll-ourbank then return.

for each wrk.
    find first txb.rtur where txb.rtur.cod = wrk.cod and txb.rtur.trm = wrk.trm and txb.rtur.rem = wrk.rem exclusive-lock no-error.
    if not available txb.rtur then create txb.rtur.
    txb.rtur.cod  = wrk.cod.
    txb.rtur.trm = wrk.trm.
    txb.rtur.rate = wrk.rate.
    txb.rtur.who = wrk.who.
    txb.rtur.whn = wrk.whn.
    txb.rtur.rem = wrk.rem.
end.
for each wrkdel.
    run savelog( "rtur", "Ставки по депозитам Юр. лиц удаление при синхронизации филиал: " + s-ourbank + " " + wrkdel.cod + " " + string(wrkdel.trm) + " " + string(wrkdel.rate)  + " " + wrkdel.who + " " + wrkdel.rem).
    find first txb.rtur where txb.rtur.cod = wrkdel.cod and txb.rtur.trm = wrkdel.trm and txb.rtur.rem = wrkdel.rem exclusive-lock no-error.
    if available txb.rtur then delete txb.rtur.
end.
