/* cdaedt.p
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

/* cdaedt.p
*/

{proghead.i "TIME DEPOSIT EDIT"}

{head-a.i
	&var = "def new shared var s-aaa like aaa.aaa."
	&file = "aaa"
	&line = " "
	&form = "aaa.aaa aaa.lgr aaa.cif aaa.gl
		 aaa.dr[1] label ""DEBIT "" aaa.cr[1] label ""CREDIT""
		 aaa.cbal aaa.hbal"
	&frame = "row 2 centered 1 col
		  title "" TIME DEPOSIT """
	&predisp = "  "
	&fldupdt = "aaa.lgr aaa.cif aaa.gl
		    aaa.dr[1] aaa.cr[1] aaa.cbal aaa.hbal"
	&vseleform = "4 col row 16 centered no-label overlay
		      title "" Options """
	&flddisp = "aaa.aaa aaa.lgr aaa.cif aaa.gl
		    aaa.dr[1] aaa.cr[1]
		    aaa.cbal aaa.hbal"
	&other1  = " "
	&other2  = " "
	&other3  = " "
	&other4  = " "
	&other5  = " "
	&other6  = " "
	&other7  = " "
	&other8  = " "
	&other9  = " "
	&other10 = " "
	&prg1 = "other"
	&prg2 = "other"
	&prg3 = "other"
	&prg4 = "other"
	&prg5 = "other"
	&prg6 = "other"
	&prg7 = "other"
	&prg8 = "other"
	&prg9 = "other"
	&prg10 = "other"
	}
