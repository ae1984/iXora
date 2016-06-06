/* aaatoday1.f
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
            header "         ОТКРЫТЫЕ СЧЕТА С " v-dbeg " ПО " v-dend "."
            skip
            "ИСПОЛНИТЕЛЬ: " ofc.name " ДАТА: " g-today skip
            "ДАТА РАСПЕЧАТКИ:" today string(time,"HH:MM:SS") skip
with frame bab no-hide no-box no-label no-underline.
