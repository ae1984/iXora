/* h-vdep1.p
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

/* help for departments  */

{global.i}
def shared var vpoint1 like ppoint.point .


  {itemlist.i
	 &where = "ppoint.point = vpoint1 and ppoint.depart > 0"
	 &file = "ppoint"
	 &frame = "row 5 centered scroll 1 12 down overlay "
	 &flddisp = "ppoint.depart ppoint.name "
	 &chkey = "depart"
	 &chtype = "integer"
	 &index  = "pdep"      /*       &file */
	 &funadd = "if frame-value = "" "" then do:
		      {imesg.i 9205}.
		      pause 1.
		      next.
		    end."
	 &set = "b"}
