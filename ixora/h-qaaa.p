/* h-qaaa.p
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

/* h-qaaa.p
*/
{global.i}
def shared var vled like led.led .
def var vlgr as char format "x(3)" extent 70.
def var xint as int.
xint = 1.
find first lgr where lgr.led eq vled.
vlgr[1] = lgr.lgr.
find last lgr where lgr.led eq vled.
vlgr[2] = lgr.lgr.


{itemlist.i
       &file = "aaa"
       &start = "def var vname like aaa.name.
		      {imesg.i 2813}
			  update vname."
       &where = "aaa.name begins vname and
     (  aaa.lgr ge vlgr[1] and aaa.lgr le vlgr[2] )"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &findadd = "find lgr where lgr.lgr = aaa.lgr no-lock."
       &flddisp = "aaa.aaa aaa.name aaa.cif lgr.led lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "lgr"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
