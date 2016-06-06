/* lcexpire3.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        PG: Expire - закрытие
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
        08/04/2011 id00810
 * CHANGES
*/

def new shared var s-lcprod as char initial 'PG'.
run lcexpire.