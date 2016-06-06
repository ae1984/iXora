/* ibplm8.p
 * MODULE
        Internet Office
 * DESCRIPTION
        Протокол работы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        ibhist.p
 * MENU
        1.8.7
 * BASES
        BANK COMM IB
 * AUTHOR
        30/10/03 sasco
 * CHANGES
*/

run connib.
run ibhist.
disconnect "ib".
