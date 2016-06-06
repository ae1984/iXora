/* s-daptr.p
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

/* s-daptr.p
*/

{global.i}

define buffer b-dpay for dpay.
def buffer b-bank for bank.
define shared var s-bank like dpay.bank.
define shared var s-dadp like dpay.dadp.

def shared var s-acc like jl.acc.
def shared var s-jh  like jh.jh.
def shared var s-consol like jh.consol initial false.

def shared var s-grp      like dpay.grp.
def shared var s-type     like dadp.type.
def shared var s-gl       like dpay.gl.
def shared var s-drft     like dpay.drft.
def shared var s-payamt   like dpay.payamt.
def shared var s-adt      like dadp.adt.
def shared var s-ddt      like dadp.ddt.
def shared var s-trm      like dadp.trm.
def shared var s-name     like bank.name.
def shared var s-rdt      like dadp.rdt.
def shared var s-bal      like dadp.bal.
def shared var s-caccr    like dadp.caccr.
def shared var s-crcvd    like dadp.crcvd.
def shared var s-detail   like dadp.detail.
def shared var s-pcnt     like dadp.pcnt.
def shared var s-cif      like dadp.cif.
def shared var s-party    like dadp.party.
def shared var s-pacct    like dpay.pacct.

def var vacc like jl.acc.
def var vcashgl as int.
def var vcitmgl as int.
def var vdtgl as int.
def var vcdagl as int.
def var vcdpgl as int.
def var vln as int.

find sysc where sysc.sysc eq "CASHGL". vcashgl = sysc.inval.
find sysc where sysc.sysc eq "CITMGL". vcitmgl = sysc.inval.
find sysc where sysc.sysc eq "DTGL". vdtgl = sysc.inval.
find sysc where sysc.sysc eq "cdagl". vcdagl = sysc.inval.
find sysc where sysc.sysc eq "cdpgl". vcdpgl = sysc.inval.

find dadp where dadp.bank eq s-bank
	  and  dadp.dadp eq s-dadp.

create dpay.
dpay.bank = dadp.bank.
dpay.dadp = dadp.dadp.

find last b-dpay where b-dpay.bank eq dadp.bank
		  and  b-dpay.dadp eq dadp.dadp no-error.
if available b-dpay then dpay.ln = b-dpay.ln + 1.
		    else dpay.ln = 1.
dpay.grp = s-grp.
dpay.type = s-type.
dpay.comm[1] = s-caccr.
/*
dpay.comm[2] = s-caccr.
*/
dpay.gl = s-gl.
dpay.drft = s-drft.
dpay.payamt = s-payamt.
dpay.pacct = s-pacct.
dpay.acc = s-acc.
dpay.pdt = g-today.
dpay.trm = s-trm.
dpay.ddt = s-ddt.
dpay.rem = s-detail.

/* ----- */
if s-type eq "I" then do:
find bank where bank.bank eq dpay.bank.
run x-jhnew.
find jh where jh.jh = s-jh.
jh.cif = dadp.cif.
jh.party = dadp.party.
dpay.jh = jh.jh.

