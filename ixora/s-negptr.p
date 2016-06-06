/* s-negptr.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* s-negptr.p
*/

{global.i}

define buffer b-rpay for rpay.

define shared temp-table w-rpay like rpay.

define shared var s-bank like rpay.bank.
define shared var s-lcno like rpay.lcno.

def shared var s-jh  like jh.jh.
def shared var s-consol like jh.consol initial false.
/*
def var vbal as dec format "zzz,zzz,zz9.99-".
def var vdam like vbal.
def var vcam like vbal.
def var vop  as int format "z".

{jhjl.f new}
*/
find first w-rpay.

def var vacc like jl.acc.
def var vdbgl as int.
def var vipgl as int.
def var vocgl as int.
def var vcagl as int.
def var vcsgl as int.
def var vcrgl as int.
def var vln as int.
def var vngl  like gl.gl extent 10.
def var v-inc as int.
def var vcashgl as int.
/*
def var vcsval as dec.
def var vcrval as dec.
def var vrbgl  as int.
def var vdefdfb as cha.
def var vngtgl as int.
def var vngsgl as int.
def var vcnsgl as int.
def var vcntgl as int.
def var vcashgl as int.

find sysc where sysc.sysc eq "CSGL". vcsval = sysc.deval.
find sysc where sysc.sysc eq "CASHGL". vcashgl = sysc.inval.
find sysc where sysc.sysc eq "CRGL". vcrval = sysc.deval.
/* find sysc where sysc.sysc eq "COBA". vcrval = sysc.deval. */

find sysc where sysc.sysc eq "RBGL". vrbgl = sysc.inval. /* nego and r/i */
/* this should be separated */

find sysc where sysc.sysc eq "DEFDFB". vdefdfb = sysc.chval.
find sysc where sysc.sysc eq "NGTGL".  vngtgl = sysc.inval.
find sysc where sysc.sysc eq "NGSGL".  vngsgl = sysc.inval.
find sysc where sysc.sysc eq "CNSGL".  vcnsgl = sysc.inval.
find sysc where sysc.sysc eq "CNTGL".  vcntgl = sysc.inval.
*/
find sysc where sysc.sysc eq "DBGL". vdbgl = sysc.inval.
find sysc where sysc.sysc eq "IPGL". vipgl = sysc.inval.
find sysc where sysc.sysc eq "OCGL". vocgl = sysc.inval.
find sysc where sysc.sysc eq "CAGL". vcagl = sysc.inval.
find sysc where sysc.sysc eq "CSGL". vcsgl = sysc.inval.
find sysc where sysc.sysc eq "CRGL". vcrgl = sysc.inval.

find sysc where sysc.sysc eq "NEGOC1". vngl[1]  = sysc.inval.
find sysc where sysc.sysc eq "NEGOC2". vngl[2]  = sysc.inval.
find sysc where sysc.sysc eq "NEGOC3". vngl[3]  = sysc.inval.
find sysc where sysc.sysc eq "NEGOC4". vngl[4]  = sysc.inval.
find sysc where sysc.sysc eq "NEGOC5". vngl[5]  = sysc.inval.
find sysc where sysc.sysc eq "NEGOC6". vngl[6]  = sysc.inval.
find sysc where sysc.sysc eq "NEGOC7". vngl[7]  = sysc.inval.
find sysc where sysc.sysc eq "NEGOC8". vngl[8]  = sysc.inval.
find sysc where sysc.sysc eq "NEGOC9". vngl[9]  = sysc.inval.
find sysc where sysc.sysc eq "NEGOCA". vngl[10]  = sysc.inval.
find sysc where sysc.sysc eq "CASHGL". vcashgl = sysc.inval.

find rim where rim.bank eq s-bank
	  and  rim.lcno eq s-lcno.

create rpay.
rpay.bank = rim.bank.
rpay.lcno = rim.lcno.
rpay.crc = rim.crc.
find last b-rpay where b-rpay.bank eq rim.bank
		  and  b-rpay.lcno eq rim.lcno no-error.
if available b-rpay then rpay.ln = b-rpay.ln + 1.
		    else rpay.ln = 1.
rpay.ptype = w-rpay.ptype.
rpay.comm[4] = w-rpay.comm[4].
rpay.ps = w-rpay.ps.
rpay.gl = w-rpay.gl.
rpay.ocomm[1] = w-rpay.ocomm[1].
rpay.ocomm[2] = w-rpay.ocomm[2].
rpay.ocomm[3] = w-rpay.ocomm[3].
rpay.ocomm[4] = w-rpay.ocomm[4].
rpay.ocomm[5] = w-rpay.ocomm[5].
rpay.ocomm[6] = w-rpay.ocomm[6].
rpay.ocomm[7] = w-rpay.ocomm[7].
rpay.ocomm[8] = w-rpay.ocomm[8].
rpay.ocomm[9] = w-rpay.ocomm[9].
rpay.ocomm[10] = w-rpay.ocomm[10].
rpay.comm[2] = w-rpay.comm[2].
rpay.orgamt = w-rpay.orgamt.
rpay.drft = w-rpay.drft.
rpay.comm[1] = w-rpay.comm[1].
rpay.comm[2] = w-rpay.comm[2].
rpay.comm[3] = w-rpay.comm[3].
rpay.payamt = w-rpay.payamt.
rpay.pacct = w-rpay.pacct.
rpay.acc = w-rpay.acc.
rpay.pdt = w-rpay.pdt.
rpay.orgdt = w-rpay.orgdt.
rpay.trm = w-rpay.trm.
rpay.duedt = w-rpay.duedt.
rpay.intdue = w-rpay.intdue.
rpay.intdt = w-rpay.intdt.
rpay.intrate = w-rpay.intrate.
rpay.interest = w-rpay.interest.
rpay.itype = w-rpay.itype.
rpay.cbank = w-rpay.cbank.
rpay.cbname = w-rpay.cbname.
rpay.crbank = w-rpay.crbank.
rpay.acct = w-rpay.acct.
rpay.tref = w-rpay.tref.
rpay.rem = w-rpay.rem.

rim.amt[2] = rim.amt[2] + rpay.orgamt.
rim.amt[4] = rim.amt[4] - rpay.comm[4].

find bank where bank.bank eq rpay.bank.

run x-jhnew.
find jh where jh.jh = s-jh.
jh.cif = rim.cif.
jh.party = rim.party.
rpay.jh = jh.jh.

if rpay.ptype eq 4 or rpay.ptype eq 5 /* usance or sight*/
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
	bill.crc = rpay.crc.
	w-rpay.bill = rpay.bill.
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
    jl.crc = rpay.crc.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = rpay.drft.
    jl.dc = "D".
	jl.gl = bill.gl.
	jl.acc = bill.bill.
	if bill.grp eq 1         /* if sight bill */
	  then jl.rem[1] =

	"063.030." +  bill.bill + "/NEGO"
	+ "/" + bill.lcno + "/"
			 + bill.refno.
				 /* if usance */
	  else do:
	  jl.rem[1] =
	"063.030." +  bill.bill + "/B/NEGO" + "/"
			 + bill.lcno + " " .

	  jl.rem[2] =  "DUE:" + string(bill.duedt) + " "
			 + string(bill.trm) + "D "
			 + string(bill.intrate) + "% "
			 + string(bill.interest).
	  end.

    vln = vln + 1.

    /* FEE APPLICANT RCV */
    if rim.fee eq 2 and rpay.comm[1] + rpay.comm[2] + rpay.comm[4] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.crc = rpay.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	if rpay.ptype = 5 then
	jl.rem[1] =
	"063.030." +  rpay.bill + "/NEGO"
		     + "/" + rpay.lcno + "(TC:"
		  + string(rpay.comm[1]) + ")".
	else
	jl.rem[1] =
	"063.030." +  rpay.bill + "/B/NEGO"
		     + "/" + rpay.lcno + "(TC:"
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
	jl.crc = rpay.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.

	if rpay.ptype = 5 then
	jl.rem[1] =
	"063.030." +  rpay.bill + "/NEGO"
	 + "/" + rpay.lcno + " (THEIR CHG)".
	else
	jl.rem[1] =
	"063.030." +  rpay.bill + "/B/NEGO"
	 + "/" + rpay.lcno + " (THEIR CHG)".

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
    jl.crc = rpay.crc.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = rpay.payamt.
    jl.dc = "C".
	if rpay.ptype = 5 then
	jl.rem[1] =
	"063.030." +  rpay.bill + "/NEGO"
	 + "/" + rpay.lcno + " (PAYMENT)".
	else
	jl.rem[1] =
	"063.030." +  rpay.bill + "/B/NEGO"
	 + "/" + rpay.lcno + " (PAYMENT)".

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
				  ock.ock = rpay.acc.
				  ock.rdt = rpay.pdt.
				  ock.dam[gl.level] = jl.dam.
				  ock.cam[gl.level] = jl.cam.
				end.
			    end.
    else if rpay.pacct eq 4 then do:
			      jl.gl = vcashgl.
			    end.
    vln = vln + 1.

    /* OUR COMMISSION */
    if rpay.comm[2] gt 0
      then do:
	repeat v-inc = 1 to 10:
	  if rpay.ocomm[v-inc] eq 0 then next.
	  create jl.
	  jl.jh = jh.jh.
	  jl.ln = vln.
	  jl.crc = rpay.crc.
	  jl.who = jh.who.
	  jl.jdt = jh.jdt.
	  jl.whn = jh.whn.
	  jl.cam = rpay.ocomm[v-inc].
	  jl.dc = "D".

	if rpay.ptype = 5 then
	jl.rem[1] =
	"063.030." +  rpay.bill + "/NEGO"
	 + "/" + rpay.lcno + " (OUR COMM)".
	else
	jl.rem[1] =
	"063.030." +  rpay.bill + "/B/NEGO"
	 + "/" + rpay.lcno + " (OUR COMM)".


	  /*
	  if rim.grp eq 1 then jl.gl = vcrgl.
			  else jl.gl = vcsgl.
	  */
	  jl.gl = vngl[v-inc].

	  if rpay.ptype eq 4
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
      end.

    /* ISSUING BANK COMMISSION */
    if rpay.comm[3] gt 0
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.crc = rpay.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	if rpay.ptype = 5 then
	jl.rem[1] =
	"063.030." +  rpay.bill + "/NEGO"
	 + "/" + rpay.lcno + " (ISSUE. BANK)".
	else
	jl.rem[1] =
	"063.030." +  rpay.bill + "/B/NEGO"
	 + "/" + rpay.lcno + " (ISSUE. BANK)".

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
	jl.crc = rpay.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (ISSUE. BANK)".
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
	jl.crc = rpay.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	if bill.grp eq 1
	  then jl.rem[1] =
	  "063.030." +
	  bill.bill + "/NEGO" + "/" + bill.lcno + "/"
			 + bill.refno.
	  else do:
	     jl.rem[1] =
	     "063.030" +
	     bill.bill + "/B/NEGO" + "/"
			 + bill.lcno + " " .

	     jl.rem[2] = "DUE:" + string(bill.duedt) + " "
			 + string(bill.trm) + "D "
			 + string(bill.intrate) + "% ".
	     end.
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
	jl.crc = rpay.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.

	if bill.grp eq 1
	  then jl.rem[1] =
	  "063.030." +
	  bill.bill + "/NEGO" + "/" + bill.lcno + "/"
			 + bill.refno.
	  else do:
	     jl.rem[1] =
	     "063.030" +
	     bill.bill + "/B/NEGO" + "/"
			 + bill.lcno + " " .

	     jl.rem[2] = "DUE:" + string(bill.duedt) + " "
			 + string(bill.trm) + "D "
			 + string(bill.intrate) + "% ".
	end.

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
	jl.crc = rpay.crc.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	if rpay.ptype = 5 then
	jl.rem[1] =
	"063.030" + rpay.bill
	+ "/NEGO" + "/" + rpay.lcno + " (ADVISE CHG)".
	else
	jl.rem[1] =
	"063.030" + rpay.bill
	+ "/B/NEGO" + "/" + rpay.lcno + " (ADVISE CHG)".
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
