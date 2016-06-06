/* rptkas.p
 * MODULE
        Отчетность
 * DESCRIPTION
	Отчет по символам касплана за период
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
	5-4-16-12
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	04/08/03 nataly	-	была добавлена распечатка проводок без символа кассового плана по заявке Горшковой О.Ф.
	02/05/06 u00121 -	Поправил пробежку по jl - убрал период из условия, добавил no-undo переменным и временным таблицам
	14/08/06 nataly -       добавила индекс на временную таблицу
*/

{global.i}
def temp-table wt no-undo
    field jh as integer
    field ln as integer
    field sim as char
    field crc like crc.crc
    field dam like jl.dam
    field cam like jl.cam
    index wt  is primary  sim crc .


def temp-table wt1 no-undo
    field sim as char
    field dam like jl.dam
    field cam like jl.cam
    index wt is unique sim .


def var v-rptfrom as date no-undo.
def var v-rptto as date no-undo.
def var v-dt as date no-undo.

def stream s-err .

update v-rptfrom label "Дата с " v-rptto label " по " with row 9 side-labels no-box centered.

output stream s-err to kasplan.err.
	do v-dt = v-rptfrom to v-rptto: /*02/05/06 u00121*/
		for each jl where jl.jdt = v-dt and jl.gl = 100100 and jl.acc = "" no-lock :
			find first jlsach where jlsach.jh eq jl.jh and jlsach.ln eq jl.ln no-lock no-error.
			if not available jlsach then 
			do:
				if jl.gl eq 100100 then 
				do:
					create wt.
					assign
						wt.sim = jl.trx
						wt.crc = jl.crc
						wt.jh = jl.jh
						wt.ln = jl.ln
						wt.dam = jl.dam
						wt.cam = jl.cam.

					put stream s-err unformatted jl.jh format ">>>>>>>9" " " jl.ln " " jl.crc " " jl.dam " " jl.cam  " " jl.trx skip.
				end.
			end.
			else do:
                        	find wt where wt.crc eq jl.crc and wt.sim eq string(jlsach.sim) no-error.
				if not available wt then 
				do:
					create wt.
					assign
						wt.sim = string(jlsach.sim)
						wt.crc = jl.crc.
				end.
				if jl.dc eq "D" then 
					wt.dam = wt.dam + jlsach.amt.
				else
					wt.cam = wt.cam + jlsach.amt.
			end.
		end.

	end.
{image1.i rpt.img}
{image2.i}

{report1.i 66}
	vtitle= "".

{report2.i 97
"'КАССОВЫЙ ОТЧЕТ (СИМВОЛЫ КАСПЛАНА)'   skip
fill('=',97) format 'x(97)' skip "}

	put "Дата " v-rptfrom " - " v-rptto skip.
	put "СИМВОЛ             НАИМЕНОВАНИЕ".
	put fill(' ',35) format 'x(35)' "ДЕБЕТ                 КРЕДИТ"  skip.
	for each wt no-lock break by wt.crc by wt.sim :
		find last crchis where crchis.crc eq wt.crc and crchis.rdt le v-rptto no-lock no-error.
		if first-of(wt.crc) then 
		do:
			put  skip(1) crchis.des skip(2).
		end.

		find cashpl where cashpl.sim eq integer(wt.sim) no-lock no-error.
		put  wt.sim " ".
		if available cashpl then 
			put cashpl.des format "x(40)" " ".
		else 
			put fill(" ",41) wt.jh  format 'zzzzzzz9' ' ' .
		put wt.dam format ">>>,>>>,>>>,>>>,>>9.99-" wt.cam format ">>>,>>>,>>>,>>>,>>9.99-" skip .
	end.

output stream s-err close.
{report3.i}
{image3.i}





