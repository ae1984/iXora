/* s-rimpay.p
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

/* s-rimpay.p
*/

{global.i}

def shared var s-bank like rim.bank.
def shared var s-lcno like rim.lcno.

def new shared var s-jh  like jh.jh.
def new shared var kjh  like jh.jh.
def new shared var s-consol like jh.consol initial false.

def new shared var s-ptype    like rpay.ptype.
def new shared var s-ps       like rpay.ps.
def new shared var s-gl       like rpay.gl.
def new shared var s-orgamt   like rpay.orgamt.
def new shared var s-drft     like rpay.drft.
def new shared var s-comm     like rpay.comm.
def new shared var s-payamt   like rpay.payamt.
def new shared var s-pacct    like rpay.pacct.
def new shared var s-acc      like rpay.acc.
def new shared var s-pdt      like rpay.pdt.
def new shared var s-orgdt    like rpay.orgdt.
def new shared var s-duedt    like rpay.duedt.
def new shared var s-intdt    like rpay.intdt.
def new shared var s-trm      like rpay.trm.
def new shared var s-intdue   like rpay.intdue.
def new shared var s-intrate  like rpay.intrate.
def new shared var s-interest like rpay.interest.
def new shared var s-itype    like rpay.itype.
def new shared var s-cbank    like rpay.cbank.
def new shared var s-cbname   like rpay.cbname.
def new shared var s-crbank   like rpay.crbank.
def new shared var s-acct     like rpay.acct.
def new shared var s-tref     like rpay.tref.
def new shared var s-rem      like rpay.rem.
def new shared var s-bill     like rpay.bill.

def var ans as log.
def var vans as log.

def buffer b-rpay for rpay.
def buffer c-rpay for rpay.
def buffer c-bank for bank.

def var vcsval as dec.
def var vcrval as dec.
def var vcival as dec.
def var vrbgl  as int.
def var vdefdfb as cha.
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

find sysc where sysc.sysc eq "CSGL". vcsval = sysc.deval.
find sysc where sysc.sysc eq "CRGL". vcrval = sysc.deval.
find sysc where sysc.sysc eq "CIGL". vcival = sysc.deval.
/* find sysc where sysc.sysc eq "COBA". vcrval = sysc.deval. */

find sysc where sysc.sysc eq "RBGL". vrbgl = sysc.inval. /* nego and r/i */
/* this should be separated */

find sysc where sysc.sysc eq "DEFDFB". vdefdfb = sysc.chval.

find rim where rim.bank eq s-bank
	  and  rim.lcno eq s-lcno.

form s-ptype colon 11 s-ps colon 45 skip
     s-gl    colon 11 gl.des skip
     s-orgamt colon 11 s-drft colon 45 skip
     s-comm[1] colon 11 label "THEIR-CHG"
     s-comm[2] colon 45 label "OUR-COMM" skip
     s-comm[4] colon 11 label "ADV-CHG"
     s-comm[3] colon 45 label "ISS.BNK-C" skip
     s-payamt colon 11 skip
     s-pacct colon 11 s-acc no-label s-pdt colon 45 skip
     s-orgdt colon 11 s-duedt colon 45 skip
     s-intdt colon 11 s-intdue colon 45 skip
     s-intrate colon 11 s-interest colon 45 skip
     s-cbank colon 11 s-cbname no-label skip
     s-crbank colon 11 skip
     s-acct colon 11  s-tref colon 45 skip
     s-rem colon 11 skip
     s-bill colon 11 s-jh colon 45 skip
     with row 4 side-label centered title " PAYMENT "
     overlay top-only frame rpay.

s-comm[4] = rim.amt[4].
if rim.tennor eq 1 then s-ptype = 2.   /* sight */
		   else s-ptype = 1.   /* usance */

display s-comm[4] with frame rpay.
update s-ptype validate(s-ptype ge 1 and s-ptype le 3,"")
	       help "1.BILL 2.REIMB. SIGHT 3.ADVISE FEE"
       with frame rpay.
