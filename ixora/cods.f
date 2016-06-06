/* cods.f
 * MODULE
        Форма для справочника кодов доходов/расходов операций
 * DESCRIPTION
        Форма для справочника кодов доходов/расходов операций
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
        01/04/05 nataly
 * BASES
        BANK COMM
 * CHANGES
        16.05.05 nataly  - добавлен признак автоматического проставления кода cods.lookaaa = yes
        23/01/06 nataly -  добавлен признак архивности
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

form cods.code column-label "Код"
     cods.dep  format "x(3)" column-label "Подр"
     cods.gl  format "zzzzz9" column-label "Счет ГК"
     cods.acc  format "x(9)" column-label "Корр счет"
     cods.lookaaa  format "да/нет" column-label "Приз."
     cods.des format "x(35)" column-label   "Описание"
     cods.arc format "да/нет"  column-label   "Арх"
        with  COLUMN 1 row 3  down frame cods.
