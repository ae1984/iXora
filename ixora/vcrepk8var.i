/* vcrepk8var.i
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
        05.03.2013 damir - Внедрено Т.З. № 1713.
*/
def {1} shared var v-dt1 as date.
def {1} shared var v-dt2 as date.
def {1} shared var v-god as inte format "9999".
def {1} shared var v-month as inte format "99".
def {1} shared var s-bnkbin as char.

def {1} shared temp-table wrk no-undo
    field n as inte
    field bank as char
    field bbin as char
    field cif as char
    field cname as char
    field prefix as char
    field bin as char
    field rnn as char
    field okpo as char
    field ctype as char
    field adr as char
    field obl as char
    field contract as inte
    field ctnum as char
    field ctdate as date
    field partner as char
    field expimp as char
    field inout as char
    field amte as deci
    field amti as deci
    field note as char.

def {1} shared temp-table wrkTemp no-undo
    field n as inte
    field bank as char
    field bbin as char
    field cif as char
    field cname as char
    field prefix as char
    field bin as char
    field rnn as char
    field okpo as char
    field ctype as char
    field adr as char
    field obl as char
    field contract as inte
    field ctnum as char
    field ctdate as date
    field partner as char
    field expimp as char
    field inout as char
    field amte as deci
    field amti as deci
    field note as char.


