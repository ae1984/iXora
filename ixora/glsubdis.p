/* glsubdis.p
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
   glsetsub.p
   Joon  March 12, 1993
*/

{global.i}
{glsetvar.i "new shared"}

/*
 if not avail gl then return . 
*/

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
repeat: 
 update gl.crc with frame gl.
run glsetcal.
vgl = gl.gl.
vsub = gl.subled.
find gltot where gltot.gl eq gl.gl and gltot.crc eq gl.crc no-error.
find glbal where glbal.gl eq gl.gl and glbal.crc eq gl.crc no-error.
display gl.gl gl.crc gl.des gl.des gl.sname gl.type gl.gl1
gl.revgl gl.autogl gl.glacr gl.glacrdb gl.subled gl.level
gl.sts gl.code  vyst vydr vycr vmst vmdr vmcr
vtst vtdr vtcr vtbl vttl vtavg with frame gl.
end.
return .
end.
 "
"
&end=" "
}

/*vtst=glbal.pdam - glbal.pcam. */
