/* s-dbgla.p
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

/* s-dbgl.p
*/

def shared var kbank  like bank.bank.
def shared var vbank  like bank.bank.
def shared var vcom   like wf.com.
def shared var vscom  like wf.scom.
def shared var vcdt   like wf.cdt.
def shared var vtpy   like wf.tpy.
def shared var vtpyac like wf.tpyac.
def shared var s-jh   like jl.jh.
def shared var s-jln  like jl.ln.
def shared var s-amt  like jl.cam.
def shared var srem as char format "x(75)" extent 5.
def shared var wfln like wf.ln.
def var answer as log.
def var vns as log.
def var vans as log.
def var vlne like wf.lne.
def var rem6 as log init true. /* FINAL BENEFICIARY ? */
def var xxx as char format "x(3)".
def var fv  as cha.
def var inc as int.
def var prc as log.
def var oldround as log.
def var vln as int.
def var vcon like wf.ln.

def var vchip like wf.cdt.
def var vfrb  like wf.cdt.

def var vdef as char format "x(79)".
def var kdef as char format "x(79)".
def var vname like bank.name.

def var recno as int.
def var code as int format '>>>>>9'.
def var ink as int.
def var pnk as char format "x" .
def var rf as char format "x(8)".
def var stpy as char format "x(16)".
def var sfpy as char format "x(16)".
def var bname like bank.name.


{global.i}

/*find jl where jl.jh eq s-jh and jl.ln = s-jln. */

do on error undo,retry:
form  " LINE:" wf.lne  skip
      "  CDT:" wf.cdt  skip
      "  3PY:" wf.tpy  skip
      "3PYAC:" wf.tpyac  skip
      "FINAL BENEFICIALY ? " rem6 skip
      "  4PY:" wf.fpy  skip
      "4PYAC:" wf.fpyac  skip
      "FINAL BENEFICIALY IS A BANK? " wf.bnk skip
      "TYPE OF ADVISE ? " wf.advtyp skip
      "ADVS:" wf.advcom  skip
      " AMT:" wf.amt  skip
      " VAL:" wf.val skip
      "COMM:" wf.com  skip
      "ADDT:" wf.scom skip
      "TESTKEY:" wf.tst skip
       with  no-label row 4 title "WIRE TRANSFER" frame lsk.
       view frame lsk.

