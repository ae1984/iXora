/* tlatrx.f
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

if m-count = 1 then
m-title = "Акцептованные кассовые операции по всем исполнителям".
if m-count = 2 then
m-title = "Акцептованные некассовые операции по всем исполнителям".
if m-count = 3 then
m-title = "Неакцептованные кассовые операции по всем исполнителям".
if m-count = 4 then
m-title = "Неакцептованные некассовые операции по всем исполнителям".
form header
  g-comp format "x(70)" skip
            "Исполнитель " g-ofc " Дата   " g-today skip
            "Дата печати  " today string(time,"HH:MM:SS") skip
            m-title format "x(70)" skip
  fill("=",131) format "x(131)"
with width 131 frame tlatrxh no-hide no-box no-label no-underline.
