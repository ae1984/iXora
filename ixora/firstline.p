/* firstline.p
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

def shared var g-ofc as char.

FUNCTION FirstLine RETURNS char ( input nLine as decimal, input nLen as decimal ).
DEF VAR cLine AS CHAR.

    find first cmp no-lock no-error.
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    IF nLine = 1 
    THEN 
        cLine = string( today, "99/99/9999" ) + ", " +
        string( time, "HH:MM:SS" ) + ", " + 
        trim( cmp.name ).
    ELSE 
        cLine = "Исполнитель: " + ofc.name.
    RETURN cLine. 
    
END FUNCTION.
/***/
