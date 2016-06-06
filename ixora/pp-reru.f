/* pp-reru.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
*/

def var r-days as date label "ДАТА   С ".
def var r-daypo as date label " ПО ".
def var u-point like point.point label "ПУНКТ ".
def var u-dep like ppoint.depart label "ДЕПАРТАМЕНТ".

update r-days r-daypo with side-label frame qq centered.
update u-point help "0 - все " u-dep help "0 - все "
       with side-label frame qq1 centered.
