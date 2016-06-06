/* s-rimpad.p
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

/* s-rimpad.p

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{global.i}

define buffer b-rpay for rpay.

define shared var s-bank like rpay.bank.
define shared var s-lcno like rpay.lcno.

def  var s-aah  as int.
def  var s-line as int.
def  var s-force as log initial false.
def var i as int.
def shared var s-jh  like jh.jh.
def shared var s-consol like jh.consol initial false.

def shared var s-ptype    like rpay.ptype.
def shared var s-ps       like rpay.ps.
def shared var s-gl       like rpay.gl.
def shared var s-orgamt   like rpay.orgamt.
def shared var s-drft     like rpay.drft.
def shared var s-comm     like rpay.comm.
def shared var s-payamt   like rpay.payamt.
def shared var s-pacct    like rpay.pacct.
def shared var s-acc      like rpay.acc.
def shared var s-pdt      like rpay.pdt.
def shared var s-orgdt    like rpay.orgdt.
def shared var s-duedt    like rpay.duedt.
def shared var s-intdt    like rpay.intdt.
def shared var s-trm      like rpay.trm.
def shared var s-intdue   like rpay.intdue.
def shared var s-intrate  like rpay.intrate.
def shared var s-interest like rpay.interest.
def shared var s-itype    like rpay.itype.
def shared var s-cbank    like rpay.cbank.
def shared var s-cbname   like rpay.cbname.
def shared var s-crbank   like rpay.crbank.
def shared var s-acct     like rpay.acct.
def shared var s-tref     like rpay.tref.
def shared var s-rem      like rpay.rem.
def shared var s-bill     like rpay.bill.

def var vbal as dec format "zzz,zzz,zz9.99-".
def var vdam like vbal.
def var vcam like vbal.
def var vop  as int format "z".

{jhjl.f new}

def var command as cha format "x".
def var vacc like jl.acc.
def var vfirst as log initial true.

def var vcagl1 as int format "zzzzz9".
def var vcagl2 as int format "zzzzz9".

find sysc where sysc.sysc eq "CAGL". /*vcagl = sysc.inval.*/
vcagl1 = integer(entry(1, sysc.chval)).
vcagl2 = integer(entry(2, sysc.chval)).

find rim where rim.bank eq s-bank
          and  rim.lcno eq s-lcno.

do transaction:
  create rpay.
  rpay.bank = rim.bank.
  rpay.lcno = rim.lcno.

  find last b-rpay where b-rpay.bank eq rim.bank
                    and  b-rpay.lcno eq rim.lcno no-error.

  if available b-rpay then rpay.ln = b-rpay.ln + 1.
                      else rpay.ln = 1.
  rpay.comm[4] = s-comm[4].
  rim.amt[4] = rim.amt[4] - rpay.comm[4].
end.
find bank where bank.bank eq s-bank.

run x-jhnew.
do transaction:
  find jh where jh.jh = s-jh.
  jh.cif = rim.cif.
  jh.party = rim.party.
  jh.crc = rim.crc.
  rpay.jh = jh.jh.
end.
display jh.jh jh.jdt jh.who
    with frame jh.
display jh.cif jh.party with frame party.
find cif where cif.cif eq jh.cif no-error.
if available cif
  then display trim(trim(cif.prefix) + " " + trim(cif.name)) @ jh.party with frame party.
do transaction:
  create jl.
  jl.jh = jh.jh.
  jl.ln = 1.
  jl.crc = jh.crc.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  jl.rem[1] = rpay.bill + "/" + rpay.lcno + " (ADVISE CHG)".
  jl.gl = vcagl1.
  /* jl.acc = . */
  jl.cam = rpay.comm[4].
  jl.dc = "C".
  find gl where gl.gl eq jl.gl.
  {jlupd-r.i}
end.

pause 0.
{x-jllis.i}
run x-jlgens.
hide all.
