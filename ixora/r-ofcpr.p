/* r-ofcpr.p
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

/* 4.12.01 /sasco/ - настройка принтера для офицеров */


define shared var vofc like ofc.ofc.
define shared var stype as logical format "1/0".
define shared var ptype as logical format "1/0".

define frame setup
             "Офицер     :" vofc skip
             "_______________________________"    skip(1)   
             "Вид печати  1 - лента       :" stype 
             help " Введите данные. F4 - отмена. F1 - закончить" skip
             "            0 - страница     "       skip
             "Печатать    1 - с пробелами :" ptype 
              help " Введите данные. F4 - отмена. F1 - закончить" skip
             "            0 - без пробелов "       skip
             with centered row 2 no-label
             title "Настройки принтера".


/* ----------------------------------------------   M A I N    P A R T  --- */

   find first ofc where ofc.ofc = vofc no-lock.
   stype = yes.
   ptype = yes.
   if ofc.mday[1] = 1 then stype = yes.
                      else stype = no.
   if ofc.mday[2] = 1 then ptype = yes.
                      else ptype = no.
   displ vofc stype ptype with frame setup.
   
   update stype with frame setup.
   update ptype with frame setup.

   hide frame setup.
