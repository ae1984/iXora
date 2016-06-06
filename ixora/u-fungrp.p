/* u-fungrp.p
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
        24/11/03 nataly был доработан вывод  группы МБД на печать
*/

/*fungrp.p mult.i
02-24-93*/


{mainhead.i}

{jabrw.i
&start     = " "
&head      = "fungrp"
&headkey   = "fungrp"
&index     = "fungrp"

&formname  = "fungrp"
&framename = "fungrp"
&where     = " "

&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = "  update fungrp.fungrp fungrp.gl fungrp.des[1] with frame fungrp. "
&predelete = " find first deal where deal.grp = fungrp.fungrp and deal.fun <>
 ' ' no-lock no-error. if available deal then do: message 'Группа использована в сделке - удаление не допускается'. pause. undo,retry. end. "
       
&prechoose = "message 'F4-выход,INS-дополнить,F10-удалить,P-распечатать'."

&postdisplay = " "

&display   = " fungrp.fungrp fungrp.gl fungrp.des[1] "

&highlight = " fungrp.fungrp fungrp.des[1]  "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
            then do transaction on endkey undo, leave:
                 update fungrp.fungrp fungrp.gl fungrp.des[1] with frame fungrp.
            end.
            else if keyfunction(lastkey) = 'P' then do:
            output to rpt.img .
               for each fungrp:
               display fungrp.fungrp fungrp.gl fungrp.des[1] with frame fungrp.
               down with frame fungrp.
               end.
            output close.
           /*output to terminal.
            unix prit rpt.img.*/
            run menu-prt('rpt.img').
            end. "

&end = "hide frame fungrp. "
}
hide message.


