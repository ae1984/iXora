/* clear-fg.p
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

define input parameter p-dc like fagra.dc.
define shared variable s-lon like lon.lon.

for each fagra where fagra.lon = s-lon and fagra.pf = "F" and
    fagra.dc = p-dc and fagra.jh = 0 exclusive-lock:
    delete fagra.
end.
