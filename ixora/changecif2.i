/* changecif2.i
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

    if m-{1} then do:
	find first {1} where {1}.cif = s-cif exclusive-lock no-error.
	if available {1} then
	repeat :
	    {1}.cif = v-cif.
	    find next {1} where {1}.cif = s-cif exclusive-lock no-error.
	    if not available {1} then leave.
	end.
    end.
