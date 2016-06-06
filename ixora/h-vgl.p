/* h-vgl.p
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

/* h-vgl.p
*/


{global.i}
{itemlist.i   &file = "gl"
	      &start  = "def var vdes like gl.des.
		  update  {h-vgl.h} vdes
		/*  help ""WILD CHARACTERS : * MULTI . SINGLE"" */
		  with no-box no-label row 3 frame opt.

		  vdes = ""*"" + vdes + ""*""."
	      &where = "gl.des matches vdes and gl.sts <> 9"
	      &frame = "{h-vglfrm.f}"
	      &flddisp = "gl.gl gl.des gl.subled"
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
