/* xas016.i
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

/* xas016.i
   check full 6 digits
   {1} = variable name
   {2} = undo label
*/

do vcnt = 1 to 6:
  if asc(substring({1},vcnt,1)) < 48 or
     asc(substring({1},vcnt,1)) > 57 then do:
     bell.
     message "You must enter full 6 digits, from 0 to 9.".
     undo {2}, retry.
   end.
end.
