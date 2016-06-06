/* help-system.p
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

/**  help-system.p  **/

{global.i}
                 
define shared variable v_system as character.

{aapbra.i

&start     = " "
&head      = "trxsys"
&index     = "system no-lock "
&formname  = "syste"
&framename = "syste"
&where     = " "
&addcon    = "false"
&deletecon = "false"
&precreate = " "
&display   = "trxsys.system trxsys.des" 
&highlight = "trxsys.system trxsys.des"
&postadd   = " "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                                                on endkey undo, leave:
                    v_system  =  trim(trxsys.system).
                    hide frame syste.
                    return.
              end."
&end = "hide frame syste."
}

