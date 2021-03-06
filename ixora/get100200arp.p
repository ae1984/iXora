﻿/* get100200arp.p
 * MODULE
        КАССА
 * DESCRIPTION
	Определить, разрешено ли пользователю работать по 100100 (касса) или только по 100200 (касса в пути).
	Если разрешено работать только по 100200 (касса в пути), то нужно найти arp - счет для указанной валюты.

	Случаи, в которых пользователю запрещено работать по 100100:
		1. 	Если касса (100100) уже заблокированна
		2.	Если СПФ к которому он прикреплен, полностью переведено на работу через кассу в пути.
			Для полного и безоговорочного перевода СПФ на кассу в пути необходимо внести код его департамент (ppoint.depart)
			в sysc.syc = "CASHW" в поле sysc.chval.
		3.	Если СПФ пользователя автоматически переводится на 100200 после определенного часа дня.
			Перевод СПФ на такой режим осуществляется п п.п. 5-3-5 (casofc.p).
			Настройка часа принудительного перехода осуществляется в sysc.sysc = "CASOFC" в поле sysc.inval.
		4.	Если СПФ пользователя разрешено выбирать между 100100 и 100200 в определенный промежуток времени.
			В этом случае, пользователю представляется возможность самому выбрать режим работы ("касса"/"касса в пути")
			Перевод СПФ на такой режим осуществляется внесением его кода (ppoint.depart) в справочник
			sysc.sysc = "CASSOF" в поле sysc.chval. Промежуток времени настраивается в том же справочнике в полях sysc.inval (начало промежутка), sysc.deval (окончание промежутка)
	Проверка на запрещение работы через 100100 производится именно в том порядке, в котором перечисленны выше описанные пункты.
	
	Для обеспечения корректной работы, в вызывающей программе необходимо определить две переменные: первая тип logical, вторая - тип char.
	Логическая переменная призвана обеспечить обработку результата работы данной процедуры, т.е.
		если,   false - разрешено работать по 100100, тогда вторая переменная не анализируется
			true  - разрешено работать только по 100200, в этом случае используем вторую переменную.
	"Чаровая" переменная возвращает ARP - счет для указанной валюты, в случае, если логическая переменная равна true.
			
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
 * AUTHOR
        17/03/2006 u00121
 * CHANGES
  	23/03/2006 u00121	- добавил еще один исходящий параметр - o-err, который возвращает признак возникновения ошибки в процессе работы процедуры, в вызывающей программе теперь можно обрабатывать ошибочную ситуацию
*/
{global.i}
{get-dep.i} 

/**Входящие параметры*********************************************************************************************************************************************************************/
def input  param i-ofc 	as char 		no-undo. /*логин для которого ищем разрешение на 100100/100200 и arp - счет его СПФ*/
def input  param i-crc  as int 			no-undo. /*код валюты, для которой ищем arp - счет кассы в пути*/
/*****************************************************************************************************************************************************************************************/
/**Исходящие параметры********************************************************************************************************************************************************************/
def output param o-yn 	as log init false 	no-undo. /*признак разрешения работы по 100100/100200, т.е. false - 100100, true - 100200*/
def output param o-arp  as char 		no-undo. /*ARP - счет СПФ офицера для работы по 100200, если офицеру разрешено работать по 100100, то возвращает пустое значение*/
def output param o-err 	as log init false	no-undo. /*признак возникновения ошибки если true - ошибка имела место, и говорит о том, что желательно прекратить работу вызывающей программы
							 **по умолчанию если возникла ошибка, то возвращается признак работы через "кассу"*/
/*****************************************************************************************************************************************************************************************/

/**Локальные переменные*******************************************************************************************************************************************************************/
def var i_temp_dep as integer 			no-undo.  /*код СПФ офицера, из ofchis.dep = ppoint.dep */
def buffer b-sysc for sysc. /*буффер для нахождения справочника разрешения выбора между 100100 и 100200 в указанном в спрвочнике промежутке времени*/
/*****************************************************************************************************************************************************************************************/


/**Основной блок поиска*******************************************************************************************************************************************************************/
i_temp_dep = get-dep(i-ofc, g-today). /*найдем код СПФ офицера*/
o-yn = false. /*на всякий случай, еще раз поставим значение по умоланию - работаем через 100100*/

find last sysc where sysc.sysc = 'CASHW' no-lock no-error. /*найдем справочник по 100200 со списком СПФ, которые обязательно раболтают только через 100200*/
if not avail sysc then /*если не нашли, то это не правильно, попроси м пользователя сообщить нам об этом*/
do:
	message "Внимание! Не найдена настройка справочника для 100200!" skip 
		"Обратитесь в ДИТ с сообщением 'Не найден справочник sysc с названием CASHW'." view-as alert-box.	
	o-err = true.
