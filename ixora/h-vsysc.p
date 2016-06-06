/* h-vsysc.p
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
  h-vsysc.p
*/
{global.i}
{itemlist.i   &var = "def shared var vsysc like sysc.sysc."
	      &updvar = "{imesg.i 0851} update vsysc."
	      &file = "sysc"
	      &frame = "row 5 centered scroll 1 3 down overlay
			 title "" SYSTEM CODE """
	      &where = "sysc.sysc begins vsysc"
	      &flddisp = "sysc.sysc sysc.des sysc.chval sysc.inval sysc.deval"
	      &chkey = "sysc"
	      &chtype = "string"
	      &index  = "sysc"
	      &funadd = "if frame-value = "" "" then
			 do:
			     {imesg.i 9205}.
			     pause 1.
			     next.
			 end."
			     }
