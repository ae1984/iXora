/* ps-prmt.i
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

run payseccheck (input g-ofc, input trim(program-name(1))).
if return-value <> "yes" then 
 do:
  display " У вас нет прав для выполнения  " +
  program-name(1) + " процедуры ! " format "x(70) "
  with centered overlay row 10 no-label frame ddd .
  pause.
  hide frame ddd .
  return .
 end.

