/* cifkated.f
 * MODULE
        Клиентская база
 * DESCRIPTION
        Форма для редактирования справочника категорий клиентов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-1-15-4
 * AUTHOR
        10.09.2003 nadejda
 * CHANGES
*/

def var v-vipis as logical format "да/нет" label "ВЫПИСКИ ДОСТУПНЫ?".

form
     codfr.code format "x(8)" label "КОД"
     codfr.name[1] format "x(50)" label "НАИМЕНОВАНИЕ"
     v-vipis 
     with row 5 centered scroll 1 12 down frame f-ed .
