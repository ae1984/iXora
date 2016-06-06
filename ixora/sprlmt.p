/* sprlmt.p
 * MODULE
        Кредитный модуль
        Редактирование справочника кредитного лимита
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
        12-1-2-9-4 
 * AUTHOR
        27.12.2005 Natalya D.
 * CHANGES
   
*/

{mainhead.i}

define variable s_rowid as rowid.
def var v-title as char init "ЛИМИТЫ ДЛЯ КРЕДИТОВ".


{jabrw.i 
&start     = " displ v-title format 'x(50)' at 16 with row 4 no-box no-label frame f-header."
&head      = "lonlimit"
&headkey   = "id"
&index     = "id"

&formname  = "sprlmt"
&framename = "f-ed"
&where     = " true "

&addcon    = "true"
&deletecon = "true"
&postcreate = " "
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать' 
  with centered row 22 no-box frame f-footer.  
  "

&predisplay = "  "
&display   = " lonlimit.id lonlimit.longrp lonlimit.lnsegm lonlimit.lonsec lonlimit.des lonlimit.amt_usd "

&highlight = " lonlimit.id  "

&postadd = " lonlimit.who = g-ofc. lonlimit.whn = g-today. "
&preupdate = " "
&update   = " lonlimit.id lonlimit.longrp lonlimit.lnsegm lonlimit.lonsec lonlimit.des lonlimit.amt_usd "
&postupdate = " lonlimit.who = g-ofc. lonlimit.whn = g-today. "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(lonlimit).
                         output to pkdata.img .
                         put skip(1) v-title format 'x(70)' skip.
                         for each lonlimit no-lock:
                             display     
                               lonlimit.id lonlimit.longrp lonlimit.lnsegm lonlimit.lonsec lonlimit.des format 'x(30)' lonlimit.amt_usd .
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('pkdata.img').
                         find lonlimit where rowid(lonlimit) = s_rowid no-lock.
                      end. "

&end = "hide frame f-ed. hide frame f-header. hide frame f-footer."
}
hide message.

