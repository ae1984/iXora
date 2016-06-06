/* xas017.i
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

/* xas017.i
   encryption
   {1} = variable to be encrypted
   {2} = variable encrypted result
*/

venctab[1] = "%". venctab[2] = "h". venctab[3] = "=". venctab[4] = "k".
venctab[5] = "@". venctab[6] = ")". venctab[7] = "r". venctab[8] = "4".
venctab[9] = "!". venctab[10] = "_". venctab[11] = "c". venctab[12] = "+".
venctab[13] = "s". venctab[14] = "^". venctab[15] = "|".

{2} = "".
do vcnt = 1 to 6:
  {2} = {2} + venctab[integer(substring({1}, vcnt, 1)) + vcnt].
end.
