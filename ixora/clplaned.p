/* clplaned.p
 * MODULE
        Название Программного Модуля
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
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* clplaned.p Кредитный модуль
   Редактирование справочника схем начисления процентов

   30.07.2003 nadejda
*/

{mainhead.i}

define variable s_rowid as rowid.
def var v-title as char init "".

{jabrw.i 
&start     = "run deftitle. displ v-title format 'x(50)' at 16 with row 4 no-box no-label frame f-header."
&head      = "codfr"
&headkey   = "code"
&index     = "codfr"

&formname  = "clplaned"
&framename = "f-ed"
&where     = " codfr.codfr = v-codfr and codfr.code <> 'msc' "

&addcon    = "true"
&deletecon = "true"
&postcreate = "codfr.codfr = v-codfr. codfr.level = 1."
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать' 
  with centered row 22 no-box frame f-footer.  
  "

&predisplay = "  "
&display   = " codfr.code codfr.name[1] codfr.name[2] "

&highlight = " codfr.code  "

&preupdate = " "
&update   = " codfr.code codfr.name[1] codfr.name[2] "
&postupdate = " codfr.codfr = v-codfr. codfr.level = 1. codfr.name[2] = caps (codfr.name[2]).
         codfr.tree-node = codfr.codfr + CHR(255) + codfr.code. "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(codfr).
                         output to pkdata.img .
                         put skip(1) v-title format 'x(70)' skip.
                         for each codfr where codfr.codfr = v-codfr no-lock:
                             display     
                               codfr.code format 'x(5)' no-label
                               codfr.name[1] format 'x(40)' label 'НАИМЕНОВАНИЕ'
                               codfr.name[2] format 'x(1)' label 'МЕТОД НАЧИСЛ'.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('pkdata.img').
                         find codfr where rowid(codfr) = s_rowid no-lock.
                      end. "

&end = "hide frame f-ed. hide frame f-header. hide frame f-footer."
}
hide message.

procedure deftitle.
  find codific where codific.codfr = v-codfr no-lock no-error.
  if not avail codific then do:
    create codific.
    assign codific.codfr = v-codfr
           codific.name = "Схемы начисления процентов по кредитам"
           codific.who = g-ofc
           codific.whn = g-today.
    find current codific no-lock.
  end.
  v-title = codific.name.
end.

