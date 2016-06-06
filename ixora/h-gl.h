/* h-gl.h
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

/* h-gl.h
*/


	   def var vdes like gl.des.
	   update ""ENTER MATCH STRING FOR DESCRIPTION..."" vdes
	   with row 21 no-box no-label frame opt.
	   vdes = ""*"" + vdes + ""*"".
