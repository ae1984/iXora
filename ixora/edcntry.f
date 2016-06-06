/* edcntry.f
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Форма для редактирования справочника стран с буквенными кодами и наименованиями
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-2-16
 * AUTHOR
        26.08.2003 nadejda
 * CHANGES
*/

form
     t-country.code format "x(2)" label "(C) КОД"
     t-country.rname format "x(30)" label "(R) РУССКОЕ НАИМЕНОВАНИЕ"
     t-country.ename format "x(30)" label "(E) МЕЖДУНАРОДНОЕ НАИМЕНОВАНИЕ"
     with width 78 row 5 centered scroll 1 12 down frame f-ed .
