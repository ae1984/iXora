/* cifkated.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Редактирование справочника категорий клиентов 
            (для 1.2 и отчетов cifkat*.p 8.1.15.*)
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-1-15-4
 * AUTHOR
        31.07.2003 sasco
 * CHANGES
        10.09.2003 nadejda - добавила признак доступности выписок
*/


{mainhead.i}

def var v-title as char init "ПЕРЕЧЕНЬ КАТЕГОРИЙ КЛИЕНТОВ".
def var v-codif as char init "cifkat".

define variable s_rowid as rowid.

{jabrw.i
&start     = "displ v-title format 'x(50)' at 15 with row 4 no-box no-label frame f-header."
&head      = "codfr"
&headkey   = "code"
&index     = "main"

&formname  = "cifkated"
&framename = "f-ed"
&where     = " codfr.codfr = v-codif and codfr.code <> 'msc' "

&addcon    = "true"
&deletecon = "true"
&postcreate = "codfr.codfr = v-codif. codfr.level = 1. codfr.name[5] = 'yes'. "
&prechoose = "displ '<F4>- выход,  <INS>- вставка,  <F10>- удалить,  <P>- печать' 
  with centered row 22 no-box frame f-footer."

&predisplay = " v-vipis = (codfr.name[5] = '') or (codfr.name[5] = 'yes'). "
&display   = " codfr.code codfr.name[1] v-vipis "
&highlight = " codfr.code  "
&preupdate = " v-vipis = (codfr.name[5] = '') or (codfr.name[5] = 'yes'). "
&update   = " codfr.code codfr.name[1] v-vipis "
&postupdate = " codfr.codfr = v-codif. codfr.level = 1. 
         codfr.tree-node = codfr.codfr + CHR(255) + codfr.code. if v-vipis then codfr.name[5] = 'yes'. else codfr.name[5] = 'no'. "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(codfr).
                         output to repdata.img .
                         for each codfr where codfr.codfr = v-codif no-lock:
                             v-vipis = (codfr.name[5] = '') or (codfr.name[5] = 'yes').
                             display codfr.code format 'x(4)' label 'КОД'
                                     codfr.name[1] format 'x(40)' label 'НАИМЕНОВАНИЕ'
                                     v-vipis.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('repdata.img').
                         find codfr where rowid(codfr) = s_rowid no-lock.
                      end. "

&end = "hide frame f-ed. hide frame f-header. hide frame f-footer."
}
hide message.




