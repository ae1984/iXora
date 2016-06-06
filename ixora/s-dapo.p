/* s-dapo.p
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

/* s-dapo.p
*/

{global.i}

define buffer b-dpay for dpay.
def buffer b-bank for bank.
define shared var s-bank like dpay.bank.
define shared var s-dadp like dpay.dadp.

def shared var s-vgl like jl.gl.
def shared var s-acc like jl.acc.
def shared var s-jh  like jh.jh.
def shared var s-consol like jh.consol initial false.
def shared var s-aah as int.
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
def new shared var s-line as int.
def new shared var s-force as log.
def var vacc like jl.acc.
def var vdfbgl as int.
def var vocgl as int.
def var vdtgl as int.
def var vcdagl as int.
def var vcdpgl as int.
def var vcapgl as int.
def var vcitmgl as int.
def var vln as int.
def var vdefdfb as cha.
def shared var vvgl like gl.gl.
def shared var vvamt as dec.

find sysc where sysc.sysc eq "defdfb". vdfbgl = sysc.inval.
				       vdefdfb = sysc.chval.
find sysc where sysc.sysc eq "ocgl". vocgl = sysc.inval.
find sysc where sysc.sysc eq "DTGL". vdtgl = sysc.inval.
find sysc where sysc.sysc eq "cdagl". vcdagl = sysc.inval.
find sysc where sysc.sysc eq "cdpgl". vcdpgl = sysc.inval.
find sysc where sysc.sysc eq "capgl". vcapgl = sysc.inval.
find sysc where sysc.sysc eq "citmgl". vcitmgl = sysc.inval.

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

dpay.comm[2] = vvamt.

dpay.gl = s-gl.
dpay.drft = s-drft.
dpay.payamt = s-payamt.
dpay.pacct = s-pacct.
dpay.acc = s-acc.
dpay.pdt = g-today.
dpay.trm = s-trm.
dpay.ddt = s-ddt.
dpay.rem = s-detail.

if s-type eq "O" then do:     /* -----------  */

run x-jhnew.
find jh where jh.jh = s-jh.
jh.cif = dadp.cif.
jh.party = dadp.party.
dpay.jh = jh.jh.


if s-caccr + vvamt eq s-drft then do:
    vln = 1.
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = s-caccr + vvamt.
    jl.dc = "D".
    if s-pacct eq 1 then do:
       jl.gl = vdfbgl.
       /*
       jl.acc = vdefdfb.
       */
       jl.acc = s-acc.
    end.
    if s-pacct eq 2 then do:
       jl.gl = vcitmgl.
    end.
    if s-pacct eq 3 then do:
       jl.gl = vdtgl.
       jl.acc = s-acc.
    end.
    if s-pacct eq 4 then do:
       jl.gl = s-vgl.
       jl.acc = s-acc.
    end.
    if dadp.grp eq 1  /* d/a */
       then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		      + " C-PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
       else jl.rem[1] = "REF#:" + dadp.dadp +  " C-PAY-THRU:"
		      + jl.acc + " CIF:" + dadp.cif. /* d/p */

    find gl where gl.gl eq jl.gl.
    {jlupd-r.i}
    vln = vln + 1.

    if vvamt ne 0 then do:
     create jl.
     jl.jh = jh.jh.
     jl.ln = vln.
     jl.who = jh.who.
     jl.jdt = jh.jdt.
     jl.whn = jh.whn.

    if dadp.grp eq 1  /* d/a */
       then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		      + " C-PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
       else jl.rem[1] = "REF#:" + dadp.dadp +  " C-PAY-THRU:"
		      + jl.acc + " CIF:" + dadp.cif. /* d/p */

     if s-grp eq 1 then do:
	/* jl.gl = vcdagl. */
	jl.gl = vvgl.
	jl.acc = s-dadp.
     end.
     if s-grp eq 2 then do:
	/* jl.gl = vcdpgl. */
	jl.gl = vvgl.
	jl.acc = s-dadp.
     end.
     jl.cam = vvamt.
     jl.dc = "C".
     /*
     find gl where gl.gl eq jl.gl.
     {jlupd-r.i}
     */
     dadp.crcvd = dadp.crcvd + vvamt.
     vln = vln + 1.
     end.

     if s-caccr ne 0 then do:
     create jl.
     jl.jh = jh.jh.
     jl.ln = vln.
     jl.who = jh.who.
     jl.jdt = jh.jdt.
     jl.whn = jh.whn.

    if dadp.grp eq 1  /* d/a */
       then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		      + " C-PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
       else jl.rem[1] = "REF#:" + dadp.dadp +  " C-PAY-THRU:"
		      + jl.acc + " CIF:" + dadp.cif. /* d/p */

     if s-grp eq 1 then do:
	/* jl.gl = vcdagl. */
	jl.gl = vcapgl.
	jl.acc = s-dadp.
     end.
     if s-grp eq 2 then do:
	/* jl.gl = vcdpgl. */
	jl.gl = vcapgl.
	jl.acc = s-dadp.
     end.
     jl.cam = s-caccr.
     jl.dc = "C".
     /*
     find gl where gl.gl eq jl.gl.
     {jlupd-r.i}
     */
     dadp.caccr = dadp.caccr - s-caccr.
     dadp.crcvd = dadp.crcvd + s-caccr.
     vln = vln + 1.
     end.
