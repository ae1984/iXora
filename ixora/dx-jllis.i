/* dx-jllis.i
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

/* x-jllis.i
*/
clear frame jl all.
vdam = 0.
vcam = 0.
vbal = 0.
i = 0.
for each jl of jh :
i = i + 1.
vdam = vdam + jl.dam.
vcam = vcam + jl.cam.
vbal = vdam - vcam.
find gl of jl no-lock.

/* ******************** for 451050 and rmz in "Payment system" */

if jl.gl = intv and jl.acc = '' then  jl.acc = substr(rem[4],100,10).

display jl.ln jl.crc jl.gl gl.sname jl.acc jl.dam jl.cam
with frame jl.

if jl.acc = substr(jl.rem[4],100,10)  then  jl.acc = '' .

/*    *****************************************  */
if i  eq 4 then do:
pause.
i = 0.
end.

if g-tty ne 0
then do:
find ttl where ttl.tty eq g-tty and ttl.ln eq jl.ln no-error.
if available ttl
then do:
color display message jl.dam when ttl.dc eq "D" with frame jl.
color display message jl.cam when ttl.dc eq "C" with frame jl.
end.
end.
down with frame jl.
end.
display vbal with frame bal.
display vdam vcam with frame tot.
