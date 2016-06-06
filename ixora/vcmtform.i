/* vcmtform.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Переход к старым и новым форматам МТ сообщений Валютного Контроля
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
        04.07.2012 damir - добавил v-MTviewbi.
*/

def var v-bin      as logi init no.
def var v-MTviewbi as logi init no.

find first sysc where sysc.sysc = 'valcon' no-lock no-error.
if avail sysc then v-bin = sysc.loval.

find first sysc where sysc.sysc = 'vcBINIINmt' no-lock no-error.
if avail sysc then v-MTviewbi = sysc.loval.


