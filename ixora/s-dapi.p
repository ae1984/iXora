/* s-dapi.p
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

/* s-dapi.p
*/

{global.i}

def  buffer b-dpay for dpay.

def  shared var s-bank like dpay.bank.
def  shared var s-dadp like dpay.dadp.
def  shared var s-aah  as int.
def  shared var s-jh      like jh.jh.
def  shared var s-consol  like jh.consol initial false.
def  shared var s-grp      like dpay.grp.
def  shared var s-type     like dadp.type.
def  shared var s-gl       like dpay.gl.
def  shared var s-drft     like dpay.drft.
def  shared var s-payamt   like dpay.payamt.
def  shared var s-adt      like dadp.adt.
def  shared var s-ddt      like dadp.ddt.
def  shared var s-trm      like dadp.trm.
def  shared var s-name     like bank.name.
def  shared var s-rdt      like dadp.rdt.
def  shared var s-bal      like dadp.bal.
def  shared var s-caccr    like dadp.caccr.
def  shared var s-crcvd    like dadp.crcvd.
def  shared var s-detail   like dadp.detail.
def  shared var s-pcnt     like dadp.pcnt.
def  shared var s-cif      like dadp.cif.
def  shared var s-party    like dadp.party.
def  shared var s-pacct    like dpay.pacct.
def  shared var s-acc      like jl.acc.
def  shared var s-vgl      like jl.gl.
def new shared var s-line as int.
def new shared var s-force as log.
def var vbal as dec format "zzz,zzz,zz9.99-".
def var vdam like vbal.
def var vcam like vbal.
def var vop  as int format "z".
def var vln as int.
def var vdfbgl as int.
def var vcitmgl as int.
def var vdtgl as int.
def var command as cha format "x".
def var vacc like jl.acc.
def var vfirst as log initial true.
def var vcdagl as int.
def var vcdpgl as int.
def var vcapgl as int.
def shared var vvamt as dec.
def shared var vvgl like gl.gl.

{jhjl.f new}

find sysc where sysc.sysc eq "cdagl". vcdagl = sysc.inval.
find sysc where sysc.sysc eq "cdpgl". vcdpgl = sysc.inval.
find sysc where sysc.sysc eq "capgl".  vcapgl = sysc.inval.
find sysc where sysc.sysc eq "defdfb". vdfbgl = sysc.inval.
find sysc where sysc.sysc eq "citmgl". vcitmgl = sysc.inval.
find sysc where sysc.sysc eq "dtgl". vdtgl = sysc.inval.

find dadp where dadp.bank eq s-bank
	   and  dadp.dadp eq s-dadp.
inner:
do on error undo, retry:
  create dpay.
  dpay.bank = dadp.bank.
  dpay.dadp = dadp.dadp.

  find last b-dpay where b-dpay.bank eq dadp.bank
		    and  b-dpay.dadp eq dadp.dadp no-error.

  if available b-dpay then dpay.ln = b-dpay.ln + 1.
		      else dpay.ln = 1.
  dpay.comm[1] = s-caccr.
  dpay.payamt = s-drft - s-caccr.
end.
find bank where bank.bank eq s-bank.
/* -- */
run x-jhnew.

do transaction:
  find jh where jh.jh eq s-jh.
  jh.cif = dadp.cif.
  jh.party = dadp.party.
  dpay.jh = jh.jh.
end.
vln = 1.
do transaction:
  if s-caccr ne 0 then do:
  create jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  if s-grp eq 1 then jl.gl = vcdagl.
		else jl.gl = vcdpgl.
  jl.acc = dpay.dadp.
  jl.cam = s-caccr.
  jl.dc = "C".
  dadp.crcvd = dadp.crcvd + s-caccr.
  dadp.caccr = dadp.caccr - s-caccr.
  if dadp.grp eq 1  /* d/a */
  then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		    + " PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
  else jl.rem[1] = "REF#:" + dadp.dadp +  " PAY-THRU:"
		    + jl.acc + " CIF:" + dadp.cif. /* d/p */
  find gl where gl.gl eq jl.gl.
  {jlupd-r.i}
  vln = vln + 1.
  end.

  if vvamt ne 0 then do:
  create jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  jl.gl = vvgl.
  jl.acc = dpay.dadp.
  jl.cam = vvamt.
  jl.dc = "C".
  dadp.crcvd = dadp.crcvd + vvamt.
  if dadp.grp eq 1  /* d/a */
  then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		    + " PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
  else jl.rem[1] = "REF#:" + dadp.dadp +  " PAY-THRU:"
		    + jl.acc + " CIF:" + dadp.cif. /* d/p */
  find gl where gl.gl eq jl.gl.
  {jlupd-r.i}
  vln = vln + 1.
  end.

  if (s-drft - s-caccr - vvamt) gt 0 then do:
     create jl.
     jl.jh = jh.jh.
     jl.ln = vln.
     jl.who = jh.who.
     jl.jdt = jh.jdt.
     jl.whn = jh.whn.
     find bank where bank.bank eq s-bank.
     jl.gl = bank.gl.
     jl.acc = s-bank.
     jl.cam = s-drft - s-caccr - vvamt.
     jl.dc = "C".
     if dadp.grp eq 1  /* d/a */
     then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		       + " PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
     else jl.rem[1] = "REF#:" + dadp.dadp +  " PAY-THRU:"
		       + jl.acc + " CIF:" + dadp.cif. /* d/p */

     find gl where gl.gl eq jl.gl.
     {jlupd-r.i}
     vln = vln + 1.

     dadp.bal = dadp.bal - jl.cam.
  end.

  create jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  if s-pacct eq 1 then jl.gl = vdfbgl.
  if s-pacct eq 2 then jl.gl = vcitmgl.
  if s-pacct eq 3 then jl.gl = vdtgl.
  if s-pacct eq 4 then jl.gl = s-vgl.
  jl.acc = s-acc.
  jl.dam = s-drft.
  jl.dc = "D".
  if dadp.grp eq 1  /* d/a */
  then jl.rem[1] = "REF#:" + dadp.dadp + " DUE:" + string(dadp.ddt)
		    + " PAY-THRU:" + jl.acc + " CIF:" + dadp.cif.
  else jl.rem[1] = "REF#:" + dadp.dadp +  " PAY-THRU:"
		    + jl.acc + " CIF:" + dadp.cif. /* d/p */
  find gl where gl.gl eq jl.gl.
  {jlupd-r.i}
  vln = vln + 1.

end.
/*
pause 0.
{x-jllis.i}
run x-jlgens.
hide all.
*/
