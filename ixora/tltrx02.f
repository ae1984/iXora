/* tltrx02.f
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

 display stream m-out2
 g-comp format "x(70)" skip
            "Исполнитель " g-ofc " Дата   " report-date skip
            "Дата печати  " today string(time,"HH:MM:SS") skip
            "Неотштампованные проводки " vtitle format "x(45)" skip
  fill("=",132) format "x(132)"
with width 132 frame tltrxh2 no-hide no-box no-label no-underline.
