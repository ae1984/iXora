/* DCffm499.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        IMLC: Корреспонденция - исходящий свифт
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
        12/03/2012 Lyubov
 * CHANGES
*/

def new shared var s-lcprod as char initial ''.
def new shared var s-mt as int.
s-mt = 499.
run lcoutcor.