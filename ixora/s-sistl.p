/* s-sistl.p
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

/* s-sistl.p
*/

def var vsele as cha form "x(12)" extent 12
 initial ["NEXT", "MODIFY", "CONFIRM", "HIST", "DELETE", "QUIT",
	  "PURCHASE", "VOUCHER", "SELL", "INT-PAY" ,"CNCL", "MATCHING"].
define shared var s-invsec like invsec.invsec.
define new shared var gdate as date.
def var vacc like jl.acc.
def var vgl like gl.gl.
def var vln as int.
def var vyr as int.
def new shared var s-jh like jl.jh.
def new shared var s-consol like jh.consol initial false.
def new shared var s-aah as int.
def new shared var s-line as int.
def new shared var s-force as log initial false.
def var vbal as dec format "zzz,zzz,zz9.99-".
def var vdam like vbal.
def var vcam like vbal.
def var vop as int format "z".

def var vcashgl like gl.gl.
def var vocgl like gl.gl.
def var vdtgl like gl.gl.
def var vdfbgl like gl.gl.
def var vcitmgl like gl.gl.
def shared frame mk.
def var vpcode as int format "z".
def var vpdes like gl.des.
def var vsgl like gl.gl.
def var vsacc like jl.acc.
def var vtotinc as dec format "zzz,zzz,zz9.99-".
def var vterm as int format "zzzzz".
def var i as int.
def var vsjh like jl.jh.
def var vproc as dec format "zzz,zzz,zz9.99-".
def var vttl like vproc.
def var vgain like vtotinc.
def var vloss like vtotinc.

def var vpof as dec format "zzz.99".
def var vbook as dec format "zz,zzz,zz9.99-".
def var vdr as dec format "zz,zzz,zz9.99-".
def var vpp as dec format "zz,zzz,zz9.99-".
def var vterm1 as int format "zzzz".
def var vterm2 as int format "zzzz".
def var vsof as dec format "zzz.99".
def var vbv as dec format "z,zzz,zzz,zz9.99-".
def var vbfgl2 like gl.gl.

{jhjl.f new}

{proghead.i}

find sysc where sysc.sysc eq "cashgl".
vcashgl = sysc.inval.
find sysc where sysc.sysc eq "ocgl".
vocgl = sysc.inval.
find sysc where sysc.sysc eq "dtgl".
vdtgl = sysc.inval.
find sysc where sysc.sysc eq "defdfb".
vdfbgl = sysc.inval.
find sysc where sysc.sysc eq "brkfe2".
vbfgl2 = sysc.inval.
{inv.f}

update vttl with frame spay.

update vpcode with frame spay.
if vpcode eq 1 then vsgl = vcashgl.
if vpcode eq 2 then vsgl = vocgl.
if vpcode eq 3 then vsgl = vdfbgl.
if vpcode eq 4 then vsgl = vdtgl.
if vpcode eq 5 then vsgl = vcitmgl.

find gl where gl.gl eq vsgl.
vpdes = gl.des.
display vpdes
	/*
	help "1.CASH  2.OFCL-CHK 3.DFB 4.DUE-TO-ACCT 5.CHECK(CASH-ITM)"
	*/
	with frame spay.
if gl.subled ne "" then update vsacc
	with frame spay.
find invsec where invsec.invsec = s-invsec.
vsof = invsec.samtrec / invsec.par.
vpof = invsec.purpr / invsec.par.
    if vpof gt 100
    then do:
      vbv = invsec.purpr - invsec.accumaa.
    end.
    if vpof le 100
    then do:
      vbv = invsec.purpr + invsec.accumaa.
    end.
    if vbv - invsec.par * vsof / 100 gt  0
    then vgain = vbv - invsec.par * vsof / 100.
    if vbv - invsec.par * vsof / 100 lt  0
    then vloss = invsec.par * vsof / 100 - vbv.

/*
if vttl - invsec.aintrec ge invsec.purpr then
   vgain = vttl - invsec.aintrec - invsec.purpr.
else
   vloss = - ( vttl - invsec.aintrec - invsec.purpr).
*/
run x-jhnew.
find jh where jh.jh = s-jh.

