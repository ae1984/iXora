/* lnprorep2.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Отчет по реструктуризации/пролонгации
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
        22/05/2010 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
*/


def shared var dat1 as date no-undo.
def shared var dat2 as date no-undo.

def shared temp-table wrk no-undo
  field bank as char
  field cif as char
  field cifn as char
  field lon as char
  field crc as integer
  field bankn as char
  field odRestr as deci
  field opType as char
  field dtRestr as date
  field who as char
  field dtPog as date
  field dtOd as date
  field dtPrc as date
  field sumPen as deci
  index idx is primary bank cifn.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

def var v-bankn as char no-undo.
if s-ourbank = "txb00" then v-bankn = "ЦО".
else do:
    find first txb.cmp no-lock no-error.
    if avail txb.cmp then v-bankn = entry(1,txb.cmp.addr[1]).
end.

def var v-cifn as char no-undo.
def var v-opType as integer no-undo.

def var v-protype_list as char no-undo extent 5.
v-protype_list[1] = "Пролонгация без отсрочки".
v-protype_list[2] = "Пролонгация с отсрочкой".
v-protype_list[3] = "Отсрочка без пролонгации/Распределение просроченных платежей без пролонгации".
v-protype_list[4] = "Перенос пени в отсроченную".
v-protype_list[5] = "--ошибка определения типа--".

for each txb.lnprohis where txb.lnprohis.type = "prolong" and txb.lnprohis.whn >= dat1 and txb.lnprohis.whn <= dat2 no-lock:
    find first txb.lon where txb.lon.lon = txb.lnprohis.lon no-lock no-error.
    if not avail txb.lon then do:
        message "Не найден сс. счет " + txb.lnprohis.lon + "!" view-as alert-box error.
        next.
    end.
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then v-cifn = trim(txb.cif.name).
    else v-cifn = "--не найден--".

    v-opType = 0.
    v-opType = integer(txb.lnprohis.sts) no-error.
    if v-opType = 0 then v-opType = 5.

    create wrk.
    assign wrk.bank = s-ourbank
           wrk.cif = txb.lon.cif
           wrk.cifn = v-cifn
           wrk.lon = txb.lon.lon
           wrk.crc = txb.lon.crc
           wrk.bankn = v-bankn
           wrk.opType = v-protype_list[v-opType]
           wrk.dtRestr = txb.lnprohis.whn
           wrk.who = txb.lnprohis.who
           wrk.dtPog = txb.lon.duedt
           wrk.dtOd = txb.lnprohis.dth
           wrk.dtPrc = txb.lnprohis.dti
           wrk.sumPen = txb.lnprohis.penAmt.

    run lonbalcrc_txb('lon',txb.lon.lon,txb.lnprohis.whn,"1,7",no,txb.lon.crc,output wrk.odRestr).
end.

