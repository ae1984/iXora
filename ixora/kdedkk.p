/* pkedkks.p
 * MODULE
        Кредитное досье
 * DESCRIPTION
        Справочник состава кред комитета
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
        18.03.2004 marinav
 * CHANGES
*/


{mainhead.i}

define variable s_rowid as rowid.
define var v-title as char init "".
define var v-cod as char.

{jabrw.i 
&start     = "run deftitle. displ v-title format 'x(50)' at 20 with row 4 no-box no-label frame f-header.
              on help of codfr.papa in frame kdedkk do: 
                 run uni_book ('kdkrkom', '*', output v-cod).
                 codfr.papa = entry(1, v-cod). displ codfr.papa with frame kdedkk.
              end. "
&head      = "codfr"
&headkey   = "code"
&index     = "codfr"

&formname  = "kdedkk"
&framename = "kdedkk"
&where     = " codfr.codfr = v-codfr and codfr.code <> 'msc' "

&addcon    = "true"
&deletecon = "true"
&postcreate = "codfr.codfr = v-codfr. codfr.level = 1."
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить' 
  with centered row 22 no-box frame f-footer. v-ln = integer (codfr.name[3]). 
  "

&predisplay = " v-ln = integer (codfr.name[3]). "
&display   = " codfr.papa codfr.code codfr.name[1] codfr.name[2] v-ln"

&highlight = " codfr.papa codfr.code  "

&preupdate = " v-ln = integer (codfr.name[3]). "
&update   = " codfr.code codfr.papa codfr.name[1] codfr.name[2] v-ln "
&postupdate = " codfr.codfr = v-codfr. codfr.level = 1. 
         codfr.tree-node = codfr.codfr + CHR(255) + codfr.code. codfr.name[3] = string(v-ln). "

&postkey   = " "

&end = "hide frame kdedkk. hide frame f-header. hide frame f-footer."
}
hide message.

procedure deftitle.
  find codific where codific.codfr = v-codfr no-lock no-error.
  if not avail codific then do:
    create codific.
    assign codific.codfr = v-codfr
           codific.name = "Состав Кредитного Комитета"
           codific.who = g-ofc
           codific.whn = g-today.
    find current codific no-lock.
  end.
  v-title = codific.name.
end.

