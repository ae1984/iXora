/* file-ext.i
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

/* file-ext.i
   identical to xas001.i
   separate file body and file extention from full file name
   {1} = variable character

   1. Define variables in your procedures.
      vfilebody vfileext
   2. length
      body = upto 8 characters from the first
      ext  = upto 3 characters after period
*/

if index({1}, ".") = 0 then do:
  vfilebody = {1}.
  vfileext = "".
end.
else do:
  vfilebody = substring({1}, 1, index({1}, ".") - 1).
  vfileext = substring({1}, index({1}, ".") + 1).
end.
