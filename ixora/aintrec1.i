/* aintrec1.i
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


	 if invsec.icalbase eq "1" then
	   vaintrec = invsec.par * invsec.coupon
	   * (g-today - invsec.sdt) / 100
	   / (date(1,1,year(g-today)) - date(12,31,year(g-today))).
	 if invsec.icalbase eq "2" then do:
	   vaintrec = invsec.par * invsec.coupon * 30 / 36000.
	   /*
	   invsec.lacrdt = date(month(g-today),1,year(g-today)) - 1.
	    */
	 end.
	 if invsec.icalbase eq "3" then do:
	   if invsec.stype eq "TBILL" or
	      invsec.stype eq "BAR" or
	      invsec.stype eq "CP" then
	      vaintrec = invsec.par * invsec.coupon
	      * (g-today - invsec.sdt) / 36000.
	   else
	      vaintrec = invsec.par * invsec.coupon
	      * (g-today - invsec.sdt) / 36000.
	 end.
	 if invsec.icalbase eq "4" then
	   vaintrec = invsec.par * invsec.coupon
	   * (g-today - invsec.sdt) / 36800.
	 if invsec.icalbase eq "5" then
	   vaintrec = invsec.par * invsec.coupon
	   * (g-today - invsec.sdt) / 36500.
