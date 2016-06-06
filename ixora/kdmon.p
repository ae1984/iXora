/* kdmon.p
 * MODULE
        Мониторинг Кредитного Досье
 * DESCRIPTION
        Работа с клиентом
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11- Работа с клиентом
 * AUTHOR
        25.02.2005 marinav
 * CHANGES

*/

{mainhead.i}

{kd.i "new"}

{kdvar.i new
"s-main = 'KDLON'. s-opt = 'KDMON'. s-page = 1."}

/*run pkdogsgn.*/
s-nodel = false.

{kdmonmn.i}


