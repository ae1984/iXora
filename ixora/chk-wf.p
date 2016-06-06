/* chk-wf.p
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
*/


/* W/T */
{global.i}

def new shared var s-amt like jl.cam.
def new shared var vcom  like wf.com.
def new shared var vscom like wf.scom.
def new shared var kbank like bank.bank.
def new shared var vbank like bank.bank.
def shared var s-jh like jl.jh.
def shared var s-jl like jl.ln.
def new shared var s-jln like jl.ln.
def var wf as log.
def new shared var vcdt   like wf.cdt.
def new shared var vtpy   like wf.tpy.
def new shared var vtpyac like wf.tpyac.

define variable v050 as integer format "zzzzz9" init 0.
define variable v100 as integer format "zzzzz9" init 0.
define variable v150 as integer format "zzzzz9" init 0.
define variable v250 as integer format "zzzzz9" init 0.

find jl where jl.jh = s-jh and jl.ln = s-jl no-error.
find gl where gl.gl = jl.gl.


find sysc where sysc.sysc = "RMDFBG" no-lock no-error.
v050 = integer(entry(1, sysc.chval)).
v100 = integer(entry(2, sysc.chval)).
v150 = integer(entry(3, sysc.chval)).
v250 = integer(entry(4, sysc.chval)).
	 
	if (v050 = gl.gl or v100 = gl.gl or v150 = gl.gl or v250 = gl.gl)
	and jl.cam ne 0 and new jl then do:
	{mesg.i 0985} update wf.
	 if wf = true then do:
	    pause 0.
	    hide all.
	    s-jh = jl.jh.
	    s-jln = jl.ln.
	    s-amt = jl.cam.
	    run s-dbgljl.
	 end.
	end.
	else if  (v050 = gl.gl or v100 = gl.gl or v150 = gl.gl or v250 = gl.gl)
	     and jl.cam ne 0 and new jl eq false then do:
	find first wf where wf.jh = jl.jh and wf.jln = jl.ln and
		      wf.sts = 0 no-error.
	if available wf then do:
	    pause 0.
	    hide all.
	    s-jh = jl.jh.
	    s-jln = jl.ln.
	    s-amt = jl.cam.
	    run ch-dbgl.
	 end.
	else do:
	 {mesg.i 0253}.
	 return.
	end.
     end. /* update */
