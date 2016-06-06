/* edcntry.f
 * MODULE
         
 * DESCRIPTIO
        Форма для редактирования справочника городов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        07.05.07 marinav
 * CHANGES
*/

form
     codfr.code format "x(5)" label "(C) КОД"
     codfr.name[1] format "x(30)" label " НАИМЕНОВАНИЕ"
     codfr.name[2] format "x(10)" label "КР БЮРО"
     with width 78 row 5 centered scroll 1 12 down frame f-ed .
