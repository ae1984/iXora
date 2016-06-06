/* tltrx31_1.f
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
"Итого касса  " m-sumdk1 at 42 m-sumkk1 skip
"Остатки касса" m-diff
  header
  fill("-",132) format "x(132)"
  with frame tltotal1 width 132
  down no-box no-label no-underline overlay.
