/* bookcod.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Редактирование одного справочника bookcod
 * RUN
        вызывается как persistent
 * CALLER
        booklist.p, pkcods.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-6-1б 4-6-5
 * AUTHOR
        22.01.2003 nadejda
 * CHANGES
        28.11.2003 nadejda  - убрала перевод кода в цифры, сортировка просто по коду
        06.05.05 marinav - добавилось поле info[2]
*/


{global.i}


def var v-title as char.
def var s_rowid as rowid.

procedure bookank.

def input parameter p-cod as char.
def input parameter p-match as char.
def input parameter p-edit as logical.


find bookref where bookref.bookcod = p-cod no-lock no-error.
v-title = bookref.bookname.

displ "<ENTER>- редактир.,  <INS>- вставка,  <Ctrl-D>- удаление, <P>- печать"
  with centered row 21 no-box frame footer.


{jabrw.i 

&start     = " "
&head      = "bookcod"
&headkey   = "bookcod"
&index     = "main"
&formname  = "bookank"
&framename = "bookcod"
&where     = " bookcod.bookcod = p-cod and 
               if p-match <> '' then bookcod.code matches p-match else true "
&addcon    = " p-edit "
&deletecon = " p-edit "
&predelete = " " 
&precreate = " "
&postcreate = " assign bookcod.bookcod = p-cod
                       bookcod.info[1] = '0'
                       bookcod.info[2] = '0'
                       bookcod.regdt = g-today
                       bookcod.regwho = g-ofc 
                       bookcod.upddt = g-today 
                       bookcod.updwho = g-ofc. 
                       bookcod.treenode = p-cod. "
&update    = " bookcod.code bookcod.name bookcod.info[1] bookcod.info[2] " 
&postupdate = " bookcod.treenode = p-cod + bookcod.code. " 
&prechoose = " "
&predisplay = " "
&display   = " bookcod.code bookcod.name bookcod.info[1] bookcod.info[2] bookcod.regdt bookcod.regwho "
&highlight = " bookcod.code bookcod.name bookcod.info[1] bookcod.info[2] bookcod.regdt bookcod.regwho "
&postkey   = " else if keyfunction(lastkey) = 'P' then  do:
                         s_rowid = rowid(bookcod).
                         output to pkdata.txt.
                         displ v-title no-label format 'x(100)' skip with no-label width 300.
                         for each bookcod where bookcod.bookcod = p-cod and 
                                  if p-match <> '' then bookcod.code matches p-match else true no-lock use-index main:
                             display bookcod.code format 'x(10)' 
                                     bookcod.name format 'x(40)' 
                                     bookcod.info[1] label 'ВЕС' format 'x(5)'
                                     bookcod.regdt 
                                     bookcod.regwho with width 300.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('pkdata.txt').
                         find bookcod where rowid(bookcod) = s_rowid no-lock.
                      end. "
&end       = " hide frame bookcod. hide frame footer. "
}

end procedure.


procedure bookself.

def input parameter p-cod as char.
def input parameter p-match as char.
def input parameter p-edit as logical.

find bookref where bookref.bookcod = p-cod no-lock no-error.
v-title = bookref.bookname.

displ "<ENTER> - редактир.,  <INS> - вставка,  <Ctrl-D> - удаление"
  with centered row 21 no-box frame footer.

{jabrw.i 

&start     = " "
&head      = "bookcod"
&headkey   = "bookcod"
&index     = "main"
&formname  = "bookcod"
&framename = "bookcod"
&where     = " bookcod.bookcod = p-cod and 
               if p-match <> '' then bookcod.code matches p-match else true "
&addcon    = " p-edit "
&deletecon = " p-edit "
&predelete = " " 
&precreate = " "
&postcreate = " assign bookcod.bookcod = p-cod
                       bookcod.regdt = g-today
                       bookcod.regwho = g-ofc 
                       bookcod.upddt = g-today 
                       bookcod.updwho = g-ofc. 
                       bookcod.treenode = p-cod. "
&update    = " bookcod.code bookcod.name " 
&postupdate = " bookcod.treenode = p-cod + bookcod.code. " 
&prechoose = " "
&predisplay = " "
&display   = " bookcod.code bookcod.name bookcod.regdt bookcod.regwho "
&highlight = " bookcod.code bookcod.name bookcod.regdt bookcod.regwho "
&postkey   = " else if keyfunction(lastkey) = 'P' then  do:
                         s_rowid = rowid(bookcod).
                         output to pkdata.txt.
                         displ v-title no-label format 'x(100)' skip with no-label width 300.
                         for each bookcod where bookcod.bookcod = p-cod and 
                                  if p-match <> '' then bookcod.code matches p-match else true no-lock use-index main:
                             display bookcod.code format 'x(10)' 
                                     bookcod.name format 'x(40)' 
                                     bookcod.regdt 
                                     bookcod.regwho with width 300.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('pkdata.txt').
                         find bookcod where rowid(bookcod) = s_rowid no-lock.
                      end. "
&end       = " hide frame bookcod. hide frame footer. "
}

end procedure.


