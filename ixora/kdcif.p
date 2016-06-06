/* kdcif.p
 * MODULE
        Название Программного Модуля
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
        4-11-2 Работа с клиентом
 * AUTHOR
        01.12.2003 marinav
 * CHANGES

*/

{mainhead.i}

{kd.i "new"}

{kdvar.i new
"s-main = 'KDLON'. s-opt = 'KDCIFNEW'. s-page = 1."}

/*run pkdogsgn.*/
s-nodel = false.

{kdcifmn.i}


