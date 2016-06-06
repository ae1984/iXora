/* browform2.i
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
        10.12.2010 evseev - увеличил ширину столбца описание до 70
*/

sub-cod.d-cod format 'x(10)' column-label 'Справочник'
sub-cod.ccode column-label ' Код '
codname format 'x(70)' column-label ' Описание ' v-from column-label ''
