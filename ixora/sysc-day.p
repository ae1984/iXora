/* sysc-day.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25.04.2011 aigul
 * BASES
        BANK
 * CHANGES
*/

find first sysc where sysc.sysc = "bday" exclusive-lock no-error.
if avail sysc then sysc.loval = yes.
find first sysc where sysc.sysc = "bday" no-lock no-error.


