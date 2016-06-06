 /* fcb_send.p
 * MODULE
        экспресс кредиты по ПК
 * DESCRIPTION
        Отправка запроса в 1КБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        11/11/2013 Luiza - ТЗ 1831
 * BASES
 		BANK COMM
 * CHANGES

*/

{global.i}

def var s-credtype as char init '10' no-undo.
def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
 display " There is no record OURBNK in bank.sysc file !!".
 pause.
 return.
end.
s-ourbank = trim(sysc.chval).

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln and pkanketa.credtype = "10" use-index bankcif no-lock no-error.
if not avail pkanketa then do:
   message "Анкета не найдена!" view-as alert-box question buttons ok.
   return.
end.
find first cif where cif.cif = v-cifcod no-lock no-error.
if avail cif then do:
   def var fcb_id as int  no-undo.

   run 1CB_RequestReport(trim(cif.bin), s-credtype, output fcb_id).
   run savelog("fcb_send", "экспресс кредиты ( банк "  + s-ourbank + " " + trim(pkanketa.cif) + " BIN:" + trim(pkanketa.rnn) + ") " + string(fcb_id)).


/* сохраним fcb_id */
   find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
        and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fcbid234" exclusive-lock no-error.

   if not avail pkanketh then create pkanketh.
   pkanketh.bank = pkanketa.bank.
   pkanketh.cif = pkanketa.cif.
   pkanketh.credtype = s-credtype.
   pkanketh.ln = pkanketa.ln.
   pkanketh.kritcod = "fcbid234".
   pkanketh.value1 = string(fcb_id).
end.
else do:
   message "Клиент не найден!" view-as alert-box question buttons ok.
   return.
end.