if s-ptype eq 3
  then do:
  /*
  update s-comm[4] with frame rpay.
  */
  end. /* ADVISE CHG ONLY */
  else do:
    /* 1. registerd as usance but paying as sight case */
    if rim.tennor ne 1 and s-ptype eq 2
      then do:
	bell.
	update s-ps with frame rpay.
	if s-ps eq false then undo, retry.
      end.

    if s-ptype eq 1
      then do on error undo, retry:  /* 2. usance only */
	s-gl = vrbgl.
	update s-gl validate(can-find(gl where gl.gl eq s-gl),"")
		    help "G/L ACCOUNT NUMBER"
	       with frame rpay.
	find gl where gl.gl eq s-gl.
	if (gl.subled eq "bill" and gl.level eq 1) eq false
	  then do:
	    bell.
	    {mesg.i 9832}.
	    undo, retry.
	  end.
	display gl.des with frame rpay.
	if rim.ibf eq true and s-gl mod 10 ne 1 or
	   rim.ibf eq false and s-gl mod 10 ne 0
	  then do:
	    bell.
	    {mesg.i 1202}.
	    undo, retry.
	  end.
      end.   /* usance only */

    if s-ptype eq 1 or s-ptype eq 2
      then do:
	if rim.grp eq 1 or rim.grp eq 2
	  then s-comm[2] = vcrval.
	else if rim.grp eq 3
	  then s-comm[2] = vcival.
      end.
    update s-orgamt with frame rpay.
    if rim.amt[2] + s-orgamt gt rim.amt[1] * (1 + rim.tol / 100)
      then do:
	bell.
	{mesg.i 6809}.
	undo, retry.
      end.
    find crc of rim.
    s-drft = s-orgamt / crc.rate[1].
    update s-drft with frame rpay.

    /* ------------ */
    find first c-rpay where c-rpay.lcno eq s-lcno
      and c-rpay.drft eq s-drft use-index lcno no-error.
    if available c-rpay
    then do:
      {mesg.i 4814} update ans.
      if ans eq false then undo, retry.
    end.
    /* ------------- */

    update s-comm[1] when rim.fee ne 1
	   s-comm[2]
	   /* s-comm[4] */
	   s-comm[3]
	   with frame rpay.
    if rim.fee eq 1
      then do:
	s-payamt = s-drft - (s-comm[2] + s-comm[3] + s-comm[4]).
      end.
    else if rim.fee eq 2
      then do:
	s-payamt = s-drft + s-comm[1] - s-comm[3].
      end.
    else if rim.fee eq 3
      then do:
	s-payamt = s-drft + s-comm[1]
		    - (s-comm[2] + s-comm[3] + s-comm[4]).
      end.
    display s-payamt with frame rpay.

    update s-pacct validate(s-pacct ge 1 and s-pacct le 3,"")
		   help "1.INWARD 2.DFB 3.OFFICIAL CHECK"
	   with frame rpay.
    if s-pacct eq 1 then do: {mesg.i 4803}.
       update s-acc with frame rpay.
    end.
    else if s-pacct eq 2
      then do:
	s-acc = vdefdfb.
	update s-acc with frame rpay.
	find bank where bank.bank = s-acc no-error.
	if not available bank then undo,retry.
	else message bank.name.

	/*
	{mesg.i 9825}.
	*/
      end.
    else if s-pacct eq 3 then do:
      {mesg.i 9831}.
      update s-acc
	 validate(can-find(ock where ock.ock eq s-acc) eq false,
      "EXISTING CHECK#")
      with frame rpay.
    end.

    if s-pacct eq 1
      then do:
	if integer(s-acc) le 0
	  then do:
	    bell.
	    {mesg.i 4803}.
	    undo, retry.
	  end.
      end.

    s-pdt = g-today.
    update s-pdt with frame rpay.
    s-orgdt = s-pdt.
    if rim.tennor ne 1 and s-ptype eq 1 /* usance payment */
      then do:
	update s-orgdt with frame rpay.
	s-intdt = s-orgdt.
	s-trm = rim.trm.
	s-duedt = s-orgdt + s-trm.
	repeat:
	  find hol where hol.hol eq s-duedt no-error.
	  if not available hol and
   weekday(s-duedt) ge v-weekbeg and
   weekday(s-duedt) le v-weekend
	    then leave.
	    else s-duedt = s-duedt + 1.
	end.
      /* ------------------------------------------------ */
      if s-pdt gt rim.expdt then
	do:
	  {mesg.i 4809} update vans.
	  if vans ne true then undo, retry.
	end.
	/* ------------------------------------------------ */
	s-trm = s-duedt - s-orgdt.
	s-intdue = s-duedt.
	display s-duedt s-intdt with frame rpay.
	update s-intdt
	       with frame rpay.

	update s-intdue
	       validate(s-intdue gt input s-intdt and
			s-intdue le input s-duedt,"")
	       with frame rpay.
	repeat:
	  find hol where hol.hol eq s-intdue no-error.
	  if not available hol and
   weekday(s-intdue) ge v-weekbeg and
   weekday(s-intdue) le v-weekend
	    then leave.
	    else s-intdue = s-intdue + 1.
	end.
	display s-intdue with frame rpay.
	update s-intrate with frame rpay.
	s-interest = s-drft * (s-intdue - s-intdt)
		      * s-intrate / 36000.
	display s-interest
		with frame rpay.
	if rim.intpay eq 1 then s-itype = "A".
			   else s-itype = "D".
      end. /* USANCE PAYMENT */
      else do:
	if rim.tennor eq 1 and s-ptype eq 2 then do:
	/* ------------------------------------------------ */
	if s-pdt gt rim.expdt then do:
	  {mesg.i 4809} update vans.
	  if vans ne true then undo, retry.
	end.
	/* ------------------------------------------------ */
	end.
      end.  /* SIGHT PAYMENT */

    update s-cbank validate(s-cbank eq "" or
			    can-find(bank where bank.bank eq s-cbank),
			    "RECORD NOT FOUND.")
	   with frame rpay.
    if s-cbank eq ""
      then do:
	update s-cbname with frame rpay.
      end.
      else do:
	find c-bank where c-bank.bank eq s-cbank.
	display c-bank.name @ s-cbname with frame rpay.
	s-crbank = c-bank.crbank.
	s-acct = c-bank.acct.
      end.
    update s-crbank
	   s-acct s-tref s-rem
	   with frame rpay.
  end.   /* EXCEPT ADV CHARGE CASES  e.g. SIGHT AND USANCE...  */
bell.
{mesg.i 0928} update ans.
if ans eq false then undo, retry.
if s-ptype ne 3
  then run s-rimptr.
  else run s-rimpad.
display s-bill s-jh with frame rpay.
pause 4.
kjh = s-jh.
run s-rimvou.
hide frame rpay.
