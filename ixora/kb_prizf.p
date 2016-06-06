/* kb_prizf.p
 * MODULE
        Отчет о признаке в кредитное бюро
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        COMM TXB
 * AUTHOR
        19/08/2013 Sayat(id01143) - ТЗ 1776 от 27/03/2013 "Изменения в отчете «Признак согласия на отправку в Кредитное Бюро»"
 * CHANGES

*/

def shared temp-table kbpriz
  field cif     as  char
  field fil     as  char
  field cifname as  char
  field lon     as  char
  field vid     as  char
  field isdt    as  date
  field duedt   as  date
  field amt     as  deci
  field priz    as  char.

def var v-sum as deci.
def shared var d-rates as deci no-undo extent 20.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.

for each txb.cif, txb.lon where txb.cif.cif = txb.lon.cif no-lock by txb.cif.cif:
    /*if txb.lon.sts <> 'A' and txb.lon.gua <> 'CL' then next.*/
    create kbpriz.
    assign  kbpriz.cif = txb.cif.cif
            kbpriz.fil = trim(txb.sysc.chval)
            kbpriz.cifname = trim(txb.cif.prefix + ' ' + txb.cif.name)
            kbpriz.lon = txb.lon.lon
            kbpriz.vid = txb.lon.gua
            kbpriz.isdt = txb.lon.rdt
            kbpriz.duedt = txb.lon.duedt.
    v-sum = 0.

    if txb.lon.gua = 'LO' then do:
        for each txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon and lookup(string(txb.trxbal.level),'1,7') <> 0 no-lock:
            v-sum = v-sum + round((txb.trxbal.dam - txb.trxbal.cam) * d-rates[txb.trxbal.crc],2).
        end.
    end.
    else do:
        for each txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon and lookup(string(txb.trxbal.level),'15,35') <> 0 no-lock:
            v-sum = v-sum + round((txb.trxbal.cam - txb.trxbal.dam) * d-rates[txb.trxbal.crc],2).
        end.
    end.

    kbpriz.amt = v-sum.

    find txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lonkb' no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccode = '01' then kbpriz.priz = 'есть'.
    else kbpriz.priz = 'нет'.
end.