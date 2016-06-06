﻿/* h-led.p
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

/* h-led.p
*/
{global.i}
{itemlist.i
       &var  = " "
       &updvar  = " "
       &where = "true"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &index = "led"
       &chkey = "led"
       &chtype = "string"
       &file = "led"
       &flddisp = "led.led led.des"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }