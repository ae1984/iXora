/* help-skgrp.p
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
	02.09.05 nataly была добавлена {sk_all.i} для перекомпиляции

*/

{sk_all.i}

{skappbra.i
      &head      = "grp"
      &index     = "grp no-lock"
      &formname  = "sk-help"
      &framename = "hgrp"
      &where     = "grp.arc <> yes "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "grp.grp grp.des"
      &highlight = "grp.grp grp.des"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           frame-value = grp.grp.
                           hide frame hgrp.
                           return.  
                    end."
      &end = "hide frame hgrp."
}          

