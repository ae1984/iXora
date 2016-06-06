/* h-lsgl.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

def shared var g-lang as char.
def var ii as inte initial 1.
def shared var v-fexc like fexp.fex.
def temp-table vgl
    field vgl as inte.
def var vgldes as char.


find first fexp where fexp.fex EQ v-fexc no-lock no-error.
if fexp.fmarg GT 0.0 then
   find sysc where sysc.sysc = "SELIGD" no-lock.
else
   find sysc where sysc.sysc = "SELLGD" no-lock.
repeat:
  if entry(ii,sysc.chval) = "" then leave.
  create vgl.
  vgl.vgl = integer(entry(ii,sysc.chval)).
  ii = ii + 1.
end.

{jabre.i
&head = "vgl"
&headkey = "vgl"
&where = "true"
&formname = "h-comgl"
&framename = "h-comgl"
&addcon = "false"
&deletecon = "false"
&predisplay = "vgldes = ''.
	       find gl where gl.gl = vgl.vgl no-error.
	       if available gl then vgldes = gl.des."
&display = "vgl.vgl vgldes"
&highlight = "vgl.vgl vgldes"
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
		 frame-value = vgl.vgl.
		 hide frame h-comgl.
		 return.
	    end."
}
