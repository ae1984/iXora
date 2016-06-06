/* kzrepscrco-opor.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        kzrepscrco.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
       05.04.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        16.04.2012 aigul - исправила вывод данных
*/

{global.i}
def shared var v-dt1 as date no-undo.
def shared var v-dt2 as date no-undo.
def shared var v-reptype as int no-undo.

def shared temp-table wrk-op
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

for each scrc where scrc.regdt >= v-dt1 and scrc.regdt <= v-dt2 no-lock:
    create wrk-op.
    wrk-op.dt = scrc.regdt.
    wrk-op.fil = "ЦО".
    if scrc.crc = 2 then wrk-op.ubuy = scrc.buycrc.
    if scrc.crc = 2 then wrk-op.usell = scrc.sellcrc.
    if scrc.crc = 2 then wrk-op.uspred = scrc.minspr.
    if scrc.crc = 3 then wrk-op.ebuy = scrc.buycrc.
    if scrc.crc = 3 then wrk-op.esell = scrc.sellcrc.
    if scrc.crc = 3 then wrk-op.espred = scrc.minspr.
    if scrc.crc = 4 then wrk-op.rbuy = scrc.buycrc.
    if scrc.crc = 4 then wrk-op.rsell = scrc.sellcrc.
    if scrc.crc = 4 then wrk-op.rspred = scrc.minspr.
    wrk-op.tim = scrc.tim.
    wrk-op.typ = "Опорные".
    wrk-op.rasp = string(scrc.order).
end.
for each wrk-op no-lock break by wrk-op.rasp:
    if first-of(wrk-op.rasp) then do:
        create wrk1.
        wrk1.dt = wrk-op.dt.
        wrk1.fil = wrk-op.fil.
        wrk1.usell = wrk-op.usell.
        wrk1.ubuy = wrk-op.ubuy.
        wrk1.uspred = wrk-op.uspred.
        wrk1.esell = wrk-op.esell.
        wrk1.ebuy = wrk-op.ebuy.
        wrk1.espred = wrk-op.espred.
        wrk1.rsell = wrk-op.rsell.
        wrk1.rbuy = wrk-op.rbuy.
        wrk1.rspred = wrk-op.rspred.
        wrk1.typ = wrk-op.typ .
        wrk1.rasp = wrk-op.rasp.
        wrk1.tim = wrk-op.tim.
   end.
   else do:
        for each wrk1 where wrk1.rasp = wrk-op.rasp and wrk1.fil = wrk-op.fil exclusive-lock:
            if wrk1.usell = 0 then do:
            wrk1.usell = wrk-op.usell.
            wrk1.ubuy = wrk-op.ubuy.
            wrk1.uspred = wrk-op.uspred.
            end.
            if wrk1.esell = 0 then do:
            wrk1.esell = wrk-op.esell.
            wrk1.ebuy = wrk-op.ebuy.
            wrk1.espred = wrk-op.espred.
            end.
            if wrk1.rsell = 0 then do:
            wrk1.rsell = wrk-op.rsell.
            wrk1.rbuy = wrk-op.rbuy.
            wrk1.rspred = wrk-op.rspred.
            end.
        end.
    end.
end.