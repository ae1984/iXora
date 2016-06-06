/* n-msg.p
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

/* n-msg.p */

define shared variable s-lang like lang.lang.
define shared variable s-ln like msg.ln.

find last msg where msg.lang eq s-lang use-index msg no-lock no-error.
if available msg then s-ln = msg.ln + 1.
		 else s-ln = 1.
		 disp s-ln. pause.
