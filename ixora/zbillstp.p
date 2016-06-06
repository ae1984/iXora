/* zbillstp.p
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

/* checked */
/* zbillst.p */

output to printer page-size 60.

for each bill break by bill.grp:
  display bill.grp bill.bill bill.lcno bill.duedt
	  bill.dam[1](total by bill.grp)
	  bill.cam[1](total by bill.grp)
	  bill.intrate
	  with frame bill down width 132.
end.
