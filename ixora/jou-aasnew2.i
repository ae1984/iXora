/* jou-aasnew2.i
 * MODULE
        Установка спец интструкций по неснижаемому остатку
 * DESCRIPTION
        Установка спец интструкций по неснижаемому остатку
 * RUN

 * CALLER
        jou-aasnew2.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        30.03.2006 nataly - выделено из jou-aasnew2.p
 * CHANGES
        17.04.06 nataly добавлена обработка кода 193,180,181 - исключения по кредитам
        02/05/2012 evseev - логирование значения aaa.hbal

*/

def input parameter s-aaa like aaa.aaa no-undo.
def input parameter s-amt as decimal no-undo.
def input parameter s-jh  like jh.jh no-undo.

def shared var g-ofc as char.
def shared var g-today as date.
def var s-code1 as char.

def var i as int no-undo.
def buffer b-aaa for aaa.
def buffer b-crc for crc.

find aaa where aaa.aaa = s-aaa no-lock no-error.
if not avail aaa or aaa.sta = "C" then return.

{&start}

find first aas where aas.aaa = s-aaa and aas.payee begins 'Неснижаемый остаток ОД' no-lock no-error.
if avail aas then return.

/*проверяем чтобы остаток был больше неснижаемого */
 find b-aaa where b-aaa.aaa = s-aaa no-lock no-error.
 if not avail b-aaa then return.
 if b-aaa.cr[1] - b-aaa.dr[1] < s-amt then return.
  find b-crc where b-crc.crc = b-aaa.crc.
 if avail b-crc then s-code1 = b-crc.code.
  message substitute ("Сумма &2 &3 будет заблокирована на счете &1 ~nкак неснижаемый остаток", s-aaa, s-amt, s-code1)
        view-as alert-box title "Предупреждение".


do transaction on error undo, return:

  find last aas_hist where aas_hist.aaa = s-aaa use-index aaaln no-lock no-error.

  create aas.

  if available aas_hist then aas.ln = aas_hist.ln + 1.
                        else aas.ln = 1.

  aas.sic = "HB".
  aas.chkamt = s-amt.
  aas.payee  = "Неснижаемый остаток ОД |" + TRIM(STRING(s-jh, "zzzzzzzzzz9")).
  aas.aaa = s-aaa.
  aas.who = g-ofc.
  aas.whn = g-today.
  aas.regdt = g-today.
  aas.tim = time.
  aas.point = 0.
  aas.depart = 0.
  aas.chkdt = g-today.

  find current aaa exclusive-lock.
  run savelog('aaahbal', 'jou-aasnew2.i ; ' + aaa.aaa + ' ; ' + string(aaa.hbal) + ' ; ' + string(aaa.hbal + aas.chkamt) + ' ; ' + string(aas.chkamt)) no-error.
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

