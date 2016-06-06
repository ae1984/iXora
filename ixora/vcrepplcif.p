/* vcrepplcif.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        поиск наименования клиента, тип контракта, страна инопартнера, наименование валюты
        для программы vcrptstr.p
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        22/11/2010 aigul
 * BASES
    BANK TXB
*/

def shared var v-cif like txb.cif.cif.
def shared var v-cifname as char.
def shared var v-rnn as char.
def shared var v-depart as int.
def shared var v-ppname as char.

v-cifname = "".  v-rnn = "". v-depart = 0. v-ppname = "".

find first txb.cif where txb.cif.cif = v-cif no-lock no-error.
if avail txb.cif then do:
   v-cifname = trim(trim(txb.cif.sname) + " " + trim(txb.cif.prefix)).
   v-rnn = string(txb.cif.jss, "999999999999").
   v-depart = integer(txb.cif.jame) mod 1000.
   find txb.ppoint where txb.ppoint.depart = v-depart no-lock no-error.
   if avail txb.ppoint then v-ppname = txb.ppoint.name.
end.