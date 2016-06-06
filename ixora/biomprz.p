/* biomprz.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
	Активация признака котроля операций по счетам клиента по средствам биометрического анализа отпечатков пальцев
	Программа только активизирует контроль, деактивация происходит в другом пункте меню, предположительно в 2-7-5
 * RUN
        Верхнее меню п.п.1-1 (MMOENT -> cifsubot -> biomprz)
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.1
 * AUTHOR
        27/08/2005 u00121
 * BASE`s
	BANK
 * CHANGES
*/
def shared var s-cif like cif.cif.

find last cif where cif.cif = s-cif.
if avail cif then
do:
	if cif.crg ne "" then 
	do:
   		message 'Клиент акцептован. Для редактирования снимите акцепт!' view-as alert-box.
	end.
	else
	do:
		if not cif.biom then
		do:
			cif.biom = true.
			message "Клиент переведен на биометрический контроль." view-as alert-box.
		end.
		else
		        message "Биометрический контроль уже активизирован!" view-as alert-box.
	end.
end.
	
