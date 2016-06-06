/* r-lnday0.p
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/
{mainhead.i}

def var v-yesterday  as date init ?.
def var v-option     as char init "report".
def var vfname       as char init "".
def var vres         as logi init no.
run r-lnday (input v-option,input v-yesterday, output vfname, input-output vres).


