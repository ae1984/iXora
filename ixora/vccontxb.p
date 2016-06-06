/* vccontxb.p
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
        BANK COMM TXB
 * CHANGES
        29.06.2012 damir.
*/

{nbankBik-txb.i}

def output parameter p-namebank as char.
def output parameter p-bnkbin   as char.

p-namebank = v-ful_bnk_ru.

find first txb.sysc where txb.sysc.sysc eq "bnkbin" no-lock no-error.
if avail txb.sysc then p-bnkbin = trim(txb.sysc.chval).


