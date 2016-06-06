/* h-psbank.p
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

/* h-bankl.p */

{global.i}

define variable qw as integer format "z".
/*
{proghead.i}

{mesg.i 0670} update qw .


	&defvar = "def var qw as integer format "z"."
*/
qw = 1.
if qw eq 1 then do:
    {itemlist.i
	&file = "bankl"
	&var = "def var vname1 like bankl.name."
	&start = "{imesg.i 9823} update vname1.
	    vname1 = ""*"" + trim( vname1 ) + ""*""".
	&where = "bankl.name matches vname1"
	&frame = "row 5 centered scroll 1 12 down overlay "
	&form = "bankl.bank bankl.name bankl.cbank"
	&index = "bank"
	&chkey = "bank"
	&chtype = "string"
	&flddisp = "bankl.bank bankl.name bankl.cbank"
	&funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end."
	&set = "1"}
	frame-value = frame-value.
   end.
