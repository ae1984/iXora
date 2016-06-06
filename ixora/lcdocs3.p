/* lcdocs3 .p
 * MODULE
        Trade Finance
 * DESCRIPTION
        External Charges - формирование документов
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
        30/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    07/04/2011 id00810 - исправлена ошибка в условии поиска результата события
    22/07/2011 id00810 - добавлены новые виды оплат комиссий
    26.07.2013 Lyubov  - ТЗ 1981, исправлена выборка провод по номеру события
 */

{global.i}
def shared var s-lc     like lc.lc.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.

def var v-bank   as char no-undo.
def var v-type   as char no-undo.
def var v-list   as char no-undo init ' Memorial statement '.
def var v-sel    as int  no-undo.
def var v-crc    as int  no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".


def new shared var s-jh     like jh.jh .
def new shared var s-remtrz like remtrz.remtrz.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN V-BANK =  SYSC.CHVAL.
else return.

find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'CurCode' no-lock no-error.
if avail lceventh and trim(lceventh.value1) <> '' then v-crc = integer(lceventh.value1).

find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'ComPtype' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-type = lceventh.value1.

if v-crc = 1 then v-list = ' Memorial statement | Payment Order '.
else if v-type = '1' or v-type = '3' then v-list = ' MT 202 | MT 756 | Memorial statement '.

run sel2('Docs',v-list, output v-sel).

case v-sel:
    when 1 then do:
        if v-crc = 1 or v-type = '2' or v-type = '4' then do:
            find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock no-error.
            if avail lceventres then do:
                for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock:
                    if lceventres.info[1] ne '' then next.
                    s-jh  = 0.
                    find first jh where jh.jh = lceventres.jh no-lock no-error.
                    if avail jh then do:
                        s-jh = jh.jh.
                        run vou_bank(1).
                    end.
                end.
            end.
            else message 'No postings avail!' view-as alert-box.
        end.
        else run lcmtext ('202',no).
    end.
    when 2 then do:
        if v-crc = 1 then do:
            find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock no-error.
            if avail lceventres then do:
                for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock:
                    if lceventres.info[1] = '' then next.
                    s-remtrz = lceventres.info[1].
                    run prtpp.
                end.
            end.
            else message 'No postings avail!' view-as alert-box.
        end.
        else do:
            find first lceventh where lceventh.bank = v-bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'MT756' no-lock no-error.
            if avail lceventh and lookup(lceventh.value1,v-logsno) > 0 then do:
                message 'Your choice had been not to create this type of document!' view-as alert-box.
                return.
            end.
            else run lcmtext ('756',no).
        end.
    end.
    when 3 then do:
        find first lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock no-error.
        if avail lceventres then do:
            for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.jh > 0 no-lock:
                if lceventres.info[1] ne '' then next.
                s-jh  = 0.
                find first jh where jh.jh = lceventres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.
    end.

end case.