/* astedtot.p
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

/*spdedt.p */
{mainhead.i}

{jabra.i
&head = "astotv"
&headkey = "kotv"
&index = "kotv"
&where = "astotv.priz = 'A'"
&addcon = "true"
&deletecon = "true"
&start = " "
&formname = "astot"
&framename = "astot"
&postadd = "  hide message no-pause.
              message color normal
'               <Enter>-ВВОД <F1>-СОХРАНЕНИЕ <F4>-ОТКАЗ'.
              update  astotv.kotv astotv.otvp
                   with frame astot.
              astotv.who = g-ofc.
              astotv.whn = g-today.
              astotv.priz ='A'."
&prechoose = "message color normal
'         <Enter>-РЕДАКТ. <Insert>-ДОБАВИТЬ <F10>-УДАЛИТЬ <F4>-ВЫХОД'."
&display   = "astotv.kotv astotv.otvp "
&highlight = "astotv.kotv astotv.otvp "
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do transaction 
          on endkey undo, leave:
            do on endkey undo, leave:
             hide message no-pause.
              message color normal
'               <Enter>-ВВОД <F1>-СОХРАНЕНИЕ <F4>-ОТКАЗ'.
	       update astotv.kotv astotv.otvp 
	        with frame astot.
              astotv.who = g-ofc.
              astotv.whn = g-today.
              astotv.priz ='A'.
              end.
               displ astotv.kotv astotv.otvp
                with frame astot.
           end."

&predelete = "find first ast where ast.addr[1] = astotv.kotv no-lock no-error.
               if available ast then do: 
                  message 'ЕСТЬ КАРТ. ' + ast.ast + ' С КОДОМ ' 
                  + ast.addr[1] + ', УДАЛИТЬ НЕЛЬЗЯ'.
                  pause 30. bell. next inner.
              end."
&end = "hide message no-pause."
}

