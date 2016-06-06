/* s-sipay.p
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

/* s-sipay.p
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
def var vttl  as dec format "zzz,zzz,zz9.99-".
def var vgain like vtotinc.
def var vloss like vtotinc.
def var vprepay like vtotinc.

def var vpof as dec format "zzz.99".
def var vbook as dec format "zz,zzz,zz9.99-".
def var vdr as dec format "zz,zzz,zz9.99-".
def var vpp as dec format "zz,zzz,zz9.99-".
def var vterm1 as int format "zzzz".
def var vterm2 as int format "zzzz".
def var vjlcam like jl.cam.

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

if vttl - invsec.aintrec le 0 then do:
   vttl = vttl.
   vprepay = 0.
end.
else do:
   /*
   vttl = invsec.aintrec.
   */
   vprepay = vttl - invsec.aintrec.
end.

run x-jhnew.
find jh where jh.jh = s-jh.

    vln = 1.
    /* 1 */
    if invsec.aintrec ne 0 then do:

    if vprepay gt 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = invsec.aintrec.
    vjlcam = jl.cam.
    jl.dc = "C".
    jl.gl = invsec.aintgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = "REF#:" + invsec.invsec.
    invsec.aintrec = 0.
    invsec.intrec = invsec.intrec + jl.cam.
    invsec.cam[2] = invsec.cam[2] + jl.cam.
    invsec.ytdint = invsec.cam[2] - invsec.ycam[2].
    vln = vln + 1.

    end.

    if vprepay le 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = vttl.
    vjlcam = jl.cam.
    jl.dc = "C".
    jl.gl = invsec.aintgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = "REF#:" + invsec.invsec.
    invsec.aintrec = invsec.aintrec - vttl.
    invsec.intrec = invsec.intrec + jl.cam.
    invsec.cam[2] = invsec.cam[2] + jl.cam.
    invsec.ytdint = invsec.cam[2] - invsec.ycam[2].
    vln = vln + 1.
    end.

    end. /* aintrec ne 0 */

    /* inv purchase amount payment to broker/seller
     1. if cash or 2. official chk or 3. dfb 4. due to customer 5. cash itm
    */

    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.rem[1] = invsec.invsec + "/"
		  + string(invsec.coupon) + "/" + invsec.stype
		  + "/" + string(invsec.mdt).
    jl.gl = vsgl.
    jl.dam = vttl.
    jl.dc = "D".
    jl.acc = vsacc.
    if vpcode eq 2 then do:
       {mesg.i 8210}.
       undo, retry.
    end.
    jl.rem[2] = jl.acc.

    find gl where gl.gl eq jl.gl.
    {jlupd-r.i}
    vln = vln + 1.

    if vprepay gt 0 then do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.cam = vprepay.
    jl.dc = "C".
    jl.gl = invsec.intgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = invsec.invsec + "/"
			 + string(invsec.coupon) + "/" + invsec.stype
			 + "/" + string(invsec.mdt).
    invsec.intrec = invsec.intrec + vprepay.
    invsec.cam[2] = invsec.cam[2] + jl.cam.
    invsec.ytdint = invsec.cam[2] - invsec.ycam[2].
    vln = vln + 1.
    end.
    /*
    do:
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = vjlcam.
    jl.dc = "D".
    jl.gl = invsec.intgl.
    jl.acc = invsec.invsec.
    jl.rem[1] = "REF#:" + invsec.invsec.
    invsec.intrec = invsec.intrec + vprepay.
    invsec.dam[2] = invsec.dam[2] + jl.dam.
    vln = vln + 1.
    end.
    */
    vsjh = jh.jh.
    {x-jllis.i}
    /* run x-jlgens.p. */
    hide all.
    view frame heading.
    view frame cif.

    display vsjh with frame spay.
    /* pause. */
    view frame mk.
