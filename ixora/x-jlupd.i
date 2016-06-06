/* x-jlupd.i
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

/* x-jlupd.i
*/

if gl.subled eq "ast"
  then do:
    find ast where ast.ast eq jl.acc no-error.
    ast.dam[gl.level] = ast.dam[gl.level] {1} jl.dam.
    ast.cam[gl.level] = ast.cam[gl.level] {1} jl.cam.
    release ast.
  end.

else if gl.subled eq "bill"
  then do:
    find bill where bill.bill eq jl.acc no-error.
    bill.dam[gl.level] = bill.dam[gl.level] {1} jl.dam.
    bill.cam[gl.level] = bill.cam[gl.level] {1} jl.cam.
    release bill.
  end.

else if gl.subled eq "cif"
  then do:
    find aaa where aaa.aaa eq jl.acc no-error.
    aaa.dr[gl.level] = aaa.dr[gl.level] {1} jl.dam.
    aaa.cr[gl.level] = aaa.cr[gl.level] {1} jl.cam.
    aaa.cbal = aaa.cbal {1} (jl.cam - jl.dam).
    /* if gl.level = 1 then aaa.cbal = aaa.cbal + jl.cam. */
    /*
    if gl.level eq 1 and aaa.cr[1] - aaa.dr[1] lt 0
      then do:
	bell.
	{mesg.i 0888}.
	pause 2.
	undo, retry.
      end.
    */
    release aaa.
  end.

/* DISABLED FOR BATCH PROCESSING by SIMON Y. KIM
else if gl.subled eq "dfb"
  then do:
    find dfb where dfb.dfb eq jl.acc no-error.
    dfb.dam[gl.level] = dfb.dam[gl.level] {1} jl.dam.
    dfb.cam[gl.level] = dfb.cam[gl.level] {1} jl.cam.
  end.
*/

else if gl.subled eq "eck"
  then do:
    find eck where eck.eck eq jl.acc no-error.
    eck.dam[gl.level] = eck.dam[gl.level] {1} jl.dam.
    eck.cam[gl.level] = eck.cam[gl.level] {1} jl.cam.
    release eck.
  end.

else if gl.subled eq "eps"
  then do:
    find eps where eps.eps eq jl.acc no-error.
    eps.dam[gl.level] = eps.dam[gl.level] {1} jl.dam.
    eps.cam[gl.level] = eps.cam[gl.level] {1} jl.cam.
    release eps.
  end.

else if gl.subled eq "fun"
  then do:
    find fun where fun.fun eq jl.acc no-error.
    fun.dam[gl.level] = fun.dam[gl.level] {1} jl.dam.
    fun.cam[gl.level] = fun.cam[gl.level] {1} jl.cam.
    release fun.
  end.

else if gl.subled eq "iof"
  then do:
    find iof where iof.iof eq jl.acc no-error.
    iof.dam[gl.level] = iof.dam[gl.level] {1} jl.dam.
    iof.cam[gl.level] = iof.cam[gl.level] {1} jl.cam.
    release iof.
  end.

else if gl.subled eq "lcr"
  then do:
    find lcr where lcr.lcr eq jl.acc no-error.
    lcr.dam[gl.level] = lcr.dam[gl.level] {1} jl.dam.
    lcr.cam[gl.level] = lcr.cam[gl.level] {1} jl.cam.
    release lcr.
  end.

else if gl.subled eq "lon"
  then do:
    find lon where lon.lon eq jl.acc no-error.
    lon.dam[gl.level] = lon.dam[gl.level] {1} jl.dam.
    lon.cam[gl.level] = lon.cam[gl.level] {1} jl.cam.
    release lon.
  end.

else if gl.subled eq "ock"
  then do:
    find ock where ock.ock eq jl.acc no-error.
    ock.dam[gl.level] = ock.dam[gl.level] {1} jl.dam.
    ock.cam[gl.level] = ock.cam[gl.level] {1} jl.cam.
    release ock.
  end.
