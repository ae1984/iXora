
/* kdrisres.p
 * MODULE
        кредитное досье
 * DESCRIPTION
        Отчет по анализу риск-менеджера
 * RUN
        kdrisres
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-11-6-7 
 * AUTHOR
        15.03.2004 marinav  
 * CHANGES 
*/

{global.i}
{kd.i new}

form s-kdcif label ' Укажите номер клиента ' format 'x(10)' skip 
     s-kdlon label ' Укажите его досье     ' format 'x(10)' skip 
           with side-label row 5 centered frame dat.

update s-kdcif with frame dat.
update s-kdlon with frame dat.

run kdrisre1.

