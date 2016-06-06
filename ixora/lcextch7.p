/* lcextch7.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC: maintain charges external(доп.расходы внешние)
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
        23.01.2013 Lyubov
 * BASES
        BANK
 * CHANGES
*/

def new shared var s-lcprod as char initial 'IDC'.
run lcextch.