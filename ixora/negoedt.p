/* negoedt.p
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

/* negoedt.p
*/
/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{mainhead.i }

def new shared var s-bank like rim.bank.
def new shared var s-lcno like rim.lcno.
def var ans as log.
def var cmd as cha format "x(7)" extent 8
    initial ["NEXT","EDIT","AMEND","PAYMENT","HISTORY","CANCEL",
    "DELETE","QUIT"].
def var vcrc like rim.crc.
def var vbal as dec format "zzz,zzz,zzz.99-" label "BALANCE".
def var vcnt as int format "zz9" label "PAYMENT COUNT".

form rim.lcno colon 11
     rim.ref colon 50 label "REF#" skip
     rim.bank colon 11 label "ISSUE-BANK" bank.name no-label skip
     rim.grp colon 11
     rim.crc colon 11 label "L/C AMOUNT" rim.amt[1] no-label
     rim.tol colon 50 skip
     vcrc colon 11 label "BALANCE" vbal no-label skip
     rim.rdt colon 11 skip
     rim.idt colon 11 rim.expdt colon 50 skip
     rim.tennor colon 11 help "1.AT SIGHT 2.AFTER SIGHT 3.FROM B/L"
     rim.trm colon 50  skip
     rim.fee colon 11 label "BANK CHRG"
     rim.intpay colon 50 label "INTEREST TYPE" help "1.ACCRUED 2.DISCOUNT"
     rim.ibf skip
     rim.cif colon 11 LABEL "BENEF" rim.party no-label skip
     rim.acc colon 11 skip
     rim.rem colon 11 skip
     rim.amt[4] colon 11 label "ADV FEE" vcnt colon 50 skip
     with width 80 row 3 side-label centered title " EXPORT L/C "
     overlay frame rim.
     /*
     rim.lcno rim.ref rim.bank rim.grp rim.ref rim.crc rim.amt[1] rim.tol
     vcrc vbal rim.rdt rim.idt rim.expdt rim.tennor  rim.trm rim.fee
     rim.intpay rim.ibf rim.cif rim.party rim.acc rim.rem rim.amt[4] vcnt
     */

form cmd
     with centered no-box no-label row 21 frame slct.

view frame bill.
view frame slct.


outer:
repeat:
  prompt-for rim.lcno with frame rim.
  find first rim using rim.lcno no-error.
  if not available rim
    then do transaction:
      bell.
      {mesg.i 1808} update ans.
      if ans eq false then undo, retry.
      create rim.
      assign rim.lcno.
      update rim.bank validate(can-find(bank where bank.bank eq bank),"")
             with frame rim.
      rim.rdt = g-today.
      rim.who = g-ofc.
      rim.tol = 0.
    end.
  vcrc = rim.crc.
  vbal = rim.amt[1] - rim.amt[2].
  vcnt = 0.
  for each rpay where rpay.bank eq rim.bank and rpay.lcno eq rim.lcno:
    vcnt = vcnt + 1.
  end.
  display
     rim.bank  rim.grp
     rim.ref
     rim.crc rim.amt[1] rim.tol
     vcrc vbal
     rim.rdt
     rim.idt rim.expdt
     rim.tennor
     rim.trm
     rim.fee
     rim.intpay rim.ibf
     rim.cif rim.party
     rim.acc
     rim.rem
     rim.amt[4] vcnt
     with frame rim.
  find cif of rim no-error.
  if available cif
    then display trim(trim(cif.prefix) + " " + trim(cif.name)) @ rim.party with frame rim.
  find bank where bank.bank eq rim.bank.
  display bank.name with frame rim.

  display cmd auto-return with frame slct.

  inner:
  repeat:
    choose field cmd with frame slct.
         if frame-value eq "EDIT"
      then do transaction:
        update rim.lcno rim.ref
               rim.bank with frame rim.
        update rim.grp with frame rim.
        update rim.crc rim.amt[1] rim.tol
               rim.idt rim.expdt
               rim.tennor
               rim.trm
               rim.fee
               rim.intpay rim.ibf
               rim.cif rim.party
               rim.acc
               rim.rem
               rim.amt[4]
               with frame rim.
        if rim.cif ne ""
          then do:
            find cif where cif.cif eq rim.cif.
            display trim(trim(cif.prefix) + " " + trim(cif.name)) @ rim.party with frame rim.
          end.
        find bank where bank.bank eq rim.bank.
        display bank.name with frame rim.
      end.
    else if frame-value eq "AMEND"
      then do:
        s-bank = rim.bank.
        s-lcno = rim.lcno.
        run s-rimamd.
        vbal = rim.amt[1] - rim.amt[2].
        display vbal with frame rim.
      end.
    else if frame-value eq "PAYMENT"
      then do:
        s-bank = rim.bank.
        s-lcno = rim.lcno.
        run s-ngpay.
        vbal = rim.amt[1] - rim.amt[2].
        display vbal rim.amt[4] with frame rim.
      end.
    else if frame-value eq "HISTORY"
      then do:
        s-bank = rim.bank.
        s-lcno = rim.lcno.
        run s-rimrev.
      end.
    else if frame-value eq "CANCEL"
      then do:
        s-bank = rim.bank.
        s-lcno = rim.lcno.
        run s-rimcnc.
        vbal = rim.amt[1] - rim.amt[2].
        display vbal rim.amt[4] with frame rim.
      end.
    else if frame-value eq "QUIT" then return.
    else if frame-value eq "DELETE "
      then do transaction:
        find first rpay where rpay.lcno eq rim.lcno
                         and  rpay.bank eq rim.bank no-error.
        {mesg.i 0824} update ans.
        if ans eq false then next.
        delete rim.
        clear frame rim.
        next outer.
      end.
    else if frame-value eq "NEXT"
      then do:
        clear frame rim.
        next outer.
      end.
  end. /* inner */
end. /* outer */
