/* h-vjh.p
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
  h-vjh.p
*/
{proghead.i}
{itemlist.i
	      &var  = "def var vtoday as date."
	      &updvar  = "{imesg.i 0994} update vtoday."
	      &file = "jh"
	      &frame = "row 5 centered scroll 1 12 down overlay
			 title "" TRANSACTION CODE """
	      &where = "jh.jh ne ? and jh.who eq g-ofc "
	      &flddisp = "jh.jh jh.jdt jh.who"
	      &chkey = "jh"
	      &chtype = "integer"
	      &index  = "jh"
	      &funadd = "if frame-value = "" "" then
			 do:
			     {imesg.i 9205}.
			     pause 1.
			     next.
			 end."
			     }
