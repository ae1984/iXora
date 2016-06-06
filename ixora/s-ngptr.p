/* s-ngptr.p
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

/* s-ngptr.p
*/

{global.i}

define shared var s-bank like rpay.bank.
define shared var s-lcno like rpay.lcno.
define shared var s-ln like rpay.ln.

def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.

def var vacc like jl.acc.
def var vdbgl as int.
def var vipgl as int.
def var vocgl as int.
def var vcagl as int.
def var vcsgl as int.
def var vcrgl as int.
def var vln as int.
def var vcnsgl as int.
def var vcntgl as int.

find sysc where sysc.sysc eq "DBGL". vdbgl = sysc.inval.
find sysc where sysc.sysc eq "IPGL". vipgl = sysc.inval.
find sysc where sysc.sysc eq "OCGL". vocgl = sysc.inval.
find sysc where sysc.sysc eq "CAGL". vcagl = sysc.inval.
find sysc where sysc.sysc eq "CSGL". vcsgl = sysc.inval.
find sysc where sysc.sysc eq "CRGL". vcrgl = sysc.inval.
find sysc where sysc.sysc eq "CNSGL". vcnsgl = sysc.inval.
find sysc where sysc.sysc eq "CNTGL". vcntgl = sysc.inval.

find rpay where rpay.bank eq s-bank
	   and  rpay.lcno eq s-lcno
	   and  rpay.ln   eq s-ln.

find rim where rim.bank eq s-bank
	  and  rim.lcno eq s-lcno.

find bank where bank.bank eq s-bank.

run x-jhnew.

find jh where jh.jh = s-jh.
jh.cif = rim.cif.
jh.party = rim.party.
rpay.jh = jh.jh.

