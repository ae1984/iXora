/* h-balaaa.p
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

{global.i}
def shared var bah like bah.bah.
find bah where bah.bah = bah no-lock.

{itemlist.i
       &file = "aaa"
       &start = "def var vname like aaa.name.
		{imesg.i 0856} update vname."
       &where = "aaa.name begins vname and aaa.crc = bah.crc"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &findadd = "find lgr where lgr.lgr = aaa.lgr no-lock."
       &flddisp = "aaa.aaa aaa.name aaa.cif lgr.led lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "name"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
