/* h-vofc.p
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

/* h-ofc.p
*/
  {global.i}
  def var vkey as cha form "x(16)".
  def var vcnt as int.
  bell.
  {mesg.i 0951} update vkey.
  if keyfunction(lastkey) = "go"
  then do:
  {itemlisy.i &where = "ofc.name begins vkey {&extra} "
	      &file = "ofc"
	      &frame = "row 3 centered scroll 1 15 down overlay
			title "" Officer Code List "" +
			"" ("" + userid('bank') + "") """
	      &flddisp = "ofc.ofc ofc.name ofc.regno ofc.tit"
	      &chkey = "ofc"
	      &chtype = "string"
	      &index  = "ofc"
	      &funadd = "
			     {imesg.i 9205}.
			     pause 1.
			     next.
			 "
			     }
  end.
  else do:
  {itemlisy.i
	&where = "ofc.ofc ge vkey"
	&file = "ofc"
	&frame = "row 3 centered scroll 1 15 down overlay
		  title "" Officer Code List "" + "" ("" + userid('bank') + "") """
	&flddisp = "ofc.ofc ofc.name ofc.regno ofc.tit"
	&chkey = "ofc"
	&chtype = "string"
	&index  = "ofc"      /* &file */
	&funadd = "
		   {imesg.i 9205}.
		   pause 1.
		   next.
		  "
		}
 end.
