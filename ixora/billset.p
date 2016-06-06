/* billset.p
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

/*
for each bill where bill.itype eq "":
if bill.cam[2] eq 0 then bill.itype = "A".
else bill.itype = "D".
end.

for each bill where bill.interest eq 0 and bill.duedt - bill.rdt ne 0:
		bill.interest =
		bill.dam[1] * (bill.duedt - bill.rdt)
			      * bill.intrate / 36000.
end.

*/
