/* astcard.p
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

/* astcard.p
*/

{mainhead.i "FRCARD"}

def var vamt like ast.crline label "BALANCE ".
def var vmeth as cha format "x(30)" label "DEPR-METH".

{image1.i rpt.img}
{image2.i}

{report1.i 63}
vtitle = "FIXED ASSET CARD  AS-OF " + string(g-today).

for each ast:
  if ast.meth eq 1 then vmeth = "STRAIGHT LINE".
  else if ast.meth eq 2 then vmeth = "SUM OF THE YEARS DIGITS".
  else if ast.meth eq 3 then vmeth = "DOUBLE DECLINING".
  {report2.i 80}
  find gl where gl.gl eq ast.gl.
  display ast.ast
	  ast.crc
	  ast.fag
	  gl.sname label "TYPE"
	  ast.cont
	  ast.rdt
	  ast.name
	  ast.ofc
	  ast.dam[1] label "INITIAL COST"
	  ast.noy
	  ast.qty
	  ast.salv
	  ast.dam[1] - ast.cam[1]
	  format "z,zzz,zzz,zzz,zz9.99-" label "CURR.BAL"
	  vmeth
	  ast.mfc
	  ast.rem
	  with 1 col frame ast.
  vamt = 0.
  vamt = vamt + ast.dam[1].
  for each jl where jl.acc eq ast.ast and jl.gl eq gl.gl.
    find gl where gl.gl eq jl.gl.
    vamt = vamt + jl.dam - jl.cam.
    display jl.jdt gl.sname
	    jl.dam jl.cam vamt skip space(10)
	    jl.rem
      with no-label down frame jl.
  end.
  page.
end.
{report3.i}
{image3.i}
