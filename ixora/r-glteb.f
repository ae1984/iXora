/* r-glteb.f
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

/* r-glteb.f
*/
     ven1 = ven.
     if tdt ne g-today then do:
     find last glday where glday.gdt le tdt and  glday.gl eq gl.gl
     and glday.crc eq crc.crc no-lock no-error.
     if available glday then  do:
        if vlog eq true then
        ven1 = glday.dam - glday.cam.
        else
        ven1 = glday.cam - glday.dam.
        if gl.type eq "R" or gl.type eq "E" then do:
            if year(glday.gdt) ne year(tdt) then ven1 = 0.
        end.
     end.  
     else ven1 = 0.
     end.


     display ven label "КОНЕЧНЫЙ БАЛАНС"  at 40 ven ne ven1 format "***/   "

             with side-label frame ebal.
