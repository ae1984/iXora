/* jou-aasdel2.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Разблокирует сумму на счете при помощи спец. инструкций после контроля старшим менеджером для внутренних платежей
 * BASES
        BANK comm
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2-13, 4-1-11
 * AUTHOR
        создан по подобию jou-aasdel.p
 * CHANGES
        29/09/2011 Luiza
        13/10/2011 Luiza
        18/10/2011 Luiza перкомпиляция
        02/05/2012 evseev - логирование значения aaa.hbal
*/

def input parameter s-aaa as char format "x(20)".
def input parameter s-amt as decimal.
def input parameter s-jh  as int.

def var v-payee as char.

v-payee = "Внутренний платеж со счета клиента |" + TRIM(STRING(s-jh, "zzzzzzzzzz9")).
find aas where aas.aaa = s-aaa and aas.payee = v-payee and aas.chkamt = s-amt exclusive-lock no-error.
if not avail aas then return.

do transaction on endkey undo, return:
   find aaa where aaa.aaa = s-aaa exclusive-lock no-error.
   if not avail aaa then undo, return.
   for each aas_hist where aas_hist.aaa = aas.aaa and
                           aas_hist.ln = aas.ln and
                           aas_hist.chkamt = aas.chkamt and
                           aas_hist.payee = aas.payee:
      delete aas_hist.
   end.
   run savelog("aaahbal", "jou-aasdel2 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
   aaa.hbal = aaa.hbal - aas.chkamt.
   delete aas.
   release aaa.
end.

message "Снята спец. инструкция для внутр платежа со сч. клиента!" view-as alert-box title "".


