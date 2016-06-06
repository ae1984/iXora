/* sum2strd.i
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

/* sum2strd.i 
   Функция перевода суммы в строку с разным количеством знаков после запятой

   13.12.2002 nadejda

*/

function sum2strd returns char (p-value as decimal, p-dec as integer).
  def var vp-str as char.
  def var vp-form as char.
  vp-form = "->>>>>>>>>>>>>>9".
  case p-dec :
    when 2 then vp-form = vp-form + ".99".
    when 4 then vp-form = vp-form + ".9999".
  end.

  if p-value = 0 then vp-str = "&nbsp;".
  else vp-str = trim(string(p-value, vp-form)).
  return vp-str.
end.

