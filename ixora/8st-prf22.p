/* 8st-prf22.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        04/12/03 nataly изменен набор счетов ГК по признаку 136 в связи с новым планом сч
        25/05/04 - suchkov - уменьшил цикл до 26
        09/09/04 - suchkov - переписал наименования баз
        25/11/04 - suchkov - Закоментированы строки со 109 по 126 
        23/02/06 - nataly  закомментировала строку 100
        03/07/06 - u00121 - добавил индексы в таблицу temp
        14/07/06 - u00119 - добавила if avail bank.gl
*/


def shared temp-table temp no-undo
  field  kod  as char
  field  gl  as integer format 'zzzzzz'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char
  index idx1-temp kod
  index idx2-temp gl kod. 

def  shared var v-gl as char extent 200.
def  shared var s-gl as char extent 200.
def  shared var vasof as date.

def  shared var i as int. 
def  shared var k as int. 
def  shared var j as int init 1. 

def var dt as decimal no-undo.
def var ct as decimal no-undo.
def var vbal as decimal no-undo.

def var m-begday as date init 01/01/1996 no-undo.
def var m-endday as date no-undo.

m-endday = vasof.

do j =  1 to 26.
	if entry(1,v-gl[j]) eq '132' then 
	do:
		for each txb.aaa where (string(txb.aaa.gl) begins "2215" or 
					string(txb.aaa.gl) begins "2217" or 
					string(txb.aaa.gl) begins "2206" or 
					string(txb.aaa.gl) begins "2207" or 
					string(txb.aaa.gl) begins "2208" or 
					string(txb.aaa.gl) begins "2219" or 
					string(txb.aaa.gl) begins "2223" or 
					string(txb.aaa.gl) begins "2125" or 
					string(txb.aaa.gl) begins "2123" or 
					string(txb.aaa.gl) begins "2127" ) 
					and txb.aaa.expdt - txb.aaa.regdt < 92 
					and txb.aaa.expdt - txb.aaa.regdt > 0 
					and aaa.regdt <= vasof no-lock BREAK BY txb.aaa.gl :
			if first-of(txb.aaa.gl) then 
			do:
				create temp. 
				assign 
					temp.kod =  '132'
					temp.gl = txb.aaa.gl
					temp.rem = '8-12-14 ' + txb.aaa.aaa.
			end.

			find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt <= vasof no-lock no-error.
			find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= vasof no-lock no-error.
			if avail txb.aab and txb.aab.bal ne 0 then 
			do:
				create temp. 
				assign
					temp.kod =  '132' 
					temp.gl = txb.aaa.gl
					temp.rem = '8-12-14 ' +  txb.aaa.aaa
					temp.val = (txb.aab.bal * txb.crchis.rate[1]) / 1000.
			end. 
		end.   

		for each txb.arp where (string(txb.arp.gl) begins "2855") and 
					txb.arp.duedt - txb.arp.rdt < 92  and 
					txb.arp.duedt - txb.arp.rdt > 0   and 
					txb.arp.rdt <= vasof no-lock BREAK BY txb.arp.gl :
			vbal = 0 .
			if first-of(txb.arp.gl) then 
			do:
				create temp. 
				assign 
					temp.kod =  '132'
					temp.gl = txb.arp.gl
					temp.rem = '8-12-14 ' + txb.arp.arp.
			end.

			find last txb.crchis where txb.crchis.crc = txb.arp.crc and txb.crchis.regdt <= vasof no-lock no-error.
			ct = 0 . dt = 0.
			for each txb.jl no-lock where txb.jl.acc eq txb.arp.arp and txb.jl.jdt gt vasof by txb.jl.jdt:
				dt =  dt + jl.dam.
				ct  = ct + jl.cam.
			end. 
			vbal = vbal + (txb.arp.cam[1] - txb.arp.dam[1])  - ( ct - dt).

			if vbal ne 0 then 
			do:
				create temp. 
				assign
					temp.kod =  '132'
					temp.gl = txb.arp.gl
					temp.rem = '8-12-14 ' + string(txb.arp.arp)
					temp.val = vbal * txb.crchis.rate[1] / 1000.
			end.

		end.
	end. /*132*/

	if entry(1,v-gl[j]) eq '136' then 
	do:
		for each txb.aaa no-lock where (string(txb.aaa.gl) begins "2215" or 
						string(txb.aaa.gl) begins "2217" or 
						string(txb.aaa.gl) begins "2206" or 
						string(txb.aaa.gl) begins "2207" or 
						string(txb.aaa.gl) begins "2208" or 
						string(txb.aaa.gl) begins "2219" or 
						string(txb.aaa.gl) begins "2223" or 
						string(txb.aaa.gl) begins "2125" or 
						string(txb.aaa.gl) begins "2123" or 
						string(txb.aaa.gl) begins "2127" ) 
						and txb.aaa.expdt - txb.aaa.regdt = 0  BREAK BY txb.aaa.gl:

			find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.regdt <= vasof no-lock no-error.
			find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= vasof no-lock no-error.
			if avail txb.aab and txb.aab.bal ne 0 then 
			do:
				create temp. 
				assign
					temp.kod =  '136'
					temp.gl = txb.aaa.gl
					temp.rem = '8-12-14 ' + txb.aaa.aaa
					temp.val = txb.aab.bal * txb.crchis.rate[1] / 1000.
			end. 
		end. 

		for each txb.arp where (string(txb.arp.gl) begins "2855") and 
					(txb.arp.duedt - txb.arp.rdt = 0  or 
					 txb.arp.duedt - txb.arp.rdt = ?) and 
					 txb.arp.rdt <= vasof no-lock BREAK BY txb.arp.gl :
			vbal = 0.
			if first-of(txb.arp.gl) then 
			do:
				create temp. 
				assign 
					temp.kod =  '136' 
					temp.gl = txb.arp.gl
					temp.rem = '8-12-14 ' + txb.arp.arp.
			end.
			find last txb.crchis where txb.crchis.crc = txb.arp.crc and txb.crchis.regdt <= vasof no-lock no-error.
			ct = 0 . dt = 0.
			for each txb.jl no-lock where txb.jl.acc eq txb.arp.arp and txb.jl.jdt gt vasof by txb.jl.jdt:
				dt =  dt + jl.dam.
				ct  = ct + jl.cam.
			end.
			vbal = vbal + (txb.arp.cam[1] - txb.arp.dam[1]) - ( ct - dt).
		end.
		if vbal ne 0 then 
		do:
			create temp. 
			assign 
				temp.kod =  '136'
				temp.gl = txb.arp.gl
				temp.rem = '8-12-14' + string(txb.arp.arp)
				temp.val = vbal * txb.crchis.rate[1] / 1000.
		end.  
	end. /*136*/

	do i =  2 to NUM-ENTRIES(v-gl[j]):
		if length(entry(i,v-gl[j])) = 6 then  
		do:
			find last bank.gl where  bank.gl.gl = integer(entry(i,v-gl[j])) and bank.gl.totlev  = 1 no-lock no-error.
			if avail bank.gl then do: 
                        for each bank.crc no-lock.
				if entry(1,v-gl[j]) eq '150' and bank.crc.crc = 4 then  
				do: 
					/*message entry(1,v-gl[j]) ' ' bank.crc.crc. pause 500. */
					next.
				end.
				find last txb.glday where txb.glday.gl = bank.gl.gl and txb.glday.gdt <= vasof and txb.glday.crc = bank.crc.crc no-lock no-error.
				if available txb.glday then 
				do:
					find last bank.crchis where bank.crchis.crc = txb.glday.crc and bank.crchis.rdt <= vasof  use-index crcrdt no-lock no-error.
					find last temp where temp.gl = txb.glday.gl and temp.kod = entry(1,v-gl[j])  no-error.
					if available temp then    
						temp.val =  temp.val +  (txb.glday.bal * bank.crchis.rate[1]) / 1000.
					else 
					do:
						create temp.  
						assign 
							temp.kod = string(entry(1,v-gl[j]))
							temp.gl = txb.glday.gl
							temp.val =  (txb.glday.bal * bank.crchis.rate[1]) / 1000.
					end.
				end. 
			end.
		    end.	
		end. 
		else 
		do:
			for each bank.gl where  integer(substr(string(bank.gl.gl),1,4)) = integer(entry(i,v-gl[j])) and bank.gl.totlev  = 1 no-lock.
				for each bank.crc no-lock.
					if entry(1,v-gl[j]) eq '150' and bank.crc.crc = 4 then  
					do: 
						/*message entry(1,v-gl[j]) ' ' bank.crc.crc. pause 500. */
						next.
					end.
					find last txb.glday where txb.glday.gl = bank.gl.gl and txb.glday.gdt <= vasof and txb.glday.crc = bank.crc.crc no-lock no-error.
					if available txb.glday then 
					do:
						find last bank.crchis where bank.crchis.crc = txb.glday.crc and bank.crchis.rdt <= vasof  use-index crcrdt no-lock no-error.
						find last temp where temp.gl = txb.glday.gl and temp.kod = entry(1,v-gl[j])  no-error.
						if available temp then    
							temp.val =  temp.val + (txb.glday.bal * bank.crchis.rate[1]) / 1000.
						else 
						do:
							create temp.  
							assign
								temp.kod = string(entry(1,v-gl[j]))
								temp.gl = txb.glday.gl
								temp.val =  (txb.glday.bal * bank.crchis.rate[1]) / 1000.
						end.
					end.
				end.
			end.
		end. 
		if entry(2,v-gl[j]) = '9999' then 
		do: 
			create temp. 
			assign
				temp.gl =  integer(entry(i,v-gl[j]))
				temp.kod = entry(1,v-gl[j]). 
		end.
	end. /*i*/     
end. /*j*/      

