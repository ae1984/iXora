/* basehis.p
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

/* basehis.p
*/

{global.i}

def shared var s-base like base.base.

{mult.i
&head = "rate"
&headkey = "cdt"
&start = " "
&where = "rate.base eq s-base"
&index = "basecdt"
&type = "string"
&datetype = "string"
&formname = "basehis"
&framename = "rate"
&addcon = "true"
&updatecon = "true"
&deletecon = "true"
&start = " "
&viewframe = " "
&predisplay = " "
&display = "rate.cdt rate.rate"
&postdisplay = " "
&numprg = "prompt"
&preadd = " "
&postadd = "rate.base = s-base. "
&newpreupdate = " "
&preupdate = " "
&update = "rate.rate rate.cdt"
&postupdate = "rate.who = userid('bank'). rate.whn = g-today. "
&newpostupdate = " "
&predelete = " "
&postdelete = " "
&get = " "
&put = " "
&end = " "
}
