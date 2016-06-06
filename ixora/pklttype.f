/* pklttype.f
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Фирма видлв писем для выбора в списке задолжников
 * RUN
        
 * CALLER
        pklttype.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-14-6
 * AUTHOR
        13.12.2003 nadejda
 * CHANGES
*/

form 
    t-cods.choice no-label format "x"
    t-cods.code  label "КОД" format "x(10)"
    t-cods.name  label "НАИМЕНОВАНИЕ" format "x(45)"
with 11 down title v-bookname overlay centered row 6 frame uni_book.
