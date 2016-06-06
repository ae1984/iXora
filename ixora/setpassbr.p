/* set-password.p
 * MODULE
        Управление офицерами Прагмы
 * DESCRIPTION
        Установка пароля пользователя принятого по умолчанию (по умолчанию пароль пользователя равен логину пользователя)
        Стандартная программа измения пароля в системной таблице
 * RUN
        
 * CALLER
        set-password.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        27.07.2006 u00121
 * CHANGES
 	06.09.2006 u00121 - сделал изменение поля visadt, для того чтобы Прагма сразу запрашивала пользователя сменить пароль
 	11.09.2006 u00121 - изменение пароля запрашивается если visadt меньше текущего дня более чем на месяц, поэтому от today отнял еще 35 дней
 	03.10.2006 u00121 - today - 35 было только для нового пользователя, что не правильно, теперь и при простом сбросе пароля будет меняться дата смены
 			  - а то Прагма не спрашивала смену
	03.12.2008 id00024 - По умолчанию пароль теперь пустой, а раньше был такойже как и логин
*/

define input param  i-ofc like txb.ofc.ofc.

find last txb._user where txb._user._userid = i-ofc no-error.
if avail txb._user then
do transaction:
	find last txb.ofc where txb.ofc.ofc = txb._user._userid no-error.
	if avail txb.ofc then
	do:
		delete txb._user.
		create txb._user.
		assign
			txb._user._userid = txb.ofc.ofc 
			txb._user._password = encode("") /* id00024 03.12.2008 */ 
			txb._user._user-name = txb.ofc.name.
		txb.ofc.visadt = today - 35.
	end.
end.
else
do:
	find last txb.ofc where txb.ofc.ofc = i-ofc no-error.
	if avail txb.ofc then
	do transaction:
		create txb._user.
		assign
			txb._user._userid = txb.ofc.ofc 
			txb._user._password = encode("") /* id00024 03.12.2008 */ 
			txb._user._user-name = txb.ofc.name.
		txb.ofc.visadt = today - 35.
	end.
end.