find stype where stype.stype eq invsec.stype.
vgl = stype.portgl.

    vln = 1.
    /* 1 */
    /* principle into inv  g/l */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    if vpof gt 100
    then do:
      jl.cam = invsec.purpr - invsec.accumaa.
      vbv = jl.cam.
    end.
    if vpof le 100
    then do:
      jl.cam = invsec.purpr + invsec.accumaa.
      vbv = jl.cam.
    end.
    jl.dc = "C".
    jl.gl = vgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = "REF#: " + invsec.invsec.
    jl.rem[2] = "ISSUER: " + invsec.issuer.
    jl.rem[3] = "F-AMT: " + string(invsec.par)
		+ "  P-MAT: " + string(invsec.purpr).
    jl.rem[4] = "MATURITY: " + string(invsec.mdt).
    jl.rem[5] = "INT-RATE: " + string(invsec.coupon)
		+ "% (" + string(invsec.sdt) + "-" +
		string(invsec.mdt) + ":" +
		string(invsec.mdt - invsec.sdt) + " DAYS)".
    invsec.cam[1] = invsec.cam[1] + jl.cam.
    vln = vln + 1.
    /* 2 */
    if vgain gt 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = vgain.
    jl.dc = "C".
    jl.gl = invsec.gaingl.
    jl.acc = invsec.invsec.
    jl.rem[1] =  "REF#:" + invsec.invsec.
    jl.rem[2] = string(vbv) + " - " + string(invsec.par) + " x " +
		string(vsof) + " /100 = " + string(vgain).
    invsec.cam[4] = invsec.cam[4] + vgain.
    vln = vln + 1.
    end.
    /* 3 */
    if vloss gt 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = vloss.
    jl.dc = "D".
    jl.gl = invsec.lossgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = "REF#:" + invsec.invsec.
    jl.rem[2] = string(invsec.par) + " x " + string(vsof) + " /100 - "
		+ string(vbv) + " = " + string(vloss).
    invsec.dam[4] = invsec.dam[4] + vloss.
    vln = vln + 1.
    end.
    /* 4 */
    if invsec.aintrec ne 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = invsec.aintrec.
    jl.dc = "C".
    jl.gl = invsec.aintgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = "REF#:" + invsec.invsec.

    invsec.aintrec = invsec.aintrec - jl.cam.
    invsec.intrec = invsec.intrec + jl.cam.
    invsec.cam[2] = invsec.cam[2] + jl.cam.
    vln = vln + 1.
    end.

    /* inv purchase amount payment to broker/seller
     1. if cash or 2. official chk or 3. dfb 4. due to customer 5. cash itm
    */
    /* 5 */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.rem[1] = "REF#:" + invsec.invsec.
    jl.gl = vsgl.
    jl.dam = invsec.par * vsof / 100
	     + invsec.par * invsec.coupon * (invsec.sdt - invsec.lcpndt)
	     - invsec.bfee[2].
    /*
    jl.dam = vttl.
    */
    jl.dc = "D".
    jl.acc = vsacc.
    if vpcode eq 2 then do:
       undo, retry.
    end.
    /* jl.rem[2] = jl.acc. */
    jl.rem[2] = string(invsec.par) + " x " + string(vsof) + " /100 + "
	     + string(invsec.par) + " x " + string(invsec.coupon)
	     + string(invsec.sdt - invsec.lcpndt) + "DAYS" + " - "
	     + string(invsec.bfee[2]).
    find gl where gl.gl eq jl.gl.
    {jlupd-r.i}
    vln = vln + 1.
    /* 6 */
    if invsec.bfee[2] ne 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = invsec.bfee[2].
    jl.dc = "D".
    jl.gl = vbfgl2.
    jl.acc = invsec.invsec.
    jl.rem[1] = "REF#:" + invsec.invsec.
    invsec.dam[3] = invsec.dam[3] + jl.dam.
    vln = vln + 1.
    end.
    /* 7 */
    if invsec.par * (vpof - 100) / 100  - invsec.accumaa gt 0
    then do:  /* prm paid */
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = invsec.par * (vpof - 100) / 100 - invsec.accumaa.
    jl.dc = "C".
    jl.gl = invsec.aexpgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = "REF#:" + invsec.invsec.
    vln = vln + 1.
    end.
    /* 8 */
    if invsec.par * (100 - vpof) / 100 - invsec.accumaa gt 0
    then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = invsec.par * (100 - vpof) / 100 - invsec.accumaa.
    jl.dc = "D".
    jl.gl = invsec.accrgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = "REF#:" + invsec.invsec.
    vln = vln + 1.
    end.

    vsjh = jh.jh.
    /*
    {x-jllis.i}
    run x-jlgens.p.
    hide all.
    view frame heading.
    view frame cif.
    */
    display vsjh with frame spay.
    pause.
