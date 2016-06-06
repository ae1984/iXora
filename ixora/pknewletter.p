/* pknewletter.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Формирование номера нового письма при создании письма
 * RUN
        
 * CALLER
        pklettercl.p, pkletterjb0.p, pkletterjb1.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-14-6
 * AUTHOR
        13.12.2003 nadejda
 * CHANGES
*/

{global.i}

def input parameter p-bank as char.
def input parameter p-param as char.
def input parameter p-type as char.
def input parameter p-first as logical.
def input parameter p-ref as char.
def input parameter p-refdt as date.
def output parameter p-nomer as char.


p-nomer = "".

do transaction on error undo, retry:
  find sysc where sysc.sysc = p-param exclusive-lock no-error.
  sysc.inval = sysc.inval + 1.
  if p-first then sysc.deval = sysc.deval + 1.
  
  p-nomer = sysc.chval + string(sysc.inval) + "-(" + trim(string(integer(sysc.deval), ">>>>>>>>>9")) + ")".

  find ofc where ofc.ofc = g-ofc no-lock no-error.

  create letters.
  assign letters.bank = p-bank
         letters.type = p-type
         letters.num = sysc.inval
         letters.docnum = p-nomer
         letters.rdt = g-today
         letters.rwho = g-ofc
         letters.whn = today
         letters.who = userid("bank")
         letters.ref = p-ref
         letters.refdt = p-refdt
         letters.profitcn = ofc.titcd
         letters.roll = integer(sysc.deval).   /* номер ведомости */
end.
release sysc.
release letters.
