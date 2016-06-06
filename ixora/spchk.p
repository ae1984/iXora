/*spchk.p
 * MODULE
       	Платежная система
 * DESCRIPTION
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

 * AUTHOR
        19.09.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        27.09.2012 Lyubov - дописала в шапку BASES
        30.07.2013 damir - Внедрено Т.З. № 1991.
        18.10.2013 yergant - TZ1750, swiftchk.i проверка swift файла
*/

{chbin.i}
{global.i}
{get-kod.i}

{chkaaa20.i}
{chk12_innbin.i}
{chkswiftfio.i}

def stream str01.
def stream str41.

def var v-strs as char no-undo.
def var v-ss as char no-undo.

def var v-str-count as integer no-undo.
def var v-payment-type as char no-undo.

def temp-table ttmps no-undo
    field sstr as char /*содержимое строки файла*/
    field scnt as integer /*порядковый номер строки в файле*/
    index ttmps-idx sstr
    index idx1 is primary scnt ascending.

def var v-32b as decimal no-undo.
def var v-32a as decimal no-undo.
def var v-32ad as char no-undo.
def var v-32ab as char no-undo.
def var v-tdt as char no-undo.
def var v-strknp as char no-undo.
def var v-errnmb as integer no-undo.
def var v-infile as char no-undo.
def var v-rnn as int no-undo.
def var v-ben as char no-undo.
def var bk as logi no-undo.
def var aaaben as char no-undo.
def var chk as int no-undo.
def var sch like aaa.aaa no-undo.
def var irs as int no-undo.
def var geo as int no-undo.
def var data as int no-undo.
def var v-date as date no-undo.

def var v-errcnt as integer no-undo.
def var ourbank as char no-undo.

function chk-bik returns logical (p-bic as char, p-acc as char).
    find last bankl where bankl.mntrm = substr(p-acc,5,3) no-lock no-error.
    if avail bankl then do:
       if bankl.bank = p-bic  then return true.
       else return false.
    end. else
   return false.
end.

find last sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
	message	"Отсутсвует настройка OURBNK в справочнике sysc!" skip
    		"Обратитесть в ДИТ с этим сообщением!" view-as alert-box title "Внимание".
	return.
end.
ourbank = trim(sysc.chval).

