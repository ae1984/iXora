/* fngrchief.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Формирование базы отпечатков, Сканирование и сравнение отпечатков пальцев для Директора и Гл.бухгалтера
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
        11/04/2006 madiyar - в вызов bisaveres добавил входной параметр - показывать или нет фрейм с запросом количества разрешенных проводок
        27/03/2008 madiyar - 0 - успешная сверка
*/

DEFINE VARIABLE ok AS LOGICAL NO-UNDO.
def input param i-cif like cif.cif.
def input param i-cod like sub-cod.d-cod.
def var res-compare as int. /*результат сверки*/

find last cif where cif.cif = i-cif  no-lock no-error. 
if avail cif and cif.biom then
do:
	find last uplfnghst where uplfnghst.cif = i-cif and uplfnghst.upl = i-cod and uplfnghst.sts no-lock no-error. /*проверим, снимались ли по нему отпечатки пальцев*/
	if not avail uplfnghst then /*если не снимались*/
	do: /*то предложим снять*/
		message 'Клиент подлежит биометрическому контролю!' skip 'Сканировать отпечатки пальцев?' skip i-cif "  " i-cod view-as alert-box WARNING BUTTONS OK-CANCEL UPDATE OK. 
		if OK then
			run fingers(input i-cif, input i-cod).
	end.
	else
	do:
		message "Сверить отпечатки пальцев?" view-as alert-box question buttons yes-no title "БИОМЕТРИЯ" update ok.
		if ok then
		do:
		    	run fngrcompare(i-cif, i-cod, output res-compare).
			case res-compare:
				when 1 then
				do:
					message "Сверка не прошла!" skip "Отправить доверенное лицо на контроль в п.п. 2-4-1-6?" view-as alert-box WARNING BUTTONS YES-NO UPDATE OK.
					if OK then
						res-compare = 4. /*Отправлен на контроль, сверка не прошла*/
				end.
				when 0 then
					message "Сверка прошла успешно!" view-as alert-box.
				when 2 then
					message "Произошла неопределенная ошибка сверки отпечатков пальцев," skip "либо сканирование было принудительно прекращено!" view-as alert-box.	
			end case.
			run biosaveres(input i-cif, input i-cod, input res-compare, yes).
		end.
	end.
end.

