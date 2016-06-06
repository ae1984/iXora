/* valpozsv0.p
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
        BANK COMM
 * CHANGES
        25.06.2012 damir.
        04.07.2012 damir - убрал output parameter,добавил RepPath,RepName.
*/

{mainhead.i}

def new shared var RepPath as char.
def new shared var RepName as char.

def var v-date   as date init ?.
def var v-option as char init "valpozsv0".

run valpozsv(input v-date,input v-option).


