/* new-bill.p
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

/* new-bill.p
*/
/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

def shared var s-acc like jl.acc.
def shared var s-gl  like gl.gl.
def shared var s-jh like jh.jh.
def shared var s-jl like jl.ln.
def var answer as log.
def shared var rtn as log initial yes.
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

{global.i}

find jh where jh.jh eq s-jh.
find jl where jl.jh eq jh.jh and jl.ln eq s-jl.
find gl where gl.gl eq s-gl.

main:
do transaction on error undo, return:
            create bill.
            bill.bill = s-acc.
            bill.rdt = g-today.
            bill.who = g-ofc.
            bill.gl = s-gl.
            bill.crc = jl.crc.
            if bill.crc eq 1 then bill.basedy = 365.
            else if bill.crc eq 2 then bill.basedy = 360.
            if gl.grp ne 0
              then do:
                bill.grp = gl.grp.
                display bill.grp with frame bill.
              end.
              else update bill.grp with frame bill.
            if jh.cif ne ""
              then do:
                bill.cif = jh.cif.
                find cif where cif.cif eq bill.cif.
                bill.cst = trim(trim(cif.prefix) + " " + trim(cif.name)).
                display bill.cif bill.cst with frame bill.
              end.
              else do:
                bill.cst = jh.party.
                display bill.cst with frame bill.
              end.
            update bill.lcno
                   bill.bank
                   bill.payment
                   bill.basedy
                   bill.rdt
                   with centered row 3 1 col frame bill
                        title " Bill Ledger ".
            if bill.grp ne 1
              then do:
                bill.orgdt = bill.rdt.
                update bill.orgdt bill.trm with frame bill.
                bill.intdt = bill.orgdt.
                bill.duedt = bill.orgdt + bill.trm.
                repeat:
                  find hol where hol.hol eq bill.duedt no-error.
                  if not available hol and
   weekday(bill.duedt) ge v-weekbeg and
   weekday(bill.duedt) le v-weekend
                    then leave.
                    else bill.duedt = bill.duedt + 1.
                end.
                bill.trm = bill.duedt - bill.orgdt.
                bill.intdue = bill.duedt.
                display bill.trm bill.duedt bill.intdt with frame bill.
                update bill.intdue
                       validate(bill.intdue gt input bill.intdt and
                                bill.intdue le input bill.duedt,"")
                       with frame bill.
                repeat:
                  find hol where hol.hol eq bill.intdue no-error.
                  if not available hol and
   weekday(bill.intdue) ge v-weekbeg and
   weekday(bill.intdue) le v-weekend
                    then leave.
                    else bill.intdue = bill.intdue + 1.
                end.
                display bill.intdue with frame bill.
                update bill.intrate with frame bill.
                bill.interest = bill.payment * (bill.intdue - bill.intdt)
                              * bill.intrate / bill.basedy / 100.
                display bill.interest with frame bill.
                update bill.itype with frame bill.
              end.
              else bill.duedt = bill.rdt.
            update bill.refno
                   with frame bill.
            find bank where bank.bank eq bill.bank.
            /*
            if bank.rim eq yes
              then do:
                find rim where rim.bank eq bill.bank
                          and  rim.lcno eq bill.lcno no-error.
                if not available rim
                  then do:
                    bell.
                    {mesg.i 4802}.
                    pause 3.
                  end.
              end.
            */
            find rim where rim.bank eq bill.bank
                      and  rim.lcno eq bill.lcno no-error.
            if available rim
              then do:
                rim.amt[2] = rim.amt[2] + bill.payment.
              end.
end.

rtn = no.
