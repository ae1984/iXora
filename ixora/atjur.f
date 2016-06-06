/* atjur.f
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
            header "         Открытые счета " skip
                   "         Юридические лица" skip
                   "         с " v-dbeg " по " v-dend "."
            skip
            "Исполнитель " ofc.name " Дата " g-today skip
            "Дата печати" today string(time,"HH:MM:SS") skip
with frame bab no-hide no-box no-label no-underline.
