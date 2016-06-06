/* h-vlon.p
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
  h-lon.p
*/
{global.i}
{itemlist.i   &var = "def var vlon like lon.lon."
	      &updvar = "{imesg.i 3807} update vlon."
	      &file = "lon"
	      &frame = "row 5 centered scroll 1 12 down overlay
			 title "" COMMERCIAL LOAN LIST """
	      &where = "lon.lon ge vlon"
	      &flddisp = "lon.lon lon.cif lon.rdt lon.dam[1] label ""DEBIT""
			  lon.cam[1] label ""CREDIT"""
	      &chkey = "lon"
	      &chtype = "string"
	      &index  = "lon"
	      &funadd = "if frame-value = "" "" then
			 do:
			     {imesg.i 9205}.
			     pause 1.
			     next.
			 end."
			     }
