/* remcrd.p
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

/* remcrd.p
*/

{global.i}

define shared var s-rem like rem.rem.
def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol.

def var vans    as log.
def var vln     as int.
def var vrmsvcg as int.
def var vrmdfbg as int.
def var vrmofcg as int.
def var vrmcash as int.
def var vrmchkg as int.

find rem where rem.rem eq s-rem.

if rem.jh ne ?
  then do:
    bell.
    {mesg.i 0817}.
    pause 5.
    undo, return.
  end.

if rem.grp eq 2 and rem.chkamt ne rem.amt /* OUTWARD PARTIAL CHK PAID */
  then do:
    bell.
    {mesg.i 0891} update vans.
    if vans eq false then return.
  end.

vln = 1.
find sysc where sysc.sysc eq "RMOFCG".
vrmofcg = sysc.inval.
find sysc where sysc.sysc eq "CASHGL".
vrmcash = sysc.inval.
find sysc where sysc.sysc eq "OCGL".
vrmchkg = sysc.inval.
run x-jhnew.
rem.rdt = g-today.
rem.jh = s-jh.
find jh where jh.jh eq s-jh.
jh.party = rem.bn[1].

create jl.
jl.jh = jh.jh.
jl.ln = vln.
vln = vln + 1.
jl.who = jh.who.
jl.jdt = jh.jdt.
jl.whn = jh.whn.
jl.rem[1] = rem.rem + " " + rem.dfb + " " + rem.ord.
jl.rem[2] = rem.bb[1].
jl.rem[3] = rem.bn[1].
jl.rem[4] = rem.ba + " " + string(rem.svc).
find iof where iof.iof eq rem.iof.
jl.gl = iof.gl.
jl.acc = rem.iof.

if rem.grp eq 1 and rem.chg eq 2 /* INWARD & REMITTER CHARGE */
then jl.dam = rem.amt + rem.svc.
else if rem.grp eq 1                  /* INWARD & OTHER */
then jl.dam = rem.amt.
else if rem.grp eq 2 and rem.chg eq 1 /* OUTWARD & BENIF CHARGE */
then jl.cam = rem.amt - rem.svc.
else jl.cam = rem.amt.                /* OTHER */

find gl where gl.gl eq jl.gl.
{x-jlupd.i +}

ts:
do:
create jl.
jl.jh = jh.jh.
jl.ln = vln.
vln = vln + 1.
jl.who = jh.who.
jl.jdt = jh.jdt.
jl.whn = jh.whn.
/* jl.rem[1] = rem.rem. */

if rem.grp eq 1
then do: if rem.ock ne ""
	 then do:
	   jl.gl = vrmofcg.
	   jl.acc = rem.ock.
	   jl.rem[1] = rem.rem + " " + rem.iof + " " + rem.ord.
	   jl.rem[2] = rem.bb[1].
	   jl.rem[3] = rem.bn[1].
	   jl.rem[4] = rem.ba + " " + string(rem.svc).
	   create ock.
	   ock.ock = rem.ock.
	   ock.who = g-ofc.
	   ock.rdt = g-today.
	   ock.payee = rem.bn[1].
	   ock.ref = rem.rem.
	   ock.gl = vrmofcg.
	 end.

	 else if rem.dfb ne ""
	 then do:
	   /* find sysc where sysc.sysc eq "RMDFBG".
	      vrmdfbg = sysc.inval. */
	   run chs-gl("Nostro bilances konts","RMDFBG",output vrmdfbg).
	   jl.gl = vrmdfbg.
	   jl.acc = rem.dfb.
	   jl.rem[1] = rem.rem + " " + rem.iof + " " + rem.ord.
	   jl.rem[2] = rem.bb[1].
	   jl.rem[3] = rem.bn[1].
	   jl.rem[4] = rem.ba + " " + string(rem.svc).
	 end.
end.

if rem.grp eq 2
then do: if rem.ock ne "" /* OUTWARD & CHECK DEPOSIT */
	 then do:
	    jl.gl = vrmchkg.
	    /*
	    jl.rem[1] = jl.rem[1] + " CHECK NO:" + rem.ock.
	    */
	    jl.rem[1] = rem.rem + " " + rem.ock + " " + rem.ord.
	    jl.rem[2] = rem.bb[1].
	    jl.rem[3] = rem.bn[1].
	    jl.rem[4] = rem.ba + " " + string(rem.svc).
	 end.
	 else if rem.ock eq ""  /* OUTWARD OTHER & CASH */
	 then do:
	    jl.gl = vrmcash.
	    jl.rem[1] = rem.rem + " " + rem.iof + " " + rem.ord.
	    jl.rem[2] = rem.bb[1].
	    jl.rem[3] = rem.bn[1].
	    jl.rem[4] = rem.ba + " " + string(rem.svc).
	 end.
end.

if rem.grp eq 1
then do: if rem.chg eq 1       /* INWARD & BENEF */
	 then jl.cam = rem.amt - rem.svc.
	 else jl.cam = rem.amt.   /* INWARD */
end.
if rem.grp eq 2
then do: if rem.chg eq 2  /* OUTWARD REMITTER */
	 then do: if rem.amt ne rem.chkamt
		  then jl.dam = rem.chkamt.
		  else jl.dam = rem.amt + rem.svc.
	 end.
	 else do: if rem.amt ne rem.chkamt  /* OTHER OUTWARD */
		  then jl.dam = rem.chkamt.
		  else jl.dam = rem.amt.
	 end.
end.

if rem.chkamt eq 0 then leave ts.
end.

find gl where gl.gl eq jl.gl.
{x-jlupd.i +}

if rem.grp eq 2 and rem.chkamt ne rem.amt /* OUTWARD PARTIAL CHK PAID */
  then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    vln = vln + 1.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.rem[1] = rem.rem + " " + rem.dfb + " " + rem.ord.
    jl.rem[2] = rem.bb[1].
    jl.rem[3] = rem.bn[1].
    jl.rem[4] = rem.ba + " " + string(rem.svc).
    jl.dam = rem.amt - rem.chkamt + rem.svc.
    jl.gl = vrmcash.
  end.

if rem.chg ne 0  /* NE NO CHARGE */
  then do:
    /* find sysc where sysc.sysc eq "RMSVCG".
       vrmsvcg = sysc.inval. */
    run chs-gl("P–rveduma komisijas bilances konts","RMSVCG",output vrmsvcg).
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    vln = vln + 1.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.rem[1] = rem.rem + " " + rem.dfb + " " + rem.ord.
    jl.rem[2] = rem.bb[1].
    jl.rem[3] = rem.bn[1].
    jl.rem[4] = rem.ba + " " + string(rem.svc).
    jl.gl = vrmsvcg.
    jl.cam = rem.svc.
  end.

if rem.grp eq 2 and rem.chg eq 3  /* OUTWARD & CASH EXTRA PAY */
  then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    vln = vln + 1.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.rem[1] = rem.rem + " " + rem.dfb + " " + rem.ord.
    jl.rem[2] = rem.bb[1].
    jl.rem[3] = rem.bn[1].
    jl.rem[4] = rem.ba + " " + string(rem.svc).
    jl.gl = vrmcash.
    jl.dam = rem.svc.
  end.
/*
for jl where jl.jh eq s-jh and (jl.dam eq 0 and jl.cam eq 0):
  delete jl.
end.     /* 0 logic change */
*/
pause 0.
display s-jh.
pause 4.
hide all.
/*
run x-jlvou.
*/
