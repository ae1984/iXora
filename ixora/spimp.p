/* spimp.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Проверка и копирование файла зарплатных отчислений для дальнейшего импорта в Иксору
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT
        /pragma/bin/spscr - скрипт разбора зарплатного файла для определения ошибок
 * MENU

 * AUTHOR
        19.09.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        27.09.2012 Lyubov - дописала в шапку BASES
        18.10.2013 yergant - TZ1750, swiftchk.i проверка swift файла
*/

{global.i}
{get-dep.i}
{comm-txb.i}
{ispen-wrkday.i}
{deparp_pmp.i}
{chbin.i}
{get-kod.i}

{chkaaa20.i}
{chk12_innbin.i}
{chkswiftfio.i}

def var v-ben as char no-undo.
def var bk as logi no-undo.
def var aaaben as char no-undo.
def var rnn as int no-undo.

def var home as char no-undo.
def var v-rkoall as char init "" no-undo.
def var v-drkoall as char init "" no-undo.
def var v-depart as integer no-undo.
def var v-rko as integer no-undo.
def var j as integer no-undo.
def var v-drko as char no-undo.
def var v-err-count as integer init 0 no-undo.

def var v-accfv as char no-undo.
def var file1 as char format "x(20)" no-undo.

def var v-str as char no-undo.
def var l-ok as logical init false no-undo.
def var v-59 as logical init false no-undo.

def var l-pfok as logical init false no-undo.
def var l-pmp-pfok as logical init false no-undo.

def var v-rnn as char no-undo.
def var v-acc as char format "x(20)" no-undo.
def var v-knp as char no-undo.
def var v-sum as char no-undo.
def var s as char init '' no-undo.
def var fname as char init '' no-undo.
def var v-infile as char no-undo.
def stream str0.
def stream str4.
def var v-count1 as integer no-undo.
def var v-count2 as integer no-undo.

define temp-table pmptemp no-undo like commonpl
	field dep as integer
	field account as char
	index pmptemp-idx account.

def var i-temp-dep as integer  no-undo.
def var v-rec-count as integer no-undo.

def stream str01.
def stream str41.
def var v-strs as char no-undo.
def var v-ss as char no-undo.

def var ew as integer no-undo.
def var seltxb as int no-undo.

def temp-table ttmps  no-undo
	field sstr as char
	field scnt as integer
	index ttmps-idx sstr
    index idx1 is primary scnt ascending.

def var v-32b as decimal no-undo.
def var v-32a as decimal no-undo.
def var v-32ad as char no-undo.
def var v-32ab as char no-undo.
def var v-tdt as char no-undo.
def var v-strknp as char no-undo.
def var chk as int no-undo.
def var sch like aaa.aaa no-undo.
def var irs as int no-undo.
def var geo as int no-undo.
def var data as int no-undo.
def var v-date as int no-undo.

def var v-errnmb as integer no-undo.
def var v-errcnt as integer no-undo.

seltxb = comm-cod().
file1 = "err_reg.rpt".

def var v-prdate as date no-undo.

find last cls no-lock no-error.

def var v-date-begin as date no-undo.
def var v-date-fin as date no-undo.

def var v-str-count as integer no-undo.
def var v-payment-type as char no-undo.

v-date-begin = g-today.
v-date-fin = v-date-begin.

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

update v-date-begin label "Введите период с " v-date-fin label " по " with centered side-label frame fdat.
hide frame fdat.

DO j = 1 TO 8:
	if is-working-day(g-today - j) then
	do:
		v-prdate = g-today - j.
		leave.
	end.
end.

for each pmpaccnt no-lock break by pmpaccnt.accnt.
	if first-of (pmpaccnt.accnt) then
		v-accfv = v-accfv + pmpaccnt.accnt + ",".
end.

	output to swift_report.txt.

	/* проверки файлов платежей */
	input stream str01 through value("ssh Administrator@`askhost` dir /b ' " + "C:\\PROV_CIK\\in\\" + "*.*'") no-echo.
	repeat:
		import stream str01 unformatted v-ss.

		v-infile = ":" + "C:\\\\PROV_CIK\\\\in\\\\" + v-ss + " ".
		unix silent value ("scp " + " Administrator@`askhost`" + v-infile + "repfs.t").
		unix silent dos-un "repfs.t repfs.tt".

		v-str-count = 1.

		input stream str41 from "repfs.tt".
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
                rnn = LENGTH(trim(replace(ttmps.sstr,"/RNN/",""))).
                    if rnn <> 12 then do:
                        put unformatted " ----- Неверное значение в поле /RNN/ " skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.
            end.

            if v-bin <> no then do:
                for each ttmps where ttmps.sstr begins "/IDN/" no-lock:
                rnn = LENGTH(trim(replace(ttmps.sstr,"/IDN/",""))).
                    if rnn <> 12 then do:
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
                v-date = int(substring(ttmps.sstr, 7, 6)).
                data = int(substring(string(year(today),"9999") + string(month(today),"99") + string(day(today + 10),"99"), 3, 6)).
                if data < v-date then do:
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
  /*Окончание обработки платежей*/

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

