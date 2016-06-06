/* h-pri.p
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

/* h-pri.p */
{global.i}
{itemlist.i
       &defvar  = " "
       &updvar  = " "
       &where = "not pri.pri begins '^'"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &form = "pri.pri pri.name pri.rate pri.itype pri.penalty"
       &index = "pri"
       &chkey = "pri"
       &chtype = "string"
       &file = "pri"
       &flddisp = "pri.pri pri.name pri.rate pri.itype pri.penalty"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
