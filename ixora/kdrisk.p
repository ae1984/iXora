/* kdzal.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
         Работы с обеспечением
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-6
 * AUTHOR
        13.01.2004 marinav
 * CHANGES
        30/04/2004 madiar - доступ только у ГБ
*/

{mainhead.i}

{kd.i "new"}

{kdvar.i new
"s-main = 'KDLON'. s-opt = 'KDRISK'. s-page = 1."}

/*run pkdogsgn.*/
s-nodel = false.

if s-ourbank <> "TXB00" then return. /* доступ только у ГО */

{kdrismn.i}

