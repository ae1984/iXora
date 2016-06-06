/* h-staaa.p
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

/* h-aaa.p
*/
{global.i}
{itemlist.i
       &file = "aaa"
       &start = "def var vname like aaa.name.
		      {imesg.i 2813}
			  update vname."
       &where = "aaa.name begins vname"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &findadd = "find lgr where lgr.lgr = aaa.lgr no-lock."
       &flddisp = "aaa.aaa aaa.name aaa.cif lgr.led lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "aaa"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
