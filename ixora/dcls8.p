/* dcls8.p
 * MODULE
        Спец.инструкции
 * DESCRIPTION
        Удаление спец.инструкции по признаку Департамента Платежных Карт.
 * RUN

 * CALLER
        dayclose.p
 * SCRIPT

 * INHERIT

 * MENU
        Закрытие дня.
 * AUTHOR
        21.10.2004 saltanat
 * CHANGES
        12.11.2004 saltanat - Добавила удаление спец.инстр. по признаку Департамента Кредитного Администрирования
        23.11.2004 saltanat - Добавила в описание признак того что удаление произошло при закрытии дня.
        02/05/2012 evseev - логирование значения aaa.hbal
*/
{global.i}

def shared var s-target as date.

for each aas where (aas.chkdt + 30 <= s-target and aas.delaas = 'd') /* Платежные карточки */
                or aas.delaas = 'k' exclusive-lock:                  /* Кредитный Департамент */

  CREATE aas_hist.

  find first aaa where aaa.aaa = aas.aaa no-lock no-error.
  IF AVAILABLE aaa THEN
   DO:
     FIND FIRST cif WHERE cif.cif= aaa.cif USE-INDEX cif NO-LOCK NO-ERROR.
     IF AVAILABLE cif THEN
      DO:
        aas_hist.cif= cif.cif.
        aas_hist.name= trim(trim(cif.prefix) + " " + trim(cif.name)).
      END.
   END.

   aas_hist.aaa    = aas.aaa.
   aas_hist.ln     = aas.ln.
   aas_hist.sic    = aas.sic.
   aas_hist.chkdt  = aas.chkdt.
   aas_hist.chkno  = aas.chkno.
   aas_hist.chkamt = aas.chkamt.
   aas_hist.payee  = aas.payee + ' Удалили в dcls8.p по признаку.'.
   aas_hist.expdt  = aas.expdt.
   aas_hist.regdt  = aas.regdt.
   aas_hist.who    = g-ofc.
   aas_hist.whn    = s-target.
   aas_hist.tim    = time.
   aas_hist.del    = aas.del.
   aas_hist.chgdat = s-target.
   aas_hist.chgtime= time.
   aas_hist.chgoper= 'D'.

   if aas.sic = 'HB' then do:
   find first aaa where aaa.aaa = aas.aaa exclusive-lock.
        run savelog("aaahbal", "dcls8 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
        aaa.hbal = aaa.hbal - aas.chkamt.
   end.

   delete aas.

end.
