/* vcrepps_newcif.p
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
 * CHANGES
        31.01.2011 aigul - добавила наименование филиалов

*/

def shared var v-cif like txb.cif.cif.
def shared var v-cifname as char.
def shared var v-fil as char.
def shared var v-filname as char.

def var v-bnk as char.
v-bnk = "0" + substr(v-fil,4,2).

v-cifname = "".
v-filname = "".

find first txb.cif where txb.cif.cif = v-cif no-lock no-error.
if avail txb.cif then v-cifname = trim(trim(txb.cif.sname) + " " + trim(txb.cif.prefix)).

find first txb.cmp where txb.cmp.code = int(v-bnk) no-lock no-error.
if avail txb.cmp then v-filname = txb.cmp.name.