if v-errnmb > 0 then do:
message '111' view-as alert-box.
	run menu-prt("swift_report.txt").
		message "Проверка путём наложения реестров по юр лицам...".
		output to value(file1).
			input stream str0 through value("ssh Administrator@`askhost` dir /b ' " + "C:\\PROV_CIK\\in\\" + "*.*'")  no-echo.
			repeat:
				import stream str0 unformatted s.
				v-infile = ":" + "C:\\\\PROV_CIK\\\\in\\\\" + s + " ".
				unix silent value ("scp " + " Administrator@`askhost`" + v-infile + "repfp.tt").
				v-rec-count = 0.
				v-59 = false.
				input stream str4 from "repfp.tt".
				repeat:
					import stream str4 unformatted v-str.
					v-str = trim(v-str).
					if v-str begins ":32A:" then v-sum = substr(v-str, 15, 18).
					if v-str begins "/KNP/" then v-knp = substr(v-str, 6, 3).
					if v-str begins ":50:" then do:
						v-acc = substr(v-str, 8, 20).
						l-ok = true.
					end.

					if v-str begins ":50" then
					do:
						v-59 = true.
						l-ok = true.
					end.

					if l-ok and v-59 and v-str begins if v-bin = no then "/RNN/" else "/IDN/" then
					do:
						find first p_f_list where p_f_list.rnn = substr(v-str, 6, 12) no-lock no-error.
						if avail p_f_list then do:
							if l-ok then l-ok = False.
						end.
					end.

					if l-ok and v-str begins if v-bin = no then "/RNN/" else "/IDN/" then
					do:
						find first p_f_list where p_f_list.rnn = substr(v-str, 6, 12) no-lock no-error.
						if not avail p_f_list then do:
							v-rnn = substr(v-str, 6, 12).
							if l-ok then l-ok = False.
						end.
					end.
				end.
				input stream str4 close.

				for each salary_p where salary_p.whn >= v-date-begin and salary_p.whn <= v-date-fin no-lock:
						if 	salary_p.acc = trim(v-acc) and salary_p.sum = decimal(replace(v-sum,",","." )) and salary_p.rnn = trim(v-rnn) and
							salary_p.knp = v-knp then do:
							    message salary_p.acc trim(v-acc) salary_p.sum decimal(replace(v-sum,",","." )) salary_p.rnn trim(v-rnn) salary_p.knp v-knp view-as alert-box.
                                l-pfok = True. leave.
						end.
				end.

				if not l-pfok then do:
					message "Несовпадение реестров: SWIFT: " + s + ", Cчет: " + v-acc + ", РНН(ИИН\БИН): " + v-rnn + ", Сумма: " + v-sum + ", КНП: " + v-knp + "\n Обработать ?"  view-as alert-box buttons yes-no update c1 as logical.
					put unformatted "Несовпадение реестров: SWIFT: " + s + "," skip
							"  Cчет: " + trim(v-acc) + "," skip
							"  РНН(ИИН\БИН): " + trim(v-rnn) + ","  skip
							"  Сумма: " + v-sum + ","  skip
							"  КНП: " + trim(v-knp) + "," skip.
					if not c1 then do:
						unix silent value ("ssh Administrator@`askhost`  mkdir C:\\\\PROV_CIK\\\\ERROR").
						unix silent value ("ssh Administrator@`askhost`  move /Y " + "C:\\\\PROV_CIK\\\\in\\\\" + s + " " +  "C:\\\\PROV_CIK\\\\ERROR\\\\" + s ).
					end.
					v-err-count = v-err-count + 1.
				end.
				l-pfok = False.
			end.
			input stream str0 close.
		output close .
	/*end.*/
end.


v-depart = get-dep(g-ofc, g-today).
if v-depart = 1 then
	v-drko = "0".
else do:
	find last sysc where sysc.sysc = "RCOZP" no-lock no-error.
	if avail sysc and sysc.chval <> "" and num-entries(sysc.chval, ";") > 1 then
	do:
		v-rkoall = entry(1, sysc.chval, ";").
		v-drkoall = entry(2, sysc.chval, ";").
	end.

	if v-rkoall <> "" then
	do:
		v-rko = lookup(string(v-depart), v-rkoall).
		if v-rko > 0 then
			v-drko = entry(v-rko, v-drkoall).
		else
			v-drko = "0".
	end.
	else
		v-drko = "0".
end.

unix value("spscr 1 " + v-drko).


home = trim(OS-GETENV("HOME")).

file-info:file-name = home + "/errors.img".

if file-info:file-type <> ? then run menu-prt(home + "/errors.img").

run menu-prt(home + "/lnt.txt").

if v-err-count <> 0 then
	run menu-prt("err_reg.rpt").
