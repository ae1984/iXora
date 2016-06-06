/* s-negpay.p
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

/* s-negpay.p
*/

{global.i}

def shared var s-bank like rim.bank.
def shared var s-lcno like rim.lcno.

def buffer b-rpay for rpay.
def buffer c-rpay for rpay.
def buffer c-bank for bank.

def new shared var s-jh  like jh.jh.
def new shared var kjh  like jh.jh.
def new shared var s-consol like jh.consol initial false.
def new shared temp-table w-rpay like rpay.

def var ans as log.
def var vans as log.
def var vnlab as cha format "x(30)" extent 10.
def var vngl  like gl.gl extent 10.
def var vncom like sysc.deval extent 10.

def var vcsval as dec.
def var vcrval as dec.
def var vrbgl  as int.
def var vdefdfb as cha.
def var vngtgl as int.
def var vngsgl as int.
def var vcnsgl as int.
def var vcntgl as int.
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

create w-rpay.

find sysc where sysc.sysc eq "CSGL". vcsval = sysc.deval.
find sysc where sysc.sysc eq "CRGL". vcrval = sysc.deval.
/* find sysc where sysc.sysc eq "COBA". vcrval = sysc.deval. */

find sysc where sysc.sysc eq "RBGL". vrbgl = sysc.inval. /* nego and r/i */
/* this should be separated */

find sysc where sysc.sysc eq "DEFDFB". vdefdfb = sysc.chval.
find sysc where sysc.sysc eq "NGTGL".  vngtgl = sysc.inval.
find sysc where sysc.sysc eq "NGSGL".  vngsgl = sysc.inval.
find sysc where sysc.sysc eq "CNSGL".  vcnsgl = sysc.inval.
find sysc where sysc.sysc eq "CNTGL".  vcntgl = sysc.inval.
find sysc where sysc.sysc eq "NEGOC1". vnlab[1] = sysc.chval.
				       vngl[1]  = sysc.inval.
				       vncom[1] = sysc.deval.
find sysc where sysc.sysc eq "NEGOC2". vnlab[2] = sysc.chval.
				       vngl[2]  = sysc.inval.
				       vncom[2] = sysc.deval.
find sysc where sysc.sysc eq "NEGOC3". vnlab[3] = sysc.chval.
				       vngl[3]  = sysc.inval.
				       vncom[3] = sysc.deval.
find sysc where sysc.sysc eq "NEGOC4". vnlab[4] = sysc.chval.
				       vngl[4]  = sysc.inval.
				       vncom[4] = sysc.deval.
find sysc where sysc.sysc eq "NEGOC5". vnlab[5] = sysc.chval.
				       vngl[5]  = sysc.inval.
				       vncom[5] = sysc.deval.
find sysc where sysc.sysc eq "NEGOC6". vnlab[6] = sysc.chval.
				       vngl[6]  = sysc.inval.
				       vncom[6] = sysc.deval.
find sysc where sysc.sysc eq "NEGOC7". vnlab[7] = sysc.chval.
				       vngl[7]  = sysc.inval.
				       vncom[7] = sysc.deval.
find sysc where sysc.sysc eq "NEGOC8". vnlab[8] = sysc.chval.
				       vngl[8]  = sysc.inval.
				       vncom[8] = sysc.deval.
find sysc where sysc.sysc eq "NEGOC9". vnlab[9] = sysc.chval.
				       vngl[9]  = sysc.inval.
				       vncom[9] = sysc.deval.
find sysc where sysc.sysc eq "NEGOCA". vnlab[10] = sysc.chval.
				       vngl[10]  = sysc.inval.
				       vncom[10] = sysc.deval.
find rim where rim.bank eq s-bank
	  and  rim.lcno eq s-lcno.

