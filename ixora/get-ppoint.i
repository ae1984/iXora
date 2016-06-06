/* get-ppoint.i
 * MODULE
        PRAGMA
 * DESCRIPTION
        Получение названия подразделения (РКО) по его номеру
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
        06/04/05 sasco
 * CHANGES
*/

function get-ppoint returns char ( dpt as int ).
    find ppoint where ppoint.point = 1 and ppoint.depart = dpt no-lock no-error.
    if not avail ppoint then return ?.
                        else return trim(ppoint.name).
end.
    
