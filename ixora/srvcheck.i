/* srvcheck.i
 * MODULE
        Общего назначения
 * DESCRIPTION
        Функция для определения - программа запущена в боевой или тестовой среде
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
        BANK
 * CHANGES
        08.09.2012 k.gitalov заменил ixora01 на ixora601
*/

function isProductionServer returns logical.
    def var res as logical no-undo.
    res = no.
    def var v-text as char no-undo.
    input through "hostname | awk -F'.' '\{print $1\}'".
    repeat:
        import unformatted v-text.
        v-text = trim(v-text).
        if v-text <> '' then leave.
    end.
    if v-text = "ixora601" then res = yes.
    return res.
end function.