end.
else
do:  /*если нашли то*/
	if lookup (string(i_temp_dep), sysc.chval) > 0  then  /*проверим, наш офицер принадлежит СПФ которые обязаны работать только по 100200*/
		o-yn = true. /*если принадлежит, то говорим что работаем по 100200*/
end.

if not o-yn then /*если до сих пор не определились - работаем по 100200 или по 1001000*/
do: /*ищем дальше*/
	find last sysc where sysc.sysc = "CASVOD" no-lock no-error. /*найдем признак блокировки 100100, и проверим блокирована она или нет?*/
	if not avail sysc then
	do:
		message "Внимание! Не найдена настройка справочника для 100100!" skip
			"Обратитесь в ДИТ с сообщением 'Не найден справочник sysc с названием CASVOD'." view-as alert-box.
		o-err = true.
	end.
	else 
		if sysc.loval then /*усли true значит касса блокирована*/
			o-yn = true. /*тогда точно работоаем по 100200*/
	if not o-yn then /*если и после этого нам все еще разрешено работать по 100100*/
	do: /*то, проверим настройки CASOFC и CASSOF*/
		find last sysc where sysc.sysc = "CASOFC" no-lock no-error. /*для начала, проверим текущее время*/
		if not avail sysc then
		do:
			message "Внимание! Не найдена настройка справочника времени принудительного перехода на 100200!" skip
				"Обратитесь в ДИТ с сообщением 'Не найден справочник sysc с названием CASOFC'." view-as alert-box.
			o-err = true.
		end.
		else
		do:
			if lookup (string(i_temp_dep), sysc.chval) > 0  then /*СПФ нашего офицера есть в списке СПФ, которые принудительно должны перейти на 100200 после указанного часа?*/
			do: /*если есть в списке - проверим время*/
				if time >= sysc.inval then /*если текущий час больше указаного часа*/
					o-yn = true. /*то говорим что работаем по 100200*/
			end.
			if not o-yn then
			do:
				find last b-sysc where b-sysc.sysc = "CASSOF" no-lock no-error.
				if not avail b-sysc then
				do:
					message "Внимание! Не найдена настройка справочника промежутка времени принудительного перехода на 100200!" skip
						"Обратитесь в ДИТ с сообщением 'Не найден справочник sysc с названием CASOFC'." view-as alert-box.
					o-err = true.
				end.
				else
				do:
					if lookup(string(i_temp_dep), b-sysc.chval) > 0 and time < b-sysc.deval and time > b-sysc.inval then /*если текущее время попадает в промежуток времени*/
					do: /*то, предлагаем пользователю самому выбрать нужный счет*/
                	                        run sel ("Укажите счет кассы", "Касса        100100|Касса в пути 100200").
			                        if return-value = "1" then 
							o-yn = false. 
						else 
							o-yn = true.
					end.							
				end.
			end.
		end.		
	end.
end.

o-arp = ''. /*на всякий случай, обнулим значение arp-счета*/

if o-yn then /*если все таки работаем по 100200*/
do: /*то, сейчас будем искать ARP - счет СПФ нашего офицера*/
	find first ofc where ofc.ofc = i-ofc no-lock no-error.
	for each arp where arp.gl = 100200 no-lock:
		if arp.crc <> i-crc then next.

		find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp no-lock no-error.
		if not avail sub-cod or sub-cod.ccode <> "obmen1002" then next.

		find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp no-lock no-error.
		if not avail sub-cod or sub-cod.ccode <> ofc.titcd then next.

		o-arp = arp.arp.
	end.
	if o-arp = '' then
	do:
		find last crc where crc.crc = i-crc no-lock no-error.
		if not avail crc then
		do:
                	message "Не найдена валюта с кодом " i-crc " !" view-as alert-box.
			o-err = true.
		end.
		else
		do:
			message "Не настроен счет КАССЫ В ПУТИ в валюте " crc.des " для вашего СПФ!" view-as alert-box title " ОШИБКА ! ".
			o-yn = false.
			o-err = true.
		end.
	end.
	
end.
else /*если таки разрешено работать по 100100*/
do:
	o-arp = ''. /*то возвращаем пустое значение ARP - счета и o-yn (признак 100100/100200) равным false, т.е. работаем по 100100*/
end.
/*****************************************************************************************************************************************************************************************/
