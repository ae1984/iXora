/* repmarj0.p
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

def var vfname       as char.
def var v-downdate   as date.
def var v-update     as date.
def var v-option     as char init "report".
def var vres         as logi init no.
run repmarj(input v-option, input v-downdate, input v-update, output vfname, input-output vres).


