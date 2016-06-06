/* s-rimrev.p
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

/* s-rimrev.p
*/

{global.i}

def shared var s-bank like rim.bank.
def shared var s-lcno like rim.lcno.

find rim where rim.bank eq s-bank
	  and  rim.lcno eq s-lcno.

for each rpay where rpay.bank eq rim.bank and rpay.lcno eq rim.lcno:
  display rpay.ln rpay.pdt
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
	  rpay.interest  at 5
	  rpay.intrate
	  rpay.trm
	  rpay.duedt
	  rpay.jh
	  rpay.cdt    /* cancelled date */
	  rpay.cjh skip
	  with row 4 centered title " PAYMENT HISTORY " overlay top-only
	    3 col down frame rpay.
end.
hide frame rpay.
