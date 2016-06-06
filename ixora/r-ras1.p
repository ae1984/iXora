/* 
 * MODULE
        r-ras1.p
 * DESCRIPTION
        формирование оборотов по расходам за период
 * RUN
        
 * CALLER
        r-ras.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-2-5-3 
 * AUTHOR
        20/05/04 valery
 * CHANGES
*/

def input parameter p-bank as char.
def shared var datBegDay as date.
def shared var datEndDay as date.
def shared var sumDtKZT as dec format "->>>,>>>,>>>,>>9.99".
def shared var sumCtKZT as dec format "->>>,>>>,>>>,>>9.99".
def shared temp-table t-ras
	field gl like txb.gl.gl
	field des like txb.gl.des
	field dat as date
	field jh like txb.jl.jh
	field dam like txb.jl.dam
	field cam like txb.jl.cam
	field crc like txb.jl.crc
	field rem like txb.jl.rem[1]
	field who like txb.jl.who
	field txbt as char.

for each txb.jl where txb.jl.jdt >= datBegDay and txb.jl.jdt <= datEndDay and substring(string(txb.jl.gl),1,1) = "5" break by txb.jl.gl by txb.jl.crc:
 
		find first txb.gl where txb.gl.gl = txb.jl.gl no-lock no-error.
                if avail txb.gl then do:
                               	create t-ras.
                               	t-ras.gl = txb.jl.gl.
                               	t-ras.des = txb.gl.des.
                               	t-ras.jh = txb.jl.jh.
				t-ras.dat = txb.jl.jdt.
                               	t-ras.dam = txb.jl.dam.
                               	t-ras.cam = txb.jl.cam.
                               	t-ras.crc = txb.jl.crc.
                          	t-ras.rem = txb.jl.rem[1].
                               	t-ras.who = txb.jl.who.
				t-ras.txbt = p-bank.
		end.
end.

