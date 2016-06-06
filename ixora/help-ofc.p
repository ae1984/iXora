/* help-ofc.p
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

/** help-ofc.p **/


/**** help-crc1.p ****/

{global.i}

{aapbra.i

&start     = " "
&head      = "ofc"
&index     = "ofc no-lock "
&formname  = "ofc"
&framename = "ofc"
&where     = " "
&addcon    = "false"
&deletecon = "false"
&precreate = " "
&display   = "ofc.ofc ofc.name" 
&highlight = "ofc.ofc ofc.name"
&postadd   = " "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, leave:
                    frame-value = ofc.ofc.
                    hide frame ofc.
                    return.
              end."
&end = "hide frame ofc."
}

