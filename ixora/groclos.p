/* groclos.p
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

/* groclos.p
   BY S. CHOI */

define var vlog as log init false.
define new  shared var s-jh like jh.jh.
define new  shared var s-consol like jh.consol.
define new  shared var vdt as date.
define var vtamt like gro.amt.
define var vgamt like gro.amt.
define var viamt like gro.amt.
define var vuamt like gro.amt.
define var vtsvc like gro.amt.
define var vgsvc like gro.amt.
define var visvc like gro.amt.
define var vusvc like gro.amt.

define var vtnum as int format ">>>9".
define var vgnum as int format ">>>9".
define var vinum as int format ">>>9".
define var vunum as int format ">>>9".
define var vnum  as int format ">>>9".

define var vttrx like jh.jh.
define var vitrx like jh.jh.
define var vgtrx like jh.jh.
define var vutrx like jh.jh.
define var vdiff like gro.amt.
define var vln as int.
define var vapagl like gl.gl.
define var vcomgl like gl.gl.
define var vsvc like gro.amt.
define var vtot like gro.amt.
define var vttrn like gro.amt.
define var vgtrn like gro.amt.
define var vitrn like gro.amt.
define var vutrn like gro.amt.

{proghead.i}

{groclos.f}

view frame gro.
update vlog with frame gro.

