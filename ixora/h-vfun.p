/* h-vfun.p
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

/* h-fun.p */

{proghead.i "FUND HELP FUNCTION"}

{itemlist.i &start = " "
	    &file = "fun"
	    &where = "fun.fun begins ""onf"" and fun.who eq userid('bank') and
		      fun.sts ne 2"
	    &frame = "row 3 centered scroll 1 15 down overlay
		      title "" FUND - LIST """
	    &flddisp = "fun.fun fun.bank
			fun.cam[1]
			label ""AVAILABLE"" fun.rdt label ""VAL DATE""
			fun.duedt fun.intrate"
	    &chkey = "fun"
	    &chtype = "string"
	    &index  = "fun"
	    &funadd = "if frame-value = "" "" then
			   do:
			      {imesg.i 9205}.
			      pause 1.
			      next.
			   end."
			   }
