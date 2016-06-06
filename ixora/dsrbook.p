/* sgnbook.p
 * MODULE
        Клиенты
        Электронное досье клиентов 
 * DESCRIPTION
        Редактирование списка документов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6-7
 * AUTHOR
        13.06.05 marinav
 * CHANGES
*/


{mainhead.i}

def var v-title as char.
def var v-cod as char init "sgndoc".
def var v-ans as logical.

find bookref where bookref.bookcod = v-cod no-lock no-error.
v-title = bookref.bookname.

displ "<ENTER> - редактир.,  <INS> - вставка,  <Ctrl-D> - удаление"
  with centered row 21 no-box frame footer.


{jabrw.i 

&start     = " "
&head      = "bookcod"
&headkey   = "bookcod"
&index     = "main"
&formname  = "bookcred"
&framename = "bookcod"
&where     = " bookcod.bookcod = v-cod "
&addcon    = " true "
&deletecon = " true "
&predelete = " " 
&precreate = " "
&postcreate = " assign bookcod.bookcod = v-cod
                       bookcod.regdt = g-today
                       bookcod.regwho = g-ofc 
                       bookcod.upddt = g-today 
                       bookcod.updwho = g-ofc. 
                       bookcod.treenode = v-cod. "
&update    = " bookcod.code bookcod.name bookcod.info[1] " 
&postupdate = " assign bookcod.regdt = g-today
                       bookcod.regwho = g-ofc
                       bookcod.treenode = v-cod + bookcod.code. " 
&prechoose = " "
&predisplay = "  "
&display   = " bookcod.code bookcod.name bookcod.regdt bookcod.regwho bookcod.info[1] "
&highlight = " bookcod.code bookcod.name bookcod.regdt bookcod.regwho bookcod.info[1] "
&postkey   = " "
&end       = " hide frame bookcod. hide frame footer. "
}

