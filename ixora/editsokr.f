/* editsokr.f
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

/* sokrat.f
*/

form sokrat.key  label "КЛЮЧ / Сокращенное название" format "x(20)"
     sokrat.full label "ВАРИАНТ / Полное название"
     with row 1 col 1 down scrollable frame sokrat.

