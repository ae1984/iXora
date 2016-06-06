/* glsetsub.p
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

{global.i}
{glsetvar.i "new shared"}
vday[2] = day(date(3,1,year(g-today)) - 1).
def buffer xglday for glday.
def buffer b-gl for gl.
def new shared var vgl like gl.gl.
def new shared var vsub like gl.subled.

{sub.i
&option="GLSUB"
&head="gl"
&headkey="gl"
&framename="gl"
&formname="gl"
&updatecon="true"
&deletecon="true"
&start="
do transaction:
 gl.crc = 1 . 
end. 
run glsetcal.
vgl = gl.gl.
vsub = gl.subled.
find gltot where gltot.gl eq gl.gl and gltot.crc eq gl.crc no-error.
find glbal where glbal.gl eq gl.gl and glbal.crc eq gl.crc no-error."
&display="display gl.gl gl.crc gl.des gl.sname gl.type gl.gl1
gl.revgl gl.autogl gl.glacr gl.glacrdb gl.subled gl.level
gl.sts gl.code gl.grp 
 vyst vydr vycr vmst vmdr vmcr
vtst vtdr vtcr vtbl vttl vtavg with frame gl."
&preupdate ="
set gl.crc   with frame gl.
run glsetcal.
vgl = gl.gl.
vsub = gl.subled.
find gltot where gltot.gl eq gl.gl and gltot.crc eq gl.crc no-error.
find glbal where glbal.gl eq gl.gl and glbal.crc eq gl.crc no-error.
display  gl.gl gl.crc gl.des gl.sname gl.type gl.gl1
gl.revgl gl.autogl gl.glacr gl.glacrdb gl.subled gl.level
gl.sts gl.code gl.grp 
 vyst vydr vycr vmst vmdr vmcr
vtst vtdr vtcr vtbl vttl vtavg with frame gl.
pause 0.
set gl.des with frame gl.
if length(gl.des) le 20 and gl.sname eq """"
then do:
gl.sname = gl.des.
display gl.sname with frame gl.
end.
set gl.sname gl.type gl.gl1 gl.revgl gl.autogl gl.glacr gl.glacrdb
gl.subled gl.level validate(true,'')  gl.sts gl.code gl.grp
 with frame gl.
   vsub = gl.subled.
if frame gl gl.subled entered and gl.level = 1 then run trxlevgl. 
"

&update=" "
/*
&update="vyst vydr vycr vmdr vmcr vtdr vtcr"
*/
&postupdate="
display vtot vavg with frame accm.
/*
update vtot with frame accm.
if gl.type eq ""A"" or gl.type eq ""E""
then do: glbal.ydam = vyst. glbal.ycam = 0. end.
else do: glbal.ycam = vyst. glbal.ydam = 0. end.
glbal.dam=glbal.ydam + vydr.
glbal.cam=glbal.ycam + vycr.
glbal.mdam=glbal.dam - vmdr.
glbal.mcam=glbal.cam - vmcr.

find last glday where glday.gl = glbal.gl and glday.crc = glbal.crc
and glday.gdt lt g-today - 1 no-error. if available glday then do:
glbal.pdam=glday.dam .
glbal.pcam=glday.cam. end.

vmst=glbal.mdam - glbal.mcam.
vtst=glbal.pdam - glbal.pcam.
vtbl=glbal.dam - glbal.cam.
if gl.type ne ""A"" and gl.type ne ""E""
then do:
vmst= - vmst.
vtst= - vtst.
vtbl= - vtbl.
end.
vttl= 0.
repeat inc= 1 to 12:
if gl.type eq ""A"" or gl.type eq ""E""
then do:
gltot.dam[inc]= vtot[inc].
gltot.cam[inc]= 0.
vavg[inc]= vtot[inc] / vday[inc].
vttl= vttl + vtot[inc].
end.
else do:
gltot.cam[inc]= vtot[inc].
gltot.dam[inc]= 0.
vavg[inc]= vtot[inc] / vday[inc].
vttl= vttl + vtot[inc].
end.
end.
vtavg= vttl / vyrday.
*/
display vmst vtst vtbl vttl vtavg with frame gl. pause 0.
display vtot vavg with frame accm."
&predelete=" "
&postdelete="delete gltot."
&end=" "
}



/*vtst=glbal.pdam - glbal.pcam. */
