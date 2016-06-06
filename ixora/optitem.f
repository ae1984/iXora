/* optitem.f
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
 * BASES
        BANK COMM
 * CHANGES
        22.06.2004 nadejda - добавлена настройка на разрешение запуска пункта, если там проверяется запрет на редактирование
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

form optitem.ln label "LN#" help " Номер по порядку в верхнем меню"
     optitem.proc label "ПРОЦ" help " Запускаемая процедура"
     v-menu format "x(10)" label "НАЗВАНИЕ" help " Название пункта верхнего меню"
     v-des format "x(30)" label "ОПИСАНИЕ" help " Описание функций пункта меню"
     v-ro format "x(15)" label "ПРОЦ.ЧТЕНИЯ" help " Запускаемая процедура 'только для чтения'"
     v-avail_run format "xxx" label "" help " Признак 'разрешен запуск' для меню 1.2."
                 validate (v-avail_run = "" or lookup(v-avail_run, "yes,no") > 0, " Допустимые значения : пустое или да/нет")
  with row 5 down col 3 overlay frame optitem.
