/* rasp.p
 * MODULE
        Казначейство
 * DESCRIPTION
        Копирование номеров распоряжений на филиалы
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
        BANK TXB
 * AUTHOR
        24/03/2009 madiyar
 * CHANGES
        30/03/2009 madiyar - номер последнего распоряжения передается параметром
        15/04/2009 madiyar - список распоряжений не очищался, исправил
*/

def input parameter p-numobm as char no-undo.
def shared var g-today as date.

find first bank.sysc where bank.sysc.sysc = 'numobm' no-lock no-error.
if avail bank.sysc then do transaction:
    find first txb.sysc where txb.sysc.sysc = 'numobm' exclusive-lock no-error.
    if not avail txb.sysc then do:
        create txb.sysc.
        assign txb.sysc.sysc = 'numobm'
               txb.sysc.inval = 0
               txb.sysc.deval = 0
               txb.sysc.daval = g-today
               txb.sysc.des = 'Номер распоряжения по обменному пункту'.
    end.
    assign txb.sysc.inval = bank.sysc.inval
           txb.sysc.deval = 0. /* нумерация льготных распоряжений обнуляется в любом случае */

    /* если распоряжение первое за сегодня - очищаем список и обновляем дату */
    if txb.sysc.daval < g-today then assign txb.sysc.chval = '' txb.sysc.daval = g-today.

    txb.sysc.chval = trim(txb.sysc.chval).
    if txb.sysc.chval <> '' then
        if substring(txb.sysc.chval,length(txb.sysc.chval),1) <> ',' then txb.sysc.chval = txb.sysc.chval + ','.
    txb.sysc.chval = txb.sysc.chval + p-numobm.

    for each txb.exch_lst exclusive-lock:
        txb.exch_lst.numr = txb.sysc.chval.
    end.
end.

