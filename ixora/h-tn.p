/* h-tn.p
 * MODULE
        Управление офицерами Прагмы
 * DESCRIPTION
        Список сотрудников с табельными номерами
 * RUN
        обязательно д.б. построена временная таблица со списком офицером - поскольку нет индекса по name!
 * CALLER
        x-ofc1.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9.1.5.8.
 * AUTHOR
        18.11.2002 nadejda
 * CHANGES
        18.08.2003 nadejda - поправлено определение таблицы и формат вывода
*/

{global.i}

def shared temp-table t-ofc-tn
  field tn as char
  field name as char
  field ofc as char
  field profitcn as char
  field fired as logical format "да/ "
  index main is primary name.

{itemlist.i 
       &file = "t-ofc-tn"
       &frame = "row 4 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ofc-tn.tn label 'ТАБНОМ' format 'x(4)'
                    t-ofc-tn.name label 'ФИО' format 'x(45)'
                    t-ofc-tn.ofc label 'ОФИЦЕР' format 'x(8)'
                    t-ofc-tn.profitcn label 'ПЦ' format 'x(4)'
                    t-ofc-tn.fired label 'УВОЛ' format 'да/ '
                   " 
       &chkey = "tn"
       &chtype = "string"
       &index  = "main" }

