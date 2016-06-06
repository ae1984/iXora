/* tltrx3.f
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
"Kase kopsumma" m-sumdk  at 73 m-sumkk  skip
"Kase atlikums" m-diff
  header
  fill("-",128) format "x(128)"
  with frame tltotal row 17 column 0  down no-box no-label no-underline overlay.
