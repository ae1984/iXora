/* pk-sysc.i
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
        04/09/2007 madiyar - добавил чтение/запись логических значений
*/

/* ------------------------------------------------------- */
/* П О Л У Ч Е Н И Е    Т Е К У Щ И Х     З Н А Ч Е Н И Й  */
/* ------------------------------------------------------- */

function get-pksysc-int returns integer (code as char).
    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code no-lock no-error.
    if not avail pksysc then return ?. else return pksysc.inval.
end function.

/* ---------------------------------------------------- */

function get-pksysc-dec returns decimal (code as char).
    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code no-lock no-error.
    if not avail pksysc then return ?. else return pksysc.deval.
end function.

/* ---------------------------------------------------- */

function get-pksysc-dat returns date (code as char).
    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code no-lock no-error.
    if not avail pksysc then return ?. else return pksysc.daval.
end function.

/* ---------------------------------------------------- */

function get-pksysc-char returns char (code as char).
    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code no-lock no-error.
    if not avail pksysc then return ?. else return pksysc.chval.
end function.

/* ---------------------------------------------------- */

function get-pksysc-log returns logical (code as char).
    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code no-lock no-error.
    if not avail pksysc then return ?. else return pksysc.loval.
end function.

/* ---------------------------------------------------- */


/* ---------------------------------------------------- */
/* У С Т А Н О В К А    Н О В Ы Х    З Н А Ч Е Н И Й    */  
/* ---------------------------------------------------- */


procedure set-pksysc-int.
def input parameter code as char.
def input parameter val as integer.

    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code exclusive-lock no-error.
    if avail sysc then pksysc.inval = val.
    release pksysc.
end.

/* ---------------------------------------------------- */

procedure set-pksysc-dec.
def input parameter code as char.
def input parameter val as decimal.

    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code exclusive-lock no-error.
    if avail sysc then pksysc.deval = val.
    release pksysc.
end.

/* ---------------------------------------------------- */

procedure set-pksysc-dat.
def input parameter code as char.
def input parameter val as date.

    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code exclusive-lock no-error.
    if avail sysc then pksysc.daval = val.
    release pksysc.
end.

/* ---------------------------------------------------- */

procedure set-pksysc-char.
def input parameter code as char.
def input parameter val as char.

    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code exclusive-lock no-error.
    if avail sysc then pksysc.chval = val.
    release pksysc.
end.

/* ---------------------------------------------------- */

procedure set-pksysc-log.
def input parameter code as char.
def input parameter val as logical.

    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = code exclusive-lock no-error.
    if avail sysc then pksysc.loval = val.
    release pksysc.
end.

/* ---------------------------------------------------- */
