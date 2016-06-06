/* get-dep.i
 * MODULE
        Название Программного Модуля
        Администрирование
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Определение департамента пользователя за дату
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
 	06.09.2006 u00121 - поставил avail в функцию get-dep и если история не найдена возвращаем 1 - говорим что он числится в ЦО
*/

function get-dep returns int ( usr as char, dat as date).
	def var v-dep like ofchis.depart no-undo.
	find last ofchis where ofc = usr and regdt <= dat use-index ofchis no-lock no-error.
	if not avail ofchis then
	do:
		find first ofchis where ofc = usr and regdt >= dat use-index ofchis no-lock no-error.
		if not avail ofchis then	    
			v-dep = 1. /*Если истории по пользователю не оказалось, то говорим, что он работает в Центральном офисе*/
		else
			v-dep = ofchis.depart.
	end.
	else
		v-dep = ofchis.depart.
	return v-dep.
end.
