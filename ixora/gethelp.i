/* gethelp.i
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

/* gethelp.i
   Get Data from Applhelp
   Ex) update field-list
       editing:
	 {gethelp.i}
       end.
*/

readkey.
if keyfunction(lastkey) eq "HELP"
  then run applhelp.
else
  apply lastkey.
/* view frame heading. */
