/* bookank.f
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Настройка справочника категорий должности для АНКЕТЫ в bookcod в COMM
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-6-15
 * AUTHOR
        16.11.2003 marinav
 * CHANGES
        28.11.2003 nadejda  - убрала перевод кода в цифры, сортировка просто по коду
*/

{global.i}

def var s_rowid as rowid.

displ "<ENTER>- редактир.,  <INS>- вставка,  <Ctrl-D>- удаление, <P>- печать"
  with centered row 21 no-box frame footer.


{jabrw.i 

&start     = " "
&head      = "bookcod"
&headkey   = "bookcod"
&index     = "main"
&formname  = "pkkateg"
&framename = "bookcod"
&where     = " bookcod.bookcod = 'pkankkat' "
&addcon    = " yes "
&deletecon = " yes "
&predelete = " " 
&precreate = " "
&postcreate = " assign bookcod.bookcod = 'pkankkat'
                       bookcod.info[1] = '0'
                       bookcod.info[2] = '10'
                       bookcod.info[3] = '27'
                       bookcod.regdt = g-today
                       bookcod.regwho = g-ofc 
                       bookcod.upddt = g-today 
                       bookcod.updwho = g-ofc. 
                       bookcod.treenode = 'pkankkat'. "
&update    = " bookcod.code bookcod.name bookcod.info[1] bookcod.info[2] bookcod.info[3] " 
&postupdate = "  bookcod.treenode = 'pkankkat' + bookcod.code. " 
&prechoose = " "
&predisplay = " "
&display   = " bookcod.code bookcod.name bookcod.info[1] bookcod.info[2] bookcod.info[3] bookcod.regdt bookcod.regwho "
&highlight = " bookcod.code bookcod.name bookcod.info[1] bookcod.info[2] bookcod.info[3] bookcod.regdt bookcod.regwho "
&postkey   = " else if keyfunction(lastkey) = 'P' then  do:
                         s_rowid = rowid(bookcod).
                         output to pkdata.txt.
                         displ 'Категории граждан' no-label format 'x(100)' skip with no-label width 300.
                         for each bookcod where bookcod.bookcod = 'pkankkat'no-lock use-index main:
                             display bookcod.code format 'x(10)' 
                                     bookcod.name format 'x(40)' 
                                     bookcod.info[1] label 'ВЕС' format 'x(5)'
                                     bookcod.info[2] format 'x(5)'
                                     bookcod.info[3] format 'x(5)'
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
