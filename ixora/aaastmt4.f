/* aaastmt4.f
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

display s-dtstr
	"ENDING BALANCE"
	aaa.stmgbal to 79 skip
	fill("_",80) format "x(80)" skip(1)
	"*** THANK YOU FOR BANKING WITH " + g-comp + " ***"
	format "x(71)" at 16
	with no-box no-label width 96 frame cbal.
