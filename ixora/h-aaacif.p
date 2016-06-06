/* h-aaacif.p
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

/* h-aaacif.p */
{global.i}
def shared var s-cif like cif.cif.

{itemlist.i
       &file = "aaa"
       &start = " "
       &where = "aaa.cif eq s-cif"
       &frame = "row 5 centered scroll 1 12 down overlay  "
       &flddisp = "aaa.aaa lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "name"
       &findadd = "find lgr where lgr.lgr eq aaa.lgr."
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
