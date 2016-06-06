/* vcon.h
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

/* vcon.h
*/


	  " ENTER SEQ-NO TO UPDATE OR ENTER 0 TO CONTINUE.."
	  vcon validate(can-find(wf where wf.ln = vcon) or vcon = 0 ,
	  "RECORD NOT FOUND")
	  with frame vcon no-label col 0
	  row 3 no-box editing: {gethelp.i} end.