rf = " ".
if kbank = " " and vcdt = " " and vtpy = " " and vtpyac = " " then do:
   update " ENTER CREDIT BANK CODE OR ENTER TO CONTINUE...."
	  kbank with frame vbnk no-label col 2
	  row 2 overlay no-box
	  editing: {gethelp.i} end.
 end.

  if vbank ne " " then do:
     find bank where bank.bank = vbank no-lock no-error.
     if available bank then  do:
     kdef = "T/F -" + bank.bank + "/" + bank.name +
	    "  CHIP:" + bank.chipno + "  ABA:" + bank.frbno.
     vchip = bank.chipno.
     vfrb =  bank.frbno.
     vname = bank.name.
   end.

     else kdef = " ".
   end.

  find bank where bank.bank = kbank no-lock no-error.
  if available bank then
  vdef = bank.bank + "/" + bank.name + "  LINE#:" + bank.lne
	    + "  CHIP:" + bank.chipno + "  ABA:" + bank.frbno.
  else vdef = " ".
  disp vdef skip
       kdef with no-box no-label row 2.

  if available bank then do:

  if  bank.lne ne " " then  do:
     {mesg.i 0908} update vans.

       if vans = true then do:
       find last wf no-lock no-error.
       if not available wf then vln = 1.
       else vln = wf.ln + 1.
       create wf.
       wf.ln = vln.
       wf.lne = bank.lne.
       wf.val = g-today.
       find first tk1-1.
       disp wf.lne with frame lsk.
       if vcdt eq " " then do:
       if bank.crbank ne " " then
       bname = bank.crbank.
       else
       bname = bank.name.
       end.
       else
       bname = vcdt.

       rf = wf.lne.
       wf.com = vcom.
       wf.scom = vscom.
       wf.amt = s-amt.
       disp wf.amt with frame lsk.
       update  /*wf.amt */ wf.val wf.com wf.scom with frame lsk.
       xxx = substring(tk1-1.type,1,3).
       {getkey.i}
       disp wf.tst with frame lsk.
       wf.who = userid('bank').
       wf.whn = g-today.
       wf.tim = time.
       {mesg.i 0928} update prc.
       if prc = false then undo,retry.
     end. /* if true */

  else do:   /* vans = false */

       if vbank ne " " then do:
       vdef = " ".
       find bank where bank.bank = vbank no-lock no-error.
       if available bank then
       vdef = "T/F -" + bank.bank + "/" + bank.name +
	      "  CHIP:" + bank.chipno + "  ABA:" + bank.frbno.
       else vdef = " ".
       end.

       disp vdef with no-box no-label.
       find last wf no-lock no-error.
       if not available wf then vln = 1.
       else vln = wf.ln + 1.
       create wf.
       wf.ln = vln.
       wf.val = g-today.
 {mesg.i 5804}.
 update wf.lne validate(wf.lne = "900" or wf.lne = "9001","RECORD NOT FOUND")
       with frame lsk.

	  wf.cdt = vcdt.
	  wf.tpy = vtpy.
	  wf.tpyac = vtpyac.


       if wf.lne = "9001" then do:

	  if bank.chipno ne " " then do:
	       wf.cdt = bank.chipno.
	       if bank.crbank ne " " then
	       bname = bank.crbank.
	       else
	       bname = bank.name.
	       rf = "9001".
	  end.

	  else do:
		if wf.cdt eq " " then do:

		if bank.crbank = " " then
		wf.cdt = bank.name .
		else wf.cdt = bank.crbank.
		rf = " ".

		end.
	  end.

       end.

       else do:  /* 900 FEDS */
	if bank.frbno ne " " then do:
	   wf.cdt = bank.frbno.
		 if bank.crbank ne " " then
		    bname = bank.crbank.
		    else
		    bname = bank.name.
	   rf = "900".
	end.
	  else do:
		if wf.cdt eq " " then do:
		 if bank.crbank = " " then
		 wf.cdt = bank.name .
		 else wf.cdt = bank.crbank.
		 rf = " ".
	       end.
       end.
     end.

       if wf.tpy = " " then
       wf.tpy = bank.name.
       if wf.tpyac = " " then
       wf.tpyac = bank.acct.

   update wf.cdt wf.tpy wf.tpyac with frame lsk.
   update rem6
	 help "(Y)ES/(N)O"
	 with frame lsk.
  if rem6 eq false then update wf.fpy wf.fpyac with frame lsk.
   update wf.bnk wf.advtyp with frame lsk.
  if wf.advtyp ne "N" then  update wf.advcom with frame lsk.
       wf.amt = s-amt.
       wf.com = vcom.
       wf.scom = vscom.
       disp wf.amt with frame lsk.
  update /*wf.amt*/ wf.val wf.com wf.scom with frame lsk.
  if wf.tpy = " " then xxx = substring(wf.cdt,1,3).
  else xxx = substring(wf.tpy,1,3).
  {getkey.i}

  disp wf.tst with frame  lsk.
       wf.who = userid('bank').
       wf.whn = g-today.
       wf.tim = time.
  {mesg.i 0928} update vns .
  if vns = false then undo, retry.
    end. /* if vans = false */
   end. /* if bank.lne ne " " */

  else if  bank.lne eq " " then do:
       find last wf no-lock no-error.
       if not available wf then vln = 1.
       else vln = wf.ln + 1.
       create wf.
       wf.ln = vln.
       wf.val = g-today.
 {mesg.i 5804}.
 update wf.lne validate(wf.lne = "900" or wf.lne = "9001","RECORD NOT FOUND")
       with frame lsk.

	  if wf.lne = "900" and vfrb ne " " then do:
	  wf.cdt = vfrb.
	  bname = vname.
	  rf = "900".
	  end.
	  else if wf.lne = "9001" and vchip ne " " then do:
	  wf.cdt = vchip.
	  bname = vname.
	  rf = "9001".
	  end.

	  wf.tpy = vtpy.
	  wf.tpyac = vtpyac.


       if wf.lne = "9001" then do:
	  if bank.chipno ne " " then do:
	       wf.cdt = bank.chipno.
	       if bank.crbank ne " " then
	       bname = bank.crbank.
	       else
	       bname = bank.name.
	       rf = "9001".
	  end.

	  else do:
		if wf.cdt eq " " then do:
		if bank.crbank = " " then
		wf.cdt = bank.name .
		else
		wf.cdt = bank.crbank.
		rf = " ".
		end.
	  end.
       end.

       else do:  /* 900 FEDS */

	if bank.frbno ne " " then do:
	   wf.cdt = bank.frbno.
		 if bank.crbank ne " " then
		    bname = bank.crbank.
		    else
		    bname = bank.name.
	   rf = "900".
	end.
	  else do:
		if wf.cdt eq " " then do:
		if bank.crbank = " " then
		 wf.cdt = bank.bank.
		else
		 wf.cdt = bank.crbank.
		 rf = " ".
	    end.
       end.
      end.
       if wf.tpy = " " then
       wf.tpy = bank.name.
       if wf.tpyac = " " then
       wf.tpyac = bank.acct.

   update wf.cdt wf.tpy wf.tpyac with frame lsk.
   update rem6
	 help "(Y)ES/(N)O"
	 with frame lsk.
  if rem6 eq false then update wf.fpy wf.fpyac with frame lsk.
   update wf.bnk wf.advtyp with frame lsk.
  if wf.advtyp ne "N" then  update wf.advcom with frame lsk.
       wf.amt = s-amt.
       wf.com = vcom.
       wf.scom = vscom.
       disp wf.amt with frame lsk.
  update /*wf.amt*/ wf.val wf.com wf.scom with frame lsk.
  if wf.tpy = " " then xxx = substring(wf.cdt,1,3).
  else xxx = substring(wf.tpy,1,3).
  {getkey.i}

  disp wf.tst with frame  lsk.
       wf.who = userid('bank').
       wf.whn = g-today.
       wf.tim = time.
  {mesg.i 0928} update vns .
  if vns = false then undo, retry.
  end.
