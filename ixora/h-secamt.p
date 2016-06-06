/* h-secamt.p
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

{h-secamt.f}.

find first lonsec1 where lonsec1.lon = s-lon and lonsec1.ln = m-ln.
repeat:
   display lonsec1.prm
	   lonsec1.vieta
	   lonsec1.novert
	   lonsec1.proc
	   lonsec1.secamt
	   lonsec1.apdr
	   with frame colla.
   update  lonsec1.prm
	   lonsec1.vieta
	   lonsec1.novert
	   lonsec1.proc go-on("PF4")
	   with frame colla.
   if lonsec1.proc < 0 or lonsec1.proc > 100
   then undo,retry.
   leave.
end.
if lonsec1.proc > 0 and lonsec1.novert > 0
then lonsec1.secamt = lonsec1.proc * lonsec1.novert / 100.
display lonsec1.secamt with frame colla.
update
      lonsec1.apdr   go-on("PF4")
      with frame colla.
if frame colla lonsec1.prm    entered or
   frame colla lonsec1.vieta  entered or
   frame colla lonsec1.novert entered or
   frame colla lonsec1.proc   entered or
   frame colla lonsec1.apdr   entered
then do:
     lonsec1.who = userid("bank").
     lonsec1.whn = g-today.
end.
hide frame colla.
readkey pause 0.
