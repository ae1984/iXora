/* x-jltot.i
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

/* x-jltot.i
*/
vdam = 0.
vcam = 0.
vbal = 0.
for each jl of jh no-lock:
vdam = vdam + jl.dam.
vcam = vcam + jl.cam.
vbal = vdam - vcam.
end.
display vdam vcam with frame tot.
display vbal with frame bal.
pause 0.
