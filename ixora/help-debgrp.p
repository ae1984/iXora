/* help-debgrp.p
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
        05/06/06 marinav - перекомпиляция
*/


def input parameter showall as log.
{skappbra.i 
      &head      = "debgrp"
      &index     = "grp no-lock"
      &formname  = "hlpdeb"
      &framename = "hgrp"
      &where     = " showall or debgrp.grp ne 0 "
      &addcon    = "false"
      &deletecon = "false"
      &display   = " debgrp.des"
      &highlight = " debgrp.des"
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           frame-value = debgrp.grp.
                           hide frame hgrp.
                           return.  
                    end."
      &end = "hide frame hgrp."
}          
