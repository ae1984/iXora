/* vcmtform_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Переход к старым и новым форматам МТ сообщений Валютного Контроля (TXB)
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
        BANK COMM TXB
 * CHANGES
        04.07.2012 damir - добавил v-MTviewbi.
*/

def var v-bin      as logi init no.
def var v-MTviewbi as logi init no.

find first txb.sysc where txb.sysc.sysc = 'valcon' no-lock no-error.
if avail txb.sysc then v-bin = txb.sysc.loval.

find first txb.sysc where txb.sysc.sysc = 'vcBINIINmt' no-lock no-error.
if avail txb.sysc then v-MTviewbi = txb.sysc.loval.
