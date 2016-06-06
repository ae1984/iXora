/* TreasInfo3.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Контроль доступа третьим лицам к счетам Клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.5.5
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM IB
 * CHANGES
        14.05.2013 damir - Внедрено Т.З. № 1731.
*/
run connib.
run TreasInfo4.
if connected("ib") then disconnect "ib".


