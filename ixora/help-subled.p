/* help-subled.p
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

/*** help-subled.p **/


{global.i}


define temp-table subled 
    field subled like gl.subled.
    
for each gl no-lock break by gl.subled:
    if first-of (gl.subled) and gl.subled ne "" then do:
        create subled.
        subled.subled = gl.subled.
    end.
end.    
  

{jabre.i

&head = "subled"
&where = "true"
&formname = "subl"
&framename = "subl"
&addcon = "false"
&deletecon = "false"
&display = "subled.subled"
&highlight = "subled.subled"
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
                frame-value = subled.subled.
                hide frame subl.
                return.
            end.
            "
&end = "hide frame subl".
}

