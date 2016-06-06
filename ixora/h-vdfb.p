/* h-vdfb.p
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
  h-vdfb.p
*/
{global.i}
{itemlist.i   &file = "dfb"
	      &frame = "row 5 centered scroll 1 12 down overlay
			 title "" DUE FROM BANK """
	      &where = "true"
	      &flddisp = "dfb.dfb dfb.name"
	      &chkey = "dfb"
	      &chtype = "string"
	      &index  = "dfb"
	      &funadd = "if frame-value = "" "" then
			 do:
			     {imesg.i 9205}.
			     pause 1.
			     next.
			 end."
			     }
