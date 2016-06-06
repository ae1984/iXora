/* cashr81.f
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

            form
            header "          Все кассовые операции. Пункт N" punum skip
            "Исполнитель " g-ofc " Дата   " g-today skip
            "Дата печати  " today string(time,"HH:MM:SS") skip
 fill("=",80) format "x(80)"
with width 130 frame a no-hide no-box no-label no-underline.
