/* vvodpf.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Проверка и копирование файла пенсионных отчислений для дальнейшего импорта в ПРАГМУ
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT
        /pragma/bin/cppfv - скрипт разбора пенсионного файла для определения ошибок
 * MENU
        5-3-9-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        06.10.2003 nadejda  - сделала передачу в скрипт второго параметра - для определения по департаменту каталога, в который переписать файл
        19.08.2004 dpuchkov - добавил автоматическую проверку реестра
        01.09.2004 dpuchkov - добавил отображение суммы и рнн
        22.10.2004 tsoy     - если Несовпадение реестров то запрос на обработку
        01.17.2005 kanat    - добавил проверку на реестр соц. отчислений
        09.03.2005 kanat    - переделал все проверки на соц. отчисления, добавил КНП и РНН ПФ в проверки по пенсиоанным платежам,
                              добавил в парсер свифтовок формирование РНН ПФ, добавил формирование отчета по несверенным свифтовкам
	22.06.2005 u00121   - перекомпиляция в связи с изменением deparp_pmp.i
	30.06.2005 marinav  - Проверка реестра юр лиц
        23/08/2005 kanat - добавил проверки файлов платежей пенсионок и соц. отчислений
        24/08/2005 kanat - добавил вывод автоматическое копирование неверных файлов в error
        06/09/2005 kanat - переделал анализ полей OPV
        03.07.2006 u00121 -  ТЗ ї370 от 19/06/06 - добавил обработку полей 57B,59 и PERIOD для пенсионных платежей
        06.09.2006 u00121 - проверка на 57B и 59 для добровольных пенсионных взносов отменена (knp = 013)
        01.02.2011 marinav - изменения в связи с переходом на БИН/ИИН
        21.09.2011 lyubov - проверка swift.txt по полю :32А:
        12.09.2012 evseev - иин/бин изменение формата с НГ
        08.01.2013 berdibekov - mt102 проверка посредством соник
        24.04.2013 evseev - tz-1720
        14.05.2013 yerganat tz-1740, добавил логирование менеджера и id если не находит счет клиента
        20.05.2013 yerganat - добавил проверку первого байта входного файла
        20.06.2013 yerganat - recompile
        03.07.2013 yerganat - tz1944, Сообщения логирования swift файлов
        27.08.2012 yerganat - tz2054, переделал логирование swift файлов, добавил logswift
        26.09.2013 yerganat - tz2107, импортируемые файлы записываются на директорию psjin
        07.11.2013 yerganat - В соответствии tz-1720 в части загрузки файла свыше 2000 вкладчиков переделал логирование файла
*/



{global.i}
{get-dep.i}
{comm-txb.i}
{ispen-wrkday.i}
{deparp_pmp.i}
{chbin.i}

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
def var v-acc as char no-undo.
def var v-knp as char no-undo.
def var v-sum as char no-undo.
def var s as char init '' no-undo.
def var fname as char init '' no-undo.
def var v-infile as char no-undo.
def stream str0.
def stream str4.
def var v-count1 as integer no-undo.
def var v-count2 as integer no-undo.
def var v-rnn-nk as char no-undo.

def var mt102 as longchar init ''.

def var all-mt102-check-code as int init 0.
def var mt102-check-code as int.
def var mt102-check-des as char.

define temp-table payment no-undo like p_f_payment
	field dep as integer
	field account as char
	index payment-idx account.

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
	index ttmps-idx sstr.

def var v-32b as decimal no-undo.
def var v-32a as decimal no-undo.
def var v-32ad as char no-undo.
def var v-32ab as char no-undo.
def var v-tdt as char no-undo.
def var v-strknp as char no-undo.

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
def var v-user-name as char no-undo.

def var rwFileLine as raw  no-undo.
def stream strm-byte.
def var v-hexStr as char.
def var  v-dir-psjin as char.

v-dir-psjin = OS-GETENV("HOME") + '/psjin'.
unix silent value ("rm -f " + v-dir-psjin + "/*").
run chengefilerights(v-dir-psjin).

