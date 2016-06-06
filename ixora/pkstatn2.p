/* pkstatn2.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Проставление классификации по экспресс-кредитам
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
        22/07/2008 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        30/09/2008 madiyar - явно указал индекс lonhar-idx1 при поиске последней записи lonhar
*/

def shared var g-today as date.
def shared var g-ofc as char.
def var v-bal as deci no-undo.
def var n as integer no-undo.

def var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

hide message no-pause.
message "Обработка " + s-ourbank + "...".

for each txb.lon where txb.lon.plan = 4 or txb.lon.plan = 5 no-lock:
    if txb.lon.opnamt <= 0 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1,7",yes,txb.lon.crc,output v-bal).
    if v-bal <= 0 then next.
    
    find first kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.rdt = g-today and kdlonkl.kod = 'klass' no-lock no-error.
    if not avail kdlonkl then do:
        message " Не найдена рассчитанная классификация " + txb.lon.cif + " " + txb.lon.lon view-as alert-box error.
        next.
    end.
    
    n = 0.
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon use-index lonln no-lock no-error.
    if avail txb.lonhar then n = txb.lonhar.ln + 1.
    
    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt = g-today exclusive-lock no-error.
    if not avail txb.lonhar then do:
        create txb.lonhar. 
        assign txb.lonhar.lon = txb.lon.lon
               txb.lonhar.ln = n
               txb.lonhar.fdt = g-today
               txb.lonhar.cif = txb.lon.cif
               txb.lonhar.akc = no
               txb.lonhar.who = g-ofc
               txb.lonhar.whn = g-today. 
    end.
    txb.lonhar.lonstat = integer(kdlonkl.val1).
    find current lonhar no-lock.
end.

