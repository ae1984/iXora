/* keysign.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Отображение подписей контроллеров
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
        BANK COMM
 * CHANGES
        26.03.2012 damir.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

def var v-transsign as logi format "да/нет" init no.
find first sysc where sysc.sysc eq "signofc" no-lock no-error.
if avail sysc then v-transsign = sysc.loval.


