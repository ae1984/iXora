/* t-lonext.p
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

/* t-lonext.p
*/

{global.i}

def shared var s-lon like lon.lon.
def shared var fduedt as date.
def shared var tduedt as date.
def new shared var s-jh  like jh.jh.

def var vbal like jl.dam.
def var vrem1 as cha.
def var vrem2 as cha.
def var vgl  like gl.gl.
def var vacc like lon.lon.

run x-jhnew.
{mesg.i 0977} string(s-jh).
find lon where lon.lon eq s-lon no-error.
vgl = lon.gl.
vacc = lon.lon.
vrem1 = "EXTENSION OF LOAN# " + lon.lon + " DUE ON " + string(fduedt).
vrem2 = "                           TO " + string(tduedt).
vbal = lon.dam[1] - lon.cam[1].
find jh where jh.jh eq s-jh.
jh.cif = lon.cif.
jh.crc = lon.crc.

create jl.
jl.jh = jh.jh.
jl.ln = 1.
jl.crc = jh.crc.
jl.who = jh.who.
jl.jdt = jh.jdt.
jl.whn = jh.whn.
jl.rem[1] = vrem1.
jl.rem[2] = vrem2.
jl.gl = vgl.
jl.acc = vacc.
jl.dam = 0.
jl.cam = vbal.
jl.dc = "C".

find gl where gl.gl eq jl.gl.
/* {x-jlupd.i +}  */
{jlupd-r.old}

create jl.
jl.jh = jh.jh.
jl.ln = 2.
jl.crc = jh.crc.
jl.who = jh.who.
jl.jdt = jh.jdt.
jl.whn = jh.whn.
jl.rem[1] = vrem1.
jl.rem[2] = vrem2.
jl.gl = vgl.
jl.acc = vacc.
jl.dam = vbal.
jl.cam = 0.
jl.dc = "D".

find gl where gl.gl eq jl.gl.
/* {x-jlupd.i +} */
{jlupd-r.old}

pause 0.
hide all.
run x-jlvou.
