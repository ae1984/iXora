/* x-jlchk.i
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

/* x-jlchk.i
		       2. protect subledger creation with blank cif
*/

def var newacc as log initial false.
vans = false.

if gl.subled eq "ast"
  then do:
    find ast where ast.ast eq jl.acc no-lock no-error.
    if not available ast
      then do:
	if gl.level = 1
	  then do:
	    vans = no.
	    bell.
	    {mesg.i 9803} update vans.
	    if not vans then undo, retry.
	    run new-ast.
	    find ast where ast.ast eq jl.acc no-lock no-error.

	    vpart = false.
	    vcarry = -1 *  ast.icost.
	    newacc = false.
	  end.
	  else do:
	    bell.
	    {mesg.i 9203}.
	    undo, retry.
	  end.
      end. /* if not available ast */
      else if jl.crc ne ast.crc
	      or (gl.level eq 1 and jl.gl ne ast.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne ast.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	     undo, retry.
	   end.
      else do: /* if available ast */
	{mesg.i 1809} ast.dam[1] - ast.cam[1].
	vpart = true.
      end.
  end.

else if gl.subled eq "bill"
  then do:
    find bill where bill.bill eq jl.acc no-lock no-error.
    if not available bill and gl.level ne 1
      then do:
	bell.
	{mesg.i 9201}.
	undo, retry.
      end.
    else if not available bill
      then do:
	vans = no.
	bell.
	{mesg.i 9804} update vans.
	if not vans then undo, retry.
	g-cif = jh.cif.
	run new-bill.
	g-cif = "".
	find bill where bill.bill eq jl.acc no-lock no-error.
	vpart = false.
	vcarry = - bill.payment.
	newacc = false.
      end.

    else if  jl.crc ne bill.crc
	    or  (gl.level eq 1 and jl.gl ne bill.gl)
	    or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne bill.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	     undo, retry.
	   end.
    else if jh.cif ne "" and jh.cif ne bill.cif
      then do:
	bell.
	{mesg.i 6803}.
	undo, retry.
      end.
    else do:
      vpart = true.
      if gl.level = 1
	then vcarry = - bill.dam[1] + bill.cam[1].
      else if gl.level = 2
	then vcarry = bill.cam[2] - bill.interest.
    end.
      if bill.grp eq 1
	then jl.rem[1] = bill.lcno + "/"
		     + bill.refno.
	else jl.rem[1] =  bill.lcno + " "
		     + "DUE:" + string(bill.duedt) + " "
		     + string(bill.trm) + "D "
		     + string(bill.intrate) + "% " + bill.refno.
  end.
else if gl.subled eq "cif"
  then do:
    find aaa where aaa.aaa eq jl.acc no-lock no-error.
    if not available aaa
      then do:
	bell.
	{mesg.i 8800}.
	undo, retry.
      end.
    else if aaa.sta eq "C" then do:
      bell.
      {mesg.i 6207}.
      pause 4.
      undo, retry.
    end.
    else if  jl.crc ne aaa.crc
	      or (gl.level eq 1 and jl.gl ne aaa.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne aaa.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	     undo, retry.
	   end.
    else if jh.cif ne "" and jh.cif ne aaa.cif
      then do:
	bell.
	{mesg.i 6803}.
	undo, retry.
      end.
    else do:
      find cif of aaa.
      {mesg.i 0826} aaa.cr[1] - aaa.dr[1] .
      vpart = true.
    end.
end.
else if gl.subled eq "dfb"
  then do:
    find dfb where dfb.dfb eq jl.acc no-lock no-error.
    if not available dfb
      then do:
	bell.
	{mesg.i 8800}.
	undo, retry.
      end.

    else if   jl.crc ne dfb.crc
	      or (gl.level eq 1 and jl.gl ne dfb.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne dfb.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	     undo, retry.
	   end.
    else do:
      message dfb.name.
      vpart = true.
    end.
  end.
else if gl.subled eq "eps"
  then do:
    find eps where eps.eps eq jl.acc no-lock no-error.
    if not available eps
      then do:
	bell.
	{mesg.i 8800}.
	undo, retry.
      end.
    else if   jl.crc ne eps.crc
	      or (gl.level eq 1 and jl.gl ne eps.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne eps.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	     undo, retry.
	   end.
    else do:
      message eps.des. /* "Dr-Cr:" eps.dam[1] "-" eps.cam[1]. */
      vpart = false.
      run epsvou.
      pause 0.
      {x-jlvf.i}
      find last epsrec where epsrec.jh eq jl.jh and
	epsrec.eps eq jl.acc no-error.
      if available epsrec then do:
	find eps where eps.eps eq epsrec.eps.
	vcarry = - epsrec.amt.
	jl.rem[1] = epsrec.rem[1].
	jl.rem[2] = epsrec.rem[2].
	jl.rem[3] = epsrec.rem[3].
	jl.rem[4] = epsrec.rem[4].
	jl.rem[5] = epsrec.rem[5].
	end.
      else undo, retry.
    end.
  end.
else if gl.subled eq "fun"
  then do:
    find fun where fun.fun eq jl.acc no-lock no-error.
    if not available fun and gl.level ne 1
      then do:
	bell.
	{mesg.i 9201}.
	undo, retry.
      end.
    else if not available fun
      then do:
	vans = no.
	bell.
	{mesg.i 9807} update vans.
	if not vans then undo, retry.
	g-cif = jh.cif.
	run new-fun.
	g-cif = "".
	find fun where fun.fun eq jl.acc no-lock no-error.
	if gl.type eq "A"
	  then vcarry = - fun.amt.
	  else vcarry = fun.amt.
	vpart = false.
      end.

      else if jl.crc ne fun.crc
	      or (gl.level eq 1 and jl.gl ne fun.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne fun.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	     undo, retry.
	   end.
    else do:
      vpart = true.
      if gl.level = 1
	then do:
	  vpart = false.
	  vcarry =   fun.dam[1] - fun.cam[1].
	end.
      else if gl.level = 2
      then do:
	if gl.type eq "R"
	  then vcarry = fun.cam[2] - fun.dam[2] - fun.interest.
	  else vcarry = fun.cam[2] - fun.dam[2] + fun.interest.
      end.
    end.
      if fun.grp le 10
	 then jl.rem[1] = fun.bank + " "
			+ "DUE:" + string(fun.duedt) + " "
			+ string(fun.trm) + "D "
			+ string(fun.intrate) + "% ".
  end.
/*
else if gl.subled eq "iof"
  then do:
    find iof where iof.iof eq jl.acc no-lock no-error.
    if not available iof
      then do:
	bell.
	{mesg.i 8800}.
	undo, retry.
      end.
    message iof.name /* "Dr-Cr:" iof.dam[1] "-" iof.cam[1]. */
    vpart = true.
  end.
*/
else if gl.subled eq "lcr"
  then do:
    if vcif = "" then do:
    bell.
    {mesg.i 2209}.
    undo,retry.
    end.
    find lcr where lcr.lcr eq jl.acc no-lock no-error.
    if not available lcr and gl.level ne 1
      then do:
	bell.
	{mesg.i 9201}.
	undo, retry.
      end.
    else if not available lcr
	then do:
	  {mesg.i 4801} update vans.
	  if not vans then undo, retry.
	  g-cif = jh.cif.
	  run new-lcr.
	  g-cif = "".
	  {x-jlvf.i} /* view frame */
	  find lcr where lcr.lcr eq jl.acc no-lock no-error.
	  if not available lcr then do:
	  bell.
	  undo,retry .
	 end.
    end.

    else if   jl.crc ne lcr.crc
	      or  (gl.level eq 1 and jl.gl ne lcr.gl)
	      or ((gl.level eq 2 and gl.gl1 ne 0 or
		   gl.level eq 3 and gl.gl1 ne 0)
	      and gl.gl1 ne lcr.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	     undo, retry.
	   end.
    else if jh.cif ne "" and jh.cif ne lcr.cif
      then do:
	bell.
	{mesg.i 6803}.
	undo, retry.
    end.
    else do:
      {mesg.i 1809} lcr.dam[1] - lcr.cam[1] .
      vpart = true.
    end.
 end.
else if gl.subled eq "lon"
  then do:
    if vcif = "" then do:
    bell.
    {mesg.i 2209}.
    undo,retry.
    end.
    find lon where lon.lon eq jl.acc no-lock no-error.
    if not available lon
      then do:
	if gl.level = 1
	  then do:
	    vans = no.
	    bell. bell.
	    {mesg.i 3803} update vans.
	    if not vans then undo, retry.
	    run new-lon.
	    find lon where lon.lon eq jl.acc no-lock no-error.
	vpart = false.
	vcarry = - lon.opnamt.
	end.
	else do:
	  bell. bell.
	  {mesg.i 9203}.
	  undo, retry.
	end.
    end.  /* if not available */

    else if   jl.crc ne lon.crc
	      or (gl.level eq 1 and jl.gl ne lon.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne lon.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	     undo, retry.
	   end.
    else if jh.cif ne "" and jh.cif ne lon.cif
      then do:
	bell.
	{mesg.i 6803}.
	undo, retry.
      end.
    else do:
      {mesg.i 1809} lon.dam[1] - lon.cam[1] .
      vpart = true.
    /* vcarry = lon.dam[1] - lon.cam[1]. */
    end.
      jl.rem[1] = "L/C#" + lon.lcr
		+ " RATE:" + lon.base + "+" + string(lon.prem)
		+ " DUE:" + string(lon.duedt).
  end.
else if gl.subled eq "ock"
  then do:
    find ock where ock.ock eq jl.acc no-lock no-error.

    if not available ock
      then do:
	if gl.level = 1
	  then do:
	    vans = no.
	    bell.
	    {mesg.i 9810} update vans.
	    if not vans then undo, retry.
	    run new-ock.
	    find ock where ock.ock eq jl.acc no-lock no-error.
	    vpart = false.
	    vcarry = -1 * ock.amt.
	    newacc = false.
	 end.

	 else do: bell. bell.
	   {mesg.i 9203} " INVALID NUMBER...".
	   undo, retry.
	 end.   /* if gl.level ne 1 */

      vpart = false.
      vcarry = ock.amt.
      jl.rem[1] = ock.ref.
    end.  /* if not available ock */

    else do:
      if ock.spflag eq true
	then do:
	  bell.
	  {mesg.i 8820}.
	  undo, retry.
      end.
      vpart = false.
      vcarry = ock.dam[1] - ock.cam[1].
    end.
  end.

else if gl.subled eq "arp"
  then do:
    find arp where arp.arp eq jl.acc no-lock no-error.
    if not available arp and gl.level ne 1
      then do:
	bell.
	{mesg.i 9201}.
	undo, retry.
      end.
    else if not available arp
      then do:
	vans = no.
	bell.
	{mesg.i 9807} update vans.
	if not vans then undo, retry.
	g-cif = jh.cif.
	run new-arp.
	g-cif = "".
	find arp where arp.arp eq jl.acc no-lock no-error.
	if gl.type eq "A"
	  then vcarry = arp.cam[1] - arp.dam[1].
	  else vcarry = arp.dam[1] - arp.cam[1].
	vpart = false.
      end.

      else if jl.crc ne arp.crc
	      or (gl.level eq 1 and jl.gl ne arp.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	     undo, retry.
	   end.
    else do:
      vpart = true.
      if gl.level = 1
	then do:
	  vpart = false.
	  vcarry =   arp.dam[1] - arp.cam[1].
	end.
    end.
  end.
