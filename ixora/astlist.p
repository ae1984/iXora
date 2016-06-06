/* astlist.p
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

/* astlist.p
*/

{proghead.i "PRINT FIXED ASSET LIST"}

def var vdt as date.
def var vmo as int.
def var vdp  as dec decimals 2.
def var vast as cha format "x(10)" label "ASSET CODE".
def var vcont as cha format "x(8)" label "CONTROL#".
def var vamt like ast.crline label "AMOUNT".
def var vbook like ast.crline  label "BOOK VALUE".
def var vdepy as int format "z9" label "DEPR YR".
def var vdepa like ast.crline label "DEPR AMOUNT".
def var vexpa like ast.crline label "YTD DEPR".
def var vrem like ast.crline label "REMAIN VALUE".
def var vins as cha format "x(10)" label "INSTALL PL".

def var tast as int format ">>,>>9" label "# ITEMS".
def var tamt like ast.crline label "AMOUNT".
def var tbook like ast.crline label "BOOK VALUE".
def var tdepa like ast.crline label "DEPR AMOUNT".
def var texpa like ast.crline label "YTD DEPR".
def var trem like ast.crline label "REMAIN VALUE".

def var inc  as int format "z9" label "##".

{image1.i rpt.img}
{image2.i}

{report1.i 63}
find first cmp.
vtitle =
"DETAIL LIST OF FIXED ASSETS " + "(" + cmp.name + ")  AS-OF "
  + string(g-today).

for each ast:
  {report2.i 132}

  if ast.ldd eq ?
    then vdt = ast.rdt.
    else vdt = ast.ldd.
  vmo = (year(g-today) * 12 + month(g-today))
      - (year(vdt) * 12 + month(vdt)).
  vdp = (ast.dam[1] - ast.salv) / ast.noy * vmo / 12.
  if vdp gt ast.dam[1] - ast.salv - ast.cam[1]
    then vdp = ast.dam[1] - ast.salv - ast.cam[1].

  repeat inc = 1 to ast.qty:
    if inc eq truncate(ast.qty,0)
      then vamt = ast.dam[1] - round(ast.dam[1] / truncate(ast.qty,0),2)
		* (truncate(ast.qty,0) - 1).
      else vamt = ast.dam[1] / truncate(ast.qty,0).
    if inc eq truncate(ast.qty,0)
      then vbook = (ast.dam[1] - ast.cam[1])
		 - round((ast.dam[1] - ast.cam[1]) / truncate(ast.qty,0),2)
		* (truncate(ast.qty,0) - 1).
      else vbook = (ast.dam[1] - ast.cam[1]) / truncate(ast.qty,0).
    if ast.ldd = ?
      then vdepy = 0.
      else vdepy = year(ast.ldd) - year(ast.rdt) + 1.
    vdepa = vamt - vbook.
    if inc = truncate(ast.qty,0)
      then vexpa = vdp - round(vdp / truncate(ast.qty,0),2)
		  * (truncate(ast.qty,0) - 1).
      else vexpa = vdp / truncate(ast.qty,0).

    vrem = vbook - vexpa.

    tast = tast + 1.
    tamt = tamt + vamt.
    tbook = tbook + vbook.
    tdepa = tdepa + vdepa.
    texpa = texpa + vexpa.
    trem = trem + vrem.
    display vast vcont
	    ast.ast inc
	    ast.name
	    ast.rdt label "PUR-DATE"
	    vamt
	    vbook
	    ast.noy skip
	    space(52)
	    vdepa
	    vexpa
	    vrem
	    vins
	    with width 132 down frame ast.
  end.
end.
display tast tamt tbook tdepa texpa trem
       with 1 col frame ttl.
{report3.i}
{image3.i}
