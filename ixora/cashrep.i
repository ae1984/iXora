/* cashrep.i
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
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        24.07.2012 damir.
*/

def var v-norep as logi init no.
find first sysc where sysc.sysc eq "repcash" no-lock no-error.
if avail sysc then v-norep = sysc.loval.



