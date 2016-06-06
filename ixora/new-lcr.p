/* new-lcr.p
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

/* new-lcr.p
*/


def shared var rtn as log initial yes.

def shared var s-acc like jl.acc .
def shared var s-gl  like gl.gl .
def new shared var s-jh like jh.jh.
def new shared var elccv  like lcrcov.elccv.
def new shared var elcname as char.
def buffer b-lcr for lcr.
def buffer b-lcrcov for lcrcov.
def buffer b-lcrcon for lcrcon.
/*
def new shared var vamtdec as dec.
def new shared var vamtcha as cha.
*/
def var answer as log.
def var vans as log.
def var vanss as log.
def var vlcr like lcr.lcr label "COPY L/C# FROM".

{global.i}
do transaction on error undo, return :
create lcr.
lcr.lcr = s-acc.
lcr.gl = s-gl.
/*lcr.crc = jl.crc.*/
lcr.rdt = g-today.
lcr.who = g-ofc.
lcr.cif = g-cif.
lcr.cond[1] =
  "1. ALL DOCUMENTS MUST BEAR OUR CREDIT NUMBER.".
lcr.cond[2] =
  "2. ALL BANKING CHARGES INCLUDING POSTAGE OUTSIDE L/C OPENING BANK ARE".
lcr.cond[3] =
  "   FOR ACCOUNT OF BENEFICIARY.".
lcr.drfr = g-comp.

form
    "Date Issue   :" lcr.opndt skip
    "L/C #        :" lcr.lcr skip
    "CIF #        :" lcr.cif skip
    "COPY L/C FROM:" vlcr skip
    "L/C Group    :" lcr.grp skip
    "L/C Category :" lcr.lcrcat skip
    "Advising Bank:" lcr.abank skip
    "             :" lcr.adv[1] skip
    "             :" lcr.adv[2] skip
    "             :" lcr.adv[3] skip
    "             :" lcr.adv[4] skip
    /* "Nego     Bank:" lcr.nego[1] skip
    "             :" lcr.nego[2] skip
    "             :" lcr.nego[3] skip
    "             :" lcr.nego[4] skip */
    "Beneficiary  :" lcr.bnf[1]  skip
    "             :" lcr.bnf[2]  skip
    "             :" lcr.bnf[3]  skip
    "             :" lcr.bnf[4]  skip
    with row 2 no-label frame newlcr1-1.
display
      lcr.lcr
      lcr.cif
      with frame newlcr1-1.
update
      vlcr
      validate(can-find(lcr where lcr.lcr eq vlcr) or vlcr = "",
      "RECORD NOT FOUND.")
      with frame newlcr1-1.
if vlcr ne ""
  then do:
    find b-lcr where b-lcr.lcr eq vlcr.
    lcr.abank = b-lcr.abank.
    lcr.adv[ 1] = b-lcr.adv[ 1].
    lcr.adv[ 2] = b-lcr.adv[ 2].
    lcr.adv[ 3] = b-lcr.adv[ 3].
    lcr.adv[ 4] = b-lcr.adv[ 4].
    lcr.bnf[ 1] = b-lcr.bnf[ 1].
    lcr.bnf[ 2] = b-lcr.bnf[ 2].
    lcr.bnf[ 3] = b-lcr.bnf[ 3].
    lcr.bnf[ 4] = b-lcr.bnf[ 4].
    lcr.cargo = b-lcr.cargo.
    lcr.draft = b-lcr.draft.
    lcr.drfr = b-lcr.drfr.
    lcr.ins = b-lcr.ins.
    lcr.lcr = s-acc.
    lcr.nbank = b-lcr.nbank.
    lcr.nego[ 1] = b-lcr.nego[ 1].
    lcr.nego[ 2] = b-lcr.nego[ 2].
    lcr.nego[ 3] = b-lcr.nego[ 3].
    lcr.nego[ 4] = b-lcr.nego[ 4].
    lcr.shipfr = b-lcr.shipfr.
    lcr.shipto = b-lcr.shipto.
    lcr.shipun = b-lcr.shipun.
    lcr.spec[ 1] = b-lcr.spec[ 1].
    lcr.spec[ 2] = b-lcr.spec[ 2].
    lcr.spec[ 3] = b-lcr.spec[ 3].
    lcr.spec[ 4] = b-lcr.spec[ 4].
    lcr.spec[ 5] = b-lcr.spec[ 5].
    lcr.spec[ 6] = b-lcr.spec[ 6].
    lcr.spec[ 7] = b-lcr.spec[ 7].
    lcr.spec[ 8] = b-lcr.spec[ 8].
    lcr.spec[ 9] = b-lcr.spec[ 9].
    lcr.spec[10] = b-lcr.spec[10].
    lcr.spec[11] = b-lcr.spec[11].
    lcr.spec[12] = b-lcr.spec[12].
    lcr.spec[13] = b-lcr.spec[13].
    lcr.spec[14] = b-lcr.spec[14].
    lcr.spec[15] = b-lcr.spec[15].
 /*
    lcr.spec[16] = b-lcr.spec[16].
    lcr.spec[17] = b-lcr.spec[17].
    lcr.spec[18] = b-lcr.spec[18].
    lcr.spec[19] = b-lcr.spec[19].
    lcr.spec[20] = b-lcr.spec[20].
  */
    for each b-lcrcov where b-lcrcov.elccv = b-lcr.lcr:
    create lcrcov.
    lcrcov.elccv = s-acc.
    lcrcov.ln = b-lcrcov.ln.
    lcrcov.lcrcov = b-lcrcov.lcrcov.
    end.
    for each b-lcrcon where b-lcrcon.elccv = b-lcr.lcr:
    create lcrcon.
    lcrcon.elccv = s-acc.
    lcrcon.ln = b-lcrcon.ln.
    lcrcon.lcrcon = b-lcrcon.lcrcon.
    end.
  end.
