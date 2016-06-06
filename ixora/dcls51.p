/* dcls51.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Обновление баланса по созданным в течении дня проводкам
 * RUN
        
 * CALLER
         dayclose.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        01.08.2003 nadejda - оптимизация циклов для использования индексов
	27.04.2005 u00121  - убрал старые комментарии и добавил новые, расписав работу программы
        27.03.2006 marinav - для LON анализировать только 1-ый уровень
*/


{global.i}

/*Проверим наличие новых счетов главной книги*/
for each gl:
	for each crc where crc.sts ne 9: /*по всем действующим валютам*/
		find glbal where glbal.gl eq gl.gl and glbal.crc eq crc.crc no-error. /*есть ли счет в балансе*/
		if not available glbal then  /*если нет ...*/
		do:
			create glbal. /*то добавляем*/
				glbal.gl = gl.gl. /*код счета*/
				glbal.crc = crc.crc. /*код валюты*/
		end. /* if not available glbal */
	end. /* for each crc */
end.  /* for each gl */

/*Найдем все проводки на закрываемый день, который еще не вошли в баланс (glbal)*/
for each jh where jh.jdt = g-today and jh.post = false use-index jdtpost: 

	for each jl of jh: 
		if jl.dam = 0 and jl.cam = 0 then 
		do:
			delete jl. /*удаляем все линии проводки у которых дебет и кредит нулевые*/
			next.
		end.



		/*Изменение баланса****************************************/
		find gl of jl. 
		find glbal where glbal.gl eq gl.gl and glbal.crc eq jl.crc no-error.
		if avail glbal then
		do:
			glbal.dam = glbal.dam + jl.dam. /*увеличиваем дебет баланса*/
			glbal.cam = glbal.cam + jl.cam. /*увеличиваем кредит баланса*/
		end.
		else
		do:
			message "Отсутвует запись в балансе (glbal) по счету " gl.gl.
			pause.
			next.
		end.
		/**********************************************************/

		/********************************************************************************************************************/
		if gl.subled <> "" then 
		do:
			case gl.subled :
				when "ast" then do: {jdtupdt.i ast} end.
				when "bill" then do: {jdtupdt.i bill} end.
				when "cif" then 
					do:
						find aaa where aaa.aaa eq jl.acc no-error.
						if gl.level >= 1 and gl.level <= 5 then 
						do:
							if available aaa then 
							do:
								if jl.dam <> 0 then 
								do:
									assign aaa.ddt = jl.jdt /*дата последнего дебета*/
										aaa.lstdb = jl.dam. /*сумма последнего дебета*/
								end.
								else 
								do:
									assign aaa.cdt = jl.jdt /*дата последнего кредита*/
										aaa.lstcr = jl.cam. /*сумма последнего кредита*/
								end.
							end.
						end.
					end.
				when "dfb" then do: {jlupsub.i dfb} end.
				when "eck" then do: {jdtupdt.i eck} end.
				when "eps" then do: {jdtupdt.i eps} end.
				when "fun" then do: {jdtupdt.i fun} end.
				when "iof" then do: {jlupsub.i iof} end.
				when "lcr" then do: {jdtupdt.i lcr} end.
				when "lon" then do: if gl.level = 1 then do: {jdtupdt.i lon} end. end.
				when "ock" then do: if gl.level <= 5 then do: {jdtupdt.i ock} end. end.
			end case.
		end.
	end.
	/********************************************************************************************************************/

	jh.post = true. /*ставим признак, проводка вошла в баланс*/
end.
return.

