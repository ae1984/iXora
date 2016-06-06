/* clcontr.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Настройка списка контролеров для утверждения выдачи средств на расчетный счет
 * RUN
        
 * CALLER
        главное меню
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-2-3-6, 4-3-7
 * AUTHOR
        08.09.2003 nadejda
 * CHANGES

*/

{mainhead.i}


def temp-table t-con
  field ofc like ofc.ofc label "ОФИЦЕР"
  field name as char label "ФИО" format "x(30)"
  field depart as char label "ДЕПАРТАМЕНТ" format "x(25)"
  field deps as logical label "СВОЙ ДЕПАРТ?" format "да/нет"
  index name is primary name
  index ofc is unique ofc.

def var i as integer.
def var v-str as char.

find first sysc where sysc.sysc = "loncon" no-lock no-error.
if avail sysc and sysc.chval <> "" then do:
  i = 1.
  repeat:
    v-str = entry (i, sysc.chval).
    find ofc where ofc.ofc = v-str no-lock no-error.
    if avail ofc then do:
      create t-con.
      t-con.ofc = v-str.
      t-con.deps = (i < num-entries (sysc.chval)) and (entry (i + 1, sysc.chval) <> "0").
      t-con.name = ofc.name.
      find codfr where codfr.codfr = "sproftcn" and codfr.code = ofc.titcd no-lock no-error.
      if avail codfr then t-con.depart = codfr.name[1].
    end.
    i = i + 2.
    if i >= num-entries (sysc.chval) then leave.
  end.
end.


define variable s_rowid as rowid.
def var v-title as char init " КОНТРОЛЕРЫ ВЫДАЧИ КРЕДИТОВ ".

{jabrw.i 
&start     = " displ v-title format 'x(50)' at 16 with row 4 no-box no-label frame f-header."
&head      = "t-con"
&headkey   = "ofc"
&index     = "name"

&formname  = "clcontr"
&framename = "f-ed"
&where     = " true "

&addcon    = "true"
&deletecon = "true"
&postcreate = " t-con.deps = yes."
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать' 
  with centered row 22 no-box frame f-footer.  
  "

&predisplay = "  "
&display   = " t-con.ofc t-con.name t-con.depart t-con.deps "

&highlight = " t-con.ofc  "

&preupdate = " "
&update   = " "
&postupdate = " update t-con.ofc with frame f-ed. 
                find ofc where ofc.ofc = t-con.ofc no-lock no-error.
                t-con.name = ofc.name.
                find codfr where codfr.codfr = 'sproftcn' and codfr.code = ofc.titcd no-lock no-error.
                t-con.depart = codfr.name[1].
                displ t-con.name t-con.depart with frame f-ed. 
                update t-con.deps with frame f-ed.   "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(t-con).
                         output to clcontr.img .
                         put skip(1) v-title format 'x(70)' skip.
                         for each t-con no-lock:
                             display t-con.ofc t-con.name t-con.depart t-con.deps.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('clcontr.img').
                         find t-con where rowid(t-con) = s_rowid no-lock no-error.
                      end. "

&end = "hide frame f-ed. hide frame f-header. hide frame f-footer."
}
hide message.


find first sysc where sysc.sysc = "loncon" no-lock no-error.
if not avail sysc then do:
  create sysc.
  assign sysc.sysc = "LONCON" 
         sysc.des = "Контролеры по кредитам (4-3-7)"
         sysc.chval = "".
end.
release sysc.

v-str = "".
for each t-con:
  if v-str <> "" then v-str = v-str + ",".
  v-str = v-str + t-con.ofc + "," + if t-con.deps then "1" else "0".
end.

find first sysc where sysc.sysc = "loncon" exclusive-lock no-error.
sysc.chval = v-str.
release sysc.