update
      lcr.opndt
/*
lcr.cif validate(can-find(cif where cif.cif = lcr.cif),"RECORD NOT FOUND")
      when g-cif eq "" */
      lcr.grp
      lcr.lcrcat
      lcr.abank
      /* lcr.nego */
      with frame newlcr1-1.
find bank where bank.bank eq lcr.abank no-error.
if available bank
      then do:
        lcr.adv[1] = bank.name.
        lcr.adv[2] = bank.addr[1].
        lcr.adv[3] = bank.addr[2].
        lcr.adv[4] = bank.addr[3].
        display lcr.adv with frame newlcr1-1.
      end.
      else do:
        update lcr.adv with frame newlcr1-1.
      end.
update lcr.bnf with frame newlcr1-1.
update
      "Latest Ship  :" lcr.shipun skip
      "Expiry Date  :" lcr.duedt skip
      "Tenor        :" lcr.tenor skip
      "Drawn on     :" lcr.drfr skip
      "Signed commercial invoice in" lcr.noi skip
      "Special custom invoice in" lcr.nos skip
      "Bill of lading" lcr.frt skip
      "Marine ins. incl." lcr.ins "Cargo Clause" lcr.cargo skip
      "Packing list in" lcr.nop skip
      /* "Air waybills" skip */
      with row 2 no-label frame newlcr1-2.

update
      "Special Documents Required:" skip
      lcr.spec skip
      with row 1 no-label frame newlcr11.

elccv = lcr.lcr.
elcname = "COVERING".
run lcr-cov.

update
      "Shipment Fr :" lcr.shipfr skip
      "Shipment To :" lcr.shipto skip
      "Partial ship:" lcr.part skip
      "Transhipment:" lcr.trns skip
      "Draft within:" lcr.draft skip
      with row 2 no-label frame newlcr2.

elccv = lcr.lcr.
elcname = "SPECIAL CONDITIONS".
run lcr-con.
find lcrcon where lcrcon.elccv eq lcr.lcr and lcrcon.ln eq 1 no-error.
if not available lcrcon then do:
  create lcrcon.
  lcrcon.elccv = lcr.lcr.
  lcrcon.ln = 1.
  lcrcon.whn = today.
  lcrcon.who = g-ofc.
  end.
lcrcon.lcrcon = lcr.cond[1].
find lcrcon where lcrcon.elccv eq lcr.lcr and lcrcon.ln eq 2 no-error.
if not available lcrcon then do:
  create lcrcon.
  lcrcon.elccv = lcr.lcr.
  lcrcon.ln = 2.
  lcrcon.whn = today.
  lcrcon.who = g-ofc.
  end.
lcrcon.lcrcon = lcr.cond[2].
find lcrcon where lcrcon.elccv eq lcr.lcr and lcrcon.ln eq 3 no-error.
if not available lcrcon then do:
  create lcrcon.
  lcrcon.elccv = lcr.lcr.
  lcrcon.ln = 3.
  lcrcon.who = g-ofc.
  lcrcon.whn = today.
  end.
lcrcon.lcrcon = lcr.cond[3].
/*
vamtdec = vopnamt.
run sudeccha.
amount = vamtcha + " U.S. DOLLORS".
{lcfrm.i}
*/

end.
rtn = no.

