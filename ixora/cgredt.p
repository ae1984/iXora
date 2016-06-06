/* cgredt.p
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


{mainhead.i}

/* {mult.i
&head = "cgr"
&headkey = "cgr"
&index = "cgr"
&where = "true"
&addcon = "true"
&deletecon = "true"
&updatecon = "true"
&numprg = "prompt"
&start = " "
&type = "integer"
&datetype = "integer"
&formname = "cgr"
&framename = "cgr"
&update = "cgr.cgr cgr.name cgr.stn"
&display = "cgr.cgr cgr.name cgr.stn"
&get = " "
&put = " "
&end = " "
}
*/

{jabra.i
&start     = " "
&head      = "cgr"
&headkey   = "cgr"
&index     = "cgr"

&formname  = "cgr"
&framename = "cgr"
&where     = "true"

&addcon    = "true"
&deletecon = "true"

&precreate = " "

&postadd   = " 
               disp cgr.cgr cgr.name cgr.stn with frame cgr.
               update cgr.cgr cgr.name cgr.stn with frame cgr."

&prechoose = "message 'F4-выход,INS-дополнить,F10-удалить'."

&predisplay = " "

&display = "cgr.cgr cgr.name cgr.stn"

&highlight = " cgr.cgr "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
            then do transaction on endkey undo, leave:
        update cgr.cgr cgr.name cgr.stn
               with frame cgr .
               end. "

&end = "hide frame cgr."
}
hide message.

