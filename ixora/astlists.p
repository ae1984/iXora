/* astlists.p
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

/* astlists.p
*/

{mainhead.i FRBO}  /* PRINT FIXED ASSET LIST */

def var vdt as date.
def var vmo as int.
def var vdp  as dec decimals 2.
def var vast as cha format "x(10)" label "ASSET CODE".
def var vcont as cha format "x(8)" label "CONTROL#".
def var vamt like ast.crline label "INIT-COST".
def var vbook like ast.crline label "BOOK VALUE".
def var vdepy as int format "z9" label "DEPR YR".
def var vdepa like ast.crline label "DEPR AMOUNT".
def var vexpa like ast.crline label "YTD DEPR".
def var vrem like ast.crline label "REMAIN VALUE".
def var vins as cha format "x(10)" label "INSTALL PL".
def var vasof as date label "AS-OF".
def var tast as int format ">>,>>9" label "# ITEMS".
def var tamt like ast.crline label "AMOUNT".
def var tbook like ast.crline label "BOOK VALUE".
def var tdepa like ast.crline label "DEPR AMOUNT".
def var texpa like ast.crline label "YTD DEPR".
def var trem like ast.crline label "REMAIN VALUE".
def var vcrc like crc.code label "CURRENCY".
def var inc  as int format "z9" label "##".

vasof = g-today.
{image1.i rpt.img}

update vasof with side-label centered frame asof.

{image2.i}
{report1.i 63}

find first cmp no-lock.
vtitle = "DETAIL LIST OF FIXED ASSETS (BRANCH NO:" + string(cmp.code) + " "
       + cmp.name + ") AS-OF " + string(vasof).

for each crc where crc.sts ne 9 break by crc.crc:

  vtitle = "PROOF SHEET FOR LOAN INTEREST AS OF " + string(g-today).

  {report2.i 132}

  find first ast where ast.crc eq crc.crc no-lock no-error.
  if not available ast then  next.

  tast = 0. tamt = 0. tbook = 0.
  tdepa = 0. texpa = 0. trem = 0.

  if first-of(crc.crc) then do:
    if not first(crc.crc) then page.
    display skip(1)
	    "[ CURRENCY - "  + crc.des  + " ]"  format "x(45)" skip
	    with no-label no-box page-top frame crc.
  end.

  for each ast  where ast.crc eq crc.crc by ast.ofc:

     if ast.ldd eq ? then vdt = ast.rdt.
     else vdt = ast.ldd.
     vmo = (year(vasof + 1) * 12 + month(vasof + 1))
	   - (year(vdt) * 12 + month(vdt)).
     vdp = (ast.icost - ast.salv) / ast.noy * vmo / 12.
     if vdp gt ast.dam[1] - ast.salv - ast.cam[1]
	 then vdp = ast.dam[1] - ast.salv - ast.cam[1].
     /*
	vamt = ast.dam[1].
     */

     vamt  = ast.icost.
     vbook = ast.dam[1] - ast.cam[1].
     if ast.ldd = ? then vdepy = 0.
     else vdepy = year(ast.ldd) - year(ast.rdt) + 1.
     vdepa = vamt - vbook.
     vexpa = vdp.
     vrem = vbook - vexpa.
     tast = tast + 1.
     tamt = tamt + vamt.
     tbook = tbook + vbook.
     tdepa = tdepa + vdepa.
     texpa = texpa + vexpa.
     trem = trem + vrem.
     vcrc = crc.code.

     display ast.fag ast.ofc /* ast.cont   */
	     /* officer field replaced control # field by mkkim */
	     ast.ast ast.name ast.crc ast.rdt label "PUR-DATE"
	     ast.qty vamt vbook skip space(46)
	     ast.noy vdepa vexpa vrem vins
	     with width 132 down frame ast.
  end. /* for each ast */

  display tast tamt vcrc tbook
	  tdepa texpa trem
	  with  1 col frame ttl.
end. /* for each crc */
{report3.i}
{image3.i}
