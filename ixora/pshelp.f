/* pshelp.f
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

/* pshelp.f
*/

  form  "Make a selection from the following list:" v-slct skip
	skip(1)
	"         PID Descriptions  .....  1" skip
	"         TYPE PS Descriptions ..  2" skip
	"         ROUTES ................  3" skip
	"         CHART OF ACCOUNT ......  4" skip
	"         BANK MASTER ...........  5" skip
	"         CIF ...................  6" skip
	"         BASE INTEREST .........  7" skip
	"         LOAN ..................  8" skip
	"         BILL OF EXCHANGE ......  9" skip
	"         REFERENCE NUMBER ...... 10" skip
	"         CALCULATOR ............ 11" skip
	"         CALENDAR .............. 12" skip
	"         ACCOUNT NUMBER ........ 13" skip
	"         CURRENCY .............. 14" skip
	"         CURRENCY CONVERSION.... 15" skip
	with row 1 centered title " H e l p   M e n u " overlay top-only
	no-label frame menu.
