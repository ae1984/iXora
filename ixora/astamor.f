/* astamor.f
 * MODULE
        Основные средства
 * DESCRIPTION
        Форма для ввода %% ставок
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
        24.01.2005 marinav
 * CHANGES
*/

form taxcat.type label "Катег"
     taxcat.cat label " Подкатег"
     taxcat.name format "x(32)" label "Наименование" 
     taxcat.pc  label "Процент"
     with column 1 row 3 15 down title " Амортизация " frame taxcat.
