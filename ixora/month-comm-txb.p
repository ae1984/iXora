/* month-comm-txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        month-comm-txb.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
       02.04.2012 aigul
 * BASES
        BANK TXB
 * CHANGES
        04.05.2012 aigul - добавила Bases
*/

find first txb.sysc where txb.sysc.sysc = "MC" exclusive-lock no-error.
if avail txb.sysc then txb.sysc.loval = no.

