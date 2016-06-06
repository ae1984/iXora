/* crch.f
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

/* crch.f */

form crchis.rdt format "99/99/99" label "РЕГ.ДАТА" crchis.rate[1] label "КУРС"
     with overlay col 45 row 5 down frame hist.

form crchis.rate[2] label "ПОКУПКА НАЛИЧН.  "
     crchis.rate[3] label "ПРОДАжА НАЛИЧН.  "
     crchis.rate[4] label "ПОКУПКА БЕЗНАЛИЧН"
     crchis.rate[5] label "ПРОДАжА БЕЗНАЛИЧН"
     crchis.rate[6] label "ПОКУПКА ДОР.ЧЕК. "
     crchis.rate[7] label "ПРОДАжА ДОР.ЧЕК. "
     with row 5 centered 1 col 1 down overlay top-only side-label frame crch.
