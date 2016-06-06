/* r-knp01.p
 * MODULE
        Обороты по расходам за период для нал. учета (версия 2, первая 11knp.p)
 * DESCRIPTION
        Обороты по расходам за период для нал. учета 
 * RUN
        nmenu
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
	r-knp02.p
	mainhead.i
	r-gl.i
 * MENU
        8-2-5-9 
 * AUTHOR
        18.02.2005 u00121
 * CHANGES
 	05.09.2006 U00121 - output теперь выводится в shared stream
*/

{mainhead.i}

{r-gl.i "new shared"}

 
     update
              v-from label "  С" help " Задайте начальную дату отчета" skip
              v-to   label " ПО" help " Задайте конечную дату отчета" skip
              v-list label "СЧЕТ ГК" format "x(69)" help " Введите счета ГК (через запятую)"
    with row 8 centered  side-label frame opt title "Задайте период отчета и счета ГК (через запятую)".

  hide frame  opt.


def var i as int no-undo. 
def var v-tmpgl as int no-undo.
def new shared stream outstr.

output stream outstr to "r-gl.txt".
	do i = 1 to num-entries(v-list):
		v-tmpgl = int(entry(i, v-list)).
		v-glacc = v-tmpgl.

		for each crc no-lock:
			v-valuta = crc.crc.
			{r-branch.i &proc = "r-knp02(txb.name)"}
		end.

		put stream outstr fill("*", 135) format "x(135)" skip.
	end.
output stream outstr close.
pause 0.
run menu-prt("r-gl.txt").

