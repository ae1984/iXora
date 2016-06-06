/* pkdeffio.p
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

/* pkdeffio.p ПотрекбКредиты
   замена казахских букв для фамилий и имен на РУССКИЕ

   Создан:  28.05.2003 Надежда Лысковская

*/

{global.i}
{pk.i}
   

def input-output parameter p-name as char.


/* 
   БУКВА          КОД АКИ      ЦИФРА    РУССКАЯ ЗАМЕНА

   А казахское    168            1           А
   I              170            2           И
   Н с хвостиком  182            3           Н
   Г с чертой     166            4           Г
   У мягкое       172            5           У
   У твердое      174            6           У
   К с хвостиком  164            7           К
   О с чертой     176            8           О
   Х казахское    180            9           Х
*/


define variable v-kazletters as char init "1,2,3,4,5,6,7,8,9".
define variable v-kazreplace as char extent 9 init ["А","И","Н","Г","У","У","К","О","Х"].
define variable i as integer.
define variable n as integer.


do i = 1 to length(p-name):
  n = lookup(substr(p-name, i, 1), v-kazletters).
  if n > 0 then substr(p-name, i, 1) = v-kazreplace[n].
end.