if rpay.ptype eq 1 or rpay.ptype eq 2
   or  rpay.ptype eq 4 or rpay.ptype eq 5 /* s/b and t/b both r/i and nego */
  then do:
    /*
    if rpay.ptype eq 1
      then do:
      */
	find gl where gl.gl eq rpay.gl.
	find nmbr where nmbr.code eq gl.code.
	{nmbr-acc.i nmbr.prefix
		    nmbr.nmbr
		    nmbr.fmt
		    nmbr.sufix}
	nmbr.nmbr = nmbr.nmbr + 1.
	create bill.
	bill.bill = vacc.
	rpay.bill = vacc.
	bill.rdt = rpay.pdt.
	bill.who = g-ofc.
	bill.gl = rpay.gl.
	bill.grp = gl.grp.
	bill.cif = rim.cif.
	bill.cst = rim.party.
	bill.payment = rpay.drft.
	bill.intrate = rpay.intrate.
	bill.orgdt = rpay.orgdt.
	bill.intdt = rpay.intdt.
	bill.duedt = rpay.duedt.
	bill.intdue = rpay.intdue.
	bill.trm = rpay.trm.
	bill.interest = rpay.interest.
	bill.itype = rpay.itype.
	bill.intdue = rpay.intdue.
	bill.bank = rpay.bank.
	bill.lcno = rpay.lcno.
	bill.dam[1] = rpay.drft.
	/* bill.refno */

    vln = 1.
    /* DRAFT */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = rpay.drft.
    jl.dc = "D".
    if rpay.ptype eq 1 or rpay.ptype eq 4     /* usance bill */
      then do:
	jl.gl = bill.gl.
	jl.acc = bill.bill.
	if bill.grp eq 1   /* at sight (conflict) ??? */
	  then jl.rem[1] = bill.bill + "/" + bill.lcno + "/"
			 + bill.refno.

	  else jl.rem[1] = bill.bill + "/"       /* ok */
			 + bill.lcno + " "
			 + "DUE:" + string(bill.duedt) + " "
			 + string(bill.trm) + "D "
			 + string(bill.intrate) + "% "
			 + string(bill.interest).
      end.
      else do:    /* at sight or advice */
	jl.gl = bank.gl.
	jl.acc = bank.bank.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (DRAFT)".
	find gl where gl.gl eq jl.gl.
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
      end.
    vln = vln + 1.

    /* FEE APPLICANT RCV */
    if rim.fee eq 2 and rpay.comm[1] + rpay.comm[2] +
       rpay.comm[4] + rpay.comm[5] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + "(TC:"
		  + string(rpay.comm[1]) + ")".
	jl.gl = bank.gl.
	jl.acc = bank.bank.
	jl.dam = rpay.comm[1] + rpay.comm[2] + rpay.comm[4]
	   + rpay.comm[5].
	jl.dc = "D".
	find gl where gl.gl eq jl.gl.
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	vln = vln + 1.
      end.

    /* FEE CONFIRM CHARGE APPLICANT RCV */
    else if rim.fee eq 3 and rpay.comm[1] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (THEIR CHG)".
	jl.gl = bank.gl.
	jl.acc = bank.bank.
	jl.dam = rpay.comm[1].
	jl.dc = "D".
	find gl where gl.gl eq jl.gl.
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	vln = vln + 1.
      end.

    /* PAYMENT */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = rpay.payamt.
    jl.dc = "C".
    jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (PAYMENT)".
	 if rpay.pacct eq 1 then do:
			      jl.gl = vipgl.
			    end.
    else if rpay.pacct eq 2 then do:
			      jl.gl = vdbgl.
			      jl.acc = rpay.acc.
			    end.
    else if rpay.pacct eq 3 then do:
			      jl.gl = vocgl.
			      jl.acc = rpay.acc.
			      find gl where gl.gl eq jl.gl.
			      if gl.subled eq "ock"
				then do:
				  create ock.
				  ock.ock = rpay.acc.
				  ock.rdt = rpay.pdt.
				  ock.dam[gl.level] = jl.dam.
				  ock.cam[gl.level] = jl.cam.
				end.
			    end.
    vln = vln + 1.
    /* OUR COMMISSION */
    if rpay.comm[2] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.cam = rpay.comm[2].
	jl.dc = "D".
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (OUR COMM)".

	if rpay.ptype eq 1 then jl.gl = vcrgl.
	else if rpay.ptype eq 2 then jl.gl = vcsgl.
	else if rpay.ptype eq 4 then jl.gl = vcntgl.
	else if rpay.ptype eq 5 then jl.gl = vcnsgl.
	/*
	if rim.grp eq 4
	then
	if rim.tennor eq 1 then   jl.gl = vcnsgl.
			   else   jl.gl = vcntgl.
	else
	if rim.tennor eq 1 then   jl.gl = vcsgl.
			   else   jl.gl = vcrgl.
	*/
	if rpay.ptype eq 1 or rpay.ptype eq 4
	  then do:
	    jl.acc = bill.bill.
	    find gl where gl.gl eq jl.gl.
	    if gl.subled eq "bill"
	      then do:
		find bill where bill.bill eq jl.acc no-error.
		bill.dam[gl.level] = bill.dam[gl.level] + jl.dam.
		bill.cam[gl.level] = bill.cam[gl.level] + jl.cam.
	      end.
	  end.
	vln = vln + 1.
      end.
    /* ISSUING BANK COMMISSION */
    if rpay.comm[3] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (ISSUE. BANK)".
	jl.gl = bank.gl.
	jl.acc = bank.bank.
	jl.cam = rpay.comm[3].
	jl.dc = "C".
	find gl where gl.gl eq jl.gl.
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	vln = vln + 1.
      end.

    /* ADVISE COMMISSION */
    if rpay.comm[4] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (ADVISE CHG)".
	jl.gl = vcagl.
	jl.acc = bill.bill.
	jl.cam = rpay.comm[4].
	jl.dc = "C".
	vln = vln + 1.
      end.
  /*
    /* OTHER COST */
    if rpay.comm[1] gt 0  and (rpay.ptype eq 4 or rpay.ptype eq 5)
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (OTHER-COST)".
	jl.gl = vcagl.
	jl.acc = bill.bill.
	jl.cam = rpay.comm[1].
	jl.dc = "C".
	vln = vln + 1.
      end.

    /* DISCREPANCY */
    if rpay.comm[5] gt 0  and (rpay.ptype eq 4 or rpay.ptype eq 5)
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (ADVISE CHG)".
	jl.gl = vcagl.
	jl.acc = bill.bill.
	jl.cam = rpay.comm[5].
	jl.dc = "C".
	vln = vln + 1.
      end.
   */
    /* DISCOUNT FEE */
    vln = 101.
    if rpay.trm gt 0 and rpay.itype eq "D"
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	if bill.grp eq 1
	  then jl.rem[1] = bill.bill + "/" + bill.lcno + "/"
			 + bill.refno.
	  else jl.rem[1] = bill.bill + "/"
			 + bill.lcno + " "
			 + "DUE:" + string(bill.duedt) + " "
			 + string(bill.trm) + "D "
			 + string(bill.intrate) + "% ".
	jl.gl = bank.gl.
	jl.acc = bank.bank.
	jl.dam = bill.interest.
	jl.dc = "D".
	find gl where gl.gl eq jl.gl.
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	vln = vln + 1.

	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	if bill.grp eq 1   /* sight bill */
	  then jl.rem[1] = bill.bill + "/" + bill.lcno + "/"
			 + bill.refno.
	  else jl.rem[1] = bill.bill + "/"
			 + bill.lcno + " "
			 + "DUE:" + string(bill.duedt) + " "
			 + string(bill.trm) + "D "
			 + string(bill.intrate) + "% ".
	find gl where gl.gl eq rpay.gl.
	jl.gl = gl.gl1.
	jl.acc = bill.bill.
	jl.cam = bill.interest.
	jl.dc = "C".
	find gl where gl.gl eq jl.gl.
	if gl.subled eq "bill"
	  then do:
	    find bill where bill.bill eq jl.acc no-error.
	    bill.dam[gl.level] = bill.dam[gl.level] + jl.dam.
	    bill.cam[gl.level] = bill.cam[gl.level] + jl.cam.
	  end.
	vln = vln + 1.
      end.
     end.

else if rpay.ptype eq 3 /* ADVISE FEE */
  then do:
  end.



  /*
  pause 0.
  {x-jllis.i}
  run x-jlgens.
  hide all.
  view frame heading.
  view frame cif.
  */
