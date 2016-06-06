/* h-s-cbank.p
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

/* h-s-cbank.p
*/
 def var vname like bank.name form "x(35)".

 {global.i}
 {itemlist.i
   &defvar  = " "
   &updvar  = " "
   &start = " {imesg.i 9823} update vname.
	      vname = ""*"" + vname + ""*""".
   &where = "true and bank.name matches vname"
   &frame = "row 5 centered scroll 1 12 down overlay"
   &index = "bank"
   &chkey = "bank"
   &chtype = "string"
   &file = "bank"
   &flddisp = "bank.bank label ""CODE""
	       bank.name format ""x(40)"" bank.lne bank.chipno bank.frbno"
   &findadd =  " "
   &funadd = "if frame-value = "" "" then do:
		{imesg.i 9205}.
		pause 1.
		next.
	      end." }
