/* astmv.p
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

define buffer b-ast for ast.
define var inc as int.
define var nast as int.

nast = 1.
for each ast where ast.ast lt "100" and length(ast.ast) eq 3:
  repeat inc = 1 to ast.qty:
    create b-ast.
    b-ast.ast = string(nast,"9999").
    b-ast.grp = ast.grp.
    b-ast.name = ast.name.
    b-ast.addr[1] = ast.addr[1].
    b-ast.addr[2] = ast.addr[2].
    b-ast.addr[3] = ast.addr[3].
    b-ast.dam[1] = (ast.dam[1] - ast.cam[1]) / ast.qty.
    b-ast.noy = ast.noy.
    b-ast.qty = 1.
    b-ast.salv = ast.salv.
    b-ast.meth = ast.meth.
    nast = nast + 1.
  end.
end.
