/* rep_conbl_shared.i
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
        BANK
 * CHANGES
        16.01.2013 damir - Внедрено Т.З. № 1610.
*/
def {1} shared var vsver as deci extent 4.
def {1} shared var dt1 as date no-undo.
def {1} shared var dt2 as date no-undo.

def {1} shared temp-table temp
    field txb as char
    field dt as date
    field gl as inte format "zzzzz9"
    field des as char  format "x(40)"
    field totgl as inte format "zzzzz9"
    field totlev as inte format "z9"
    field bal1 as deci format "z,zzz,zzz,zzz,zz9.99-" /* KZT */
    field bal2 as deci format "z,zzz,zzz,zzz,zz9.99-" /* USD */
    field bal3 as deci format "z,zzz,zzz,zzz,zz9.99-" /* EUR */
    field bal4 as deci format "z,zzz,zzz,zzz,zz9.99-" /* RUB */
    field bal5 as deci format "z,zzz,zzz,zzz,zz9.99-" /* GBP */
    field bal6 as deci format "z,zzz,zzz,zzz,zz9.99-" /* SEK */
    field bal7 as deci format "z,zzz,zzz,zzz,zz9.99-" /* AUD */
    field bal8 as deci format "z,zzz,zzz,zzz,zz9.99-" /* CHF */
    field bal9 as deci format "z,zzz,zzz,zzz,zz9.99-" /* ZAR */
    field bal10 as deci format "z,zzz,zzz,zzz,zz9.99-" /* CAD */
    field baltot as deci format "z,zzz,zzz,zzz,zz9.99-"
    field usd as inte init 0.
