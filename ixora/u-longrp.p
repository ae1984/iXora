/* u-longrp.p
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

/*longrp.p mult.i
02-24-93*/


{mainhead.i}
/*
{mult.i

&head = "longrp"
&headkey = "longrp"
&index = "longrp"
&type = "integer"
&datetype = "integer"
&where = "true"
&addcon = "true"
&deletecon = "true"
&updatecon = "true"
&formname = "longrp"
&framename = "longrp"
&numprg = "prompt"
&display = "longrp.longrp longrp.des longrp.gl"
&update = "longrp.longrp longrp.des longrp.gl"
&end = " "
}
*/
{jabra.i
&start     = " "
&head      = "longrp"
&headkey   = "longrp"
&index     = "longrp"

&formname  = "longrp"
&framename = "longrp"
&where     = "true"

&addcon    = "true"
&deletecon = "true"

&precreate = " "

&postadd   = " 
               lonfiz = integer(substr(string(longrp.stn), 1, 1)).
               lonsrok = integer(substr(string(longrp.stn), 2, 1)).
               disp longrp.longrp longrp.des longrp.gl lonfiz lonsrok with frame longrp.
               update longrp.longrp longrp.des longrp.gl lonsrok lonfiz with frame longrp.
               longrp.stn = lonfiz * 10 + lonsrok.
               "

&prechoose = "message 'F4-–r–,INS-papild.,F10-dzёst.'."

&predisplay = " 
               lonfiz = integer(substr(string(longrp.stn), 1, 1)).
               lonsrok = integer(substr(string(longrp.stn), 2, 1)). "

&display = "longrp.longrp longrp.des longrp.gl lonsrok lonfiz"

&highlight = " longrp.longrp "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
            then do transaction on endkey undo, leave:
            lonfiz = integer(substr(string(longrp.stn), 1, 1)).
            lonsrok = integer(substr(string(longrp.stn), 2, 1)).
            update longrp.longrp longrp.des longrp.gl lonsrok lonfiz
               with frame longrp .
               longrp.stn = lonfiz * 10 + lonsrok.
               end. "

&end = "hide frame longrp."
}
hide message.
