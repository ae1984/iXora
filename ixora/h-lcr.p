﻿/* h-lcr.p
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

/* h-lcr.p
*/
{global.i}
{itemlist.i
       &updvar = "def var vlcr like lcr.lcr.
		  {imesg.i 4818} update vlcr."
       &file = "lcr"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "lcr.lcr ge vlcr"
       &flddisp = "lcr.lcr lcr.cif lcr.rdt lcr.dam[1] label ""DEBIT""
			  lcr.cam[1] label ""CREDIT"""
       &chkey = "lcr"
       &chtype = "string"
       &index  = "lcr"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }