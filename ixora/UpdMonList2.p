/* UpdMonList2.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        05.07.2013 dmitriy. ТЗ 1947
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def input parameter p-chval as char extent 17.
def var i as int.

i = 1.
for each comm.txb where comm.txb.consolid = yes no-lock:
    find first txb.sysc where txb.sysc.sysc = "vw_" + string(comm.txb.city, "99") exclusive-lock no-error.
    if avail txb.sysc and txb.sysc.chval <> p-chval[i] then do transaction:
        sysc.chval =  p-chval[i].
    end.

    i = i + 1.
end.