if vlog eq true then do:

  find crc where crc.crc eq 1.
  find sysc where sysc.sysc eq "APAGL".
  vapagl = sysc.inval.
  find sysc where sysc.sysc eq "COMGL".
  vcomgl = sysc.inval.
  for each gro where gro.rdt eq g-today and gro.sts eq 5
      break by gro.type by gro.gro:

    if gro.type eq 1 and gro.amt ne 0 then do:
      vtamt = vtamt + gro.amt.
      vtnum = vtnum + 1.
    end.
    else if gro.type eq 2 and gro.amt ne 0 then do:
      vgamt = vgamt + gro.amt.
      vgnum = vgnum + 1.
    end.
    else if gro.type eq 3 and gro.amt ne 0 then do:
      viamt = viamt + gro.amt.
      vinum = vinum + 1.
    end.
    else if gro.type eq 4  and gro.amt ne 0 then do:
      vuamt = vuamt + gro.amt.
      vunum = vunum + 1.
    end.
  end.  /* for each gro */


  find first gro where gro.rdt eq g-today and gro.type eq 1
			and gro.sts eq 5  no-error.

  if available gro then do:
   find grotyp where grotyp.type eq 1.
   if grotyp.pby eq 2 then do:
     for each gro where gro.rdt eq g-today and gro.sts eq 5 and gro.type eq 1:
       vtsvc = vtsvc + gro.svc.
     end.
   end. /* if grotyp.pby eq 2 */
   else if grotyp.pby eq 1 and grotyp.scg eq 2 then vtsvc = grotyp.camt * vtnum.
   else if grotyp.pby eq 1 and grotyp.scg eq 1 then
      vtsvc = round(vtamt * grotyp.crate / 100 * exp(10,crc.decpnt),0)
			       / exp(10,crc.decpnt).
   else undo,leave.

   do on error undo, retry:
     run x-jhnew.
     find jh where jh.jh = s-jh.
     vttrx = s-jh.
     vln = 1.
   end.

   create jl.
   jl.jh  = jh.jh.
   jl.ln  = vln.
   jl.who = jh.who.
   jl.jdt = jh.jdt.
   jl.whn = jh.whn.
   jl.gl =  vapagl.
   jl.acc = "".
   jl.dc = "D".
   jl.crc = 1.
   jl.dam =  vtsvc .
     /* jl.fdam = jl.dam. */
   jl.rem[1] = grotyp.acc + "  " + gro.acct.
   vln = vln + 1.

   create jl.
   jl.jh  = jh.jh.
   jl.ln  = vln.
   jl.who = jh.who.
   jl.jdt = jh.jdt.
   jl.whn = jh.whn.
   jl.gl = vcomgl.
   jl.acc = "".
   jl.dc = "C".
   jl.crc = 1.
   jl.cam = vtsvc.
     /* jl.fcam = jl.cam. */
   jl.rem[1] = "SERVICE CHARGE ON TELEPHONE BILLS".
 end. /* if available gro */

 find first gro where gro.rdt eq g-today and gro.type eq 2
		      and gro.sts eq 5 no-error.
 if available gro then do:
   find grotyp where grotyp.type eq 2.
   if grotyp.pby eq 2 then do:
     for each gro where gro.rdt eq g-today and gro.sts eq 5 and gro.type eq 2:
       vgsvc = vgsvc + gro.svc.
     end.
   end. /* if grotyp.pby eq 2 */
   else if grotyp.pby eq 1 and grotyp.scg eq 2 then vgsvc = grotyp.camt * vgnum.
   else if grotyp.pby eq 1 and grotyp.scg eq 1 then
      vgsvc = round(vgamt * grotyp.crate / 100 * exp(10,crc.decpnt),0)
			       / exp(10,crc.decpnt).
   else undo,leave.

   do on error undo, retry:
     run x-jhnew.
     find jh where jh.jh = s-jh.
     vgtrx = s-jh.
     vln = 1.
   end.

   create jl.
   jl.jh  = jh.jh.
   jl.ln  = vln.
   jl.who = jh.who.
   jl.jdt = jh.jdt.
   jl.whn = jh.whn.
   jl.gl = vapagl.
   jl.acc = "".
   jl.dc = "D".
   jl.crc = 1.
   jl.dam =  vgsvc.
     /* jl.fdam = jl.dam. */
   jl.rem[1] = grotyp.acc + "  " + gro.acct.
   vln = vln + 1.

   create jl.
   jl.jh  = jh.jh.
   jl.ln  = vln.
   jl.who = jh.who.
   jl.jdt = jh.jdt.
   jl.whn = jh.whn.
   jl.gl = vcomgl.
   jl.acc = "".
   jl.dc = "C".
   jl.crc = 1.
   jl.cam =  vgsvc.
     /* jl.fcam = jl.cam. */
   jl.rem[1] = "SERVICE CHARGE ON GAS & ELECTRIC.".
 end.

 find first gro where gro.rdt eq g-today and gro.type eq 3
		 and gro.sts eq 5 no-error.
 if available gro then do:
   find grotyp where grotyp.type eq 3.
   if grotyp.pby eq 2 then do:
     for each gro where gro.rdt eq g-today and gro.sts eq 5 and gro.type eq 3:
       visvc = visvc + gro.svc.
     end.
   end. /* if grotyp.pby eq 2 */
   else if grotyp.pby eq 1 and grotyp.scg eq 2 then visvc = grotyp.camt * vinum.
   else if grotyp.pby eq 1 and grotyp.scg eq 1 then
      visvc = round(viamt * grotyp.crate / 100 * exp(10,crc.decpnt),0)
			       / exp(10,crc.decpnt).
   else undo,leave.
   do on error undo, retry:
     run x-jhnew.
     find jh where jh.jh = s-jh.
     vitrx = s-jh.
     vln = 1.
   end.

   create jl.
   jl.jh  = jh.jh.
   jl.ln  = vln.
   jl.who = jh.who.
   jl.jdt = jh.jdt.
   jl.whn = jh.whn.
   jl.gl = vapagl.
   jl.acc = "".
   jl.dc = "D".
   jl.crc = 1.
   jl.dam =  visvc.
    /* jl.fdam = jl.dam. */
   jl.rem[1] = grotyp.acc + "  " + gro.acct.
   vln = vln + 1.

   create jl.
   jl.jh  = jh.jh.
   jl.ln  = vln.
   jl.who = jh.who.
   jl.jdt = jh.jdt.
   jl.whn = jh.whn.
   jl.gl =  vcomgl.
   jl.acc = "".
   jl.dc = "C".
   jl.crc = 1.
   jl.cam = visvc.
     /* jl.fcam = jl.cam. */
   jl.rem[1] = "SERVICE CHARGE ON FARMER'S INSURANCE".
 end.  /* if available gro (type 3) */

 find first gro where gro.rdt eq g-today and gro.type eq 4
		 and gro.sts eq 5 no-error.
 if available gro then do:
   find grotyp where grotyp.type eq 4.
   if grotyp.pby eq 2 then do:
     for each gro where gro.rdt eq g-today and gro.sts eq 5 and gro.type eq 4:
       vusvc = vusvc + gro.svc.
     end.
   end. /* if grotyp.pby eq 2 */
   else if grotyp.pby eq 1 and grotyp.scg eq 2 then vusvc = grotyp.camt * vunum.
   else if grotyp.pby eq 1 and grotyp.scg eq 1 then
      vusvc = round(vuamt * grotyp.crate / 100 * exp(10,crc.decpnt),0)
			       / exp(10,crc.decpnt).
   else undo,leave.
   do on error undo, retry:
     run x-jhnew.
     find jh where jh.jh = s-jh.
     vutrx = s-jh.
     vln = 1.
   end.

   create jl.
   jl.jh  = jh.jh.
   jl.ln  = vln.
   jl.who = jh.who.
   jl.jdt = jh.jdt.
   jl.whn = jh.whn.
   jl.gl = vapagl.
   jl.acc = "".
   jl.dc = "D".
   jl.crc = 1.
   jl.dam =  vusvc.
     /* jl.fdam = jl.dam. */
   jl.rem[1] = grotyp.acc + "  " + gro.acct.
   vln = vln + 1.

   create jl.
   jl.jh  = jh.jh.
   jl.ln  = vln.
   jl.who = jh.who.
   jl.jdt = jh.jdt.
   jl.whn = jh.whn.
   jl.gl =  vcomgl.
   jl.acc = "".
   jl.dc = "C".
   jl.crc = 1.
   jl.cam = vusvc.
     /* jl.fcam = jl.cam. */
   jl.rem[1] = "SERVICE CHARGE ON CAR INSURANCE".
 end.

 for each gro where gro.rdt eq g-today and gro.sts eq 5:
    gro.sts = 9.
 end.
 vnum = vtnum + vgnum + vinum + vunum.
 vttrn = vtamt - vtsvc.
 vgtrn = vgamt - vgsvc.
 vitrn = viamt - visvc.
 vutrn = vuamt - vusvc.
 vsvc = vtsvc + vgsvc + visvc + vusvc.
 vtot = vttrn + vgtrn + vitrn + vutrn.
 hide frame gro.

 {comp.f}


end.
else leave.
