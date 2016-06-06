/* sysbnk1.p
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

/* sysbank.p
*/

{proghead.i "BANK FILE"}

{head-a.i
	&var = "def new shared var s-bank like bank.bank. "
	&file = "bank"
	&line = " "
	&form = "
		 bank.bank colon 17
		 bank.name colon 17
		 bank.addr colon 17
		 bank.attn colon 17
		 bank.tel  colon 17
		 bank.tlx  colon 17
		 bank.fax  colon 17
		 bank.chipno colon 17
		 bank.frbno colon 17
		 bank.crline  colon 17
		 bank.gl      label ""O-CL BANK G/L#"" colon 17
		 bank.acc label ""T-CL BANK CODE"" colon 50
		 bank.crbank  label ""T-CL BANK NAME"" colon 17
		 bank.acct    label ""T-CL BANK ACCT#"" colon 17
		 bank.ibf     colon 17
		 bank.inter   colon 50
		 bank.intrate colon 17
		 bank.rim     colon 50
		 "
	&frame = "row 3 centered side-label
		  title "" Bank Master """
	&predisp = "  "
	&fldupdt = "
		 bank.bank bank.name bank.addr
		 bank.attn bank.tel bank.tlx bank.fax
		 bank.chipno bank.frbno  bank.crline
		 bank.gl bank.acc
		 bank.crbank bank.acct
		 bank.ibf bank.inter bank.intrate bank.rim
		   "
	&vseleform = "1 col row 3 col 67 no-label overlay"
	&flddisp = "
		 bank.bank bank.name bank.addr
		 bank.attn bank.tel bank.tlx bank.fax
		 bank.intrate bank.crline bank.gl bank.acc
		 bank.rim bank.crbank bank.acct
		 bank.ibf bank.inter
		"
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
