/* help-fun.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/** help-fun.p **/


{global.i}

define temp-table wset
    field wproc as character
    field wname like jouset.fundes.
    
for each jouset no-lock break by jouset.fname:
    if first-of (jouset.fname) then do:
        create wset.
        wset.wproc = jouset.fname.
        wset.wname = jouset.fundes.
    end.
end.

{help-fun.f}

{jabre.i

&head = "wset"
&where = "true"
&formname = "help-fun"
&framename = "ffun"
&addcon = "false"
&deletecon = "false"
&display = "wset.wproc wset.wname"
&highlight = "wset.wproc wset.wname"
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, leave:
                    frame-value = wset.wproc.
                    hide frame ffun.
                    return.
              end."
&end = "hide frame ffun."


}


