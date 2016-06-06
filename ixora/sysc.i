/* sysc.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* ------------------------------------------------------- */
/* П О Л У Ч Е Н И Е    Т Е К У Щ И Х     З Н А Ч Е Н И Й  */
/* ------------------------------------------------------- */

function get-sysc-int returns integer (code as char).
    find sysc where sysc.sysc = code no-lock no-error.
    if not avail sysc then return ?. else return sysc.inval.
end function.

/* ---------------------------------------------------- */

function get-sysc-dec returns decimal (code as char).
    find sysc where sysc.sysc = code no-lock no-error.
    if not avail sysc then return ?. else return sysc.deval.
end function.

/* ---------------------------------------------------- */

function get-sysc-dat returns date (code as char).
    find sysc where sysc.sysc = code no-lock no-error.
    if not avail sysc then return ?. else return sysc.daval.
end function.

/* ---------------------------------------------------- */


function get-sysc-cha returns char (code as char).
    find sysc where sysc.sysc = code no-lock no-error.
    if not avail sysc then return ?. else return sysc.chval.
end function.

/* ---------------------------------------------------- */



/* ---------------------------------------------------- */
/* У С Т А Н О В К А    Н О В Ы Х    З Н А Ч Е Н И Й    */  
/* ---------------------------------------------------- */


procedure set-sysc-int.
def input parameter code as char.
def input parameter val as integer.

    find sysc where sysc.sysc = code no-error.
    if avail sysc then sysc.inval = val.

end.

/* ---------------------------------------------------- */

procedure set-sysc-dec.
def input parameter code as char.
def input parameter val as decimal.

    find sysc where sysc.sysc = code no-error.
    if avail sysc then sysc.deval = val.

end.

/* ---------------------------------------------------- */

procedure set-sysc-dat.
def input parameter code as char.
def input parameter val as date.

    find sysc where sysc.sysc = code no-error.
    if avail sysc then sysc.daval = val.

end.

/* ---------------------------------------------------- */

procedure set-sysc-cha.
def input parameter code as char.
def input parameter val as char.

    find sysc where sysc.sysc = code no-error.
    if avail sysc then sysc.chval = val.

end.

/* ---------------------------------------------------- */
