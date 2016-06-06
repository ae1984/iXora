/* ibpasswd.r
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

 * MENU
        1.8.8
 * BASES
        BANK COMM IB
 * AUTHOR
        11/10/07 sasco
 * CHANGES
*/

run connib.
run ibpasswd.
disconnect "ib".
