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
        31.03.09 id00363
 * CHANGES

*/

function get-dep returns int ( usr as char, dat as date).
	def var v-dep like txb.ofchis.depart no-undo.
	find last txb.ofchis where txb.ofchis.ofc = usr and txb.ofchis.regdt <= dat use-index ofchis no-lock no-error.
	if not avail ofchis then
	do:
		find first txb.ofchis where txb.ofchis.ofc = usr and txb.ofchis.regdt >= dat use-index ofchis no-lock no-error.
		if not avail ofchis then	    
			v-dep = 1. /*Если истории по пользователю не оказалось, то говорим, что он работает в Центральном офисе*/
		else
			v-dep = txb.ofchis.depart.
	end.
	else
		v-dep = txb.ofchis.depart.
	return v-dep.
end.
