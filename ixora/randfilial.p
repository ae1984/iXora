/* randfilial.p
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Розыгрыш меню по филиалам
 * BASES
        BANK COMM
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        sel3 randmain
 * MENU
        
 * AUTHOR
        07/04/2008 Alex
 * CHANGES
*/

repeat on endkey undo,leave:

def var v-filials as char no-undo.
def var v-select as integer no-undo.

v-filials = ' '.

for each txb where txb.consolid no-lock break by txb.txb:
  if v-filials <> "" then v-filials = v-filials + " | ".
  v-filials = v-filials + string(txb.txb + 1) + ". " + txb.name.
end.

v-select = 0.

run sel3 (" ВЫБЕРИТЕ ОФИС/ФИЛИАЛ БАНКА ", v-filials, output v-select).

if v-select = 0 then return.

find first comm.txb where comm.txb.consolid and comm.txb.txb = v-select - 2 no-lock no-error.
if connected ("txb") then disconnect "txb".
connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
run randmain.
    
if connected ("txb")  then disconnect "txb".

end.