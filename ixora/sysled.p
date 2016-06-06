/* sysled.p
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

/* checked */
/* sysled.p
*/

{mainhead.i SETDPT}  /* Account Type Structure */

{head-a.i
	&var = "def new shared var s-led like led.led. "
	&file = "led"
	&line = " "
	&form = " {sysled.f} "
	&frame = " {sysledfm.f} "
	&predisp = "  "
	&fldupdt = "led.des led.drcr
		    led.dormantprd
		    led.inactprd led.lab led.cntlab led.prgadd led.prgedt
		    led.prgdel"
	&vseleform = " {sysvse.f} "
	&flddisp = "led.led led.des led.drcr
		    led.dormantprd
		    led.inactprd led.lab led.cntlab
		    led.prgadd led.prgedt led.prgdel"
	&other1  = "ACCNT-GRP"
	&other2  = " "
	&other3  = " "
	&other4  = " "
	&other5  = " "
	&other6  = " "
	&other7  = " "
	&other8  = " "
	&other9  = " "
	&other10 = " "
	&prg1 = "sys-lgr"
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
