/* keyord.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Переключатель на новый и старый форматы приходных и расходных кассовых ордеров
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

def var v-noord as logi format "да/нет" init no.
find first sysc where sysc.sysc eq "noorder" no-lock no-error.
if avail sysc then v-noord = sysc.loval.


