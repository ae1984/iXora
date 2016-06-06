/* k0-cash.p
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

/* k0-cash.p
*/

{mainhead.i CASH} /* "CASH кас. план " */

{mult.i
&head = "cashpl"
&headkey = "sim"
&where = "true"
&index = "sim"
&type = "trim"
&datetype = "string"
&formname = "sim"
&framename = "sim"
&addcon = "true"
&updatecon = "true"
&deletecon = "true"
&start = " "
&viewframe = " "
&predisplay = " "
&display = "sim cashpl.des"
&postdisplay = " "
&numprg = "prompt"
&preadd = " "
&postadd = " if trim(string(sim)) = """" then delete cashpl ."
&newpreupdate = " "
&preupdate = " "
&update = "sim validate(sim ne 0,'') cashpl.des"
&postupdate = " "
&newpostupdate = " "
&predelete = " "
&postdelete = " "
&get = " "
&put = " "
&end = " "
}
