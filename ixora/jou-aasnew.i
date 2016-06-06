/* jou-aasnew.i
 * MODULE
        Клиентская база
 * DESCRIPTION
        Блокирует сумму на счете получателя при помощи спец. инструкций для контроля старшим менеджером
 * RUN

 * CALLER
        jou-aasnew.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        03.10.2003 nadejda - выделено из jou-aasnew.p
 * CHANGES
        28/04/2012 evseev - логирование значения aaa.hbal
*/


def input parameter s-aaa like aaa.aaa.
def input parameter s-amt as decimal.
def input parameter s-jh  like jh.jh.

def shared var g-ofc as char.
def shared var g-today as date.

def var i as int.

find aaa where aaa.aaa = s-aaa no-lock no-error.
if not avail aaa or aaa.sta = "C" then return.

{&start}

message substitute ("Сумма будет заблокирована на счете &1 ~nдля контроля старшим менеджером", s-aaa)
        view-as alert-box title "Предупреждение".


do transaction on error undo, return:

  find last aas_hist where aas_hist.aaa = s-aaa use-index aaaln no-lock no-error.

  create aas.

  if available aas_hist then aas.ln = aas_hist.ln + 1.
                        else aas.ln = 1.

  aas.sic = "HB".
  aas.chkamt = s-amt.
  aas.payee  = "Контроль старшим менеджером |" + TRIM(STRING(s-jh, "zzzzzzzzzz9")).
  aas.aaa = s-aaa.
  aas.who = g-ofc.
  aas.whn = g-today.
  aas.regdt = g-today.
  aas.tim = time.
  aas.point = 0.
  aas.depart = 0.

  find current aaa exclusive-lock.
  run savelog('aaahbal', 'jou-aasnew.i ; ' + aaa.aaa + ' ; ' + string(aaa.hbal) + ' ; ' + string(aaa.hbal + aas.chkamt) + ' ; ' + string(aas.chkamt)) no-error.
  aaa.hbal = aaa.hbal + aas.chkamt.
  find current aaa no-lock.

  CREATE aas_hist.
  FIND FIRST cif WHERE cif.cif = aaa.cif USE-INDEX cif NO-LOCK NO-ERROR.
  IF AVAILABLE cif THEN DO:
    aas_hist.cif = cif.cif.
    aas_hist.name = trim(trim(cif.prefix) + " " + trim(cif.name)).
  END.

  aas_hist.aaa = aas.aaa.
  aas_hist.ln = aas.ln.
  aas_hist.sic = aas.sic.
  aas_hist.chkdt = aas.chkdt.
  aas_hist.chkno = aas.chkno.
  aas_hist.chkamt = aas.chkamt.
  aas_hist.payee = aas.payee.
  aas_hist.expdt = aas.expdt.
  aas_hist.regdt = aas.regdt.
  aas_hist.who = aas.who.
  aas_hist.whn = aas.whn.
  aas_hist.tim = aas.tim.
  aas_hist.del = aas.del.
  aas_hist.chgdat = g-today.
  aas_hist.chgtime = time.
  aas_hist.chgoper = 'A'.

  release aas.
  release aas_hist.

end.