form w-rpay.ptype colon 11 w-rpay.ps colon 45 skip
     w-rpay.gl    colon 11 gl.des skip
     w-rpay.orgamt colon 11 w-rpay.drft colon 45 skip
     w-rpay.comm[2] colon 45 label "OUR-COMM" skip
     w-rpay.comm[4] colon 11 label "ADV-CHG"
     w-rpay.comm[3] colon 45 label "ISS.BNK-C" skip
     w-rpay.comm[5] colon 11 label "OTHER COST" skip
     w-rpay.payamt colon 11 skip
     w-rpay.pacct colon 11 w-rpay.acc no-label w-rpay.pdt colon 45 skip
     w-rpay.orgdt colon 11 w-rpay.duedt colon 45 skip
     w-rpay.intdt colon 11 w-rpay.intdue colon 45 skip
     w-rpay.intrate colon 11 w-rpay.interest colon 45 skip
     w-rpay.cbank colon 11 w-rpay.cbname no-label skip
     w-rpay.crbank colon 11 skip
     w-rpay.acct colon 11  w-rpay.tref colon 45 skip
     w-rpay.rem colon 11 skip
     w-rpay.bill colon 11 s-jh colon 45 skip
     with row 4 side-label centered title "NEGOTIATION"
     overlay frame rpay.

form vnlab[1] w-rpay.ocomm[1] skip
     vnlab[2] w-rpay.ocomm[2] skip
     vnlab[3] w-rpay.ocomm[3] skip
     vnlab[4] w-rpay.ocomm[4] skip
     vnlab[5] w-rpay.ocomm[5] skip
     vnlab[6] w-rpay.ocomm[6] skip
     vnlab[7] w-rpay.ocomm[7] skip
     vnlab[8] w-rpay.ocomm[8] skip
     vnlab[9] w-rpay.ocomm[9] skip
     vnlab[10] w-rpay.ocomm[10] skip
     with row 9 no-label overlay top-only centered frame ocomm.

w-rpay.comm[4] = rim.amt[4].
if rim.tennor eq 1 then w-rpay.ptype = 5.   /* sight */
		   else w-rpay.ptype = 4.   /* usance */

display w-rpay.comm[4] with frame rpay.
update w-rpay.ptype validate(w-rpay.ptype ge 3 and w-rpay.ptype le 5,"")
	       help "3.ADVISE FEE 4.USANCE 5. SIGHT"
       with frame rpay.
