/* updmns.p
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


def  shared var s-acc like jl.acc.
def  shared var s-aaa like aaa.aaa.
def  shared var s-gl like gl.gl.
def  shared var s-jl like jl.ln.
def  shared var s-aah  as int.
def  shared var s-line as int.
def  shared var s-force as log initial false.
def  shared var vcif like cif.cif.
def  shared var rcd as int .
find first jl where recid(jl) = rcd no-lock .
find first gl where gl.gl = jl.gl no-lock .
{jlupd-f.i - }
