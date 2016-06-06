/* ps-prmts.i
 * MODULE
        Платежная ссистема
 * DESCRIPTION
	Проверка на прав на полочки платежной системы очереди 2L
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
	Включаемый файл
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
	06.04.2005 u00121 - Добавлена автоматическая выдача прав доступа на полочки соответсвующие СПФ, к которому привязан офицер.
			    В sysc , где sysc.sysc= RKOPSS,  в переменной sysc.chval необходимо перечислить через запятую,
			    в формате "<id - департамента офицера(таблица ppoint)> + <:> + <название полочки>", код департамента и полочки на которую доступ дается автоматически
*/

/*
if index(program-name(1),'.') eq 0 then
 find first pssec where trim(pssec.proc) =
  trim(program-name(1)) + '(' + v-rsub + ')' no-lock no-error .

if not avail pssec or lookup(g-ofc,pssec.ofcs) eq 0 then
 do:
  bell.
  Message ' У вас нет прав для выполнения процедуры ' +
   program-name(1) + '(' + v-rsub + ') ! ' .
  pause.    
  next.
 end.
*/

	def var v-psrko as char. /*код проверки прав на полочку для СПФ, формат "<id - департамента офицера(таблица ppoint)> + <:> + <название полочки>"*/
	run payseccheck (input g-ofc, input trim(program-name(1)) + '(' + v-rsub + ')').
	if return-value <> "yes" then 
	do:
		find first sysc where sysc.sysc = "RKOPSS" no-lock no-error. /*Права на полочки по СПФ, список прав на полочки для СПФ*/
		if avail sysc then
		do:
			v-psrko = string(get-dep(g-ofc, g-today)) + ":" + v-rsub. /*формируем код проверки*/
			if lookup(v-psrko, sysc.chval) = 0 then
			do:
				Message ' У вас нет прав для выполнения процедуры ' + program-name(1) + '(' + v-rsub + ') ! ' .
				pause.    
				next.
			end.
		end.
	        else
		do:
			Message ' У вас нет прав для выполнения процедуры ' + program-name(1) + '(' + v-rsub + ') ! ' .
			pause.    
			next.
		end.
	end.
