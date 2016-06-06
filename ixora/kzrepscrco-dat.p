/* kzrepscrco-dat.p
 * MODULE
        7.4.3.6.3 Опорные и курсы филиала для о/п
 * DESCRIPTION
        Описание
 * RUN
        kzrepscrco
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        05.12.2011 aigul
 * BASES
        BANK TXB
 * CHANGES
        07.12.2011 aigul - исправила вывод системного времени
        05.04.2012 aigul - внесла изменения по сохранению данных
        16.04.2012 aigul - исправила вывод данных
*/

def shared var v-dt1 as date no-undo.
def shared var v-dt2 as date no-undo.
def shared var v-reptype as int no-undo.
def shared temp-table wrk
    field dt as date
    field fil as char
    field usell as decimal
    field ubuy as decimal
    field uspred as decimal
    field esell as decimal
    field ebuy as decimal
    field espred as decimal
    field rsell as decimal
    field rbuy as decimal
    field rspred as decimal
    field tim as int
    field typ as char
    field rasp as char.
def shared temp-table wrk1
    field dt as date
    field fil as char
    field usell as decimal
    field ubuy as decimal
    field uspred as decimal
    field esell as decimal
    field ebuy as decimal
    field espred as decimal
    field rsell as decimal
    field rbuy as decimal
    field rspred as decimal
    field tim as int
    field typ as char
    field rasp as char.
def var v-bank as char.
def var v-bcode as char.
find txb.cmp no-lock no-error.
v-bank = txb.cmp.name.
v-bcode = substr(string(txb.cmp.code),1,2).
def var v-tim as int.
if v-reptype = 1 or v-reptype = 3 then do:
    v-tim = 0.
    for each txb.crchis where txb.crchis.regdt >= v-dt1 and txb.crchis.regdt <= v-dt2 and txb.crchis.order <> ""
    use-index crchis-idx1 no-lock:
        create wrk.
        wrk.dt = txb.crchis.regdt.
        wrk.fil = v-bank.
        wrk.ubuy = 0.
        wrk.usell = 0.
        wrk.ebuy = 0.
        wrk.esell = 0.
        wrk.rbuy = 0.
        wrk.rsell = 0.
        if txb.crchis.crc = 2 then wrk.ubuy = txb.crchis.rate[2].
        if txb.crchis.crc = 2 then wrk.usell = txb.crchis.rate[3].
        if txb.crchis.crc = 3 then wrk.ebuy = txb.crchis.rate[2].
        if txb.crchis.crc = 3 then wrk.esell = txb.crchis.rate[3].
        if txb.crchis.crc = 4 then wrk.rbuy = txb.crchis.rate[2].
        if txb.crchis.crc = 4 then wrk.rsell = txb.crchis.rate[3].
        wrk.typ = "Стандартные".
        wrk.rasp = txb.crchis.order.
        wrk.tim = txb.crchis.tim.
        /*if (v-bcode = "12" or v-bcode = "11" or v-bcode = "4" or v-bcode = "1") then
        wrk.tim  = crchis.tim + 3600.*/
    end.
end.
if v-reptype = 1 or v-reptype = 4 then do:
    for each txb.crclg where txb.crclg.whn >= v-dt1 and txb.crclg.whn <= v-dt2 and txb.crclg.order <> ""
    use-index whn_idx no-lock:
        create wrk.
        wrk.dt = txb.crclg.whn.
        wrk.fil = v-bank.
        wrk.ubuy = 0.
        wrk.usell = 0.
        wrk.ebuy = 0.
        wrk.esell = 0.
        wrk.rbuy = 0.
        wrk.rsell = 0.
        if txb.crclg.crcpr = 2 then wrk.ubuy = txb.crclg.crcpok.
        if txb.crclg.crcpr = 2 then wrk.usell = txb.crclg.crcprod.
        if txb.crclg.crcpr = 3 then wrk.ebuy = txb.crclg.crcpok.
        if txb.crclg.crcpr = 3 then wrk.esell = txb.crclg.crcprod.
        if txb.crclg.crcpr = 4 then wrk.rbuy = txb.crclg.crcpok.
        if txb.crclg.crcpr = 4 then wrk.rsell = txb.crclg.crcprod.
        wrk.typ = "Льготные".
        wrk.rasp = txb.crclg.order.
        wrk.tim = txb.crclg.tim.
    end.
end.

