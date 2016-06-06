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
*/


def input parameter p-code like bank.cods.code.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if txb.sysc.chval = "TXB00"  then return.

find first bank.cods where bank.cods.code = p-code no-lock no-error.
find first txb.cods  where txb.cods.code  = p-code exclusive-lock no-error.

do transaction on  error undo, retry:
    if not avail txb.cods then do:
        create txb.cods.
        txb.cods.code = p-code.
    end.
    if avail bank.cods then do:
        txb.cods.dep = bank.cods.dep.
        txb.cods.gl  = bank.cods.gl.
        txb.cods.acc = bank.cods.acc.
        txb.cods.lookaaa = bank.cods.lookaaa.
        txb.cods.des = bank.cods.des.
        txb.cods.arc = bank.cods.arc.
    end.
end.

