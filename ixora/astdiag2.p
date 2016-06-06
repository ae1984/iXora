/* astdiag2.p
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

for each ast where ast.ast gt "000" and
ast.ast lt "100" and length(ast.ast) eq 4:
accumulate ast.ast ast.qty (total) ast.dam[1] (total) ast.cam[1] (total).
end.
display (accum total ast.qty) (accum total ast.dam[1]) (accum total ast.cam[1]).
