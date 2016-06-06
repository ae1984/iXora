/* h-arptype.p
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

/* h-arptype.p
*/
{global.i}
{itemlist.i
       &file = "arptype"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "true"
       &flddisp = "arptype.arptype format 'zzz' arptype.des format 'x(50)'"
       &chkey = "arptype"
       &chtype = "integer"
       &index  = "arptype"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
