/* sgnsysc.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Управление хранилищем карточек - импорт, замена, списки файлов
        Список файлов в хранилище
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-1
 * AUTHOR
        13.02.2004 nadejda
 * CHANGES
        01/06/2006 madiyar - сортировка по txb.txb
        14/03/2008 madiyar - run sel3
*/


def var v-filials as char no-undo.
def var v-select as integer no-undo.

for each txb where txb.consolid no-lock break by txb.txb:
  if v-filials <> "" then v-filials = v-filials + " | ".
  v-filials = v-filials + string(txb.txb + 1) + ". " + txb.name.
end.
v-filials = " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | " + v-filials.

v-select = 0.

run sel3 (" ВЫБЕРИТЕ ОФИС/ФИЛИАЛ БАНКА ", v-filials, output v-select).

if v-select = 0 then return.

