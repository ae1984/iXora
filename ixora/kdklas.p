/* kdklas.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Справочник для классификации кредитов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-4-4 
 * AUTHOR
        29.12.03 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов

*/

{mainhead.i}
/*{kd.i "new"} */
pause 0.
define variable s_rowid as rowid.

{jabrw.i 
&head      = "kdklas"
&headkey   = "kod"
&index     = "kritcod"

&formname  = "kdklas"
&framename = "kdkri"
&where     = "true"

&addcon    = "true"
&deletecon = "true"
&postcreate = " "
       
&prechoose = " hide message. message 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать'."
&postdisplay = " "

&display   = " kdklass.type kdklass.ln kdklass.kod kdklass.name kdklass.sprav kdklass.proc "
&update    = " kdklass.type kdklass.ln kdklass.kod kdklass.name kdklass.sprav kdklass.proc "
&postupdate = " "
            
&highlight = " kdklass.type kdklass.ln kdklass.kod "

&postkey   = " else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(kdklass).
                         output to pkdata.img .
                         for each kdklass no-lock:
                             display kdklass.ln kdklass.kod kdklass.name kdklass.proc kdklass.sprav 
                                 with width 310.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('pkdata.img').
                         find kdklass where rowid(kdklass) = s_rowid no-lock.
                      end. "

&end = "hide all no-pause."
}
hide message.