if dpay.grp eq 1 or dpay.grp eq 2
  then do:
    vln = 1.
    /* DRAFT */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    if s-pacct eq 1 then jl.gl = vcashgl.
    if s-pacct eq 2 then do:
      jl.gl = vcitmgl.
      jl.acc = s-acc.
    end.
    if s-pacct eq 3 then do:
      jl.gl = vdtgl.
      jl.acc = s-acc.
      find aaa where aaa.aaa eq s-acc no-error.
      aaa.cr[1] = aaa.cr[1] - (s-drft + s-caccr).
      aaa.dr[1] = aaa.dr[1] + (s-drft + s-caccr).
    end.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = dpay.drft + s-caccr.
    jl.dc = "D".
    if dpay.grp eq 1 or dpay.grp eq 2
      then do:
	jl.acc = s-acc.
	if dadp.grp eq 1  /* d/a */
	  then jl.rem[1] = dadp.dadp +  "/" + "DUE" + string(dadp.ddt)
			 + " " + string(dadp.trm).
	  else jl.rem[1] = dadp.dadp + "/" + "PAID " +
			 string(g-today) + " " + string(dpay.drft). /* d/p */
      end.
      /*
      else do:
	jl.gl = bank.gl.
	      /* assign issue bank g/l  e.g. h.o.(iof) or due from bank */
	jl.acc = bank.bank.
	jl.rem[1] = dpay.dadp + "/" + dpay.dadp + " (DRAFT)".
	find gl where gl.gl eq jl.gl.
	/* BATCH PROCESSING FOR IOF  */
	if gl.subled eq "iof"   /* iof update not dfb */
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
      end.
      */
      dadp.bal = dadp.bal - s-drft.
      dadp.pcnt = s-pcnt + 1.
    vln = vln + 1.
    end.
    /* COMM RCVD */
    if s-caccr ne 0 and s-grp eq 2  /* d/p case only */
      then do:
	create jl.
	jl.jh = jh.jh.
	jl.ln = vln.
	jl.who = jh.who.
	jl.jdt = jh.jdt.
	jl.whn = jh.whn.
	jl.rem[1] = dpay.dadp + "/" + dpay.dadp + "("
		  + string(dadp.caccr) + ")".
	jl.gl = vcdpgl.
	jl.acc = dadp.dadp.
	jl.cam = s-caccr.
	jl.dc = "C".
	/*
	find gl where gl.gl eq jl.gl.
	/* BATCH PROCESSING FOR IOF
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
	*/
	*/
	dadp.crcvd = dadp.crcvd + s-caccr.
	dadp.caccr = dadp.caccr - s-caccr.
	vln = vln + 1.
      end.

    /* PAYMENT */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = s-drft.
    jl.dc = "C".
    jl.rem[1] = dpay.dadp + "/" + dpay.dadp + " (PAYMENT)".
    jl.gl = bank.gl.
    jl.acc = bank.bank.
	find gl where gl.gl eq jl.gl.
	/* BATCH PROCESSING FOR IOF */
	if gl.subled eq "iof"
	  then do:
	    find iof where iof.iof eq jl.acc no-error.
	    iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	    iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
	  end.
    vln = vln + 1.
    dpay.payamt = s-drft + s-caccr.
end. /* ------ */

else if s-type eq "O" then do:     /* -----------  */

run x-jhnew.
find jh where jh.jh = s-jh.
jh.cif = dadp.cif.
jh.party = dadp.party.
dpay.jh = jh.jh.

    vln = 1.
    /* DRAFT */
    if dpay.drft ne 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = dpay.drft.
    jl.dc = "D".
	if dadp.grp eq 1  /* d/a */
	  then jl.rem[1] = dadp.dadp +  "/" + "DUE" + string(dadp.ddt)
			 + " " + string(dadp.trm).
	  else jl.rem[1] = dadp.dadp + "/" + "PAID " +
			 string(g-today) + " " + string(dpay.drft). /* d/p */
      find bank where bank.bank eq dpay.bank.
      if available bank then do:
	jl.gl = bank.gl.
	    /* assign issue bank g/l due from bank */
	jl.acc = bank.acc.
      end.
      dadp.bal = dadp.bal - s-drft.
      dadp.pcnt = s-pcnt + 1.
    vln = vln + 1.
    end.

    if dpay.drft ne 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = dpay.drft.
    jl.dc = "C".
    jl.acc = dpay.bank.
    /*
    jl.acc = "c0010".
    */
    if dadp.grp eq 1  /* d/a */
       then jl.rem[1] = dadp.dadp +  "/" + "DUE" + string(dadp.ddt)
		      + " " + string(dadp.trm).
       else jl.rem[1] = dadp.dadp + "/" + "PAID " +
			 string(g-today) + " " + string(dpay.drft). /* d/p */
    /*
    find b-bank where b-bank.bank eq "c0010".
    */
    find b-bank where b-bank.bank eq dpay.bank.
    if available b-bank then do:
      jl.gl = b-bank.gl.
	   /* assign issue bank g/l  e.g. h.o.(iof) */
      jl.acc = b-bank.bank.
    end.
    find gl where gl.gl eq jl.gl.
	/* BATCH PROCESSING FOR IOF  */
    if gl.subled eq "iof"   /* iof update not dfb */
       then do:
	 find iof where iof.iof eq jl.acc no-error.
	 iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
	 iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
       end.
   end.
end.  /* end of s-type eq "O" */
