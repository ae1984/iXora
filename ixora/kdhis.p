/* kdhis.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Электронное кредитное досье
        Кредитная история
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
       kdhismn.i 
 * MENU
        4-11-3 кредИст 
 * AUTHOR
        27/08/03 marinav
 * CHANGES
        09.01.03 marinav
*/

{mainhead.i}

{kd.i}

{kdvar.i new
"s-main = ''. s-opt = 'KDHISNEW'. s-page = 1."}

s-nodel = false.
{kdhismn.i}


