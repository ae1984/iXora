/* lcintch5.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        SBLC: maintain charges internal (доп.расходы внутренние)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        14/03/2011 id00810
 * BASES
        BANK
 * CHANGES
*/

def new shared var s-lcprod as char initial 'SBLC'.
run lcintch.