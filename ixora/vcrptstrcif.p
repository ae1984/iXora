/* vcrptstrcif.p
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
        06.11.2006 u00600 
        
*/

def shared var v-cif like txb.cif.cif. def shared var v-name as char.
def shared var v-gr10 as char. def shared var v-tovar as char.
def shared var v-crc like txb.ncrc.crc. def shared var v-crcN as char.
def shared var v-str1 like txb.codfr.code. def shared var v-strana as char.

v-name = "".  v-gr10 = "". v-crcN = "". v-strana = "".

find first txb.cif where txb.cif.cif = v-cif no-lock no-error.
   if avail txb.cif then v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).

find first txb.codfr where txb.codfr.codfr = 'vccontr' and txb.codfr.code = v-tovar no-lock no-error.
  if avail txb.codfr then v-gr10 = txb.codfr.name[1].

find first txb.codfr where txb.codfr.codfr = 'iso3166' and txb.codfr.code = v-str1 no-lock no-error.
  if avail txb.codfr then v-strana = txb.codfr.name[1].

find first txb.ncrc where txb.ncrc.crc = v-crc no-lock no-error.
  if avail txb.ncrc then v-crcN = txb.ncrc.code.
  else v-crcN = "".

