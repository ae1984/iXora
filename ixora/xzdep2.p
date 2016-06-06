/* xzdep2.p
 * MODULE
        Операционист
 * DESCRIPTION
        Отчет по депозитам открытым депозитам ФЛ.
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
        BANK COMM
 * AUTHOR
        03.03.2005 u00121
 * CHANGES
 
 * BASES
	BANK
*/

def var d_opnamt as decimal.
def var d_dopvznos as integer.
def var d_izyatie as integer.
def var d_convert as integer.
def temp-table t-qqqqqqqqq like aaa.
def var v-val as char.
def var ddd as integer.
def var chacc as char.
def var ia as integer.
def var convert as integer.
def var v-dt as date.
def var v-file as char init "depo2.csv".

define frame nnn
  v-dt label "Введите дату" help "Все депозиты действующие на вводимую даты" skip
with side-labels centered row 7.

update v-dt with frame nnn.

output to value(v-file). 
put unformatted "Действующие депозиты на " ";" string(v-dt, "99/99/9999") ";" skip.

    put unformatted 	"CIF" ";"
			"Счет" ";"
	                "Валюта" ";"
                    	"Сумма первонач взноса" ";"
                    	"Дата открытия" ";"
                    skip.


for each lgr where lgr.led = "tda" no-lock:
	for each aaa where aaa.lgr = lgr.lgr and aaa.regdt <= v-dt and aaa.cltdt >= v-dt no-lock:
		find last cif where cif.cif = aaa.cif no-lock no-error.
		if avail cif then 
		do:
			d_opnamt   = 0. 
			d_izyatie  = 0.  
			d_dopvznos = 0.
			for each jl where jl.acc = aaa.aaa and jl.dc = "C" and jl.jdt >= aaa.regdt and jl.lev = 1 no-lock use-index acc:
				if jl.cam - jl.dam > 0 then
					d_opnamt = d_opnamt + (jl.cam - jl.dam).
			end.

			if aaa.crc = 1 then v-val = "KZT" .
			if aaa.crc = 2 then v-val = "USD" .
			if aaa.crc = 11 then v-val = "EUR" .

			put unformatted cif.cif ";"
					"[" aaa.aaa "]" ";"
					v-val ";"
					replace(trim(string(d_opnamt, "->>>>>>>>>>9.99")), ".", ",") ";"
					aaa.regdt ";"
				skip.
		end.
	end.
end.

 
output close.
unix silent cptwin  value(v-file) excel.














