/* h-typeps.p
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

/* h-pid.p */
{global.i}
define var vselect as cha format "x".
define var vgrp like bill.itype format "x(7)".

  do:
       {itemlist.i
	&var = "def var vnum like ptyp.ptype."
	&where = "true"
	&frame = "row 2 centered scroll 1 15 down overlay top-only"
	&index = "ptype"
	&predisp =" "
	&chkey = "ptype"
	&chtype = "string"
	&file = "ptyp"
	&flddisp = "ptyp"
	&funadd = "if frame-value = "" ""
		     then do:
			  bell.
			  {imesg.i 9206}.
			  pause 1.
			  next.
		   end."
	&set = "d"
       }
end.
