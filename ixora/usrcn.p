/* usrcn.p
 * MODULE
        Депозитарий
 * DESCRIPTION
        Отчет по счетам сейфовых ячеек.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.1.8.14
 * BASES
        BANK COMM IB
 * AUTHOR
        21.06.2011 id00004
 * CHANGES
*/



run connib.
run usrcn1.
disconnect "ib".
