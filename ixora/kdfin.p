/* kdашт.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Финансовый анализ
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
       kdfinmn.i 
 * MENU
        4-11-2 Фин.анал 
 * AUTHOR
        01/12/03 marinav
 * CHANGES
*/

{mainhead.i}

{kd.i}

{kdvar.i new
"s-main = ''. s-opt = 'KDFINNEW'. s-page = 1."}

s-nodel = false.
{kdfinmn.i}


