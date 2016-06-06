/* testpf.p
 * MODULE
        Название Программного Модуля
       	Платежная система
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Проверка правильности заполения Swift-сообщения
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        23/08/2005 kanat - добавил проверки файлов платежей пенсионок и соц. отчислений
        24/08/2005 kanat - добавил вывод автоматическое копирование неверных файлов в error
        06/09/2005 kanat - переделал анализ полей OPV
        03.07.2006 u00121 -  ТЗ ї370 от 19/06/06 - добавил обработку полей 57B,59 и PERIOD для пенсионных платежей
        06.09.2006 u00121 - проверка на 57B и 59 для добровольных пенсионных взносов отменена (knp = 013)
        14.03.2011 marinav - добавлено условие по ИИН/БИН
        21.09.2011 lyubov - проверка swift.txt по полю :32А:
*/

{chbin.i}

def stream str01.
def stream str41.

def var v-strs as char no-undo.
def var v-ss as char no-undo.

def var v-str-count as integer no-undo.
def var v-payment-type as char no-undo.

def temp-table ttmps no-undo
    field sstr as char /*содержимое строки файла*/
    field scnt as integer /*порядковый номер строки в файле*/
    index ttmps-idx sstr.

def var v-32b as decimal no-undo.
def var v-32a as decimal no-undo.
def var v-32ad as char no-undo.
def var v-32ab as char no-undo.
def var v-tdt as char no-undo.
def var v-strknp as char no-undo.
def var v-errnmb as integer no-undo.
def var v-infile as char no-undo.


def var v-errcnt as integer no-undo.
def var ourbank as char no-undo.

find last sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
	message	"Отсутсвует настройка OURBNK в справочнике sysc!" skip
    		"Обратитесть в ДИТ с этим сообщением!" view-as alert-box title "Внимание".
	return.
end.
ourbank = trim(sysc.chval).

