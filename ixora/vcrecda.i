/* vcrecda.i
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
        29.06.2012 damir.
*/

if p-bank = "TXB00" or p-bank = "" then do:
    if p-bank = "" then p-bank = "TXB00".
    run RECNAME(p-bank,output v-txbbank,output v-bnkbin).
end.

if p-bank <> "TXB00" and p-bank <> "" then do:
    run RECNAME(p-bank,output v-txbbank,output v-bnkbin).
end.


