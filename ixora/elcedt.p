/* elcedt.p
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

/* elcedt.p

*/

{mainhead.i ELCENT}

def new shared var s-bank like rim.bank.
def new shared var s-lcno like rim.lcno.
def var ans as log.
def var cmd as cha format "x(7)" extent 9
    initial ["NEXT","EDIT","AMEND","NEGO","PAYMENT","HISTORY","CANCEL",
    "DELETE","QUIT"].
def var vcrc like rim.crc.
def var vbal like rim.crline label "BALANCE" decimals 2.
def var vcnt as int format "zz9" label "PAYMENT COUNT".
def var vnew as log.

{elcedt.f}

view frame bill.
view frame slct.


outer:
repeat:
  vnew = false.
  prompt-for rim.lcno with frame rim.
  find first rim using rim.lcno no-error.
  if not available rim
    then do transaction:
      bell.
      {mesg.i 1808} update ans.
      if ans eq false then undo, retry.
      create rim.
      assign rim.lcno.
      rim.rdt = g-today.
      rim.who = g-ofc.
      rim.tol = 0.
      vnew = true.
    end.
  vcrc = rim.crc.
  vbal = rim.amt[1] - rim.amt[2].
  vcnt = 0.
  for each rpay where rpay.bank eq rim.bank and rpay.lcno eq rim.lcno:
    vcnt = vcnt + 1.
  end.
  display
     rim.bank
     rim.grp rim.ref
     rim.crc rim.amt[1] rim.tol
     vcrc vbal
     rim.rdt
     rim.idt rim.expdt
     rim.tennor
     rim.trm
     rim.fee
     rim.intpay
     rim.cif rim.party
     rim.acc
     rim.rem
     rim.amt[4] vcnt
     with frame rim.
  find cif of rim no-error.
  if available cif
    then do: display trim(trim(cif.prefix) + " " + trim(cif.name)) @ rim.party with frame rim.
             rim.party = trim(trim(cif.prefix) + " " + trim(cif.name)). end.
  find bank where bank.bank eq rim.bank no-error.
  if available bank
    then display bank.name with frame rim.

  inner:
  repeat:
    display cmd auto-return with frame slct.
    if vnew eq false
      then choose field cmd with frame slct.
    if frame-value eq "EDIT" or vnew
      then do transaction:
        update rim.ref
               rim.bank validate(can-find(bank where bank.bank eq bank),"")
               rim.grp
               rim.crc rim.amt[1] rim.tol
               rim.idt
               rim.expdt
               rim.tennor
               rim.trm  when rim.tennor ne 1
               rim.fee
            /*   validate(rim.fee = 1 or rim.fee = 2 ,"RECORD NOT FOUND") */
               rim.intpay  when rim.tennor ne 1
               rim.cif validate(can-find(cif where cif.cif eq cif)
                 or rim.cif eq "",
               "NO-CUSTOMER RECORD FOUND")
               rim.party
               rim.acc
               rim.rem
               rim.amt[4]
               with frame rim.
        if rim.cif ne ""
          then do:
            find cif where cif.cif eq rim.cif.
            display trim(trim(cif.prefix) + " " + trim(cif.name)) @ rim.party with frame rim.
            rim.party = trim(trim(cif.prefix) + " " + trim(cif.name)).
          end.
        find bank where bank.bank eq rim.bank.
        display bank.name with frame rim.
        vnew = false.
      end.
    else if frame-value eq "AMEND"
      then do:
        s-bank = rim.bank.
        s-lcno = rim.lcno.
        run s-rimamd.
        vbal = rim.amt[1] - rim.amt[2].
        display vbal with frame rim.
      end.
    else if frame-value eq "NEGO"
      then do:
        s-bank = rim.bank.
        s-lcno = rim.lcno.
        run s-negpay.
        vbal = rim.amt[1] - rim.amt[2].
        display vbal rim.amt[4] with frame rim.
        next outer.
      end.
    else if frame-value eq "PAYMENT"
      then do:
        s-bank = rim.bank.
        s-lcno = rim.lcno.
        run s-rimpay.
        vbal = rim.amt[1] - rim.amt[2].
        display vbal rim.amt[4] with frame rim.
        next outer.
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
