/* contxb.p
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
        --/--/2012 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        05.05.2012 damir.
        07.05.2012 damir - добавил входной параметр p-namebank.
        14.08.2012 damir - дополнения согласно С.З. от 13.08.2012.
        24.12.2012 damir - Внедрено Т.З. № 1619.Тестирование ИИН/БИН.
*/

{chbin_txb.i}

def input  parameter p-input1 as char.
def output parameter p-input2 as char.
def output parameter p-input3 as char.

find first txb.aaa where txb.aaa.aaa = p-input1 no-lock no-error.
if avail txb.aaa then do:
    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if avail txb.cif then do:
        if v-bin then p-input2 = txb.cif.bin.
        else p-input2 = txb.cif.jss.

        p-input3 = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
    end.
end.
else do:
    if v-bin then do:
        find first txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
        if avail txb.sysc then p-input2 = trim(txb.sysc.chval).
    end.
    else do:
        find first txb.cmp no-lock no-error.
        if avail txb.cmp then p-input2 = trim(txb.cmp.addr[2]).
    end.

    find first txb.sysc where txb.sysc.sysc eq "fullnamerus" no-lock no-error.
    if avail txb.sysc then p-input3 = trim(txb.sysc.chval).
end.