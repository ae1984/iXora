/* s-rimptr.p
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

/* s-rimptr.p
*/

{global.i}

define buffer b-rpay for rpay.

define shared var s-bank like rpay.bank.
define shared var s-lcno like rpay.lcno.

def shared var s-jh  like jh.jh.
def shared var s-consol like jh.consol initial false.

def shared var s-ptype    like rpay.ptype.
def shared var s-ps       like rpay.ps.
def shared var s-gl       like rpay.gl.
def shared var s-orgamt   like rpay.orgamt.
def shared var s-drft     like rpay.drft.
def shared var s-comm     like rpay.comm.
def shared var s-payamt   like rpay.payamt.
def shared var s-pacct    like rpay.pacct.
def shared var s-acc      like rpay.acc.
def shared var s-pdt      like rpay.pdt.
def shared var s-orgdt    like rpay.orgdt.
def shared var s-duedt    like rpay.duedt.
def shared var s-intdt    like rpay.intdt.
def shared var s-trm      like rpay.trm.
def shared var s-intdue   like rpay.intdue.
def shared var s-intrate  like rpay.intrate.
def shared var s-interest like rpay.interest.
def shared var s-itype    like rpay.itype.
def shared var s-cbank    like rpay.cbank.
def shared var s-cbname   like rpay.cbname.
def shared var s-crbank   like rpay.crbank.
def shared var s-acct     like rpay.acct.
def shared var s-tref     like rpay.tref.
def shared var s-rem      like rpay.rem.
def shared var s-bill     like rpay.bill.

def var vacc like jl.acc.
def var vdbgl as int.
def var vipgl as int.
def var vocgl as int.
def var vcagl as int.
def var vcsgl as int.
def var vcrgl as int.
def var vcigl as int.
def var vln as int.
def var vcashgl as int.

find sysc where sysc.sysc eq "DBGL". vdbgl = sysc.inval.
find sysc where sysc.sysc eq "IPGL". vipgl = sysc.inval.
find sysc where sysc.sysc eq "OCGL". vocgl = sysc.inval.
find sysc where sysc.sysc eq "CAGL". vcagl = sysc.inval.
find sysc where sysc.sysc eq "CSGL". vcsgl = sysc.inval.
find sysc where sysc.sysc eq "CRGL". vcrgl = sysc.inval.
find sysc where sysc.sysc eq "CIGL". vcigl = sysc.inval.
find sysc where sysc.sysc eq "CASHGL". vcashgl = sysc.inval.

find rim where rim.bank eq s-bank
	  and  rim.lcno eq s-lcno.

create rpay.
rpay.bank = rim.bank.
rpay.lcno = rim.lcno.
rpay.crc  = rim.crc.
find last b-rpay where b-rpay.bank eq rim.bank
		  and  b-rpay.lcno eq rim.lcno no-error.
if available b-rpay then rpay.ln = b-rpay.ln + 1.
		    else rpay.ln = 1.
rpay.ptype = s-ptype.
rpay.comm[4] = s-comm[4].
rpay.ps = s-ps.
rpay.gl = s-gl.
rpay.comm[2] = s-comm[2].
rpay.orgamt = s-orgamt.
rpay.drft = s-drft.
rpay.comm[1] = s-comm[1].
rpay.comm[2] = s-comm[2].
rpay.comm[3] = s-comm[3].
rpay.payamt = s-payamt.
rpay.pacct = s-pacct.
rpay.acc = s-acc.
rpay.pdt = s-pdt.
rpay.orgdt = s-orgdt.
rpay.trm = s-trm.
rpay.duedt = s-duedt.
rpay.intdue = s-intdue.
rpay.intdt = s-intdt.
rpay.intrate = s-intrate.
rpay.interest = s-interest.
rpay.itype = s-itype.
rpay.cbank = s-cbank.
rpay.cbname = s-cbname.
rpay.crbank = s-crbank.
rpay.acct = s-acct.
rpay.tref = s-tref.
rpay.rem = s-rem.

rim.amt[2] = rim.amt[2] + rpay.orgamt.
rim.amt[4] = rim.amt[4] - rpay.comm[4].

find bank where bank.bank eq rpay.bank.

run x-jhnew.
find jh where jh.jh = s-jh.
jh.cif = rim.cif.
jh.crc = rim.crc.
jh.party = rim.party.
rpay.jh = jh.jh.

