/* adrfmtlo.i
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

/* adrfmtlo.i
   Local Address Setup
*/

define var {1} as char format "x(35)" extent 5.

{1}[1] = {2}name.
{1}[2] = {2}addr[1].

if {2}addr[2] = "" then do:
  {1}[3] = {2}city + " " + {2}state + " " + string({2}zip,"99999-xxxx").
  {1}[4] = "".
end.
else do:
  {1}[3] = {2}addr[2].
  {1}[4] = {2}city + " " + {2}state + " " + string({2}zip,"99999-xxxx").
end.
