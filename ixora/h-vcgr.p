/* h-vcgr.p
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

{global.i}
{itemlist.i   &file = "cgr"
	      &where = "true"
	      &frame = "row 3 centered scroll 1 15 down overlay no-label
			 title "" Customer Group """
	      &flddisp = "cgr.cgr cgr.name"
	      &chkey = "cgr"
	      &chtype = "integer"
	      &index  = "cgr"
	      &funadd = "if frame-value = "" "" then
			 do:
			     {imesg.i 9205}.
			     pause 1.
			     next.
			 end."
			     }
