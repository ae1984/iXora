/* tlatrx3.f
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
"ИтогСумм" m-sumd  at 76 m-sumk  skip
"Остаток " m-diff
  header
  fill("-",131) format "x(131)"
  with frame tltotal  down no-box no-label no-underline overlay.
