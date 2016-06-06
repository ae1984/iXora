/* mnfin.p
 * MODULE
        Кредитный модуль Мониторинг
 * DESCRIPTION
        Финансовый анализ
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
       mnfinmn.i 
 * MENU
        4-11- Фин.анал 
 * AUTHOR
        01/03/05 marinav
 * CHANGES
*/

{mainhead.i}

{kd.i}

{kdvar.i new
"s-main = ''. s-opt = 'KDMONFIN'. s-page = 1."}

s-nodel = false.
{mnfinmn.i}


