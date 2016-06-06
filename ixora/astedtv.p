/* astedtv.p
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

/* astedtv.p должно быть редактирование мест расположения - 
запрещено, т.к. это Профит-центры - можно редактировать только сам справочник */

{functions-def.i}

displ "  Редактировать СПИСОК МЕСТ РАСПОЛОЖЕНИЯ основных средств  " skip 
      "      разрешено только через справочник Профит-центров  " skip
      "           с учетом признака доходный/затратный  " with centered frame msgf.

run uni_help1('sproftcn', '...').

hide frame msgf.

def stream rep.
output stream rep to reppc.img.
put stream rep 
FirstLine( 1, 1 ) format "x(70)" skip(2)
  "     СПИСОК МЕСТ РАСПОЛОЖЕНИЯ " skip 
  "         основных средств" skip(2)
  "   КОД     НАИМЕНОВАНИЕ" skip
  fill("-", 70) format "x(70)" skip.


for each codfr where codfr.codfr = 'sproftcn' and codfr.code matches '...' no-lock.
  put stream rep "   "  codfr.code codfr.name[1] format "x(50)" skip.
end.
put stream rep fill("-", 70) format "x(70)" skip(2).
output stream rep close.

run menu-prt('reppc.img').

