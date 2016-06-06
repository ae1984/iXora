/* h-optlang.p
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

/* h-optlang.p */
{global.i}
{itemlist.i
       &defvar  = " "
       &where = "optlang.lang eq g-lang"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &form = "optlang.optmenu optlang.ln optlang.des optlang.menu"
       &index = "optlang"
       &chkey = "optmenu"
       &chtype = "string"
       &file = "optlang"
       &flddisp = "optlang.optmenu optlang.ln optlang.des optlang.menu"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
