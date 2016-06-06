/* get-kod.i
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

/* --------------------------------------- */
/* 09.02.2003 by Sasco - получение КОД/КБе */
/* Параметры - указать все, что известно,  */
/* если не известно, то просто кавычки     */
/*                                         */
/* порядок: счет AAA, номер CIF            */
/* --------------------------------------- */

/* Вернуть /юр(2)-физ(1)-лицо/ + /сектор экономики/  */
function get-kod returns char (vaaa as char, vcif as char).
    def var vfiz as char.
    def var vsek as char.
    
    find first cif where cif.cif = vcif no-lock no-error.
    if not avail cif and vaaa <> "" then do:
       find aaa where aaa.aaa = vaaa no-lock no-error.
       if not avail aaa then return ?.
       find cif where cif.cif = aaa.cif no-lock no-error.
       if not avail cif then return ?.
    end.

    find first sub-cod where sub-cod.sub = "cln" and 
                             sub-cod.acc = cif.cif and 
                             sub-cod.d-cod = "secek" 
                             no-lock no-error.
    if not avail sub-cod then return ?.
    vsek = sub-cod.ccode.

    find first sub-cod where sub-cod.sub = "cln" and 
                             sub-cod.acc = cif.cif and 
                             sub-cod.d-cod = "clnsts" 
                             no-lock no-error.
    if not avail sub-cod then return ?.
    vfiz = (if sub-cod.ccode = "1" then "1" else "2").

    return vfiz + vsek.
end function.



/* Вернуть /резиденство/ + /сектор экономики/  */
function get-kodkbe returns char (vaaa as char, vcif as char).
    
    find first cif where cif.cif = vcif no-lock no-error.
    if not avail cif and vaaa <> "" then do:
       find aaa where aaa.aaa = vaaa no-lock no-error.
       if not avail aaa then return ?.
       find cif where cif.cif = aaa.cif no-lock no-error.
       if not avail cif then return ?.
    end.

    find first sub-cod where sub-cod.sub = "cln" and 
                             sub-cod.acc = cif.cif and 
                             sub-cod.d-cod = "secek" 
                             no-lock no-error.
    if not avail sub-cod then return ?.
    return substr (cif.geo, 3, 1) + trim(sub-cod.ccode).

end function.

