/* s-lonnd2.f
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

define variable ko1 as character format "x(10)" extent 3 init [
       "Приложения",
       "Печать",
       "Выход"].
define variable i as integer.

form
    ko1
    with no-label 1 down row 15 overlay 1 columns column 1 frame ko1.

define shared variable s-lon like lon.lon.