end.  /* end of s-caccr + vvamt eq s-drft */

else do:
    vln = 1.
    /* DRAFT */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = dpay.drft.
    find bank where bank.bank eq "selfbnk".
    jl.gl = bank.gl.
    jl.dc = "D".
    jl.acc = "SELFBNK".
    if dadp.grp eq 1  /* d/a */
    then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		      + " PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
    else jl.rem[1] = "REF#:" + dadp.dadp +  " PAY-THRU:"
		      + jl.acc + " CIF:" + dadp.cif. /* d/p */
    dadp.bal = dadp.bal - (s-drft - s-caccr).
    dadp.pcnt = s-pcnt + 1.
    find gl where gl.gl eq jl.gl.
    {jlupd-r.i}
    vln = vln + 1.

    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = dpay.drft - s-caccr - vvamt.
    jl.dc = "C".
    if s-pacct eq 1 then do:
       jl.gl = vdfbgl.
       /*
       jl.acc = vdefdfb.
       */
       jl.acc = s-acc.
    end.
    if s-pacct eq 2 then do:
       jl.gl = vocgl.
       jl.acc = s-acc.
       create ock.
       ock.ock = s-acc.
       ock.gl = vocgl.
       ock.rdt = g-today.
       ock.whn = g-today.
       /*
       ock.cam[1] = s-drft - s-caccr.
       */
       ock.payee = dadp.party.
    end.
    if s-pacct eq 3 then do:
       jl.gl = vdtgl.
       jl.acc = s-acc.
    end.
    if s-pacct eq 4 then do:
       jl.gl = s-vgl.
       jl.acc = s-acc.
    end.
    if dadp.grp eq 1  /* d/a */
    then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		      + " PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
    else jl.rem[1] = "REF#:" + dadp.dadp +  " PAY-THRU:"
		      + jl.acc + " CIF:" + dadp.cif. /* d/p */
    find gl where gl.gl eq jl.gl.
    {jlupd-r.i}
     vln = vln + 1.

  if s-caccr + vvamt gt 0 then do:
     if s-caccr gt 0 then do:
     create jl.
     jl.jh = jh.jh.
     jl.ln = vln.
     jl.who = jh.who.
     jl.jdt = jh.jdt.
     jl.whn = jh.whn.
     jl.rem[1] = dpay.dadp.

     if s-grp eq 1 then do:
	/* jl.gl = vcdagl. */
	jl.gl = vcapgl.
	jl.acc = s-dadp.
     end.
     if s-grp eq 2 then do:
	/* jl.gl = vcdpgl.  */
	jl.gl = vcapgl.
	jl.acc = s-dadp.
     end.
     jl.cam = s-caccr.
     jl.dc = "C".
     if dadp.grp eq 1  /* d/a */
     then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		       + " PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
     else jl.rem[1] = "REF#:" + dadp.dadp +  " PAY-THRU:"
		       + jl.acc + " CIF:" + dadp.cif. /* d/p */
     /*
     find gl where gl.gl eq jl.gl.
     {jlupd-r.i}
     */
     dadp.caccr = dadp.caccr - s-caccr.
     dadp.crcvd = dadp.crcvd + s-caccr.
     vln = vln + 1.
     end.

     if vvamt gt 0 then do:
     create jl.
     jl.jh = jh.jh.
     jl.ln = vln.
     jl.who = jh.who.
     jl.jdt = jh.jdt.
     jl.whn = jh.whn.
     jl.rem[1] = dpay.dadp.

     if s-grp eq 1 then do:
	/* jl.gl = vcdagl. */
	jl.gl = vvgl.
	jl.acc = s-dadp.
     end.
     if s-grp eq 2 then do:
	/* jl.gl = vcdpgl.  */
	jl.gl = vvgl.
	jl.acc = s-dadp.
     end.
     jl.cam = vvamt.
     jl.dc = "C".
     if dadp.grp eq 1  /* d/a */
     then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		       + " PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
     else jl.rem[1] = "REF#:" + dadp.dadp +  " PAY-THRU:"
		       + jl.acc + " CIF:" + dadp.cif. /* d/p */
     /*
     find gl where gl.gl eq jl.gl.
     {jlupd-r.i}
     */
     dadp.crcvd = dadp.crcvd + vvamt.
     vln = vln + 1.
     end.
  end.

  end.
end.  /* end of s-type eq "O" */
