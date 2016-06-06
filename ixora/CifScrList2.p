/* CifScrList2.p
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

def input parameter p-chval as char.

find first txb.sysc where txb.sysc.sysc = "CifScr" exclusive-lock no-error.
if avail txb.sysc then do transaction:
    txb.sysc.chval = p-chval.
end.


