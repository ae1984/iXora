/* s-rimcnc.p
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

/* s-rimcnc.p
*/

{global.i}

def buffer b-jh for jh.
def buffer b-jl for jl.

def var fv as char.
def var inc as int.

def shared var s-bank like rim.bank.
def shared var s-lcno like rim.lcno.

def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.
def new shared var s-aah  as int.
def new shared var s-line as int.
def new shared var s-force as log initial false.

def var vacc like jl.acc.

find rim where rim.bank eq s-bank
	  and  rim.lcno eq s-lcno.

form      rpay.ln rpay.pdt
	  rim.bank label "ISS-BANK"
	  rpay.bill
	  rpay.payamt
	  rpay.cbank label "CLAIM/NEGO-BANK" skip
	  rpay.cbname at 5
	  rpay.crbank at 5
	  rpay.acct at 5 rpay.tref skip
	  rpay.drft at 5
	  rpay.comm[1] label "TC"
	  rpay.comm[2] label "OC"
	  rpay.comm[3] label "IC"
	  rpay.comm[4] label "AC" skip
	  rpay.interest
	  rpay.intrate
	  rpay.trm
	  rpay.duedt
	  rpay.cdt skip
	  with row 5 centered title " PAYMENT HISTORY " overlay top-only
	  down frame rpay.

for each rpay where rpay.bank eq rim.bank and rpay.lcno eq rim.lcno:
  display rpay.ln rpay.pdt
	  rim.bank label "ISS-BANK"
	  rpay.bill
	  rpay.payamt
	  rpay.cbank label "CLAIM/NEGO-BANK" skip
	  rpay.cbname at 5
	  rpay.crbank at 5
	  rpay.acct at 5 rpay.tref skip
	  rpay.drft
	  rpay.comm[1] label "TC"
	  rpay.comm[2] label "OC"
	  rpay.comm[3] label "IC"
	  rpay.comm[4] label "AC" skip
	  rpay.interest
	  rpay.intrate
	  rpay.trm
	  rpay.duedt
	  rpay.cdt skip
	  with row 5 centered title " PAYMENT HISTORY " overlay top-only
	  down frame rpay.
  down 1 with frame rpay.
end.
prompt-for rpay.ln with frame rpay editing: {gethelp.i} end.
find rpay where rpay.bank eq s-bank
	   and  rpay.lcno eq s-lcno
	  using rpay.ln no-error.
if not available rpay
  then do:
    bell.
    {mesg.i 0230}.
    return.
  end.

if rpay.jh ne 0         /* when there is a control #  */
  then do:
    find jh where jh.jh eq rpay.jh.
    if jh.post eq true   /* when this is posted already */
      then do:
	run x-jhnew.
	rpay.cjh = s-jh.
	find jh  where jh.jh   eq s-jh.
	find b-jh where b-jh.jh eq rpay.jh.
	jh.crc = b-jh.crc.
	jh.cif = b-jh.cif.
	jh.party = b-jh.party.
	for each b-jl of b-jh:
	  create jl.
	  jl.jh = jh.jh.
	  jl.ln = b-jl.ln.
	  jl.crc = jh.crc.
	  jl.who = jh.who.
	  jl.jdt = jh.jdt.
	  jl.whn = jh.whn.
	  jl.sts = b-jl.sts.
	  jl.rem[1] = b-jl.rem[1].
	  jl.rem[2] = b-jl.rem[2].
	  jl.rem[3] = b-jl.rem[3].
	  jl.rem[4] = b-jl.rem[4].
	  jl.rem[5] = b-jl.rem[5].
	  jl.gl = b-jl.gl.
	  jl.acc = b-jl.acc.
	  jl.dam = b-jl.cam.
	  jl.cam = b-jl.dam.
	  if b-jl.dc eq "D"
	    then jl.dc = "C".
	    else jl.dc = "D".
	  jl.consol = b-jl.consol.
	  find gl where gl.gl eq jl.gl.
	  {jlupd-r.i}
	end.
	run x-jlvou.      /* print cancel voucher automatically */
      end.
      else do:      /* when not posted yet */
	for each jl of jh:
	  find gl where gl.gl eq jl.gl.
	  {jlupd-f.i}
	  delete jl.
	end.
      end.
       /* register cancel date, recover l/c amount and commision */
       /* only when there is a control # */
    rpay.cdt = g-today.
    rim.amt[2] = rim.amt[2] - rpay.drft.
    rim.amt[4] = rim.amt[4] + rpay.comm[4].

  end.
