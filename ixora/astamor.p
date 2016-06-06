/* astamor.p
 * MODULE
        Основные средства 6-1-6
 * DESCRIPTION
        Редактирование справочника %% ставок
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
        24.01.2005 marinav
 * CHANGES
*/


{global.i}
def var v-pc as deci.


{jabro.i 
&start     = " "
&head      = "taxcat"
&headkey   = "type"
&index     = "cat"
&formname  = "astamor"
&framename = "taxcat"
&where     = "true"
&addcon    = "true"
&deletecon = "true"
&predelete = " " 
&precreate = " "
&postadd    = "update taxcat.type taxcat.cat taxcat.name taxcat.pc  with frame taxcat." 
&prechoose = "message 'F4-выход,INS-доб, F10-удаление'."
&predisplay = " "
&display   = " taxcat.type taxcat.cat taxcat.name taxcat.pc "
&highlight = " taxcat.type taxcat.cat taxcat.name "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do transaction
                                             on endkey undo, next inner:
              find taxcat where recid(taxcat) = crec exclusive-lock.
                v-pc = taxcat.pc. 
                update taxcat.type taxcat.cat taxcat.name taxcat.pc with frame taxcat.
                if v-pc ne taxcat.pc then do: find first taxcathis where taxcathis.type = taxcat.type and
                taxcathis.cat = taxcat.cat and taxcathis.dtform = g-today no-error. if avail taxcathis then do :
                taxcathis.pc = taxcat.pc. taxcathis.rdt = g-today. taxcathis.who = g-ofc. end. 
                else do: create taxcathis. taxcathis.type = taxcat.type. taxcathis.cat = taxcat.cat. 
                taxcathis.dtform = g-today. taxcathis.pc = taxcat.pc. taxcathis.rdt = g-today. taxcathis.who = g-ofc. end. end.
              end. "
&end = "hide frame taxcat."
}
hide message.
