/* atl.f
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

/*atl.f*/            
            form
            header "          Остатки валюты в кассе. Пункт N" point.point 
            " за  " g-today format "99/99/9999" skip
            "Дата печати  " today format "99/99/9999" string(time,"HH:MM:SS")             skip fill("=",80) format "x(80)"
            with width 130 frame a no-hide no-box no-label no-underline.

