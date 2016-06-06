/* vcrptac1cif.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        поиск наименования клиента
        для программы vcrptac1.p
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        19/11/2010 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        22.05.2012 damir - перекомпиляция.
*/

def shared var v-cif like txb.cif.cif.
def shared var v-name as char.
v-name = "".

find first txb.cif where txb.cif.cif = v-cif no-lock no-error.
   if avail txb.cif then v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).