def var v-dir-swifts as char.
def var v-swift-digest as char.
v-dir-swifts = "/data/import/swift_check/".
run chengefilerights(v-dir-swifts).
v-dir-swifts = v-dir-swifts + g-ofc.
run chengefilerights(v-dir-swifts).
v-dir-swifts = v-dir-swifts + "/" + string(YEAR(g-today), "9999") + string(MONTH(g-today) , "99")  + string(DAY(g-today), "99").
run logswift(v-dir-swifts, "Run the programm vvodpf at " + string(time,"hh:mm:ss")).
run chengefilerights(v-dir-swifts).




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
/*
if seltxb = 0 then
do: */
	output to swift_report.txt.

	/*------------------ 23/08/2005 kanat - добавил проверки файлов платежей пенсионок и соц. отчислений ---------------*/
	input stream str01 through value("ssh Administrator@`askhost` dir /b ' " + "C:\\PROV_CIK\\in\\" + "*.*'") no-echo.
	repeat:
		import stream str01 unformatted v-ss.

		v-infile = ":" + "C:\\\\PROV_CIK\\\\in\\\\" + v-ss + " ".
		unix silent value ("scp " + " Administrator@`askhost`" + v-infile + "repfs.t").
		unix silent dos-un "repfs.t repfs.tt".
        /*Начинаем логировать*/
        run logswift(v-dir-swifts, "=============================================================================== ").
        run logswift(v-dir-swifts, "==============> Start of checking swift " + v-ss).

		v-str-count = 1.

        unix silent echo >> "repfs.tt".
		input stream str41 from "repfs.tt".
		repeat:
			import stream str41 unformatted v-strs.
			/*v-strs = trim(v-strs).*/
            if length(mt102) > 0 then
                mt102 = mt102 + '\n' + v-strs.
            else
                mt102 = v-strs.
			create ttmps.
			assign
				ttmps.sstr = v-strs
				ttmps.scnt = v-str-count.
			v-str-count = v-str-count + 1.

            run logswift(v-dir-swifts, v-strs).
		end.
		input stream str41 close.

		put unformatted "==========================================================" skip.
		put unformatted "Файл: " v-ss skip.
		put unformatted "==========================================================" skip(1).



        /*Здесь входной файл прочитывается по-байтно и проверяется первый символ, он должен быть "{", hex = 7b*/
        input stream strm-byte  from value("repfs.tt") binary no-echo no-map no-convert.
        length(rwFileLine) = 1.
        import STREAM strm-byte unformatted rwFileLine.
        v-hexStr = HEX-ENCODE(rwFileLine).
        length(rwFileLine) = 0.
        input stream strm-byte close.

        /*Логируем тело файла и в заголовке пишем mt5 digest содержимого*/
        v-swift-digest = HEX-ENCODE(MD5-DIGEST(mt102, v-dir-swifts + string(time))).
        run logswift(v-dir-swifts, v-dir-swifts + string(time)).
        run logswift(v-dir-swifts, "MD5 DIGEST of this message is " + v-swift-digest).

        if INDEX(v-hexStr, "7b") = 1 then do:
            run mt102_swift_check(input mt102, 'GCVP_MT102', v-swift-digest, output mt102-check-code, output mt102-check-des).
        end. else do:
            mt102-check-code=1.
            mt102-check-des="Кодировка файла "+ v-ss + " неправильная. Поменяйте на cp1251".
        end.

        /*Логируем результат проверки swift файла через интеграционный сервис*/
        run logswift(v-dir-swifts, "==============> Code of swiftcheck " +  string(mt102-check-code)).
        run logswift(v-dir-swifts, "==============> Description of swiftcheck " + mt102-check-des).


        if mt102-check-code <> 0 then do:

            put unformatted mt102-check-des skip.
        end.

        if mt102-check-code = 2 then do:
                find first ofc where ofc.ofc = g-ofc  no-lock no-error.
                if avail ofc then do:
                    v-user-name = ofc.name.
                end.
                put unformatted "Менеджер : " v-user-name  " id: " g-ofc skip.
        end.

		if mt102-check-code <> 0 then do:
            all-mt102-check-code = 1.
			unix silent value ("ssh Administrator@`askhost`  IF NOT EXIST C:\\\\PROV_CIK\\\\ERROR \\( mkdir C:\\\\PROV_CIK\\\\ERROR \\)") .
			unix silent value ("ssh Administrator@`askhost`  move /Y " + "C:\\\\PROV_CIK\\\\in\\\\" + v-ss + " " +  "C:\\\\PROV_CIK\\\\ERROR\\\\" + v-ss ).
		end.
        else do:
            unix silent value ("cp repfs.t " + v-dir-psjin + "/" + v-ss).
            unix silent value ("ssh Administrator@`askhost`  IF NOT EXIST C:\\\\PROV_CIK\\\\ARCH \\( mkdir C:\\\\PROV_CIK\\\\ARCH \\)") .
			unix silent value ("ssh Administrator@`askhost`  move /Y " + "C:\\\\PROV_CIK\\\\in\\\\" + v-ss + " " +  "C:\\\\PROV_CIK\\\\ARCH\\\\" + v-ss ).
        end.

        mt102 = "". /*Очищаем свивт */
		v-errcnt = 0.
	end.
	input stream str01 close.

	put unformatted "==========================================================" skip.
	output close.

	if all-mt102-check-code <> 0 then
		run menu-prt("swift_report.txt").
	/*------------------ 23/08/2005 kanat - добавил проверки файлов платежей пенсионок и соц. отчислений ---------------*/

	message "Вы хотите выполнить предварительную сверку реестров ФИЗ. ЛИЦ ?" view-as alert-box buttons yes-no update b as logical.
	if b then do:
		message "Проверка путём наложения реестров по физ лицам...".
		output to value(file1).

		for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date >= v-date-begin and p_f_payment.date <= v-date-fin and p_f_payment.deluid = ?  no-lock:
			if lookup(string(p_f_payment.cod), "100,200,300") <> 0 then
			do:
				create payment.
				buffer-copy p_f_payment to payment.
				assign
					payment.dep = get-dep(payment.uid, payment.date)
					payment.account = deparp_pmp(payment.dep).
				v-count1 = v-count1 + 1.
			end.
		end.

		for each commonpl where commonpl.txb = seltxb and commonpl.date >= v-date-begin and commonpl.date <= v-date-fin and commonpl.grp = 15 and commonpl.deluid = ? no-lock:
			create pmptemp.
			buffer-copy commonpl to pmptemp.
			assign
				pmptemp.dep = get-dep(pmptemp.uid, pmptemp.date)
			pmptemp.account = deparp_pmp(pmptemp.dep).
			v-count2 = v-count2 + 1.
		end.

		/*input stream str0 through value("ssh Administrator@`askhost` dir /b ' " + "C:\\PROV_CIK\\in\\" + "*.*'")  no-echo.*/
        input stream str0 through value(" dir -1 "  + v-dir-psjin)  no-echo.
		repeat:
			import stream str0 unformatted s.

			/*v-infile = ":" + "C:\\\\PROV_CIK\\\\in\\\\" + s + " ".
			unix silent value ("scp " + " Administrator@`askhost`" + v-infile + "repfp.tt").*/
            unix silent value ("cp " + v-dir-psjin + "/" + s + " repfp.tt").


			v-rec-count = 0.
			v-59 = false.

			input stream str4 from "repfp.tt".
			repeat:
				import stream str4 unformatted v-str.

				v-str = trim(v-str).
				if v-str begins ":32A:" then v-sum = substr(v-str, 15, 18).
				if v-str begins "/KNP/" then v-knp = substr(v-str, 6, 3).
				if v-str begins ":50:" then do:
					v-acc = substr(v-str, 8, 9).
					l-ok = true.
				end.

				if v-str begins ":59" then
				do:
					v-59 = true.
					l-ok = true.
				end.

				if l-ok and v-59 and v-str begins if v-bin = no then "/RNN/" else "/IDN/" then
				do:
					find last p_f_list where p_f_list.rnn = substr(v-str, 6, 12) no-lock no-error.
					if avail p_f_list then do:
						v-rnn-nk = substr(v-str, 6, 12).
						if l-ok then l-ok = False.
					end.
				end.

				if l-ok and v-str begins if v-bin = no then "/RNN/" else "/IDN/" then
				do:
					find first p_f_list where p_f_list.rnn = substr(v-str, 5, 12) no-lock no-error.
					if not avail p_f_list then do:
						v-rnn = substr(v-str, 5, 12).
						if l-ok then l-ok = False.
					end.
				end.
			end.
			input stream str4 close.

			if lookup(v-acc,v-accfv) <> 0 then
			do:
				if v-count1 <> 0 then do:
					for each payment where payment.account = trim(v-acc) no-lock:
						if payment.amt = decimal(replace(v-sum,",","." )) and payment.rnn = trim(v-rnn) and payment.distr = trim(v-rnn-nk) then do:
							l-pfok = True.
							leave.
						end.
					end.
				end.

				if v-count2 <> 0 then do:
					for each pmptemp where pmptemp.account = trim(v-acc) no-lock:
						find first commonls where commonls.txb = seltxb and commonls.grp = pmptemp.grp and commonls.type = pmptemp.type no-lock no-error.
						if pmptemp.sum = decimal(replace(v-sum,",","." )) and pmptemp.rnn = trim(v-rnn) and commonls.knp = trim(v-knp) then do:
							l-pmp-pfok = True.
							leave.
						end.
					end.
				end.

				if not l-pfok and not l-pmp-pfok then do:
					message "Несовпадение реестров: SWIFT: " + s + ", РНН(ИИН\БИН): " + v-rnn + ", Сумма: " + v-sum + ", КНП: " + v-knp + "\n Обработать ?"  view-as alert-box buttons yes-no update c as logical.
                			put unformatted "Несовпадение реестров: SWIFT: " + s + "," skip
                					"  РНН(ИИН/БИН): " + trim(v-rnn) + ","  skip
                					"  Сумма: " + v-sum + ","  skip
                					"  КНП: " + trim(v-knp) + " Фонд ГНПФ " + trim(v-rnn-nk) skip.
					if not c then do:
						/*unix silent value ("ssh Administrator@`askhost`  mkdir C:\\\\PROV_CIK\\\\ERROR").
						unix silent value ("ssh Administrator@`askhost`  move /Y " + "C:\\\\PROV_CIK\\\\in\\\\" + s + " " +  "C:\\\\PROV_CIK\\\\ERROR\\\\" + s ).*/

                        unix silent value ("rm " + v-dir-psjin + "/" + s).
					end.

					v-err-count = v-err-count + 1.
				end.
			end.
			l-pfok = False.
			l-pmp-pfok = False.
		end.
		input stream str0 close.
		output close .
	end.
	else do: /* 30.06.1005 marinav */
		message "Вы хотите выполнить предварительную сверку реестров ЮР. ЛИЦ ?" view-as alert-box buttons yes-no update b1 as logical.
		if b1 then do:
			message "Проверка путём наложения реестров по юр лицам...".
			output to value(file1).
				/*input stream str0 through value("ssh Administrator@`askhost` dir /b ' " + "C:\\PROV_CIK\\in\\" + "*.*'")  no-echo.*/
                input stream str0 through value(" dir -1 " + v-dir-psjin)  no-echo.
				repeat:
					import stream str0 unformatted s.
					/*v-infile = ":" + "C:\\\\PROV_CIK\\\\in\\\\" + s + " ".
					unix silent value ("scp " + " Administrator@`askhost`" + v-infile + "repfp.tt").*/
                    unix silent value ("cp " + v-dir-psjin + "/" + s + " repfp.tt").
    				v-rec-count = 0.
					v-59 = false.
					input stream str4 from "repfp.tt".
					repeat:
						import stream str4 unformatted v-str.
						v-str = trim(v-str).
						if v-str begins ":32A:" then v-sum = substr(v-str, 15, 18).
						if v-str begins "/KNP/" then v-knp = substr(v-str, 6, 3).
						if v-str begins ":50:" then do:
							v-acc = substr(v-str, 8, 9).
							l-ok = true.
						end.

						if v-str begins ":59" then
						do:
							v-59 = true.
							l-ok = true.
						end.

						if l-ok and v-59 and v-str begins if v-bin = no then "/RNN/" else "/IDN/" then
						do:
							find first p_f_list where p_f_list.rnn = substr(v-str, 5, 12) no-lock no-error.
							if avail p_f_list then do:
								v-rnn-nk = substr(v-str, 5, 12).
								if l-ok then l-ok = False.
							end.
						end.

						if l-ok and v-str begins if v-bin = no then "/RNN/" else "/IDN/" then
						do:
							find first p_f_list where p_f_list.rnn = substr(v-str, 5, 12) no-lock no-error.
							if not avail p_f_list then do:
								v-rnn = substr(v-str, 5, 12).
								if l-ok then l-ok = False.
							end.
						end.
					end.
					input stream str4 close.

					for each pay_ur where pay_ur.whn >= v-date-begin and pay_ur.whn <= v-date-fin no-lock:
							if 	pay_ur.acc = trim(v-acc) and pay_ur.sum = decimal(replace(v-sum,",","." )) and pay_ur.rnn = trim(v-rnn) and
								pay_ur.rnnf = trim(v-rnn-nk) and pay_ur.knp = v-knp then
							do:
								l-pfok = True. leave.
							end.
					end.

					if not l-pfok then do:
						message "Несовпадение реестров: SWIFT: " + s + ", Cчет: " + v-acc + ", РНН(ИИН\БИН): " + v-rnn + ", Сумма: " + v-sum + ", КНП: " + v-knp + "\n Обработать ?"  view-as alert-box buttons yes-no update c1 as logical.
						put unformatted "Несовпадение реестров: SWIFT: " + s + "," skip
								"  Cчет: " + trim(v-acc) + "," skip
								"  РНН(ИИН\БИН): " + trim(v-rnn) + ","  skip
								"  Сумма: " + v-sum + ","  skip
								"  КНП: " + trim(v-knp) + "," skip
								"  Фонд ГЦВП " + trim(v-rnn-nk) skip.
						if not c1 then do:
							/*unix silent value ("ssh Administrator@`askhost`  mkdir C:\\\\PROV_CIK\\\\ERROR").
							unix silent value ("ssh Administrator@`askhost`  move /Y " + "C:\\\\PROV_CIK\\\\in\\\\" + s + " " +  "C:\\\\PROV_CIK\\\\ERROR\\\\" + s ).
                            */

                            unix silent value ("rm " + v-dir-psjin + "/" + s).
						end.
						v-err-count = v-err-count + 1.
					end.
					l-pfok = False.
				end.
				input stream str0 close.
			output close .
		end.
	end.