if w-rpay.ptype eq 3
  then do:
  /*
  update w-rpay.comm[4] with frame rpay.
  */
  end. /* ADVISE CHG ONLY */
  else do:
    /* 1. registerd as usance but paying as sight case */
    if rim.tennor ne 1 and w-rpay.ptype eq 5
      then do:
	bell.
	update w-rpay.ps with frame rpay.
	if w-rpay.ps eq false then undo, retry.
      end.

    if w-rpay.ptype eq 4 or w-rpay.ptype eq 5
      then do on error undo, retry:
	     if w-rpay.ptype eq 4 then w-rpay.gl = vngtgl.
	else if w-rpay.ptype eq 5 then w-rpay.gl = vngsgl.
	update w-rpay.gl validate(can-find(gl where gl.gl eq w-rpay.gl),"")
		    help "G/L ACCOUNT NUMBER"
	       with frame rpay.
	find gl where gl.gl eq w-rpay.gl.
	if (w-rpay.ptype eq 4 and
	    gl.subled eq "bill" and gl.level eq 1 and gl.grp ne 1) eq false
	    and
	   (w-rpay.ptype eq 5 and
	    gl.subled eq "bill" and gl.level eq 1 and gl.grp eq 1) eq false
	  then do:
	    bell.
	    {mesg.i 9832}.
	    undo, retry.
	  end.
	display gl.des with frame rpay.
	if rim.ibf eq true and gl.ibfact eq false or
	   rim.ibf eq false and gl.ibfact eq true
	  then do:
	    bell.
	    {mesg.i 1202}.
	    undo, retry.
	  end.
      end.

    if w-rpay.ptype eq 4 or w-rpay.ptype eq 5
      then w-rpay.comm[2] = vcrval. /* nego commission ??????? */

    update w-rpay.orgamt with frame rpay.
    if rim.amt[2] + w-rpay.orgamt gt rim.amt[1] * (1 + rim.tol / 100)
      then do:
	bell.
	{mesg.i 6809}.
	undo, retry.
      end.
    find crc of rim.
    w-rpay.drft = w-rpay.orgamt. /* divided by crc.rate[1] for single g/l */
    update w-rpay.drft with frame rpay.

    /* ------------ */
    find first c-rpay where c-rpay.lcno eq w-rpay.lcno
      and c-rpay.drft eq w-rpay.drft use-index lcno no-error.
    if available c-rpay
    then do:
      {mesg.i 4814} update ans.
      if ans eq false then undo, retry.
    end.
    /* ------------- */
    display vnlab with frame ocomm.
    update w-rpay.ocomm[1] when vnlab[1] ne ""
	   w-rpay.ocomm[2] when vnlab[2] ne ""
	   w-rpay.ocomm[3] when vnlab[3] ne ""
	   w-rpay.ocomm[4] when vnlab[4] ne ""
	   w-rpay.ocomm[5] when vnlab[5] ne ""
	   w-rpay.ocomm[6] when vnlab[6] ne ""
	   w-rpay.ocomm[7] when vnlab[7] ne ""
	   w-rpay.ocomm[8] when vnlab[8] ne ""
	   w-rpay.ocomm[9] when vnlab[9] ne ""
	   w-rpay.ocomm[10] when vnlab[10] ne ""
	   with frame ocomm.
    w-rpay.comm[2] = w-rpay.ocomm[1]
	      + w-rpay.ocomm[2]
	      + w-rpay.ocomm[3]
	      + w-rpay.ocomm[4]
	      + w-rpay.ocomm[5]
	      + w-rpay.ocomm[6]
	      + w-rpay.ocomm[7]
	      + w-rpay.ocomm[8]
	      + w-rpay.ocomm[9]
	      + w-rpay.ocomm[10].
    display w-rpay.comm[2] with frame rpay.
    update /* w-rpay.comm[4] */
	   w-rpay.comm[3]
	   w-rpay.comm[5]
	   with frame rpay.
    if rim.fee eq 1       /* this part will be modified */
      then do:
	w-rpay.payamt = w-rpay.drft -
	(w-rpay.comm[2] + w-rpay.comm[3] + w-rpay.comm[4]).
      end.
    else if rim.fee eq 2
      then do:
	w-rpay.payamt = w-rpay.drft + w-rpay.comm[1] - w-rpay.comm[3].
      end.
    else if rim.fee eq 3
      then do:
	w-rpay.payamt = w-rpay.drft + w-rpay.comm[1]
		    - (w-rpay.comm[2] + w-rpay.comm[3] + w-rpay.comm[4]).
      end.                /* this part will be modified */
    display w-rpay.payamt with frame rpay.

    update w-rpay.pacct validate(w-rpay.pacct ge 1 and w-rpay.pacct le 4,"")
		   help "1.INWARD 2.DFB 3.CURRENT ACCOUNT 4.CASH"
	   with frame rpay.
    if w-rpay.pacct eq 1 then do:
       {mesg.i 4803}.
       update w-rpay.acc with frame rpay.
    end.
    else if w-rpay.pacct eq 2
      then do:
	w-rpay.acc = vdefdfb.
	update  w-rpay.acc with frame rpay.
	{mesg.i 9825}.
	find dfb where dfb.dfb eq w-rpay.acc no-error.
	if not available dfb then do:
	  {mesg.i 0230}.
	  undo,retry.
	end.
      end.
    else if w-rpay.pacct eq 3 then do on error undo , retry:
      {mesg.i 1812}.
      update w-rpay.acc
   /* validate(can-find(aaa where aaa.aaa eq w-rpay.acc),
      "RECORD NOT FOUND")  */
      with frame rpay.
      find aaa where aaa.aaa = w-rpay.acc no-error.
      if aaa.crc ne rim.crc then do:
	 {mesg.i 0998}.
	 undo, retry.
      end.
    end.

    if w-rpay.pacct eq 1
      then do:
	if integer(w-rpay.acc) le 0
	  then do:
	    bell.
	    {mesg.i 4803}.
	    undo, retry.
	  end.
      end.

    w-rpay.pdt = g-today.
    update w-rpay.pdt with frame rpay.
    w-rpay.orgdt = w-rpay.pdt.
    if rim.tennor ne 1 and w-rpay.ptype eq 4 /* usance payment */
      then do:
	update w-rpay.orgdt with frame rpay.
	w-rpay.intdt = w-rpay.orgdt.
	w-rpay.trm = rim.trm.
	w-rpay.duedt = w-rpay.orgdt + w-rpay.trm.
	repeat:
	  find hol where hol.hol eq w-rpay.duedt no-error.
	  if not available hol and
   weekday(w-rpay.duedt) ge v-weekbeg and
   weekday(w-rpay.duedt) le v-weekend
	    then leave.
	    else w-rpay.duedt = w-rpay.duedt + 1.
	end.
      /* ------------------------------------------------ */
      if w-rpay.pdt gt rim.expdt then
	do:
	  {mesg.i 4809} update vans.
	  if vans ne true then undo, retry.
	end.
	/* ------------------------------------------------ */
	w-rpay.trm = w-rpay.duedt - w-rpay.orgdt.
	w-rpay.intdue = w-rpay.duedt.
	display w-rpay.duedt w-rpay.intdt with frame rpay.
	update w-rpay.intdt
	       with frame rpay.

	update w-rpay.intdue
	       validate(w-rpay.intdue gt input w-rpay.intdt and
			w-rpay.intdue le input w-rpay.duedt,"")
	       with frame rpay.
	repeat:
	  find hol where hol.hol eq w-rpay.intdue no-error.
	  if not available hol and
   weekday(w-rpay.intdue) ge v-weekbeg and
   weekday(w-rpay.intdue) le v-weekend
	    then leave.
	    else w-rpay.intdue = w-rpay.intdue + 1.
	end.
	display w-rpay.intdue with frame rpay.
	update w-rpay.intrate with frame rpay.
	w-rpay.interest = w-rpay.drft * (w-rpay.intdue - w-rpay.intdt)
		      * w-rpay.intrate / 36000.
	display w-rpay.interest
		with frame rpay.
	if rim.intpay eq 1 then w-rpay.itype = "A".
			   else w-rpay.itype = "D".
      end. /* USANCE PAYMENT */
      else do:
	if rim.tennor eq 1 and w-rpay.ptype eq 5 then do:
	/* ------------------------------------------------ */
	if w-rpay.pdt gt rim.expdt then do:
	  {mesg.i 4809} update vans.
	  if vans ne true then undo, retry.
	end.
	/* ------------------------------------------------ */
	end.
      end.  /* SIGHT PAYMENT */

    update w-rpay.cbank validate(w-rpay.cbank eq "" or
			    can-find(bank where bank.bank eq w-rpay.cbank),
			    "RECORD NOT FOUND.")
	   with frame rpay.
    if w-rpay.cbank eq ""
      then do:
	update w-rpay.cbname with frame rpay.
      end.
      else do:
	find c-bank where c-bank.bank eq w-rpay.cbank.
	display c-bank.name @ w-rpay.cbname with frame rpay.
	w-rpay.crbank = c-bank.crbank.
	w-rpay.acct = c-bank.acct.
      end.
    update w-rpay.crbank
	   w-rpay.acct w-rpay.tref w-rpay.rem
	   with frame rpay.
  end.   /* EXCEPT ADV CHARGE CASES  e.g. SIGHT AND USANCE...  */
bell.
{mesg.i 0928} update ans.
if ans eq false then undo, retry.
if w-rpay.ptype ne 3
  then run s-negptr.
  else run s-rimpad.
display w-rpay.bill s-jh with frame rpay.
kjh = s-jh.
run s-rimvou.
hide frame rpay.
