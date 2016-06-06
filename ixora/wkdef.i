/* wkdef.i
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

/* ================================================================
=								  =
=		WeekEnd & Holiday Selection 			  =
=								  =
================================================================ */


define {1} variable wkstrt as integer.
define {1} variable wkend  as integer.

if "{1}" = "new shared" then do:

find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc then wkstrt = sysc.inval.
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc then wkend = sysc.inval.

end.
