/* vcrepac0.p
 * MODULE
        Название модуля - п.м. 9,3,7.
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

{defperem.i "new"}

def var v-option as char init "report".
def var v-date   as date init ?.
def var vres     as logi init no.

hide message. pause 0.
run vcrepac(input v-option, input v-date, input-output vres).


