/* .p
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
        --/--/2011 damir
 * BASES
        BANK TXB
 * CHANGES
        12.04.2011 damir - синхронизация
*/

def input parameter p-codfr as char.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
if txb.sysc.chval = "TXB00" then return.

for each txb.codfr where txb.codfr.codfr = p-codfr exclusive-lock:
    delete txb.codfr.
end.

for each bank.codfr where bank.codfr.codfr = p-codfr  no-lock:
    do transaction on error undo, retry:
        create txb.codfr.
        buffer-copy bank.codfr to txb.codfr.
    end.
end.


