/* sysled.f
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

 /* sysled.f
 */


		  ""    Ledger Name..."" led.led ""   "" skip
		  ""    Description..."" led.des skip(1)
		  ""    LOAN/DEPOST..."" led.drcr
			 help ""Enter 1 for loan account, -1 for deposit""
			       skip(1)
		  ""    Dormant Period"" led.dormantprd skip
		  ""    Inactive --   "" led.inactprd skip(1)
		  ""    Level Amount and Counter        "" skip
		  ""        1"" led.lab[1] cntlab[1] skip
		  ""        2"" led.lab[2] cntlab[2] skip
		  ""        3"" led.lab[3] cntlab[3] skip
		  ""        4"" led.lab[4] cntlab[4] skip
		  ""        5"" led.lab[5] cntlab[5] skip
		  ""    Program to add "" led.prgadd skip
		  ""    Program to edit"" led.prgedt skip
		  ""    Program to del "" led.prgdel skip