/*end.*/
/** 30/06/2005 **/

v-depart = get-dep(g-ofc, g-today).
if v-depart = 1 then
	v-drko = "0".
else do:
	find last sysc where sysc.sysc = "RCOPNJ" no-lock no-error.
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


/*Логирую все файлы который будут загружены в Иксору*/
run logswift(v-dir-swifts, "======> List files which willl be uploaded to ixora").
/*input stream str0 through value("ssh Administrator@`askhost` dir /b ' " + "C:\\PROV_CIK\\in\\" + "*.*'")  no-echo.*/
input stream str0 through value(" dir -1 " + v-dir-psjin)  no-echo.
repeat:
   import stream str0 unformatted s.
   run logswift(v-dir-swifts, "               " + s).
end.
run logswift(v-dir-swifts, " ").

unix value("cppfv 1 " + v-drko).


home = trim(OS-GETENV("HOME")).

file-info:file-name = home + "/errors.img".

if file-info:file-type <> ? then run menu-prt(home + "/errors.img").

run menu-prt(home + "/lnt.txt").

if v-err-count <> 0 then
	run menu-prt("err_reg.rpt").


procedure chengefilerights.
	def input parameter dir_name as char.
    def var v-exist as char.

	input through value( "find " + dir_name + ";echo $?").
	repeat:
  		import unformatted v-exist.
	end.
	if v-exist <> "0" then do:
       unix silent value ("mkdir " + dir_name).
  	   unix silent value("chmod 777 " + dir_name).
	end.

    if v-exist = "0" then do:
       unix silent value("chmod 777 " + dir_name).
    end.
end procedure.

procedure logswift.
    def input parameter file_name as char.
    def input parameter v_message as char.

    output to value(file_name) APPEND.
        put unformatted v_message skip.
    output close.

end procedure.