/* chifname.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Ищем первого руководителя организации и главбуха
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        26/06/2009 galina
 * BASES
        BANK TXB
 * CHANGES
        06/06/2011 evseev - переход на ИИН/БИН
*/
{chbin_txb.i}

def input parameter p-rnn as char.
def output parameter p-chif as char.
def output parameter p-mnbnk as char.
p-chif = ''.
p-mnbnk = ''.
if v-bin then find first txb.cif where txb.cif.bin = p-rnn no-lock no-error.
else find first txb.cif where txb.cif.jss = p-rnn no-lock no-error.
if avail txb.cif then do:
   find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.cif.cif and sub-cod.d-cod = "clnchf" no-lock no-error.
   if avail txb.sub-cod and txb.sub-cod.ccode ne "msc" then p-chif = txb.sub-cod.rcode.
   find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.cif.cif and sub-cod.d-cod = "clnbk" no-lock no-error.
   if avail txb.sub-cod and txb.sub-cod.ccode ne "msc" then p-mnbnk = txb.sub-cod.rcode.
   if trim(p-mnbnk) = '' then p-mnbnk = 'НЕ ПРЕДУСМОТРЕНО'.
   if trim(p-chif) = '' then p-mnbnk = 'НЕ ПРЕДУСМОТРЕНО'.
end.

