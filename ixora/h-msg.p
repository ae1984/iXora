/* h-msg.p
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

/* h-msg.p */
{global.i}
{itemlist.i
       &updvar  = "def var vlang like msg.lang.
		   {imesg.i 1812} update vlang."
       &defvar  = " "
       &updvar  = " "
       &where = "msg.lang eq vlang"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &index = "msg"
       &chkey = "msg"
       &chtype = "string"
       &form = "msg.ln msg.msg"
       &flddisp = "msg.ln msg.msg"
       &file = "msg"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
