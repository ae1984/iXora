/* newiof.p
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

/* iofedt.p
*/

def var vans as log init false.
def var cmd as char form "x(6)" extent 5
  initial ["NEXT","SETUP","EDIT","DELETE","QUIT"].

def var vyst as dec format "zzz,zzz,zzz,zzz.99-".
def var vydr like vyst.
def var vycr like vyst.
def var vmst like vyst.
def var vmdr like vyst.
def var vmcr like vyst.
def var vtst like vyst.
def var vtdr like vyst.
def var vtcr like vyst.
def var vbal like vyst.

form cmd with centered no-box no-label row 21 frame slct.

{mainhead.i }  /*  INTER OFFICE REGISTER  */

loop:
repeat:
  form    " OFFICE#    : " iof.iof skip
	  " G/LACCT#   : " iof.gl  skip
	  " GROUP      : " iof.grp skip
	  " NAME       : " iof.name skip
	  " ADDRESS    : " iof.addr[1] skip
	  "            : " iof.addr[2] skip
	  "            : " iof.addr[3] skip
	  " PHONE      : " iof.tel
	  " TELEX       : " at 37 iof.tlx skip
	  " FAX        : " iof.fax
	  " CONTACT     : " at 37 iof.attn format "x(10)" skip(0)
	  " CUR-BALANCE : " vbal skip
	  " YEAR START : " vyst
	  "  YEAR DEBIT  : " vydr skip
	  " YEAR CREDIT : " at 37 vycr skip
	  " MONTH START: " vmst
	  "  MONTH DEBIT : " vmdr skip
	  " MONTH CREDIT: " at 37 vmcr skip
	  " YSTDY START: " vtst
	  "  YSTDY DEBIT : " vtdr skip
	  " YSTDY CREDIT: " at 37 vtcr
	  with row 3 centered no-label title " INTER OFFICE "
	       frame iof.

  view frame iof.
  prompt-for iof.iof with frame iof.
  find iof using iof.iof no-error.
  if not available iof then do:
     bell.
     {mesg.i 1807} update vans.
     if vans eq false then next.
	hide message.
	create iof.
	assign iof.iof.
	iof.rdt = g-today.
	iof.who = g-ofc.
	iof.whn = g-today.
	vans = false.
	end.

     vyst = iof.ydam[1] - iof.ycam[1].
     vydr = iof.dam[1]  - iof.ydam[1].
     vycr = iof.cam[1]  - iof.ycam[1].
     vmst = iof.mdam[1] - iof.mcam[1].
     vmdr = iof.dam[1]  - iof.mdam[1].
     vmcr = iof.cam[1]  - iof.mcam[1].
     vtst = iof.dam[3]  - iof.cam[3].
     vtdr = iof.dam[1]  - iof.dam[3].
     vtcr = iof.cam[1]  - iof.cam[3].
     vbal = iof.dam[1] - iof.cam[1].

     display
	iof.gl
	iof.grp
	iof.name
	iof.addr[1]
	iof.addr[2]
	iof.addr[3]
	iof.tel
	iof.tlx
	iof.fax
	iof.attn
	vbal
	vyst
	vydr
	vycr
	vmst
	vmdr
	vmcr
	vtst
	vtdr
	vtcr
	with frame iof.
     display cmd auto-return with frame slct.
     repeat:
	choose field cmd with frame slct.
	if frame-value eq "NEXT" then leave.
	else if frame-value eq "DELETE" then do:
	   {mesg.i 0970} update vans.
	   if vans then delete iof.
	   hide message.
	   clear frame iof all.
	   vans = false.
	   next loop.
	   end.
	else if frame-value eq "SETUP" then do:
	update
	   iof.gl
	   iof.grp
	   iof.name
	   iof.addr[1]
	   iof.addr[2]
	   iof.addr[3]
	   iof.tel
	   iof.tlx
	   iof.fax
	   iof.attn
	   with frame iof.
	end.
     else if frame-value eq "EDIT" then do:
	update
	   vyst
	   vydr
	   vycr
	   vmst
	   vmdr
	   vmcr
	   vtst
	   vtdr
	   vtcr
	   with frame iof.
	find gl where gl.gl eq iof.gl.
	if gl.type eq "A" then do:
	   iof.ydam[1] = vyst.
	   iof.ycam[1] = 0.
	   end.
	else do:
	   iof.ycam[1] = vyst.
	   iof.ydam[1] = 0.
	   end.
	iof.dam[1]  = iof.ydam[1] + vydr.
	iof.cam[1]  = iof.ycam[1] + vycr.
	iof.mdam[1] = iof.dam[1]  - vmdr.
	iof.mcam[1] = iof.cam[1]  - vmcr.
	iof.dam[3]  = iof.dam[1]  - vtdr.
	iof.cam[3]  = iof.cam[1]  - vtcr.
	end.
     else if frame-value eq "QUIT" then return.
     end.
  clear frame slct all.
 end.
