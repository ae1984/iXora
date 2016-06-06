/* syncofcbr.p
 * MODULE
        Управление офицерами Прагмы
 * DESCRIPTION
        Синхронизация настройки польователя в филиале
 * RUN
        
 * CALLER
        syncofc.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        27.07.2006 u00121
 * CHANGES
 	08.09.2006 u00121 - добавил синхронизацию истории последнего места работы, когда сотрудник уже зарегистрированн на филиале
	04.12.2008 id00024 - добавил полную синхронизацию
*/
def input parameter setpas as log no-undo.
define input param  i-ofc like txb.ofc.ofc.


/*ofc*/
find last bank.ofc where bank.ofc.ofc = i-ofc no-lock no-error.
if avail bank.ofc then
do:
	find last txb.ofc where txb.ofc.ofc = bank.ofc.ofc no-error. /*ищем существующую учетную запись пользователя*/
	if avail txb.ofc then
	do transaction: /*если нашли, то просто синхронизируем поля записи*/

/* 		buffer-copy bank.ofc except expr to txb.ofc no-error. /* если запись уже существовала, то синхронизируем все кроме прав доступа на пакеты */ */

		buffer-copy bank.ofc to txb.ofc no-error. /*если запись уже существовала, то синхронизируем все - 04.12.2008 id00024 */
		if error-status:error then
			message error-status:get-message(1) error-status:get-number(1) view-as alert-box.


		find last bank.ofchis where bank.ofchis.ofc = bank.ofc.ofc no-lock no-error. 
		if avail bank.ofchis then
		do: 
			create txb.ofchis.
			buffer-copy bank.ofchis to txb.ofchis no-error.
			if error-status:error then delete txb.ofchis. /* 04.12.2008 id00024 - добавил удаление записи в случае если за сегодня записи совпадают */
			/* message error-status:get-message(1) error-status:get-number(1) view-as alert-box. /* 04.12.2008 id00024 - убрал дурацкий мэссадж */ */
		end.

	end.
	else
	do transaction:
		create txb.ofc.
		buffer-copy bank.ofc to txb.ofc no-error.
		if error-status:error then
			message error-status:get-message(1) error-status:get-number(1) view-as alert-box.
		else
		do:
/* 			txb.ofc.expr[1] = ''. /*копируем всю запись, за исключением поля с правами на пакеты доступа, т.к. на филиале они могут отличаться*/ синхронизируем все - 04.12.2008 id00024 */

			find last bank.ofchis where bank.ofchis.ofc = bank.ofc.ofc no-lock no-error.
			if avail bank.ofchis then
			do:
			 	create txb.ofchis. 
				buffer-copy bank.ofchis to txb.ofchis no-error.
			if error-status:error then do:
			delete txb.ofchis. /* 04.12.2008 id00024 - добавил удаление записи в случае если за сегодня записи совпадают */
			message error-status:get-message(1) error-status:get-number(1) view-as alert-box. 

			end.
			end.
		end.
	end.
	if setpas then /*если указали, что нужно сбросить пароль, то деалем это*/
		run setpassbr(i-ofc). /*установка пароля по умолчанию*/
end.