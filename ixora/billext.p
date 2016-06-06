/* billext.p
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

/* billext.p
*/

{proghead.i "EXTEND BILL INTEREST DUE"}

def new shared var s-jh  like jh.jh.
def new shared var s-bill like bill.bill.
def new shared var vintdt like bill.intdt.
def new shared var vintdue like bill.intdue.
def new shared var vtrm like bill.trm.
def new shared var vntrm like bill.trm.
def new shared var vintrate like bill.intrate.
def new shared var vinterest like bill.interest.
def new shared var vgl like gl.gl label "PAY G/L#".
def new shared var vacc like jl.acc.

def var ans as log.
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

form        "OUR-REF#:" bill.bill skip
	    "L/C-NMBR:" bill.lcno skip
	    "AMOUNT  :" bill.payment skip
	    "REG-DATE:" bill.rdt skip
	    "ORG-DATE:" bill.orgdt "    TERM:" bill.trm
	    "    DUE-DATE:" bill.duedt skip
	    "INT-DATE:" bill.intdt "    TERM:" vtrm
	    "    INT-DUE :" bill.intdue skip
	    "INT-RATE:" bill.intrate skip
	    "INTEREST:" bill.interest "(" bill.itype ")"
	    skip(1)
	    "INT-DATE:" vintdt "    TERM:" vntrm
	    "    INT-DUE :" vintdue skip
	    "INT-RATE:" vintrate skip
	    "INTEREST:" vinterest skip
	    "PAY G/L#:" vgl "SUB-LEDGER:" vacc
	    with frame bill row 3 centered no-label no-box.

repeat:
  vintdt = ?.
  vintdue = ?.
  vntrm = 0.
  vintrate = 0.
  vinterest = 0.
  vgl = 0.
  vacc = "".
  clear frame bill.
  prompt bill.bill with frame bill.
  find bill using bill.bill.
  vtrm = bill.intdue - bill.intdt.
  display bill.lcno bill.payment
	  bill.orgdt bill.duedt bill.trm
	  bill.intdt bill.intdue vtrm
	  bill.intrate bill.interest bill.itype
	  with frame bill.
  if bill.intdue ge bill.duedt
    then do:
      bell.
      {mesg.i 3200}.
      undo, retry.
    end.
  vintdt = bill.intdue.
  vintrate = bill.intrate.
  update vintdt vintdue validate(vintdue gt input vintdt and
				 vintdue le bill.duedt,"")
	 vintrate
	 with frame bill.
  repeat:
    find hol where hol.hol eq vintdue no-error.
    if not available hol and
   weekday(vintdue) ge v-weekbeg and
   weekday(vintdue) le v-weekend
      then leave.
      else vintdue = vintdue + 1.
  end.
  vntrm = vintdue - vintdt.
  vinterest = bill.payment * (vintdue - vintdt)
			      * vintrate / 36000.
  display vintdue vntrm vinterest with frame bill.
  update vgl vacc with frame bill.
  /*
  update vpay help "1.HO A/C  2.BRANCH A/C  3.DUE FROM A/C"
	 with frame bill.

  if vpay eq "2" or vpay eq "3"
    then do:
      update vacc with frame bill.
    end.
  */
  {mesg.i 0928} update ans.
  if ans eq false then undo, retry.
  s-bill = bill.bill.
  run s-bilext.
  run x-jlvou.
end.
