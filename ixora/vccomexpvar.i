/* vccomexpvar.i
 * MODULE
        Название модуля - Валютный контроль
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
        25.12.2012 damir - Внедрено Т.З. 1306.
*/

def {1} shared temp-table t-dolgs
    field cif as char
    field txb as char
    field namefil as char
    field depart as inte
    field cifname as char
    field contract as inte
    field ctdate as date
    field ctnum as char
    field ctei as char
    field ncrc as inte
    field sumcon as deci
    field sumusd as deci
    field sumdolg as deci
    field lcnum as char
    field days as inte
    field cifrnn as char
    field cifokpo as char
    field ctterm  as char
    field cardnum as char
    field carddt as char
    field srokrep as deci.

def {1} shared var s-dtb as date.
def {1} shared var s-dte as date.
def {1} shared var s-closed as logi format "да/нет".