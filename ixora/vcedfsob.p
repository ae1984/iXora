/* vcedfsob.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Редактирование справочника форм собственности
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-6-10, 9-1-2-12
 * AUTHOR
        18.10.2002 nadejda
 * CHANGES
        25.08.2003 nadejda - изменен индекс и формирование tree-node, поскольку теперь сортировка по русским символам идет верно
*/


{mainhead.i}

def var v-codif as char init "ownform".
def var s_rowid as rowid.



{jabrw.i
&start     = "displ 'ОРГАНИЗАЦИОННО-ПРАВОВЫЕ ФОРМЫ' format 'x(50)' at 15 with row 4 no-box no-label frame vcheader."
&head      = "codfr"
&headkey   = "code"
&index     = "cdco_idx"

&formname  = "vcedfsob"
&framename = "vced"
&where     = " codfr.codfr = v-codif and codfr.code <> 'msc' "

&addcon    = "true"
&deletecon = "true"
&postcreate = "codfr.codfr = v-codif. codfr.level = 1. tree-node = v-codif + 'ZZZZZZZZZZZ'. "
      
&prechoose = "displ 'F4- выход,  INS- вставка,  F10- удалить,  P- печать,  S- сортировка' 
  with centered row 22 no-box frame vcfooter."

&postdisplay = " "

&display   = " codfr.code codfr.name[1] "

&highlight = " codfr.code  "

&update   = " codfr.code codfr.name[1] "

&postupdate = " codfr.tree-node  = 'ownform' + caps(codfr.code). "

&postkey   = "else if keyfunction(lastkey) = 'P' then do:
                         s_rowid = rowid(codfr).
                         output to vcdata.img .
                         for each codfr where codfr.codfr = v-codif no-lock:
                             display codfr.code codfr.name[1].
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('vcdata.img').
                         find codfr where rowid(codfr) = s_rowid no-lock.
                      end.
              else if keyfunction(lastkey) = 'S' then do:
                         for each codfr where codfr.codfr = v-codif use-index cdco_idx :
                           codfr.tree-node  = 'ownform' + caps(codfr.code). 
                         end.
                         clin = 0.
                         next upper.
                      end. "

&end = "hide frame vced. hide frame vcheader. hide frame vcfooter."
}
hide message.




