/* lnodnor2.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расчет % резерва по однородным кредитам
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
        25/01/2011 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        26/08/2013 Sayat(id01143) - ТЗ 1850 от 17/05/2013 "Изменения в расчет однородных кредитов по АФН"
*/

def shared var g-today as date.

def shared var s-full_od as deci no-undo extent 6.
def shared var s-pr_od as deci no-undo extent 6.
def shared var s-full_prc as deci no-undo extent 6.
def shared var s-pr_prc as deci no-undo extent 6.

def shared var s-rates as deci no-undo extent 3.
def shared var s-lim as deci no-undo.

def shared var add_pr as integer no-undo.

def var v-bal as deci no-undo.
def var v-prc as deci no-undo.
def var v-maxpr as integer no-undo.
def var v-days_od as integer no-undo.
def var v-days_prc as integer no-undo.
def var v-maxpr_old as integer no-undo.
def var i as integer no-undo.
def var n as integer no-undo.

def var v-lst as char no-undo init "81,82,90,92,67,20,60,11,21,70,80,95,96".

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

do i = 1 to num-entries(v-lst):
    for each txb.lon where txb.lon.grp = integer(entry(i,v-lst)) no-lock:
        if txb.lon.opnamt <= 0 then next.
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1,7",yes,txb.lon.crc,output v-bal).
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2,9",yes,txb.lon.crc,output v-prc).
        if v-bal + v-prc <= 0 then next. /* ???????? */

        if txb.lon.crc <> 1 then assign v-bal = v-bal * s-rates[txb.lon.crc] v-prc = v-prc * s-rates[txb.lon.crc].

        if v-bal > s-lim then next.

        if txb.lon.grp = 90 or txb.lon.grp = 92 then n = 1.
        else if txb.lon.grp = 81 or txb.lon.grp = 82 then n = 2.
        else if txb.lon.grp = 67 then n = 3.
        else if txb.lon.grp = 20 or txb.lon.grp = 60 then n = 4.
        else if txb.lon.grp = 11 or txb.lon.grp = 21 or txb.lon.grp = 70 or txb.lon.grp = 80 then n = 5.
        else if txb.lon.grp = 95 or txb.lon.grp = 96 then n = 6.


        s-full_od[n] = s-full_od[n] + v-bal.
        s-full_prc[n] = s-full_prc[n] + v-prc.

        v-maxpr = 0.
        run lndayspry_txb(txb.lon.lon,g-today,yes,output v-days_od,output v-days_prc,output v-maxpr_old).
        if v-days_od > 0 then v-days_od = v-days_od + add_pr.
        if v-days_prc > 0 then v-days_prc = v-days_prc + add_pr.
        if v-days_od > v-days_prc then v-maxpr = v-days_od. else v-maxpr = v-days_prc.

        if v-maxpr > 14 then assign s-pr_od[n] = s-pr_od[n] + v-bal s-pr_prc[n] = s-pr_prc[n] + v-prc.
    end.
end.


