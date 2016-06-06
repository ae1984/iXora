/* h-glacr.p
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
   h-glacr.p
*/
{global.i}
{itemlist.i
 &file = "gl"
 &start  = " {h-gl.h} "
 &where = "gl.des matches vdes and gl.sts <> 9"
 &frame = "row 5 centered scroll 1 12 down overlay "
 &flddisp = "gl.gl gl.des gl.subled gl.level"
 &chkey = "gl"
 &chtype = "integer"
 &index  = "gl"
 &funadd = "if frame-value = "" "" then do:
	      {imesg.i 9205}.
	      pause 1.
	      next.
	    end."
}
