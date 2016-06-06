/* image3.i
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

/* image3.i
   image file handling part 3
   5.22.87  created by yong k. yoon
   1. Include this file at the end of your procedure.
   2. Refer to image1.i ans image2.i.

   02-03-88 modified yong k. yoon
   11-11-88 revised by Simon Y. Kim
   12-07-88 revised by Simon Y. Kim
*/

define buffer cdser for sysc.

define var size as int format ">>>>>>>>>".

if vprint then do:
  if g-batch eq false then do:
    hide message no-pause.
    {mesg.i 0903}.
  end.
  if      opsys = "msdos" then
    dos silent value(dest) value(vimgfname).
  else if opsys = "unix" then do:
    unix silent value(dest) value(vimgfname).
  end.
end. /* vprint */

if g-cdlib then do transaction:
  create cdlib.
  find cdser where cdser.sysc eq "CDSER".
  find sysc where sysc.sysc eq "CDLIB".
  if sysc.daval ne g-today then do:
    sysc.daval = g-today.
    sysc.inval = 1.
  end.
  else sysc.inval = sysc.inval + 1.
  cdlib.cdlib = integer(substring(string(g-today),7,2) +
			substring(string(g-today),1,2) +
			substring(string(g-today),4,2) +
			string(sysc.inval,"999")).
  cdlib.gdt = g-today.
  cdlib.who = g-ofc.
  cdlib.ttl = g-mdes.
  cdlib.cd = cdser.inval.
  cdlib.dest = dest.
  unix silent cp value(vimgfname) value(sysc.chval + "/" + string(cdlib.cdlib)).
end.
pause 0.
