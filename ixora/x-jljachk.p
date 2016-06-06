/* x-jljachk.p
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

/* x-jljachk.p

   01-30-95 Sushinin Vladimir - check after run new-arp.
*/
{global.i}
{trxln.i}
def shared var s-jl like jl.ln.
def var vbal like jl.dam.
def var vcif like cif.cif.
def buffer xaaa for aaa.

find jl where jl.jh = s-jh and jl.ln = s-jl.
find gl of jl.
find jh of jl.
vcif = jh.cif.
if gl.subled eq "ast"
  then do:
    find ast where ast.ast eq jl.acc and ast.gl = jl.gl no-lock no-error.
    if not available ast then do:
	rcode = false.
	rdes = "AST subled. " + jl.acc + "not found. TRX line aborted.".
	return.
    end. /* if not available ast */
    if jl.crc ne ast.crc
	      or (gl.level eq 1 and jl.gl ne ast.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne ast.gl)
	   then do:
	    {rmsg.i 2208}
	    return.
    end.
    if jl.dc = "C" then do:
     if ast.dam[1] - ast.cam[1] - jl.cam < 0 then do:
      rcode = false.
      rdes = "AST subled. " + jl.acc + ". "
	   + "Not enough balance. TRX line aborted.".
      return.
     end.
    end.
end. /*ast*/

else if gl.subled eq "bill" then do:
  find bill where bill.bill eq jl.acc and bill.gl eq jl.gl no-lock no-error.
  if not available bill
      then do:
	rcode = false.
	rdes = "BIL subled. " + jl.acc + "not found. TRX line aborted.".
	return.
  end. /* if not available ast */
  else if jl.crc ne bill.crc
	    or  (gl.level eq 1 and jl.gl ne bill.gl)
	    or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne bill.gl)
	   then do:
	    {rmsg.i 2208}.
	    return.
	   end.
  else if jh.cif ne "" and jh.cif ne bill.cif
      then do:
	{rmsg.i 6803}.
        return.
  end.
  if bill.grp eq 1
	then jl.rem[1] = bill.lcno + "/"
		     + bill.refno.
	else jl.rem[1] =  bill.lcno + " "
		     + "DUE:" + string(bill.duedt) + " "
		     + string(bill.trm) + "D "
		     + string(bill.intrate) + "% " + bill.refno.
end. /*bil*/
else if gl.subled eq "cif"
  then do:
    find aaa where aaa.aaa eq jl.acc and aaa.gl eq jl.gl no-lock no-error.
    if not available aaa then do:
	rcode = false.
	rdes = "CIF subled. " + jl.acc + "not found. TRX line aborted.".
	return.
    end.
    else if aaa.sta eq "C" then do:
      {rmsg.i 6207}.
      return.
    end.
    else if  jl.crc ne aaa.crc
	      or (gl.level eq 1 and jl.gl ne aaa.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne aaa.gl)
	   then do:
	   {rmsg.i 2208}.
	    return.
    end.
    else if jh.cif ne "" and jh.cif ne aaa.cif
      then do:
	{rmsg.i 6803}.
	return.
    end.
    else if jl.dc = "D" then do:
      if aaa.craccnt ne "" then
	find first xaaa where xaaa.aaa = aaa.craccnt no-lock no-error .
      if available xaaa then
      vbal = aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal.
      else vbal = aaa.cr[1] - aaa.dr[1] - aaa.hbal.
      if vbal - jl.dam < 0 then do:
	rcode = false.
	rdes = "CIF subled. " + jl.acc
	     + " out of balance. TRX line aborted.".
	return.
      end.
    end.
end. /*CIF*/
else if gl.subled eq "dfb"
  then do:
    find dfb where dfb.dfb eq jl.acc and dfb.gl = jl.gl no-lock no-error.
    if not available dfb
      then do:
	rcode = false.
	rdes = "CIF subled. " + jl.acc + "not found. TRX line aborted.".
	return.
    end.
    else if   jl.crc ne dfb.crc
	      or (gl.level eq 1 and jl.gl ne dfb.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne dfb.gl)
	   then do:
	    {rmsg.i 2208}.
	    return.
    end.
end.
/*
else if gl.subled eq "eps"
  then do:
    find eps where eps.eps eq jl.acc and eps.gl = jl.gl no-lock no-error.
    if not available eps
      then do:
	bell.
	{mesg.i 8800}.
	    return.
      end.
    else if   jl.crc ne eps.crc
	      or (gl.level eq 1 and jl.gl ne eps.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne eps.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	    return.
	   end.
    else do:
      message eps.des. /* "Dr-Cr:" eps.dam[1] "-" eps.cam[1]. */
  /*    vpart = false.*/
    /*  run epsvou. */
      pause 100.
      {x-jlvf.i}

      /*
      31/01/95 svl

      find last epsrec where epsrec.jh eq jl.jh and
	epsrec.eps eq jl.acc no-error.
      if available epsrec then do:
	find eps where eps.eps eq epsrec.eps.
/*      vcarry = - epsrec.amt.
*/      jl.rem[1] = epsrec.rem[1].
	jl.rem[2] = epsrec.rem[2].
	jl.rem[3] = epsrec.rem[3].
	jl.rem[4] = epsrec.rem[4].
	jl.rem[5] = epsrec.rem[5].
	end.
      else undo, retry.
      */
    end.
  end.
