/* mnhis.p
 * MODULE
        Кредитный модуль Мониторинг
 * DESCRIPTION
        Кредитный анализ
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
       mnhismn.i 
 * MENU
        4-11-  
 * AUTHOR
        01/03/05 marinav
 * CHANGES
*/

{mainhead.i}

{kd.i}

{kdvar.i new
"s-main = ''. s-opt = 'KDMONHIS'. s-page = 1."}

s-nodel = false.
{mnfinmn.i}


