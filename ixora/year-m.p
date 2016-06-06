/* year-m.p
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

define input  parameter p1 as character.
define output parameter p2 as character.
p2 = "".
if index(p1,"/") = 0 or index(p1,"/") = r-index(p1,"/")
then undo,return.
p2 = trim(substring(p1,r-index(p1,"/") + 1)).
if length(p2) = 2
then p2 = substring(string(year(today),"9999"),1,2) + p2.
