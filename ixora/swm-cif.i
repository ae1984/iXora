/* swm-cif.i
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

/* KOVAL Поиск CIF */

def var lscif as logical init false.

if not lscif then do:
	find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
	if avail aaa then do:
		lscif = true.
		scif = aaa.cif.
	end.
end.

if not lscif then do:
	find first arp where arp.arp = remtrz.dracc no-lock no-error.
	if avail arp then do:
		lscif = true.
		scif = arp.cif.
	end.
end.

if not lscif then do:
	find first lon where lon.lon = remtrz.dracc no-lock no-error.
	if avail lon then do:
		lscif = true.
		scif = lon.cif.
	end.
end.

if not lscif then scif = ?.
