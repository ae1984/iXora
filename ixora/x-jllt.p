/* x-jllt.p
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

/* x-jllt.p .. list current trx by trx no. */

for each jl
	    break by    jl.jh descending  by jl.ln:
    display jl.jh jl.ln jl.gl
	    jl.dam(total by jl.jh)
	    jl.cam(total by jl.jh)
	    with frame jllst down row 2 .
end.
