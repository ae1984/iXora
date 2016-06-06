/* sgnsysc.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Управление хранилищем карточек - импорт, замена, списки файлов
        Настройки хранилища
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-3
 * AUTHOR
        29.02.2004 nadejda
 * CHANGES
*/

{mainhead.i SGNCARD0}
{sgn.i}

define variable s_rowid as rowid.
def var v-title as char init " НАСТРОЙКИ ХРАНИЛИЩА КАРТОЧЕК ПОДПИСЕЙ ".
def var v-addparam as char init "".

form
     sysc.chval label "СТРОКА" format "x(300)"
   with overlay row 16 centered frame f-char.


{jabrw.i 
&start     = "displ v-title format 'x(50)' at 20 with row 4 no-box no-label frame f-header."
&head      = "sysc"
&headkey   = "sysc"
&index     = "sysc"

&formname  = "sgnsysc"
&framename = "f-dat"
&where     = " sysc.sysc begins 'sgn' or lookup(sysc.sysc, v-addparam) > 0 "

&addcon    = "true"
&deletecon = "true"
&postcreate = " "
&postupdate   = " update sysc.chval with frame f-char scrollable. 
                  hide frame f-char no-pause. "
       
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать' 
  with centered row 22 no-box frame f-footer."

&postdisplay = " "

&display   = " sysc.sysc sysc.des sysc.daval sysc.deval sysc.inval sysc.loval "
&update    = " sysc.sysc sysc.des sysc.daval sysc.deval sysc.inval sysc.loval "
&highlight = " sysc.sysc "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(sysc).
                         output to sgndata.img .
                         for each sysc where sysc.sysc begins 'sgn' or lookup(sysc.sysc, v-addparam) > 0 no-lock:
                             display sysc.sysc sysc.des sysc.daval sysc.deval sysc.inval sysc.loval
                               sysc.chval.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('sgndata.img').
                         find sysc where rowid(sysc) = s_rowid no-lock.
                      end. "

&end = "hide all no-pause."
}
hide message.


