/* h-aas.p
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

/* h-aas.p */
{global.i}
{itemlist.i
	 &updvar  = "def var vaaa like aaa.aaa.
		     {imesg.i 1812} update vaaa."
	 &where = "aas.aaa eq vaaa"
	 &frame = "row 5 centered scroll 1 12 down overlay "
	 &index = "aaaln"
	 &chkey = "aaa"
	 &chtype = "string"
	 &file = "aas"
	 &flddisp = "aas.aaa aas.chkno aas.chkamt aas.chkdt aas.sic"
	 &funadd = "if frame-value = "" "" then do:
		      {imesg.i 9205}.
		      pause 1.
		      next.
		    end."}
