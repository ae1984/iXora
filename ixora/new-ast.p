/* new-ast.p
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

/* new-ast.p
*/

def shared var s-acc like jl.acc.
def shared var s-gl  like gl.gl.
def shared var s-jh like jh.jh.
def shared var s-jl like jl.ln.
def var answer as log.
def shared var rtn as log initial yes.

{global.i}

find jh where jh.jh eq s-jh.
find jl where jl.jh eq jh.jh and jl.ln eq s-jl.
find gl where gl.gl eq s-gl.

do transaction on error undo,return :

create ast.
ast.who = g-ofc.
ast.ast = s-acc.
ast.rdt = g-today.
ast.gl = s-gl.
ast.crc = jl.crc.

	    /****
	    if gl.grp ne 0
	      then do:
		ast.grp = gl.grp.
		display ast.grp with frame ast.
	      end.
	      else update ast.grp with frame ast.
	      *****/

update ast.fag ast.rdt ast.name
    with centered row 4 1 col frame ast title " FIXED ASSET FILE ".

repeat:
    update ast.icost ast.salv label "DEPR.CHARGES" ast.amt[3] label "SALVAGE"
	with centered row 4 1 col frame ast title " FIXED ASSET FILE ".

	if ast.icost ne ast.salv + ast.amt[3] then do:
	    {mesg.i 255}.
	    next.
	end.
	else leave.
end.

update ast.qty ast.noy ast.mfc ast.rem
    with centered row 4 1 col frame ast title " FIXED ASSET FILE ".



update ast.cont label "KATEGORIJA" ast.ser label "KODS"
    ast.ref label "NOLIET. LIKME" ast.crline label "S…KOTN. VЁRT§BA"
    ast.ddt[1] label "GADS"
    with centered row 4 1 col frame ast title " FIXED ASSET FILE ".


end.
rtn = no.
