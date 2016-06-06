/* h-sysc.p
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

/* h-sysc.p */
{global.i}
{itemlist.i
       &defvar  = " "
       &updvar  = " "
       &where = "true"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &form = "sysc.sysc sysc.des form ""x(25)"" sysc.inval
		sysc.chval form ""x(19)"" sysc.loval sysc.daval"
       &index = "sysc"
       &chkey = "sysc"
       &chtype = "string"
       &file = "sysc"
       &flddisp = "sysc.sysc sysc.des sysc.inval sysc.chval sysc.loval
		   sysc.daval"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
