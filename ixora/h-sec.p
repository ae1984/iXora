﻿/* h-sec.p
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

/* h-sec.p */
{global.i}
{itemlist.i
       &defvar  = " "
       &updvar  = " "
       &where = "true"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &form = "sec.ofc sec.fname"
       &index = "ofcfname"
       &chkey = "ofc"
       &chtype = "string"
       &file = "sec"
       &flddisp = "sec.ofc sec.fname"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
