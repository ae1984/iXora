/* optmenu.p
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

/* optmenu.p */
def new shared var s-optmenu  like optmenu.optmenu. 
def shared var g-lang as char.

{jabra.i
&start     = " "
&head      = "optmenu"
&headkey   = "optmenu"
&index     = "optmenu"

&formname  = "optmenu"
&framename = "optmenu"
&where     = "true"

&addcon    = "true"
&deletecon = "true"

&precreate = " "

&postadd   = " 
               disp optmenu.optmenu optmenu.des with frame optmenu.
               update optmenu.optmenu optmenu.des with frame optmenu.
               s-optmenu = optmenu.optmenu.
               run optitem.  readkey pause 0. "
               

&prechoose = "message 'F4-Выход, INS-вставка, F10-удаление'."

&predisplay = " "

&display = "optmenu.optmenu optmenu.des"

&highlight = " optmenu.optmenu optmenu.des "


&predelete = "
for each optitem where optitem.optmenu eq optmenu.optmenu:
  find first optlang where optlang.optmenu eq optitem.optmenu and
    optlang.ln eq optitem.ln no-error.
  if avail optlang then delete optlang.
  delete optitem.
end."
&postkey   = "else if keyfunction(lastkey) = 'RETURN'
            then do transaction on endkey undo, leave:
               update optmenu.optmenu optmenu.des with frame optmenu. 
               s-optmenu = optmenu.optmenu.
               run optitem. 
             end. "

&end = "hide frame optmenu."
}
hide message.