output to swift_report.txt.
/*------------------ 23/08/2005 kanat - добавил проверки файлов платежей пенсионок и соц. отчислений ---------------*/
	input stream str01 through value("ssh Administrator@`askhost` dir /b ' " + "C:\\PROV_CIK\\in\\" + "*.*'")  no-echo. /*Читаем содержимое каталога C:\PROV_CIK\in*/
	repeat:
		import stream str01 unformatted v-ss. /*получим имя файла*/

		v-infile = ":" + "C:\\\\PROV_CIK\\\\in\\\\" + v-ss + " ". /*сформируем полный путь к нему*/
		unix silent value ("scp " + " Administrator@`askhost`" + v-infile + "repfs.t").  /*скопируем на сервер*/
		unix silent dos-un "repfs.t repfs.tt". /*перекодируем*/

		v-str-count = 1. /*количество строк скинем на 1*/

		input stream str41 from "repfs.tt". /*читаем содержимое файла*/
		repeat:
			import stream str41 unformatted v-strs.
			v-strs = trim(v-strs).

			create ttmps.
			assign
				ttmps.sstr = v-strs
				ttmps.scnt = v-str-count.

			v-str-count = v-str-count + 1.
		end.
		input stream str41 close.

		put unformatted "==========================================================" skip.
		put unformatted "Файл: " v-ss skip.
		put unformatted "==========================================================" skip(1).

		find first ttmps where ttmps.sstr matches "*1:F01K0547000000*" no-lock no-error.
		if not avail ttmps then do:
			put unformatted " ----- Неверное значение в 1 блоке" skip.
			v-errnmb = v-errnmb + 1.
			v-errcnt = v-errcnt + 1.
		end.

		find first ttmps where ttmps.sstr matches "*2:I102SGROSS000000*" no-lock no-error.
		if not avail ttmps then do:
			put unformatted " ----- Неверное значение во 2 блоке" skip.
			v-errnmb = v-errnmb + 1.
			v-errcnt = v-errcnt + 1.
		end.

		find first ttmps where ttmps.sstr begins ":20:" no-lock no-error.
		if not avail ttmps then do:
			put unformatted " ----- Отсутствует поле :20:" skip.
			v-errnmb = v-errnmb + 1.
			v-errcnt = v-errcnt + 1.
		end.

		find first ttmps where ttmps.sstr begins ":50:/D/" no-lock no-error.
		if not avail ttmps then do:
			put unformatted " ----- Отсутствует поле :50:/D/" skip.
			v-errnmb = v-errnmb + 1.
			v-errcnt = v-errcnt + 1.
		end.
		else
		do:
			find first arp where arp.arp = trim(replace(ttmps.sstr,":50:/D/","")) no-lock no-error.
			if not avail arp then do:
				find first aaa where aaa.aaa = trim(replace(ttmps.sstr,":50:/D/","")) no-lock no-error.
				if not avail aaa then do:
					put unformatted " ----- Неверное значение в поле :50:/D/ -> " trim(replace(ttmps.sstr,":50:/D/","")) skip.
					v-errnmb = v-errnmb + 1.
					v-errcnt = v-errcnt + 1.
				end.
			end.
		end.

		def var v-knp as char no-undo.
		find first ttmps where ttmps.sstr begins "/KNP/" no-lock no-error.
		if avail ttmps then do:
			if entry(3,ttmps.sstr,"/") = "012" or entry(3,ttmps.sstr,"/") = "017" then
				v-payment-type = "SC". /*социальный*/
			else
				v-payment-type = "PN". /*пенсионный*/
		        v-knp = entry(3,ttmps.sstr,"/").
		end.

		v-32b = 0.
		v-32a = v-32b.

		if v-payment-type = "SC" then
		do: /*Если платеж социальный*/
      /*iban*/
			find first ttmps where ttmps.sstr begins ":57B:GCVPKZ2A" no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле :57B:" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where ttmps.sstr begins ":59:KZ67009SS00368609110" no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле :59:" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.


			if v-bin = no then find first ttmps where ttmps.sstr matches "*/RNN/600400073391" no-lock no-error.
                                      else find first ttmps where ttmps.sstr matches "*/IDN/970740001013" no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле /RNN/IDN/" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where ttmps.sstr matches "*OPV*" no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле :70:/OPV/S" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.
			else
			do:
				if not trim(replace(ttmps.sstr,":70:/OPV/","")) begins "S" then do:
					put unformatted " ----- Неверное значение в поле :70:/OPV/S" skip.
					v-errnmb = v-errnmb + 1.
					v-errcnt = v-errcnt + 1.
				end.
			end.

			find first ttmps where ttmps.sstr matches "*/IRS/*" and ttmps.scnt >= 9 and ttmps.scnt <= 11 no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле /IRS/ отправителя" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where ttmps.sstr matches "*/SECO/*" and ttmps.scnt >= 9 and ttmps.scnt <= 12 no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле /SECO/ отправителя" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where ttmps.sstr begins "/period/" no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле /period/" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.
			else
			do:
				if replace(ttmps.sstr,"/period/","") = "" or replace(ttmps.sstr,"/period/","") = ? then do:
					put unformatted " ----- Неверное значение в поле /period/" skip.
					v-errnmb = v-errnmb + 1.
					v-errcnt = v-errcnt + 1.
				end.
			end.


			find first ttmps where ttmps.sstr begins "/IRS/1" and ttmps.scnt >= 15 and ttmps.scnt <= 19 no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле /IRS/ получателя" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where (ttmps.sstr matches "*/SECO/1*" or ttmps.sstr matches "*/SECO/01*" or ttmps.sstr matches "*/SECO/05*" or ttmps.sstr matches "*/SECO/5*") and
						ttmps.scnt >= 15 and ttmps.scnt <= 19 no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле /SECO/ получателя" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where ttmps.sstr begins "32B" and decimal(replace(trim(ttmps.sstr), ",", ".")) = 0 no-lock no-error.
			if avail ttmps then do:
				put unformatted " ----- Неверное значение в поле 32B" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			for each ttmps where ttmps.sstr begins ":32B" no-lock.
				v-32b = v-32b + decimal(replace(trim(entry(2,ttmps.sstr,"T")), ",", ".")).
			end.

			find first ttmps where ttmps.sstr begins ":32A" and decimal(replace(trim(entry(2,ttmps.sstr,"T")), ",", ".")) > 0 no-lock no-error.
			if avail ttmps then do:
				v-32a = decimal(replace(trim(entry(2,ttmps.sstr,"T")), ",", ".")).
                v-32ab = substring(ttmps.sstr, 6, 6).
			end.

            v-tdt = substring(string(year(today),"9999") + string(month(today),"99") + string(day(today),"99"), 3, 6).

            if v-tdt <> v-32ab then do:
                put unformatted " ----- Неверное значение в поле :32А: - дата валютирования не соотвествует дате проведения платежа " skip.
                v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			if v-32b <> v-32a then do:
				put unformatted " ----- Сумма поле в 32B (" v-32b ") не равна 32A (" v-32a ")" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.
		end. /*Окончание обработки социальных платежей */

		v-32b = 0.
		v-32a = v-32b.

		if v-payment-type = "PN" then /*обработка пенсионных платежей*/
		do:
			/*u00121 ТЗ ї370 от 03/07/06*************************************************************/
			if v-knp <> '013' then /*06/09/2006 u00121 проверка на 57B и 59 для добровольных пенсионных взносов отменена (knp = 013)*/
			do:
      /*iban*/
				find first ttmps where ttmps.sstr begins ":57B:GCVPKZ2A" no-lock no-error.
				if not avail ttmps then do:
					put unformatted " ----- Неверное значение в поле :57B:" skip.
					v-errnmb = v-errnmb + 1.
					v-errcnt = v-errcnt + 1.
				end.

				find first ttmps where ttmps.sstr begins ":59:KZ12009NPS0413609816" no-lock no-error.
				if not avail ttmps then do:
					put unformatted " ----- Неверное значение в поле :59:" skip.
					v-errnmb = v-errnmb + 1.
					v-errcnt = v-errcnt + 1.
				end.
			end.

			for each ttmps where ttmps.sstr begins "/NAME/" no-lock .
                           if length(trim(ttmps.sstr)) > 66 then do:
				put unformatted " ----- Неверное значение в поле /NAME/ - длина более 60 символов" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
                           end.
                        end.

			if v-bin = no then find first ttmps where ttmps.sstr matches "*/RNN/600400073391" no-lock no-error.
                                      else find first ttmps where ttmps.sstr matches "*/IDN/970740001013" no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле /RNN/IDN/" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.


			def var v-21 as log init false no-undo. /*по умолчанию значение false, пока не встретится поле 21, после этого поле принимает значение true, следующая смена на false произойдет после
								появления поля period*/
			def var v-21cnt as int init 0 no-undo.
			def var v-periodcnt as int init 0 no-undo.
			v-21 = false.
			for each ttmps no-lock break by ttmps.scnt.
				if ttmps.sstr matches "*/period/*" then    /*появилось поле period*/
				do:
					if not v-21   then /*а встречалось ли до этого момента поле 21 и не первый ли раз появилось поле PERIOD */
					do:
						if v-periodcnt = 0 then  /*если ранее 21 поле не встречалось и поле period не встречалось тоже, то это означает, что period находится в последовательности A, что не правильно*/
						do:
							put unformatted " ----- Неверное расположение поля /PERIOD/ для пенсионного платежа - поле находится в последовательности 'А', должно быть в 'B', строка " ttmps.scnt skip.
							v-errnmb = v-errnmb + 1.
							v-errcnt = v-errcnt + 1.
						end.
						do:
							put unformatted " ----- Неверное расположение поля /PERIOD/ для пенсионного платежа - не найдено 21 поле перед ним, строка " ttmps.scnt skip.
							v-errnmb = v-errnmb + 1.
							v-errcnt = v-errcnt + 1.
						end.
					end.
					else
					do:
						v-21 = false.
						v-periodcnt = v-periodcnt + 1.
					end.
				end.
				if ttmps.sstr begins ":21" then
				do:
					v-21 = true.
					v-21cnt = v-21cnt + 1.
				end.
			end.
			/*u00121 ТЗ ї370 от 03/07/06*************************************************************/

			find first ttmps where ttmps.sstr begins "/PSO/01" or ttmps.sstr begins "/PSO/1" no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле /PSO/" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where ttmps.sstr begins "/PRT/05" or ttmps.sstr begins "/PRT/5" no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Неверное значение в поле /PRT/" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where ttmps.sstr begins "/KNP/" no-lock no-error.
			if avail ttmps and replace(ttmps.sstr,"/KNP/","") <> ? then do:
				v-strknp = replace(ttmps.sstr,"/KNP/","").
			end.
			else do:
				put unformatted " ----- Неверное значение в поле /KNP/" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			if v-strknp = "010" or v-strknp = "10" or v-strknp = "019" or v-strknp = "19" then do:
				find first ttmps where ttmps.sstr matches "*OPV*" no-lock no-error.
				if not avail ttmps then do:
					put unformatted " ----- Отсутствует поле /OPV/" skip.
					v-errnmb = v-errnmb + 1.
					v-errcnt = v-errcnt + 1.
				end.
				else do:
					if not trim(replace(ttmps.sstr,":70:/OPV/","")) begins "C" then do:
						put unformatted " ----- Неверное значение в поле :70:/OPV/C" skip.
						v-errnmb = v-errnmb + 1.
						v-errcnt = v-errcnt + 1.
					end.
				end.
			end.

			if v-strknp = "013" or v-strknp = "13" then do:
				find first ttmps where ttmps.sstr matches "*OPV*" no-lock no-error.
				if not avail ttmps then do:
					put unformatted " ----- Неверное значение в поле :70:/OPV/V" skip.
					v-errnmb = v-errnmb + 1.
					v-errcnt = v-errcnt + 1.
				end.
				else do:
					if not trim(replace(ttmps.sstr,":70:/OPV/","")) begins "V" then do:
						put unformatted " ----- Неверное значение в поле :70:/OPV/V" skip.
						v-errnmb = v-errnmb + 1.
						v-errcnt = v-errcnt + 1.
					end.
				end.
			end.

			find first ttmps where ttmps.sstr begins "32B" and decimal(replace(trim(ttmps.sstr), ",", ".")) = 0 no-lock no-error.
			if avail ttmps then do:
				put unformatted " ----- Неверное значение в поле 32B" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			for each ttmps where ttmps.sstr begins ":32B" no-lock.
				v-32b = v-32b + decimal(replace(trim(entry(2,ttmps.sstr,"T")), ",", ".")).
			end.

			find first ttmps where ttmps.sstr begins ":32A"  no-lock no-error.
			if avail ttmps then
			do:
				if  decimal(replace(trim(entry(2,ttmps.sstr,"T")), ",", ".")) > 0 then
					v-32a = decimal(replace(trim(entry(2,ttmps.sstr,"T")), ",", ".")).
                    v-32ad = substring(ttmps.sstr, 6, 6).
			end.

            v-tdt = substring(string(year(today),"9999") + string(month(today),"99") + string(day(today),"99"), 3, 6).

            if v-tdt <> v-32ad then do:
                put unformatted " ----- Неверное значение в поле :32А: - дата валютирования не соотвествует дате проведения платежа " skip.
                v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

			if v-32b <> v-32a then do:
				put unformatted " ----- Сумма поле в 32B (" v-32b ") не равна 32A (" v-32a ")" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.
		end.  /*Окончание обработки пенсионных платежей*/

		for each ttmps.
			delete ttmps.
		end.

		if v-errcnt <> 0 then
		do:
			unix silent value ("ssh Administrator@`askhost`  mkdir C:\\\\PROV_CIK\\\\ERROR").
			unix silent value ("ssh Administrator@`askhost`  move /Y " + "C:\\\\PROV_CIK\\\\in\\\\" + v-ss + " " +  "C:\\\\PROV_CIK\\\\ERROR\\\\" + v-ss ).
		end.

		v-errcnt = 0.
	end.
	input stream str01 close. /*Окончание чтения каталога C:\PROV_CIK\in, т.е. файлы кончились*/

	put unformatted "==========================================================" skip.
	put unformatted " ----- ВСЕГО ОБНАРУЖЕНО " string(v-errnmb) " ОШИБОК. " skip.
output close.

if v-errnmb > 0 then  /*если имели место ошибки*/
	run menu-prt("swift_report.txt"). /*то выведем отчет об ошибках на экран*/
/*------------------ 23/08/2005 kanat - добавил проверки файлов платежей пенсионок и соц. отчислений ---------------*/
else
do:
	def var home as char.

	unix value("cppfv 0").

	home = trim(OS-GETENV("HOME")).

	file-info:file-name = home + '/errors.img'.

	if file-info:file-type <> ? then run menu-prt(home + '/errors.img').
end.





