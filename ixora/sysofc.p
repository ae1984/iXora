/* sysofc.p
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
/* sysofc.p
   edith4.i ---> head.i
   01-26-89 by WR

   &file                                &addvar
   &line                                &vseleform .. 1 col overlay row 3
   &form                                &no-del
					&no-edit .. if true no edit
   &frame                               &start
   &findref    : find reference file    &end
   &newdft     : New default value      &startin
   &fldupdt                             &endin
   &flddisp
   &other1 ........ &other 10 ....blank allowed
   &prg1 .......... &prg10    ....
   &start1 .......  &start10    &end1 .....
*/

{proghead.i "Officer Master File"}

{head-a.i &var = "def var s-ofc like ofc.ofc. "
	&file = "ofc"  &line = " "
	&form =
		"ofc.ofc ofc.name ofc.addr ofc.tel"
	&frame = "1 col row 3 centered
		  title "" Officer """
	&predisp = "  "
	&fldupdt =
		"ofc.ofc ofc.name ofc.addr ofc.tel"
	&vseleform = "1 col row 3 col 67 no-label overlay"
	&flddisp =
		"ofc.ofc ofc.name ofc.addr ofc.tel"
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
