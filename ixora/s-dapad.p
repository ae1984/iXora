/* s-dapad.p
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

/* s-dadppad.p
   s-rimpad.p modified for D/A D/P 05-13-91

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{global.i}

define buffer b-dpay for dpay.

define shared var s-bank like dpay.bank.
define shared var s-dadp like dpay.dadp.
def shared var s-aah  as int.
def shared var s-jh      like jh.jh.
def shared var s-consol  like jh.consol initial false.
def  shared var s-grp      like dpay.grp.
def  shared var s-type     like dadp.type.
def  shared var s-gl       like dpay.gl.
def  shared var s-drft     like dpay.drft.
def  shared var s-payamt   like dpay.payamt.
def  shared var s-adt      like dadp.adt.
def  shared var s-ddt      like dadp.ddt.
def  shared var s-trm      like dadp.trm.
def  shared var s-name     like bank.name.
def  shared var s-rdt      like dadp.rdt.
def  shared var s-bal      like dadp.bal.
def  shared var s-caccr    like dadp.caccr.
def  shared var s-crcvd    like dadp.crcvd.
def  shared var s-detail   like dadp.detail.
def  shared var s-pcnt     like dadp.pcnt.
def  shared var s-cif      like dadp.cif.
def  shared var s-party    like dadp.party.
def  shared var s-pacct    like dpay.pacct.
def new shared var s-line as int.
def new shared var s-force as log.
def var vbal as dec format "zzz,zzz,zz9.99-".
def var vdam like vbal.
def var vcam like vbal.
def var vop  as int format "z".
def var i as int.

{jhjl.f new}

def var command as cha format "x".
def var vacc like jl.acc.
def var vfirst as log initial true.

def var vcdagl as int.
def var vcdpgl as int.

find sysc where sysc.sysc eq "cdagl". vcdagl = sysc.inval.
find sysc where sysc.sysc eq "cdpgl". vcdpgl = sysc.inval.

find dadp where dadp.bank eq s-bank
          and  dadp.dadp eq s-dadp.

do transaction:
  create dpay.
  dpay.bank = dadp.bank.
  dpay.dadp = dadp.dadp.

  find last b-dpay where b-dpay.bank eq dadp.bank
                    and  b-dpay.dadp eq dadp.dadp no-error.

  if available b-dpay then dpay.ln = b-dpay.ln + 1.
                      else dpay.ln = 1.
  dpay.comm[1] = s-caccr.
  dpay.payamt = s-caccr.
end.
find bank where bank.bank eq s-bank.
/* -- */
run x-jhnew.

do transaction:
  find jh where jh.jh = s-jh.
  jh.cif = dadp.cif.
  jh.party = dadp.party.
  dpay.jh = jh.jh.
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
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  jl.rem[1] = dpay.dadp + "/" + dpay.dadp + " (COMM-ACCR)".
  if s-grp eq 1 then jl.gl = vcdagl.
                  else jl.gl = vcdpgl.
  jl.acc = dpay.dadp.
  jl.cam = s-caccr.
  jl.dc = "C".
  dadp.crcvd = dadp.crcvd + s-caccr.
  dadp.caccr = dadp.caccr - s-caccr.
  find gl where gl.gl eq jl.gl.
  {jlupd-rold.i}
end.

pause 0.
{x-jllis.i}
run x-jlgens.
hide all.
