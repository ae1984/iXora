/* sum2str.i
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


function sum2str returns char (p-value as decimal).
  def var vp-str as char.
  if p-value = 0 then vp-str = "&nbsp;".
  else vp-str = trim(string(p-value, "->>>>>>>>>>>>>>9.99")).
  return vp-str.
end.
