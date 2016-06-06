/* convgl.i
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Реализация библиотеки функций для работы со счетами конвертации
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
        30/10/2012 madiyar
 * CHANGES
*/

/* Возвращает правильный счет конвертации для указанной валюты и стороны операции */
function getConvGL returns integer (p-crc as integer, p-dc as char).
    def var v-gl as integer no-undo.
    v-gl = 0.
    p-dc = caps(p-dc).
    find first {1}.crc where {1}.crc.crc = p-crc no-lock no-error.
    if avail {1}.crc then do:
        if p-crc = 1 then do:
            if p-dc = "D" then v-gl = 185900.
            else
            if p-dc = "C" then v-gl = 285900.
        end.
        else do:
            if p-dc = "D" then v-gl = 185800.
            else
            if p-dc = "C" then v-gl = 285800.
        end.
    end.
    return v-gl.
end.

/* Определить принадлежность счета ГК к счетам конвертации */
function isConvGL returns logical (p-gl as integer).
    def var v-res as logical no-undo.
    v-res = (p-gl = 185800) or (p-gl = 185900) or (p-gl = 285800) or (p-gl = 285900).
    return v-res.
end.

/* Определить принадлежность счета ГК к счетам конвертации в тенге */
function isConvKztGL returns logical (p-gl as integer).
    def var v-res as logical no-undo.
    v-res = (p-gl = 185900) or (p-gl = 285900).
    return v-res.
end.

/* Определить принадлежность счета ГК к счетам конвертации в валюте */
function isConvValGL returns logical (p-gl as integer).
    def var v-res as logical no-undo.
    v-res = (p-gl = 185800) or (p-gl = 285800).
    return v-res.
end.
