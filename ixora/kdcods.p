/* kdcods.p
 * MODULE
        Кредитное досье
 * DESCRIPTION
        Список справочников в comm с возможностью добавления и редактирования
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-11-4-3
 * AUTHOR
        
 * CHANGES
        29.12.2003 marinav - копия pkcods
*/


def var v-booklist as char init "kd".

{mainhead.i}

def var v-oldcod as char.

form
  "<ENTER> - редактир.,  <INS> - вставка,  <Ctrl-D> - удаление,  <TAB> - справочник"
  with centered row 21 no-box frame footer.

def var hbookcod as handle.
run bookcod persistent set hbookcod.


{jabrw.i 

&start     = " "
&head      = "bookref"
&headkey   = "bookcod"
&index     = "bookcod"
&formname  = "bookref"
&framename = "bookref"
&where     = " bookref.bookcod begins v-booklist "
&addcon    = "true"
&deletecon = "true"
&prevdelete = "for each bookcod where bookcod.bookcod = bookref.bookcod.
                delete bookcod. end. " 
&precreate = " "
&postcreate = " bookref.regdt = g-today. bookref.regwho = g-ofc. "
&preupdate = " v-oldcod = bookref.bookcod. "
&update    = " bookref.bookcod bookref.bookname "
&postupdate = " if new bookref then do:
                  create bookcod.
                  assign bookcod.bookcod = bookref.bookcod 
                         bookcod.code = 'msc'
                         bookcod.name = 'другое'
                         bookcod.info[1] = '0'
                         bookcod.regdt = g-today
                         bookcod.regwho = g-ofc
                         bookcod.upddt = g-today
                         bookcod.updwho = g-ofc.
                  bookcod.treenode = bookref.bookcod + bookcod.code.
                end.
                else
                if v-oldcod <> bookref.bookcod then do:
                  for each bookcod where bookcod.bookcod = v-oldcod.
                    bookcod.bookcod = bookref.bookcod. 
                    bookcod.treenode =  bookref.bookcod + 
                                        substr(bookcod.treenode, length(v-oldcod) + 1).
                  end.
                end. "
&prechoose = " "
&predisplay = " view frame footer. "
&display   = " bookref.bookcod bookref.bookname bookref.regdt bookref.regwho "
&highlight = " bookref.bookcod bookref.bookname "
&postkey   = " else 
                 if keyfunction(lastkey) = 'TAB' then do:
                   run bookank in hbookcod (bookref.bookcod, '*', yes). 
                   view frame footer.
                 end. "
&end       = " hide frame bookref. hide frame footer. "
}



