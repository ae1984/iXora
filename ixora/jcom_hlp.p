/* jcom_hlp.p
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

/** jcom_hlp.p **/


{mainhead.i}
{jcom_hlp.f}

define shared variable com_rec as recid.

{jabre.i
&start = "find jouset where recid (jouset) eq com_rec no-lock."
&head = "joucom"
&where = "joucom.comtype eq jouset.proc and joucom.comnat eq jouset.natcur
            and joucom.fname eq jouset.fname"
&formname = "jcom_hlp"
&framename = "f_hlp"
&addcon = "false"
&deletecon = "false"
&display = "joucom.comcode joucom.comdes joucom.comnat joucom.comprim"
&highlight = "joucom.comcode joucom.comdes joucom.comnat joucom.comprim"
&prechoose = "message ' ENTER - выбор кода комиссии '."
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do on endkey 
                undo, leave:

                frame-value = joucom.comcode.
                hide frame f_hlp.
                return.
                next upper.
            end. 
            "
&end = "hide frame f_hlp."            
}


