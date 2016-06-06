/* apterm.i
 * MODULE
        Платежи Авангард-Плат
 * DESCRIPTION
        Функции для инициализации аутентификационной информации по Авангард-Плат
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
        13/10/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

function getTermId returns integer (input scode as char).
    def var res as integer no-undo.
    res = 0.
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = scode no-lock no-error.
    if avail pksysc then res = truncate(pksysc.deval,0).
    return res.
end function.

function getUserId returns integer (input scode as char).
    def var res as integer no-undo.
    res = 0.
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = scode no-lock no-error.
    if avail pksysc then res = pksysc.inval.
    return res.
end function.

function getPass returns char (input scode as char).
    def var res as char no-undo.
    res = ''.
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = scode no-lock no-error.
    if avail pksysc then res = pksysc.chval.
    return res.
end function.

function isTermAccessible returns logi (input scode as char).
    def var res as logi no-undo.
    res = no.
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = scode no-lock no-error.
    if avail pksysc then res = pksysc.loval.
    return res.
end function.