end. /* if available bank */

  else do:     /* not available bank */

  find bank where bank.bank = vbank no-lock no-error.
  if available bank then do:
  vdef = bank.bank + "/" + bank.name + "  LINE#:" + bank.lne
	    + "  CHIP:" + bank.chipno + "  ABA:" + bank.frbno.
  bname = bank.name.
  end.
  else vdef = " ".
  disp vdef with no-box no-label.

       find last wf no-lock no-error.
       if not available wf then vln = 1.
       else vln = wf.ln + 1.
       create wf.
       wf.val = g-today.
       wf.ln = vln.
 {mesg.i 5804}.
 update wf.lne validate(wf.lne = "900" or wf.lne = "9001","RECORD NOT FOUND")
       with frame lsk.

       if vdef ne " " and wf.lne = "900" then do:
	     wf.cdt = bank.frbno.
	     rf = "900".
       end.
       else if vdef ne " " and wf.lne = "9001" then do:
       wf.cdt = bank.chipno.
       rf = "9001".
       end.
       else wf.cdt = vcdt.
       wf.tpy = vtpy.
       wf.tpyac = vtpyac.
   update wf.cdt wf.tpy wf.tpyac with frame lsk.
   update rem6
	 help "(Y)ES/(N)O"
	 with frame lsk.
  if rem6 eq false then update wf.fpy wf.fpyac with frame lsk.
   update wf.bnk wf.advtyp with frame lsk.
  if wf.advtyp ne "N" then  update wf.advcom with frame lsk.
       wf.amt = s-amt.
       wf.com = vcom.
       wf.scom = vscom.
       disp wf.amt with frame lsk.
  update /*wf.amt*/ wf.val wf.com wf.scom with frame lsk.
  if wf.tpy = " " then xxx = substring(wf.cdt,1,3).
  else xxx = substring(wf.tpy,1,3).
  {getkey.i}
  disp wf.tst with frame  lsk.
       wf.who = userid('bank').
       wf.whn = g-today.
       wf.tim = time.
  {mesg.i 0928} update vns .
  if vns = false then undo, retry.
 end.  /* if not available bank */

 wf.jh = s-jh.
 wf.jln = s-jln.
 if rf ne " " then do:
    if wf.cdt ne " " then rf = " (" + wf.cdt + ")".
    else rf = " (" + rf + ")".
 end.
 stpy = substring(wf.tpy,1,35).
 sfpy = substring(wf.fpy,1,35).


 if rf ne " " then
 srem[1] = " T/F:" + bname + " " + rf.
 else
 srem[1] = " T/F:" + wf.cdt.
 srem[2] = "3A/C:" + stpy + " (" + wf.tpyac + ")".
 srem[3] = "4A/C:" + sfpy + " (" + wf.fpyac + ")".
 srem[4] = " REF:" + wf.com.
 srem[5] = "    :" + wf.scom + " TKEY:" + string(wf.tst).
 wfln = wf.ln.
 end.  /* end repeat */
