/* grotyp.p
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

/* grotyp.p */

{mainhead.i}

{mult.i
&head = "grotyp"
&headkey = "type"
&index = "type"
&type = "integer"
&datetype = "integer"
&where = "true"
&addcon = "true"
&deletecon = "true"
&updatecon = "true"
&formname = "grotyp"
&framename = "grotyp"
&numprg = "prompt"
&display = "grotyp.type grotyp.des grotyp.pday grotyp.scg
	    grotyp.camt grotyp.crate grotyp.trn grotyp.acc grotyp.chc
	    grotyp.pby grotyp.pen grotyp.pamt grotyp.prate"
&update ="grotyp.type grotyp.des grotyp.pday grotyp.scg
	  grotyp.camt grotyp.crate grotyp.trn grotyp.acc  grotyp.chc
	  grotyp.pby grotyp.pen grotyp.pamt grotyp.prate"
&postupdate = "grotyp.who = userid('bank'). grotyp.whn = g-today."
&end = " "
}
