/* syncnmenu.p
 * MODULE
	Администрирование
 * DESCRIPTION
        Синхронизация пунктов меню с филиалами
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
	{r-branch.i &proc = syncnmenu.p}
 * CALLER
        Список процедур, вызывающих этот файл
	callsynnm.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        19.04.2006 u00121
 * BASE`S
	BANK, TXB
 * CHANGES
	20.04.2006 u00121 -	при удалении прав пользователей мешались тригеры таблицы sec, откомпилиеннные под базу с логическим именем bank. 
				Перенаправил путь к библиотеке в каталог, в котором лежат эти тригеры, откомпиленые под логическое имя txb.
*/

def var v-propath as char no-undo.

find last txb.cmp no-lock no-error.
if avail txb.cmp then
do:
	displ "Синхронизация пунктов меню " txb.cmp.name with frame f no-labels centered . pause 0.
end.

/*Удалим с филиала пункты, удаленные в Центральном офисе (Алмате)**************************************************/
for each txb.nmenu . /*Бежим по пунктам филиала*/
	find last bank.nmenu where bank.nmenu.fname eq txb.nmenu.fname no-lock no-error. /*Найдем пункт филиала в Алмате*/
	if not avail bank.nmenu then /*если не найден*/
	do transaction: /*будем удалять*/
		find last txb.nmdes where txb.nmdes.fname eq txb.nmdes.fname no-error. /*Найдем описание удаляемого пункта*/
		if avail txb.nmdes then /*если есть*/
			delete txb.nmdes. /*удаляем описание*/

		/*Отнимем все права к удаляемому пункту*/
		v-propath = propath. /*20.04.2006 u00121 так как нам будут мешаться тригеры ниже используемой таблицы txb.sec, перенаправим путь к библиотеке в каталог в котором лежат эти тригеры откомпиленые под логическое имя txb*/
		propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error. /*20.04.2006 u00121*/

		for each txb.ofc no-lock:  /*бежим по списку пользователей*/
			for each txb.sec where txb.sec.ofc = txb.ofc.ofc and txb.sec.fname = txb.nmenu.fname: /*проверям, есть ли у пользователя права к удаляемому пункту меню*/
				delete txb.sec. /*если есть удаляем права*/
			end.
		end.
               	propath = v-propath no-error. /*20.04.2006 u00121 вернем старый путь к библотеки на "родину"*/
		delete txb.nmenu. /*Удаляем сам пункт меню*/

	end.
end.
/******************************************************************************************************************/

/*Добавляем/изменяем пункты добавленные в ЦО (Алматы)**************************************************************/
for each bank.nmenu no-lock. /*Бежим по пунктам Алматы*/
	find last txb.nmenu where txb.nmenu.fname = bank.nmenu.fname no-error. /*Ищем соответсвующий пункт в филиале*/
	if avail txb.nmenu then /*если нашли */
	do: /*то проверим полное соответствие*/
		if txb.nmenu.father ne bank.nmenu.father then /*совпадает ли родительский пункт*/
		do transaction:
			txb.nmenu.father = bank.nmenu.father. /*если не совпадает - синхронизируем с Алматой*/
		end.
		if txb.nmenu.ln ne bank.nmenu.ln  then /*совпадает ли порядковый номер пункта*/
		do transaction:
			txb.nmenu.ln = bank.nmenu.ln. /*если не совпадает - синхронизируем с Алматой*/
		end.
		if txb.nmenu.proc ne bank.nmenu.proc then /*совпадает ли программа пункта*/
		do transaction:
			txb.nmenu.proc = bank.nmenu.proc. /*если не совпадает - синхронизируем с Алматой*/
		end.
		if txb.nmenu.link ne bank.nmenu.link then /*совпадает ли ссылка на другой пункт*/
		do transaction:
			txb.nmenu.link = bank.nmenu.link. /*если не совпадает - синхронизируем с Алматой*/
		end.

		find last bank.nmdes where bank.nmdes.fname eq bank.nmenu.fname no-lock no-error. /*проверим наличие описание пункта на Алмате*/
		if avail bank.nmdes then /*если описание есть*/
		do: /*то проверям полное соответсвие с Алматой*/
			find last txb.nmdes where txb.nmdes.fname eq bank.nmenu.fname no-error. /*ищем описание пункта на филиале*/
			if avail txb.nmdes then /*если найдено описание на филиале*/
			do:
				if txb.nmdes.lang ne bank.nmdes.lang then /*соответсвует ли язык пункта*/
				do transaction:
					txb.nmdes.lang = bank.nmdes.lang. /*если не совпадает - синхронизируем с Алматой*/
				end.
				if txb.nmdes.des ne bank.nmdes.des then /*совпадает ли название пункта*/
				do transaction:
					txb.nmdes.des = bank.nmdes.des. /*если не совпадает - синхронизируем с Алматой*/
				end.
			end.
			else /*если не найдено описание пункта на филиале*/
			do transaction: /*создадим его*/
				create txb.nmdes.
				assign
					txb.nmdes.fname = bank.nmdes.fname
					txb.nmdes.lang  = bank.nmdes.lang
					txb.nmdes.des	= bank.nmdes.des.
			end.
		end.
	end.
	else /*если не нашли пункта на филиале*/
	do transaction: /*создадим его*/
		create txb.nmenu. /*создание самого пункта*/
		assign
			txb.nmenu.father = bank.nmenu.father
			txb.nmenu.ln = bank.nmenu.ln
			txb.nmenu.proc = bank.nmenu.proc
			txb.nmenu.fname = bank.nmenu.fname
			txb.nmenu.link = bank.nmenu.link.
	
		/*чистим описание пункта, если токовое имелло место, так на всякий случай*/
		for each txb.nmdes where txb.nmdes.fname = bank.nmenu.fname.
			delete txb.nmdes.
		end.
		/*синхронизируем описание вновь созданного пункта, если таковое конечно же имеется на Алмате*/
		find last bank.nmdes where bank.nmdes.fname eq bank.nmenu.fname no-lock no-error.
		if avail bank.nmdes then
		do:
			create txb.nmdes.
			assign
				txb.nmdes.fname = bank.nmdes.fname
				txb.nmdes.lang  = bank.nmdes.lang
				txb.nmdes.des	= bank.nmdes.des.
		end.
	end.
end.
/******************************************************************************************************************/
