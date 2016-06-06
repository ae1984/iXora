/* h-vvgl.p
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
  h-vvgl.p
*/
{global.i}
{itemlist.i   &var = "def var vvgl like gl.gl."
	      &file = "gl"
	      &frame = "row 5 centered scroll 1 12 down overlay
			 title "" G/L CODE """
	      &where = "gl.subled eq ""LON"" and gl.level eq 1"
	      &flddisp = "gl.gl gl.des gl.subled gl.grp"
	      &chkey = "gl"
	      &chtype = "integer"
	      &index  = "gl"
	      &funadd = "if frame-value = "" "" then
			 do:
			     {imesg.i 9205}.
			     pause 1.
			     next.
			 end."
			     }
