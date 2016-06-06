/* comm-txb_txb.i
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
        --/--/2013 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
*/
function comm-txb returns char():
    def buffer b-sysc for txb.sysc.
    find b-sysc where b-sysc.sysc = "ourbnk" no-lock no-error.
    if not avail b-sysc or b-sysc.chval = "" then do:
        display " This isn't record OURBNK in b-sysc file !!".
        pause.
        return "".
    end.
    return trim(b-sysc.chval).
end.