output to swift_report.txt.
/* проверки файлов платежей */
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

        {swiftchk.i} /*Дополнительные проверки в swift файле*/

		find first ttmps where ttmps.sstr matches "*1:F01K054700000000001000001*" no-lock no-error.
		if not avail ttmps then do:
			put unformatted " ----- Неверное значение в 1 блоке" skip.
			v-errnmb = v-errnmb + 1.
			v-errcnt = v-errcnt + 1.
		end.

		find first ttmps where ttmps.sstr matches "*2:I102SGROSS000000U3003*" no-lock no-error.
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
				find first aaa where aaa.aaa = trim(replace(ttmps.sstr,":50:/D/","")) no-lock no-error.
				if not avail aaa then do:
					put unformatted " ----- Неверное значение в поле :50:/D/ -> " trim(replace(ttmps.sstr,":50:/D/","")) skip.
					v-errnmb = v-errnmb + 1.
					v-errcnt = v-errcnt + 1.
				end.
                else sch = aaa.aaa.
		end.

		v-32b = 0.
		v-32a = v-32b.

			find first ttmps where ttmps.sstr begins ":52B:" no-lock no-error.
			if avail ttmps then do:
                if trim(replace(ttmps.sstr,":52B:","")) <> "FOBAKZKA" then do:
                    put unformatted " ----- Неверное значение в поле :52B:" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
            end.
            if not avail ttmps then do:
                put unformatted " ----- Отсутсвует поле :52B:" skip.
                v-errnmb = v-errnmb + 1.
                v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where ttmps.sstr begins ":57B:" no-lock no-error.
			if avail ttmps then do:
                v-ben = trim(replace(ttmps.sstr,":57B:","")).
                find last bankl where bankl.bank = v-ben no-lock no-error.
                if not avail bankl then do:
                    put unformatted " ----- Неверное значение в поле :57B:" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
            end.
            if not avail ttmps then do:
                put unformatted " ----- Отсутсвует поле :57B:" skip.
                v-errnmb = v-errnmb + 1.
                v-errcnt = v-errcnt + 1.
			end.

			find first ttmps where ttmps.sstr begins ":59:" no-lock no-error.
            if avail ttmps then do:
                aaaben = trim(replace(ttmps.sstr,":59:","")).
                bk = chk-bik(v-ben,aaaben).
                if bk = no then do:
                    put unformatted " ----- Неверное значение в поле :59:" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
            end.
			if not avail ttmps then do:
				put unformatted " ----- Отсутствует поле :59:" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

            if v-bin = no then do:
                for each ttmps where ttmps.sstr begins "/RNN/" no-lock:
                v-rnn = LENGTH(trim(replace(ttmps.sstr,"/RNN/",""))).
                    if v-rnn <> 12 then do:
                        put unformatted " ----- Неверное значение в поле /RNN/ " skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.
            end.

            if v-bin <> no then do:
                for each ttmps where ttmps.sstr begins "/IDN/" no-lock:
                v-rnn = LENGTH(trim(replace(ttmps.sstr,"/IDN/",""))).
                    if v-rnn <> 12 then do:
                        put unformatted " ----- Неверное значение в поле /IDN/ " skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.
            end.


			if v-bin = no then do:
                find first ttmps where ttmps.sstr begins "/RNN/" and ttmps.scnt >= 5 and ttmps.scnt <= 9 no-lock no-error.
                if avail ttmps then do:
                    find first aaa where aaa.aaa = sch no-lock no-error.
                    if avail aaa then do:
                        find first cif where cif.cif = aaa.cif no-lock no-error.
                        if not avail cif then do:
                            put unformatted " ----- Клиент не найден " skip.
                            v-errnmb = v-errnmb + 1.
                            v-errcnt = v-errcnt + 1.
                        end.
                        else do:
                            if trim(replace(ttmps.sstr,"/RNN/","")) <> cif.jss then do:
                                put unformatted " ----- Неверное значение в поле /RNN/ отправителя " skip.
                                v-errnmb = v-errnmb + 1.
                                v-errcnt = v-errcnt + 1.
                            end.
                        end.
                    end.
                end.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутствует поле /RNN/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
            end.

            if v-bin <> no then do:
                find first ttmps where ttmps.sstr begins "/IDN/" and ttmps.scnt >= 5 and ttmps.scnt <= 9 no-lock no-error.
                if avail ttmps then do:
                    find first aaa where aaa.aaa = sch no-lock no-error.
                    if avail aaa then do:
                        find first cif where cif.cif = aaa.cif no-lock no-error.
                        if not avail cif then do:
                            put unformatted " ----- Клиент не найден " skip.
                            v-errnmb = v-errnmb + 1.
                            v-errcnt = v-errcnt + 1.
                        end.
                        else do:
                            if trim(replace(ttmps.sstr,"/IDN/","")) <> cif.bin then do:
                                put unformatted " ----- Неверное значение в поле /IDN/ отправителя " skip.
                                 v-errnmb = v-errnmb + 1.
                                v-errcnt = v-errcnt + 1.
                            end.
                        end.
                    end.
                end.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутствует поле /IDN/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
            end.

			if v-bin = no then do:
                for each ttmps where ttmps.sstr begins "/RNN/" and ttmps.scnt > 20 no-lock:
                if avail ttmps then do:
                    find first rnn where rnn.trn = trim(replace(ttmps.sstr,"/RNN/","")) no-lock no-error.
                    if not avail rnn then do:
                        find first rnnu where rnnu.trn = trim(replace(ttmps.sstr,"/RNN/","")) no-lock no-error.
                        if not avail rnnu then do:
                            put unformatted " -----  РНН не найден " skip.
                            v-errnmb = v-errnmb + 1.
                            v-errcnt = v-errcnt + 1.
                        end.
                    end.
                end.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутствует поле /RNN/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
                end.
            end.

			if v-bin <> no then do:
                for each ttmps where ttmps.sstr begins "/IDN/" and ttmps.scnt > 20 no-lock:
                if avail ttmps then do:
                    find first rnn where rnn.bin = trim(replace(ttmps.sstr,"/IDN/","")) no-lock no-error.
                    if not avail rnn then do:
                        find first rnnu where rnnu.bin = trim(replace(ttmps.sstr,"/IDN/","")) no-lock no-error.
                        if not avail rnnu then do:
                            put unformatted " -----  РНН не найден " skip.
                            v-errnmb = v-errnmb + 1.
                            v-errcnt = v-errcnt + 1.
                        end.
                    end.
                end.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутствует поле /RNN/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
                end.
            end.

			find first ttmps where ttmps.sstr matches "*/IRS/*" and ttmps.scnt >= 9 and ttmps.scnt <= 11 no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Отсутствует поле /IRS/ отправителя" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.
            else do:
                find first aaa where aaa.aaa = sch no-lock no-error.
                if avail aaa then do:
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if not avail cif then do:
                        put unformatted " ----- Клиент не найден" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                    else do:
                        irs = int(trim(replace(ttmps.sstr,"/IRS/",""))).
                        geo = int(substr(cif.geo, 3, 1)).
                        if (irs < 1 or irs > 2) or irs <> geo then do:
                            put unformatted " ----- Неверное значение в поле /IRS/ отправителя" skip.
                            v-errnmb = v-errnmb + 1.
                            v-errcnt = v-errcnt + 1.
                        end.
                    end.
                end.
            end.

            find first ttmps where ttmps.sstr matches "*/IRS/*" and ttmps.scnt >= 15 and ttmps.scnt <= 19 no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Отсутствует поле /IRS/ получателя" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.
            else do:
                irs = int(trim(replace(ttmps.sstr,"/IRS/",""))).
                if irs <> 1 then do:
                    put unformatted " ----- Неверное значение в поле /IRS/ получателя" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
            end.

			find first ttmps where ttmps.sstr matches "*/SECO/*" and ttmps.scnt >= 2 and ttmps.scnt <= 12 no-lock no-error.
			if not avail ttmps then do:
				put unformatted " ----- Отсутствует поле /SECO/ отправителя" ttmps.sstr skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.
            else do:
                find first aaa where aaa.aaa = sch no-lock no-error.
                if avail aaa then do:
                    if int(trim(replace(ttmps.sstr,"/SECO/",""))) <> int(substring(get-kod("", aaa.cif), 2, 1)) then do:
                        put unformatted " ----- Неверное значение в поле /SECO/ отправителя" ttmps.sstr skip.
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

			find first ttmps where ttmps.sstr begins ":32A" and decimal(replace(trim(entry(2,ttmps.sstr,"T")), ",", ".")) > 0 no-lock no-error.
			if avail ttmps then do:
				v-32a = decimal(replace(trim(entry(2,ttmps.sstr,"T")), ",", ".")).
                v-32ab = substring(ttmps.sstr, 6, 6).
			end.

            v-tdt = substring(string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99"), 3, 6).

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

		v-32b = 0.
		v-32a = v-32b.

			for each ttmps where ttmps.sstr begins "/NAME/" no-lock .
                if length(trim(ttmps.sstr)) > 66 then do:
                    put unformatted " ----- Неверное значение в поле /NAME/ - длина более 60 символов" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                 end.
            end.

			find first ttmps where ttmps.sstr begins "/VO/" no-lock no-error.
			if avail ttmps then do:
                if integer(trim(replace(ttmps.sstr,"/VO/",""))) <> 1 then do:
                    put unformatted " ----- Неверное значение в поле /VO/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
			end.

			find first ttmps where ttmps.sstr begins "/PSO/" no-lock no-error.
			if avail ttmps then do:
                if length(trim(replace(ttmps.sstr,"/PSO/",""))) > 2 then do:
                    put unformatted " ----- Неверное значение в поле /PSO/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
			end.

			find first ttmps where ttmps.sstr begins "/PRT/" no-lock no-error.
			if avail ttmps then do:
                if length(trim(replace(ttmps.sstr,"/PRT/",""))) > 2 then do:
                    put unformatted " ----- Неверное значение в поле /PRT/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
			end.

            find first ttmps where ttmps.sstr begins "/DATE/" no-lock no-error.
			if avail ttmps then do:
                v-date = date(inte(substr(ttmps.sstr,9,2)),inte(substr(ttmps.sstr,11,2)),inte(substr(ttmps.sstr,7,2))).
                if today < v-date then do:
                    put unformatted " ----- Неверное значение в поле /DATE/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
			end.

			find first ttmps where ttmps.sstr begins "/KNP/" no-lock no-error.
			if avail ttmps and replace(ttmps.sstr,"/KNP/","") <> ? then do:
				v-strknp = replace(ttmps.sstr,"/KNP/","").
                if int(v-strknp) <> 311 then do:
                    put unformatted " ----- Неверное значение в поле /KNP/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
			end.
			else do:
				put unformatted " ----- Отсутствует поле /KNP/" skip.
				v-errnmb = v-errnmb + 1.
				v-errcnt = v-errcnt + 1.
			end.

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
else
do:
	def var home as char.

	unix value("spscr 0").

	home = trim(OS-GETENV("HOME")).

	file-info:file-name = home + '/errors.img'.

	if file-info:file-type <> ? then run menu-prt(home + '/errors.img').
end.