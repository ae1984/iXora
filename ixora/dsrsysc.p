/* dsrsysc.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Управление досье клиентв - импорт, замена, списки файлов
        Файл общих настроек
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6
 * AUTHOR
        07.02.2005 marinav
 * CHANGES
*/

{mainhead.i}
{dsr.i}

define variable s_rowid as rowid.
def var v-title as char init " НАСТРОЙКИ ХРАНИЛИЩА ДОСЬЕ КЛИЕНТОВ ".
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
&where     = " sysc.sysc begins 'dsr' or lookup(sysc.sysc, v-addparam) > 0 "

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
                         output to dsrdata.img .
                         for each sysc where sysc.sysc begins 'dsr' or lookup(sysc.sysc, v-addparam) > 0 no-lock:
                             display sysc.sysc sysc.des sysc.daval sysc.deval sysc.inval sysc.loval
                               sysc.chval.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('dsrdata.img').
                         find sysc where rowid(sysc) = s_rowid no-lock.
                      end. "

&end = "hide all no-pause."
}
hide message.


