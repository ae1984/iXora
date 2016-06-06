/* synchol.p
 * MODULE
	Администрирование АБПК
 * DESCRIPTION
	Синхронизация справочника праздничных дней с филиалами
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
	{r-branch.i &proc = synchol.p}
 * CALLER
        Список процедур, вызывающих этот файл
	syshol.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        03/05/06 u00121
 * BASES
	BANK
	TXB
 * CHANGES

*/

find last txb.cmp no-lock no-error. /*покажем, какой филиал обрабатывается*/
if avail txb.cmp then
do:
	displ "Синхронизация пунктов меню " txb.cmp.name with frame f no-labels centered . pause 0.
end.

def buffer b-txbhol for txb.hol. /*буфер для удаления записи из справочника, чтобы не бегать по всем справочнику на филиале без no-lock, для удаления ненужных праздников*/

for each bank.hol no-lock. /*бежим по праздникам центральной базы*/
	find last txb.hol where txb.hol.hol = bank.hol.hol no-error. /*ищем праздник центральной базы в справочнике филиала*/
	if not avail txb.hol then /*если не находим*/
	do transaction:
		create txb.hol. /*то создаем его*/
		buffer-copy bank.hol to txb.hol.
	end. 
	else  /*если нашли*/
	do:
		if txb.hol.name <> bank.hol.name then /*проверим идентичность названия праздника*/
		do transaction: /*если разное название*/
			txb.hol.name = bank.hol.name. /*синхронизируем с центральной базой*/
		end.

		if txb.hol.stn <> bank.hol.stn then /*проверим идентичность статуса праздничного дня*/
		do transaction: /*если разные статусы*/
			txb.hol.stn = bank.hol.stn. /*синхронизируем с центральной базой*/
		end.
	end.
end.

for each txb.hol fields (txb.hol.hol) no-lock. /*проверим наличие удаленных праздников в центральной базе*/
	find last bank.hol where bank.hol.hol = txb.hol.hol no-lock no-error. /*есть ли праздник из справочника филиала в справочнике центральной базы*/
	if not avail bank.hol then /*если нет */
	do:
		find last b-txbhol of txb.hol no-error.
		if avail b-txbhol then
		do transaction:
			delete b-txbhol. /*то удаляем его из справочника филиала*/
		end.
	end.
end.