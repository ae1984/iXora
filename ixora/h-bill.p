/* h-bill.p
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

/* h-bill.p
*/

{global.i}
{itemlist.i
       &file = "bill"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "bill.grp ge 2 and  bill.duedt ge g-today
			       and bill.dam[1] gt bill.cam[1]"
       &flddisp = "bill.bill bill.grp bill.gl
		   bill.dam[1] - bill.cam[1] format ""z,zzz,zzz,zz9.99-""
				     label ""balance"""
       &chkey = "bill"
       &chtype = "string"
       &index  = "bill"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
