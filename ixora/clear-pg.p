/* clear-pg.p
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
define variable v-dc like fagra.dc.

define buffer fagra1 for fagra.

if p-dc = "D"
then v-dc = "C".
else v-dc = "D".
for each fagra where fagra.lon = s-lon and fagra.pf = "P" and
    fagra.dc = p-dc exclusive-lock:
    find first fagra1 where fagra1.falon = fagra.falon and fagra1.pf = "F" and
         fagra1.dc = v-dc and fagra1.nr = fagra.nr no-lock no-error.
    if not available fagra1
    then delete fagra.
end.
