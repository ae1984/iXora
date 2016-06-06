/* aaastset.p
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

/* aaastset.p
   Account Statement Set
*/

def var vbal as dec decimals 2 format "zzzz,zzz,zzz.99- ".
def var fdt as date.
def var tdt as date.
def var vday as int format "zz9".
def var vasof as date label "AS-OF".
{proghead.i "ACCOUNT STATEMENT SET"}

do on error undo, retry:
  update vasof with frame q row 7 centered 2 col no-box.
end.

for each aaa where aaa.pass eq "" and aaa.sta ne "C"
   ,each lgr of aaa where lgr.led eq "DDA" or lgr.led eq "SAV":

  fdt = aaa.stmdt + 1.
  tdt = vasof.
  vday = tdt - fdt + 1.
  if fdt gt tdt then next.

  vbal = aaa.stmgbal.
  for each jl where jl.acc eq aaa.aaa
	       and  jl.jdt ge fdt
	       and  jl.jdt le tdt
	      use-index acc
     ,each gl where gl.gl eq jl.gl and gl.subled eq "cif" and gl.level eq 1
	      by jl.jdt by jl.jh:
    vbal = vbal + jl.cam - jl.dam.
  end.
  if vbal ne aaa.cr[1] - aaa.dr[1]
    then do:
      bell.
      {mesg.i 1001}.
      undo, retry.
    end.
  aaa.lstmgbal = aaa.stmgbal.
  aaa.lstmcbal = aaa.stmcbal.
  aaa.lstmavg = aaa.mtdacc / vday.
  aaa.lstmavl = aaa.mtdavl / vday.
  aaa.stmgbal = vbal.
  aaa.stmcbal = aaa.cbal.
  aaa.stmdt = tdt.
  aaa.mtdacc = 0.
  aaa.mtdavl = 0.
end.
