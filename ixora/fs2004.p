/*
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/

def shared var pro_res as decimal.
def shared var v-name as char.

def var i as int.
def var v-bal as decimal.

def var st as char FORMAT "x(76)".


def temp-table temp
  field  kod  as char
  field  gl  as char format 'x(7)'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 

def frame ac v-name with centered title "Расчет полей отчета" row 5.

pro_res = 0.
v-bal = 0.

def var sum-gl as dec init 0.
def var v-gl as char.

INPUT FROM value("/data/reports/tgl.rep").
repeat:
	import unformatted st.
	create temp.
	temp.kod = entry(2,st).
	temp.gl = entry(1,st).

	temp.val = dec(entry(4,st)) / 1000.
end.
INPUT CLOSE.


INPUT FROM VALUE("/data/reports/fs2004.rep").
REPEAT:
	import unformatted st.
 	displ v-name no-label with frame ac . pause 0.	
	if entry(1,st) = v-name then 
	do:            
		do i = 2 to num-entries (st):
			v-gl = entry(i,st).
		        for each temp where temp.gl = v-gl break by gl.
	        	    accumulate temp.val (total by temp.gl).
		            if last-of(temp.gl) then v-bal = v-bal + accum total by (temp.gl) temp.val.
		        end.
		end.
	end.

	else
		if entry(1,st) = "#" then 
		do: 
			if entry(2,st) = v-name then 
			do: 
				do i = 3 to num-entries (st):
					v-gl = entry(i,st).
				        for each temp where temp.gl = v-gl and temp.kod <> "1" break by gl.
			        	    accumulate temp.val (total by temp.gl).
				            if last-of(temp.gl) then v-bal = v-bal + accum total by (temp.gl) temp.val.
				        end.
				end.
			end.
		end.           


end.
INPUT CLOSE.

pro_res = v-bal.
