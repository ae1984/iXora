/* h-depart.p
 * MODULE
        Общие хелпы
 * DESCRIPTION
        F2 по департаментам 
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        21.06.2004 nadejda
 * CHANGES
*/

{global.i}

{itemlist.i 
       &file = "ppoint"
       &frame = "row 4 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = "ppoint.depart FORMAT '99' LABEL 'КОД '
                   ppoint.name FORMAT 'x(50)' LABEL 'НАИМЕНОВАНИЕ ДЕПАРТАМЕТА'" 
       &chkey = "depart"
       &chtype = "integer"
       &index  = "pdep" }