else if gl.subled eq "fun"
  then do:
    find fun where fun.fun eq jl.acc and fun.gl = jl.gl no-lock no-error.
    if not available fun and gl.level ne 1
      then do:
	bell.
	{mesg.i 9201}.
	    return.
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
/*      if gl.type eq "A"
	  then vcarry = - fun.amt.
	  else vcarry = fun.amt.
	vpart = false.
	end.
*/
      /*else*/ if jl.crc ne fun.crc
	      or (gl.level eq 1 and jl.gl ne fun.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne fun.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	    return.
	   end.
    else do:
/*      vpart = true.*/
      if gl.level = 1
	then do:
/*        vpart = false.
	  vcarry =   fun.dam[1] - fun.cam[1].
*/      end.
      else if gl.level = 2
      then do:
/*      if gl.type eq "R"
	  then vcarry = fun.cam[2] - fun.dam[2] - fun.interest.
	  else vcarry = fun.cam[2] - fun.dam[2] + fun.interest.
*/    end.
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
	    return.
    end.
    find lcr where lcr.lcr eq jl.acc and lcr.gl = jl.gl no-lock no-error.
    if not available lcr and gl.level ne 1
      then do:
	bell.
	{mesg.i 9201}.
	    return.
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
	    return.
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
	    return.
	   end.
    else if jh.cif ne "" and jh.cif ne lcr.cif
      then do:
	bell.
	{mesg.i 6803}.
	    return.
    end.
    else do:
      {mesg.i 1809} lcr.dam[1] - lcr.cam[1] .
/*      vpart = true.*/
    end.
 end.
else if gl.subled eq "lon"
  then do:
/* if vcif = "" then do:
    bell.
    {mesg.i 2209}.
	    return.
    end.               */
    find lon where lon.lon eq jl.acc and lon.gl = jl.gl no-lock no-error.
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
/*          vpart = false.
	    vcarry = - lon.opnamt.
*/      end.
	else do:
	find lon where lon.lon eq jl.acc no-lock no-error.
	find gl where gl.gl = lon.gl no-lock.
       if ( jl.gl ne gl.gl1 ) or ( jl.crc ne lon.crc ) then do:
	  bell. bell.
	  {mesg.i 9203}.
	    return.
	end.
      end.
    end.  /* if not available */

    else if   jl.crc ne lon.crc
	      or (gl.level eq 1 and jl.gl ne lon.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne lon.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	    return.
	   end.
    else if jh.cif ne "" and jh.cif ne lon.cif
      then do:
	bell.
	{mesg.i 6803}.
	    return.
      end.
    else do:
      {mesg.i 1809} lon.dam[1] - lon.cam[1] .
/*    vpart = true.
     vcarry = lon.dam[1] - lon.cam[1]. */
    end.
      jl.rem[1] = "L/C#" + lon.lcr
		+ " RATE:" + lon.base + "+" + string(lon.prem)
		+ " DUE:" + string(lon.duedt).
  end.
else if gl.subled eq "ock"
  then do:
    find ock where ock.ock eq jl.acc and ock.gl = jl.gl no-lock no-error.

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
/*          vpart = false.
	    vcarry = -1 * ock.amt.
*/          newacc = false.
	 end.

	 else do: bell. bell.
	   {mesg.i 9203} " INVALID NUMBER...".
	    return.
	 end.   /* if gl.level ne 1 */

  /*    vpart = false.
      vcarry = ock.amt.
  */    jl.rem[1] = ock.ref.
    end.  /* if not available ock */

    else do:

       if jl.crc ne ock.crc
	      or (gl.level eq 1 and jl.gl ne ock.gl)
	      or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne ock.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	    return.
	   end.
      else do: /* if available ock */


	if ock.spflag eq true
	    then do:
		bell.
		{mesg.i 8820}.
		return.
	    end.
/*      vpart = false.
	vcarry = ock.dam[1] - ock.cam[1].
*/      end.
    end.
  end.

else if gl.subled eq "arp"
  then do:
    find arp where arp.arp eq jl.acc and arp.gl = jl.gl no-lock no-error.
    if not available arp and gl.level ne 1
      then do:
	bell.
	{mesg.i 9201}.
	    return.
      end.
    else if not available arp
      then do:
	vans = no.
	bell.
	{mesg.i 1808} update vans.
	if not vans then undo,retry.
	g-cif = jh.cif.
	run new-arp.
	g-cif = "".
	find arp where arp.arp eq jl.acc no-lock no-error.
/*      if gl.type eq "A"
	  then vcarry = arp.cam[1] - arp.dam[1].
	  else vcarry = arp.dam[1] - arp.cam[1].
	vpart = false.
	end.
*/
     /* else*/  if jl.crc ne arp.crc
	      or (gl.level eq 1 and jl.gl ne arp.gl)
	   then do:
	     bell.
	     {mesg.i 2208}.
	    return.
	   end.
    else do:
/*      vpart = true.
*/      if gl.level = 1
	then do:
/*        vpart = false.
	  vcarry =   arp.dam[1] - arp.cam[1]. */
	end.
    end.
  end.
*/
rcode = true.
return.
