/* h-lgr2.p
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
        25.02.04 nataly была добавлена кросс-конвертация из любой валюты в любую 
*/

/* h-lgr.p
*/
def  shared  var v-gl like gl.gl.
def  shared var val2 as integer.

{global.i}
{itemlist.i 
       &var  = " "
       &updvar  = " "
       &where = "substr(trim(lgr.des),1,3) ne 'n/a' and lgr.crc = val2 and (lgr.led = 'cda' or lgr.led = 'tda') and lgr.gl = v-gl"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &index = "lgr"
       &chkey = "lgr"
       &chtype = "string"
       &file = "lgr"
       &flddisp = "lgr.lgr lgr.led lgr.des format 'x(30)' lgr.gl lgr.nxt"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
