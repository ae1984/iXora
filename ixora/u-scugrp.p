/* u-scugrp.p
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
 * BASES
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*fungrp.p mult.i
02-24-93*/

 

{mainhead.i}

{jabrw.i
&start     = " "
&head      = "scugrp"
&headkey   = "scugrp"
&index     = "scugrp"

&formname  = "scugrp"
&framename = "scugrp"
&where     = " "

&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = "  update scugrp.scugrp scugrp.gl scugrp.des[1] with frame scugrp. "
&predelete = " /*find first deal where deal.grp = fungrp.fungrp and deal.fun <>
 ' ' no-lock no-error. if available deal then do: message 'Группа использована в сделке - удаление не допускается'. pause. undo,retry. end.*/ "
       
&prechoose = "message 'F4-выход,INS-дополнить,Ctrl+D-удалить,P-распечатать'."

&postdisplay = " "

&display   = " scugrp.scugrp scugrp.gl scugrp.des[1] "

&highlight = " scugrp.scugrp scugrp.des[1]  "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
            then do transaction on endkey undo, leave:
                 update scugrp.scugrp 
                        scugrp.gl  validate(can-find(gl where gl.gl eq scugrp.gl),
                                 'Счет ГК не найден... ') 
                        scugrp.des[1] with frame scugrp.
            end.
            else if keyfunction(lastkey) = 'P' then do:
            output to rpt.img .
               for each scugrp:
               display scugrp.scugrp scugrp.gl scugrp.des[1] with frame scugrp.
               down with frame scugrp.
               end.
            output close.
           /*output to terminal.
            unix prit rpt.img.*/
            run menu-prt('rpt.img').
            end. "

&end = "hide frame scugrp. "
}
hide message.


