/* r-srokm3.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM TXB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	04/12/03 nataly внесены изменения в список счетов ГК (новый ПС)
	27/04/06 u00121 изменил поиск по aaa вынес уловие в нутрь цикла, добавил условие для поиска по счетам зарегисрированным до указанной пользователем даты влючительно.
*/

def input parameter v-dat as date.

def var v-br 	as char 		no-undo.
def var summ 	as deci init 0 		no-undo.
def var v-spisgl as char init "2215,2217,2206,2207,2208,2219,2223,2125,2123,2127" no-undo.


find last txb.cmp no-lock no-error.
if avail txb.cmp then
	v-br = txb.cmp.name.	

displ txb.cmp.name with no-label no-box. pause 0.

output to a0.out append.

	put v-br format 'x(50)' skip.
	put unformatted skip(1) "Депозиты на срок до 3-х месяцев по состоянию за " v-dat " -----" skip(1).
	put 'Бал/сч    Счет      Вал    Срок(дн)     Сумма        Сумма в тенге' skip.
	put '--------------------------------------------------------------------' skip.   

	for each txb.aaa where txb.aaa.regdt <= v-dat no-lock:
		if lookup(substr(string(txb.aaa.gl),1,4), v-spisgl) > 0 and (txb.aaa.expdt - txb.aaa.regdt) < 92 and (txb.aaa.expdt - txb.aaa.regdt) > 0 then
		do:
			find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt le v-dat no-lock no-error.
			find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= v-dat no-lock no-error.
			if avail txb.aab and txb.aab.bal ne 0 then 
			do:
				put txb.aaa.gl '  ' txb.aaa.aaa '  ' txb.aaa.crc ' ' txb.aaa.expdt - txb.aaa.regdt txb.aab.bal format '>>>,>>>,>>9.99'  txb.aab.bal * txb.crchis.rate[1] format '>>>,>>>,>>>,>>9.99'  skip.
				summ = summ + txb.aab.bal * txb.crchis.rate[1].
			end.
		end.
	end.

	put space(46) summ format '->>>,>>>,>>>,>>9.99' skip(4).


	put v-br format 'x(50)' skip.
	put unformatted skip(1) "Счета до востребования по состоянию за " v-dat " -----" skip(1).
	put 'Бал/сч    Счет      Вал    Срок(дн)     Сумма        Сумма в тенге' skip.
	put '--------------------------------------------------------------------' skip.   

	summ = 0.

	for each txb.aaa  where txb.aaa.regdt <= v-dat  no-lock:
		if lookup(substr(string(txb.aaa.gl),1,4), v-spisgl) > 0 and (txb.aaa.expdt - txb.aaa.regdt) = 0 then
		do:
			find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt le v-dat no-lock no-error.
			find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= v-dat no-lock no-error.
			if avail txb.aab and txb.aab.bal ne 0 then 
			do:
				put txb.aaa.gl '  ' txb.aaa.aaa '  ' txb.aaa.crc ' ' txb.aaa.expdt - txb.aaa.regdt txb.aab.bal format '>>>,>>>,>>9.99'  txb.aab.bal * txb.crchis.rate[1] format '>>>,>>>,>>>,>>9.99'  skip.
				summ = summ + txb.aab.bal * txb.crchis.rate[1].
			end.
		end.
	end.
	put space(46) summ format '->>>,>>>,>>>,>>9.99' skip(4).

output close.
