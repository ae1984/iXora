/* vcrepfinvar.i
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
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
*/
def {1} shared var v-dt as date.

def {1} shared temp-table t-dolgs
    field lender as char
    field borrower as char
    field ctnum as char
    field ctdate as date
    field sumdolg as deci
    field ctterm as char.