if rpay.ptype eq 1 or rpay.ptype eq 2 /* usance or sight*/
  then do:
    if rpay.ptype eq 1   /* if usance */
      then do:
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
	s-bill = rpay.bill.
	bill.rdt = rpay.pdt.
	bill.who = g-ofc.
	bill.gl = rpay.gl.
	bill.crc = rpay.crc.
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
      end.

    else if rpay.ptype eq 2        /* if sight */
      then do:
	find nmbr where nmbr.code eq "PO".
	{nmbr-acc.i nmbr.prefix
		    nmbr.nmbr
		    nmbr.fmt
		    nmbr.sufix}
	nmbr.nmbr = nmbr.nmbr + 1.
	rpay.bill = vacc.       /* no bill only rpay record creation */
	s-bill = rpay.bill.
      end.
    vln = 1.

    /* DRAFT */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.crc = jh.crc.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = rpay.drft.
    jl.dc = "D".
    if rpay.ptype eq 1       /* if usance */
      then do:
	jl.gl = bill.gl.
	jl.acc = bill.bill.
	if bill.grp eq 1         /* if sight bill */
	  then jl.rem[1] = bill.bill + "/" + bill.lcno + "/"
			 + bill.refno.
				 /* if usance */
	  else jl.rem[1] = bill.bill + "/"
			 + bill.lcno + " "
			 + "DUE:" + string(bill.duedt) + " "
			 + string(bill.trm) + "D "
			 + string(bill.intrate) + "% "
			 + string(bill.interest).
      end.
      else do:              /* if sight */
	jl.gl = bank.gl.
	      /* assign issue bank g/l  e.g. h.o.(iof) or due from bank */
	jl.acc = bank.bank.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (DRAFT)".
	find gl where gl.gl eq jl.gl.
	/* BATCH PROCESSING FOR IOF
	if gl.subled eq "iof"   /* iof update not dfb */
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	*/
      end.
    vln = vln + 1.

    /* FEE APPLICANT RCV */
    if rim.fee eq 2 and rpay.comm[1] + rpay.comm[2] + rpay.comm[4] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.crc = jh.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + "(TC:"
		  + string(rpay.comm[1]) + ")".
	jl.gl = bank.gl.   /* issue bank g/l iof or dfb */
	jl.acc = bank.bank.
	jl.dam = rpay.comm[1] + rpay.comm[2] + rpay.comm[4].
	jl.dc = "D".
	find gl where gl.gl eq jl.gl.
	/* BATCH PROCESSING FOR IOF
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	*/
	vln = vln + 1.
      end.

    /* FEE CONFIRM CHARGE APPLICANT RCV */
    else if rim.fee eq 3 and rpay.comm[1] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.crc = jh.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (THEIR CHG)".
	jl.gl = bank.gl.
	jl.acc = bank.bank.
	jl.dam = rpay.comm[1].
	jl.dc = "D".
	find gl where gl.gl eq jl.gl.
	/* BATCH PROCESSING FOR IOF
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	*/
	vln = vln + 1.
      end.

    /* PAYMENT */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.crc = jh.crc.
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
			      jl.gl = vdbgl.   /* default dfb g/l */
			      jl.acc = rpay.acc.
			    end.
    else if rpay.pacct eq 3 then do:
			      jl.gl = vocgl.
			      jl.acc = rpay.acc.
			      find gl where gl.gl eq jl.gl.
			      if gl.subled eq "ock"
				then do:
				  create ock.
				  ock.gl = jl.gl.
				  ock.crc = rpay.crc.
				  ock.ock = rpay.acc.
				  ock.rdt = rpay.pdt.
				  ock.dam[gl.level] = jl.dam.
				  ock.cam[gl.level] = jl.cam.
				end.
			    end.

    else if rpay.pacct eq 4 then do:
			      jl.gl = vcagl.   /* default dfb g/l */
			    end.

    vln = vln + 1.

    /* OUR COMMISSION */
    if rpay.comm[2] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.crc = jh.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.cam = rpay.comm[2].
	jl.dc = "D".
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (OUR COMM)".
	if rim.grp eq 1
	  then jl.gl = vcrgl.
	else if rim.grp eq 2
	  then jl.gl = vcsgl.
	else if rim.grp eq 3
	  then jl.gl = vcigl.
	if rpay.ptype eq 1
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
	jl.crc = jh.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (ISSUE. BANK)".
	jl.gl = bank.gl.
	jl.acc = bank.bank.
	jl.cam = rpay.comm[3].
	jl.dc = "C".
	find gl where gl.gl eq jl.gl.
	/* BATCH PROCESSING FOR IOF
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	*/
	vln = vln + 1.
      end.

    /* ADVISE COMMISSION */
    if rpay.comm[4] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.crc = jh.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (ADVISE CHG)".
	jl.gl = vcagl.
	jl.cam = rpay.comm[4].
	jl.dc = "C".
	vln = vln + 1.
      end.

    /* DISCOUNT FEE */
    vln = 101.
    if rpay.trm gt 0 and rpay.itype eq "D"
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.crc = jh.crc.
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
	/* BATCH PROCESSING FOR IOF
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	*/
	vln = vln + 1.

	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.crc = jh.crc.
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
/*
else if rpay.ptype eq 3 /* ADVISE FEE */
  then do:
    /* ADVISE COMMISSION */
    if rpay.comm[4] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.crc = jh.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (ADVISE CHG)".
	jl.gl = vcagl.
	jl.cam = rpay.comm[4].
	jl.dc = "C".
	vln = vln + 1.
	pause 0.
	{x-jllis.i}
	run x-jlgens.
	hide all.
	view frame heading.
	view frame cif.
      end.
  end.
*/
