/* TreasInfo.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Доступ третьим лицам к счетам Клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.5.3
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM IB
 * CHANGES
        14.05.2013 damir - Внедрено Т.З. № 1731.
*/
run connib.
run TreasInfo2.
if connected("ib") then disconnect "ib".


