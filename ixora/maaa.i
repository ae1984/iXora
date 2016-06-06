/* maaa.i
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

	    if gl.subled eq "cif" then do:
		run aah-num.
		find aah where aah.aah eq s-aah.
		aah.crc = jl.crc.
		jl.aah = s-aah.
		create aal.
		aal.aah = jl.aah.
		aal.ln = 1.
		aal.crc = jl.crc.
		aal.jh = jl.jh.
		aah.aaa = jl.acc.
		find aaa where aaa.aaa eq aah.aaa.
		aah.lgr = aaa.lgr.
		aal.aaa = jl.acc.
		aal.lgr = aaa.lgr.

		if jl.dc eq "D" then do:
		    aal.aax = 21.
		    aal.amt = jl.dam.
		end.
		else do:
		    aal.aax = 71.
		    aal.amt = jl.cam.
		end.

		aal.regdt = g-today.
		aal.who = g-ofc.
		aal.whn = today.
		aal.tim = time.
		aal.stn = 9.
		find aax where aax.lgr eq aal.lgr and aax.ln eq aal.aax.
		s-aah = jl.aah.
		s-line = 1.

		run aaa-pls.

		find aal where aal.aah eq jl.aah and aal.ln  eq 1.

		if aal.sta eq "RJ" then do:
		    {mesg.i 0888}.
		    pause 2.
		    undo, retry.
		end.

		jl.bal = aaa.cr[1] - aaa.dr[1].
		aah.amt = aah.amt + aal.amt * aax.drcr.
		aah.bal = aaa.cr[1] - aaa.dr[1].
		aal.bal = aaa.cr[1] - aaa.dr[1].
	    end.
