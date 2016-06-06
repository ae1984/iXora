/* jlupsub.i
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

/* jlupsub.i
*/

find {1} where {1}.{1} = jl.acc no-error.
if not available {1}
  then do:
    find {1} where {1}.{1} = "{1}" no-error.
    if not available {1}
      then do:
	create {1}.
	{1}.{1} = "{1}".
	jl.acc = "{1}".
      end.
  end.


if jl.dam ne 0 then {1}.ddt[gl.level] = jl.jdt.
	       else {1}.cdt[gl.level] = jl.jdt.
