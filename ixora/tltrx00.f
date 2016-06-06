/* tltrx00.f
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

if m-count = 1 then m-title = "Akceptёt–s oper–cijas".
if m-count = 2 then m-title = "Neakceptёt–s oper–cijas".

form header
  g-comp format "x(70)" skip
	    "IzpildЁt–js " g-ofc " Datums " g-today skip
	    "Drukas datums" today string(time,"HH:MM:SS") skip
	    m-title format "x(45)" skip
  fill("=",134) format "x(134)"
with width 134 frame tltrxh00 no-hide no-box no-label no-underline.
