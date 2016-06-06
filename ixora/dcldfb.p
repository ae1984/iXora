/* dcldfb.p
 * MODULE
	Отчетность        
 * DESCRIPTION
        Отчет по ностро счету 900161014
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12-6-2-4
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	21.11.02 - marinav - Отражает остаток только на текущий момент
	25.04.06 - suchkov - Отражает остаток на любую дату
	08.08.06 - u00121  - Увы, но не совсем на любую, а только на ту, на которую был histrxbal, а на текущую дату показывались кривые данные, т.к. histrxbal формируется только
			   - после закрытия опер. дня. Поэтому, добавил проверку на теущий опер. день, и в случае совпадения дат, ищем по таблице dfb.
*/


{mainhead.i}
def var vdfb 	like rem.tdfb init "ALL" no-undo.
def var vdam 	like jl.dam 		no-undo.
def var vcam 	like jl.cam 		no-undo.
def var bbal 	like jl.cam init 0 	no-undo.
def var sdate 	as date 		no-undo.
def var c1 	as char format "x(24)" 	no-undo.
def var c2 	as char format "x(16)" 	no-undo.
def var c3 	as char 		no-undo.
def var c4 	as char format "x(11)" 	no-undo.
def var c5 	as char 		no-undo.
def var c6 	as char 		no-undo.
def var c7 	as char format "x(11)" 	no-undo.
def var c8 	as char 		no-undo.
 
 vdfb = '400161670'.
 sdate = g-today.

update sdate label "Введите дату" with side-labels centered.

{sdf.f}.
output to rpt.img.

put space(22) c1 skip(1).
put space(20) c2 sdate c3 sdate.


if sdate <> g-today then
do:
	find last histrxbal where histrxbal.sub = "dfb" and histrxbal.acc = vdfb and histrxbal.lev = 1 and histrxbal.dt <= sdate no-lock no-error.
	if avail histrxbal then
	do:
		put skip(2) 	
			"-------------------------------------------" vdfb  "-----------------------------------------------" skip
			space(18) c4 space(12) c5 space(14) c6 space(14) c7 skip
			"----------------------------------------------------------------------------------------------------"skip
			c8 string (time,"HH:MM:SS")
			histrxbal.dam - histrxbal.cam format "zzz,zzz,zzz,zz9.99-"
			histrxbal.dam histrxbal.cam skip .
		put 	"----------------------------------------------------------------------------------------------------"skip.		
                for each jl where jl.acc = vdfb and jl.jdt = sdate no-lock :
                	accumulate jl.dam  ( total ) .
                	accumulate jl.cam  ( total ) .
                end.

                vdam =  accum total jl.dam .
                vcam =  accum total jl.cam .

                bbal = bbal + vdam - vcam .

                put 	sdate histrxbal.dam - histrxbal.cam - bbal format "z,zzz,zzz,zzz,zz9.99-"
                	vdam vcam   format "z,zzz,zzz,zzz,zz9.99-"
                	histrxbal.dam - histrxbal.cam - bbal + vdam - vcam  format "z,zzz,zzz,zzz,zz9.99-" skip.
	end.
	else
	do:
		message "Отсутствует история по ностро-счету за " sdate skip
			"(таб. HISTRXBAL)" view-as alert-box.
	end.
end.
else
do:
	find last dfb where dfb.dfb = vdfb no-lock no-error.
	if avail dfb then
	do:
		put skip(2) 
			"-------------------------------------------" dfb.dfb  "-----------------------------------------------" skip
			space(18) c4 space(12) c5 space(14) c6 space(14) c7 skip
			"----------------------------------------------------------------------------------------------------"skip
			c8 string (time,"HH:MM:SS")
			dfb.dam[1] - dfb.cam[1] format "zzz,zzz,zzz,zz9.99-"
			dfb.dam[1] dfb.cam[1] skip.
		put "----------------------------------------------------------------------------------------------------"skip.

		for each jl where jl.acc = vdfb and jl.jdt = sdate no-lock:
			accumulate jl.dam  ( total ) .
			accumulate jl.cam  ( total ) .
		end.

		vdam =  accum total jl.dam .
		vcam =  accum total jl.cam .
		bbal = bbal + vdam - vcam .

		put 	sdate dfb.dam[1] - dfb.cam[1] - bbal format "z,zzz,zzz,zzz,zz9.99-"
			vdam vcam   format "z,zzz,zzz,zzz,zz9.99-"
			dfb.dam[1] - dfb.cam[1] - bbal + vdam - vcam  format "z,zzz,zzz,zzz,zz9.99-" skip.
	end.
	else
	do:
			message "Отсутствуют текущие остатки по ностро-счету за " sdate skip 
				"(таб. DFB)" view-as alert-box.
	end.

end.




output close.
unix silent cptwo rpt.img.
