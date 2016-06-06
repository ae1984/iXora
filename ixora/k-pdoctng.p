/* k-pdoctng.p
 * MODULE
		Формирование первой проводки RMZ	
 * DESCRIPTION
	    Проверка на заполнение справочника "Вид документа" ТЗ N 1380 от 24.02.2005
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
        ispognt.p
 * MENU
	    Перечень пунктов Меню Прагмы 
 * AUTHOR
	    03.03.2005 u00121
 * CHANGES
        01/04/2011 madiyar - изменился справочник pdoctng, исправил инициализацию значения справочника
*/

def shared var s-remtrz like remtrz.remtrz .
def output parameter v-pr as char init '0'.
def input parameter v-crc as int.

if v-crc = 1 then /*если валюта платежа KZT, то проверяем*/
do:
		find sub-cod where  sub-cod.acc    = s-remtrz /*RMZ созданного документа*/
				and sub-cod.sub    = 'rmz'    /*Тип созданного документа*/
				and sub-cod.d-cod  = 'pdoctng'  /*код справочника видов документа*/
				and sub-cod.ccode <> 'msc' no-lock no-error. /*значение не должно оставаться незаполненным*/
		if not avail sub-cod then
		do:
			message "Необходимо проставить код Вида документа (см.опцию 'Справочник' - 'pdoctng')!".
			pause.
			v-pr = '1'.
		end.
end.
else
do: 

 /*если валюта платежа не KZT, то принудительно ставим Вид документа = 19 (Иные способы)*/
		find sub-cod where  sub-cod.acc    = s-remtrz /*RMZ созданного документа*/
				and sub-cod.sub    = 'rmz'    /*Тип созданного документа*/
				and sub-cod.d-cod  = 'pdoctng'  /*код справочника видов документа*/
				no-error. /*значение не должно оставаться незаполненным*/
		if avail sub-cod then
		do:
			sub-cod.ccode = '19'.
			v-pr = '0'.
		end.

end.
