/* r-knp02.p
* MODULE
	Обороты по расходам за период для нал. учета (версия 2, первая 11knp.p)
* DESCRIPTION
	Обороты по расходам за период для нал. учета 
* RUN
	nmenu
* CALLER
	r-knp01.p
* SCRIPT
	Список скриптов, вызывающих этот файл
* INHERIT
	r-gl.i
* MENU
	8-2-5-9 
* AUTHOR
	18.02.2005 u00121
* CHANGES
	05.09.2006 u00121 - добавил no-undo, fields в for each, output в shared stream, вывод окошка-индикатора работы программы
*/

{r-gl.i "shared"}

def input parameter v-name as char.

def var v-rnn as char format "x(12)" no-undo. 

def shared stream outstr.

def buffer bglday for txb.glday.
def buffer b-jl for txb.jl.
def var v-corracc as int format ">>>>>>" no-undo.
def var v-outsum as dec format "->>>,>>>,>>>,>>>,>>9.99" no-undo.
def var v-dat as date no-undo.
def var v-isdata as logical no-undo.


find first txb.glday where txb.glday.gl = v-glacc and (txb.glday.gdt >= v-from and txb.glday.gdt <= v-to) and txb.glday.crc = v-valuta no-lock no-error.
if avail txb.glday then 
do:
	find last txb.gl where txb.gl.gl = v-glacc no-lock no-error.
	put stream outstr  	v-name format "x(25)" skip 
		"ОБОРОТЫ ПО СЧЕТУ " v-glacc " " txb.gl.des format "x(40)" " "  skip 
		"ЗА ПЕРИОД С " v-from " ПО " v-to skip
		fill("-", 135) format "x(135)" skip.

	find last bglday where bglday.gl = v-glacc and bglday.gdt < v-from and bglday.crc = v-valuta no-lock no-error.
		put stream outstr "Входящее сальдо " fill(" ", 12) format "x(12)" .
		if avail bglday then 
		do:
			if txb.gl.type = "A" or  txb.gl.type = "E" then 
				put stream outstr bglday.bal skip. 
			else 
				put stream outstr fill(" ", 22) format "x(22)" bglday.bal    skip.
		end.
		else 
		do:
			if txb.gl.type = "A" or  txb.gl.type = "E" then 
				put stream outstr 0 format "z,zzz,zzz,zzz,zz9.99-" skip. 
			else 
				put stream outstr fill(" ", 22) format "x(22)" 0 format "z,zzz,zzz,zzz,zz9.99-"   skip.
		end.

	put stream outstr fill("-", 135) format "x(135)" skip.

	do v-dat = v-from to v-to:
		for each txb.jl fields (txb.jl.jh txb.jl.jdt txb.jl.rem[1] txb.jl.ln txb.jl.genln txb.jl.dam txb.jl.cam) 
				where txb.jl.jdt = v-dat and txb.jl.gl = v-glacc and txb.jl.crc = v-valuta  no-lock:
			v-dt = v-dt + txb.jl.dam.
			v-ct = v-ct + txb.jl.cam.
			if txb.jl.genln <> 0 then 
			do: /* проводка создавалась по шаблону */
				find first b-jl where b-jl.jh = txb.jl.jh and b-jl.dam = txb.jl.cam and b-jl.cam = txb.jl.dam and b-jl.genln = txb.jl.genln no-lock no-error.
				if avail b-jl then 
					v-corracc = b-jl.gl.            
				else 
					v-corracc = 0.
			end.
			else 
			do: /* проводка создавалась без шаблона, и при этом поле genln не было проставлено */
				find first b-jl where b-jl.jh = txb.jl.jh and b-jl.dam = txb.jl.cam and b-jl.cam = txb.jl.dam and (b-jl.ln + 1 = txb.jl.ln or b-jl.ln - 1 = txb.jl.ln) no-lock no-error.
				if avail b-jl then 
					v-corracc = b-jl.gl.            
				else 
					v-corracc = 0.
			end.

			v-rnn = "". /*Находим РНН дебиторов*/
			find last txb.debmon where txb.debmon.jh = txb.jl.jh no-lock no-error.
			if not avail txb.debmon then
			do:
				find last txb.debhis where txb.debhis.jh = txb.jl.jh no-lock no-error.
				if avail txb.debhis then
				do:
					find last txb.debls where txb.debls.grp = txb.debhis.grp and txb.debls.ls = txb.debhis.ls no-lock no-error.
					if avail txb.debls then
						v-rnn = txb.debls.rnn.
				end.
			end.
			else
			do:
				if txb.debmon.rnn <> "" then
					v-rnn = txb.debmon.rnn.
				else
				do:
        				find last txb.debhis where txb.debhis.jh = txb.jl.jh no-lock no-error.
         				if avail txb.debhis then
         				do:
                 				find last txb.debls where txb.debls.grp = txb.debhis.grp and txb.debls.ls = txb.debhis.ls no-lock no-error.
				                 if avail txb.debls then	
				                         v-rnn = txb.debls.rnn.
	         			end.
 				end.
			end.
			if v-rnn = "" then v-rnn = "нет РНН".
			displ txb.jl.jdt txb.jl.jh v-valuta with overlay centered no-labels row 18 1 down title v-name. pause 0.
			put stream outstr txb.jl.jdt " " txb.jl.jh " " v-corracc " " txb.jl.dam " " txb.jl.cam txb.jl.rem[1] " " v-rnn format "x(12)" skip.
		end.
	end. /*v-dat*/

	find last txb.glday where txb.glday.gl = v-glacc and txb.glday.gdt <= v-to and txb.glday.crc = v-valuta no-lock.

	put stream outstr fill("-", 135) format "x(135)" skip
		"Итого обороты " fill(" ", 15) format "x(15)" v-dt "   " v-ct skip
	    fill("-", 135) format "x(135)" skip.

	put stream outstr "Исходящее сальдо "  fill(" ", 11) format "x(11)" .

	if avail  bglday then 
	do:
		if txb.gl.type = "A" or  txb.gl.type = "E" then 
			put stream outstr bglday.bal + v-dt - v-ct format "z,zzz,zzz,zzz,zz9.99-" skip. 
		else 
			put stream outstr fill(" ", 22) format "x(22)" bglday.bal + v-ct - v-dt format "z,zzz,zzz,zzz,zz9.99-"  skip.
	end.
	else 
	do:
		if txb.gl.type = "A" or  txb.gl.type = "E" then 
			put stream outstr 0 + v-dt - v-ct format "z,zzz,zzz,zzz,zz9.99-" skip. 
		else 
			put stream outstr fill(" ", 22) format "x(22)" 0 + v-ct - v-dt format "z,zzz,zzz,zzz,zz9.99-"  skip.
	end.
	put stream outstr  skip (2).
	v-ct = 0.
	v-dt = 0.
end.
