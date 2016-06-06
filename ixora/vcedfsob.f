/* vced.f
 * MODULE
        Клиентская база
 * DESCRIPTION
        Форма для редактирования справочника организационно-правовых форм
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-6-10, 9-1-2-12
 * AUTHOR
        25.08.2003 nadejda - выделено в отдельную форму
 * CHANGES
*/


form
     codfr.code format "x(20)" label "КОД ОРГ.-ПРАВ.ФОРМЫ"
     codfr.name[1] format "x(50)" label "НАИМЕНОВАНИЕ"
     with row 5 centered scroll 1 12 down frame vced .
