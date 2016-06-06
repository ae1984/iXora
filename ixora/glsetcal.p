/* glsetcal.p
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

/*
  glsetcal.p
  To reduce the size of sub.i in glsubset.p
  March 15, 1993
*/
{global.i}
def shared var s-gl like gl.gl.
def var vgl like gl.gl.
{glsetvar.i "shared"}
def var v-dam like jl.dam.
def var v-cam like jl.cam.

vday[month(g-today - 1)] = day(g-today - 1).
vyrday=0.
repeat inc = 1 to month(g-today - 1):
vyrday=vyrday + vday[inc].
end.

find gl where gl.gl eq s-gl.
find gltot where gltot.gl eq gl.gl and gltot.crc eq gl.crc no-error.
if not available gltot
then do:
create gltot.
gltot.gl=gl.gl.
gltot.crc=gl.crc.
end.
find glbal where glbal.gl eq gl.gl and glbal.crc eq gl.crc no-error.
if not available glbal
then do:
create glbal.
glbal.gl=gl.gl.
glbal.crc=gl.crc.
end.
vyst=glbal.ydam - glbal.ycam.
vydr=glbal.dam - glbal.ydam.
vycr=glbal.cam - glbal.ycam.
vmst=glbal.mdam - glbal.mcam.
vmdr=glbal.dam - glbal.mdam.
vmcr=glbal.cam - glbal.mcam.
/*
vtst=glbal.pdam - glbal.pcam.
*/
vtst=glbal.dam - glbal.cam.
v-dam = 0.
v-cam = 0.
for each jl where jl.jdt eq g-today and jl.crc eq gl.crc and jl.gl eq gl.gl 
no-lock :
v-dam = v-dam + jl.dam.
v-cam = v-cam + jl.cam.
end.
vtdr= v-dam. /*glbal.dam - glbal.pdam.*/
vtcr= v-cam. /*glbal.cam - glbal.pcam.*/
vtbl= vtst + v-dam - v-cam. /* glbal.dam - glbal.cam.*/
if gl.type ne "A" and gl.type ne "E"
then do:
vyst= - vyst.
vmst= - vmst.
vtst= - vtst.
vtbl= - vtbl.
end.
vttl = 0.
repeat inc= 1 to 12:
if gl.type eq "A" or gl.type eq "E"
then do:
vtot[inc]=gltot.dam[inc] - gltot.cam[inc].
vavg[inc]=vtot[inc] / vday[inc].
vttl=vttl + gltot.dam[inc] - gltot.cam[inc].
end.
else do:
vtot[inc]= - gltot.dam[inc] + gltot.cam[inc].
vavg[inc]= vtot[inc] / vday[inc].
vttl= vttl - gltot.dam[inc] + gltot.cam[inc].
end.
end.
vtavg= vttl / vyrday.
