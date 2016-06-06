/* v-cps-get.i
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


function v-cps-get char (

    input src as char,
    input acode as char,
    input idx as int,
    input defval as char).

/* If acode is not found within src defval will be returned */

def var cpos as int no-undo.

    acode = '/' + acode + '/'.
    cpos  = 0.
    repeat while idx > 0:
       cpos = index( src, acode, cpos + 1 ).
       if cpos = 0 then leave.
       idx = idx - 1.
    end.
    if cpos = 0 then return defval.
    cpos    = cpos + length( acode ).
    idx     = index( src, '/', cpos ).
    if idx  = 0 then
    return substr( src, cpos ).
    return substr( src, cpos, idx - cpos ).

end function.

/***/