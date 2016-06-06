/* a_pplist.p
 * MODULE

 * DESCRIPTION
        Список длительных платежных поручений
 * BASES
        BANK
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        16/07/2013 Luiza ТЗ № 1738
 * CHANGES

*/


{mainhead.i}

def var v-bank as char no-undo.
def new shared var vlst as int.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    message "Нет параметра ourbnk sysc! " view-as alert-box.
    return.
end.
v-bank = sysc.chval.

    run sel2 ("Список :", " 1. Полный | 2. Текущий | 3. Удаленных ", output vlst).
    if keyfunction (lastkey) = "end-error" then return.
    if (vlst < 1) or (vlst > 3) then return.
    case vlst:
        when 1 then do:
            if v-bank = "TXB00" then run a_pplistf00.
            else run a_pplistf.
        end.
        when 2 then do:
            if v-bank = "TXB00" then run a_pplistc00.
            else run a_pplistc.
        end.
        when 3 then do:
            if v-bank = "TXB00" then run a_pplistd00.
            else run a_pplistd.
        end.
    end.
