/* bioconjh.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Контроль разрешенных проводок во время формирования проводки
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
	subcod.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        19/09/05 u00121
 * CHANGES
*/


{global.i}

def input param i-acc like aaa.aaa.
def output param  o-res as log init true.

find last ofc where ofc.ofc = g-ofc no-lock no-error . /*Найдем департамент офицера создающего проводку*/
if avail ofc and ofc.titcd = "103" then /*проверка на биометрический контроль происходит только для сотрудников Операционного департамента*/
do:
	find last aaa where aaa.aaa = i-acc no-lock no-error. /*Найдем счет, чтобы найти код клиента*/
	if avail aaa then
	do:
		find last cif where cif.cif = aaa.cif no-lock no-error. /*найдем клиента*/
		if avail cif then
		do:
			if cif.biom then /*если клиент переведен на биометрический контроль */ 
			do:
		 		find last biojhcnt where biojhcnt.cif = cif.cif and biojhcnt.dt = g-today  no-error. /*проверяем наличие разрешенных проводок*/
				if not avail biojhcnt then /*если нет даже записи */
					o-res = false. /*проводки запрещены*/ 
				else
					if biojhcnt.cnt <= 0 then /*если запись найдена, но количество проводок ноль*/
						o-res = false. /*проводки запрещены*/
					else
						biojhcnt.cnt = biojhcnt.cnt - 1.
			end.
		end.
	end.
end.

