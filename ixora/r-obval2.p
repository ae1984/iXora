/* r-obval2.p
 * MODULE
        Название Программного Модуля
	Отчетность
 * DESCRIPTION
        Отчет по купленной-проданной инвалюте
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
        03/11/03 nataly при поиске joudoc jl.whn -> jl.jdt , иначе не показывались проводки выходных дней
        23/01/04 sasco  добавил проверку на смену валюты при поиске обменных операций
        26/10/04 kanat добавил ofc и ofc_name для отчета 
	05/05/06 u00121 - заменил суммы из joudoc на суммы из jl, т.к. были прециденты, когда сумма в joudoc, в силу неких причин, не совпадала с суммой проводки
			- добавил опцию no-undo в описание переменных и временной таблицы
*/


def  shared var v-name as char no-undo.
def  shared var      fdate as date no-undo.
def  shared var      tdate as date no-undo. 

define buffer bjl for txb.jl.

def  shared  temp-table temp no-undo
     field    dc    as    char format "x(1)"
     field    debv  as decimal format "zzzz,zzz,zz9.99"
     field    credv as decimal format "zzzz,zzz,zz9.99"
     field    crc   as integer 
     field    rate  as decimal format "zzz9.99"
     field    rko as char
     field    ofc   as char 
     field    ofc_name as char
     index main is primary crc dc rate credv debv.

def var v-dt as date no-undo.
def var i1 as integer no-undo.

do v-dt = fdate to tdate:
	for each txb.jl where txb.jl.jdt = v-dt no-lock:

		if txb.jl.gl <> 100100 and txb.jl.gl <> 100300 and txb.jl.gl <> 100200 then next.

		if txb.jl.crc = 1 or substring(txb.jl.rem[1],1,5) <> "Обмен" then next.
		
		find first bjl where bjl.jh = txb.jl.jh and bjl.crc <> txb.jl.crc no-lock use-index jhln no-error.
		if not avail bjl then next.

		if not ((jl.dam <> 0 and jl.ln = 1) or (jl.cam <> 0 and jl.ln = 4)) then next.

		/*03/11/03 nataly*/
		find txb.joudoc where joudoc.jh = txb.jl.jh and joudoc.who = jl.who and joudoc.whn = jl.jdt no-lock no-error.
		if avail txb.joudoc then 
		do.
			create temp. 
				temp.rko = v-name.

			if jl.dam <> 0 then 
			do.
				temp.dc    = "d".
				temp.debv  = /*txb.joudoc.dramt*/ txb.jl.dam. /*05/05/06 u00121*/
				temp.crc   = txb.jl.crc.
				temp.rate  = txb.joudoc.brate.
			end.
			else 
			do.
				temp.dc    = "c".
				temp.credv = /*txb.joudoc.cramt*/ txb.jl.cam. /*05/05/06 u00121*/
				temp.crc = txb.jl.crc.
				temp.rate = txb.joudoc.srate.
			end.

			temp.ofc = txb.jl.who.
	
			find first txb.ofc where txb.ofc.ofc = txb.jl.who no-lock no-error.
			if avail txb.ofc then
				temp.ofc_name = txb.ofc.name.
			else
				temp.ofc_name = "Unknown".
		end.
	end.
end.


