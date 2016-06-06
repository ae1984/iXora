/* x-lonvou.p
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

/* x-lonvou.p
*/

{global.i}

def var vi as int.
define  shared   var s-jh like jh.jh .
define shared variable s-lon like lon.lon.
define shared variable s-gl like gl.gl.
define buffer bjl for jl.
def var vcash as log.
define var vdb as cha format "x(9)" label " ".
define var vcr as cha format "x(9)" label " ".
define var vdes  as cha format "x(32)" label " ". /* chart of account desc */
define var vname as cha format "x(30)" label " ". /* name of customer */
define var vrem as cha format "x(55)" extent 7 label " ".
define var vamt like jl.dam extent 7 label " ".
define var vext as cha format "x(40)" label " ".
define var vtot like jl.dam label " ".
define var vcontra as cha format "x(53)" extent 5 label " ".
define var vpoint as int.
define var inc as int.
define var tdes like gl.des.
define var tty as cha format "x(20)".
define var vconsol as log.
define var vcif as cha format "x(6)" label " ".
define var vofc like ofc.ofc label  " ".
def var vcrc like crc.code label " ".

def var xamt like fun.amt.
def var xdam like jl.dam.
def var xcam like jl.cam.
def var xco as char format "x(2)" label "".
def var vcha2 as cha format "x(50)".
def var vcha3 as cha format "x(50)".
def var vcha1 as cha format "x(65)".
def new shared var v-point like point.point.
define new shared variable s-longl as integer extent 20.
define variable v-gl like gl.gl.

define variable s-lon%gl   like gl.gl.
define variable s-sa%gl    like gl.gl.
define variable s-glsoda%  like gl.gl.
define variable pvn_debet  like gl.gl.
define variable pvn_kredit like gl.gl.
define variable gl-noform  like gl.gl.
define variable gl-atalg   like gl.gl.
define variable ok as logical.

{x-jlvou.f}

find jh where jh.jh eq s-jh.
find sysc where sysc.sysc = "CASHGL".
find lon where lon.lon = s-lon no-lock.
find gl where gl.gl = lon.gl no-lock.
v-gl = gl.gl1.

find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

run f-longl(lon.gl,"lon%gl,sa%gl,glsoda%,pvn_debet,pvn_kredit,gl-noform,gl-atalg",output ok).
if not ok
then do:
   bell.
   message lon.lon " - x-lonvou:"
   "longl не определен счет".
   pause.
   return.
end.

s-lon%gl   = s-longl[1].
s-sa%gl    = s-longl[2].
s-glsoda%  = s-longl[3].
pvn_debet  = s-longl[4].
pvn_kredit = s-longl[5].
gl-noform  = s-longl[6].
gl-atalg   = s-longl[7].

def var arp-gl like gl.gl.
find arp where arp.arp = "44" + string(lon.crc) + "LIZ" no-lock no-error.
if not available arp
then do:
   bell.
   message "Несуществующая АРП карточка" "44" + string(lon.crc) + "ЛИЗ".
   pause.
   return.
end.
arp-gl = arp.gl.

output to vou.img page-size 0.
put skip(3)
"=============================================================================="
skip vcha1 skip .
put point.addr[1] skip.
if point.addr[2] <> " " then put point.addr[2] skip.
if point.addr[3] <> " " then put point.addr[3] skip.
put point.regno skip point.licno skip.
put jh.jh " " jh.jdt " " string(time,"HH:MM") " "
jh.cif " " jh.party " * " jh.who skip.
put
"------------------------------------------------------------------------------"
skip.
vcash = false.
xdam = 0. xcam = 0.
for each jl of jh use-index jhln break by jl.crc by jl.ln:
    if jl.gl <> s-gl and jl.gl <> lon.gl and jl.gl <> v-gl and jl.gl <> s-lon%gl
    and jl.gl <> s-sa%gl and jl.gl <> s-glsoda% and jl.gl <> pvn_debet and
    jl.gl <> pvn_kredit and jl.gl <> gl-noform and jl.gl <> gl-atalg 
    and jl.gl <> arp-gl
    then next.
    find crc where crc.crc eq jl.crc.
    find gl of jl.
    if jl.gl = sysc.inval then vcash = true.
    if jl.dam ne 0 then do:
    xamt = jl.dam.
    xdam = xdam + jl.dam.
    xco  = "DR".
    end.
    else do:
    xamt = jl.cam.
    xcam = xcam + jl.cam.
    xco = "CR".
    end.
    disp jl.ln jl.gl gl.sname jl.acc
         crc.code xamt xco
         with down width 132 frame jlprt no-label no-box.
    if last-of(jl.crc) then do:
put vcha2 xdam crc.code skip vcha3
xcam crc.code skip.
    xcam = 0. xdam = 0. end.

end.
/*
if not ( trim(jh.party) matches "RM*G*" or
 trim(jh.party) matches "FX*G*"  ) then  */
 do:
put "--------------------------------------"
    "----------------------------------------" skip(0).
for each jl of jh where jl.ln = 1 use-index jhln break by jl.crc by jl.ln:
  if trim(jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5]) ne "" then
/*   put jl.ln " " jl.gl " " gl.sname skip(0). */
   do vi = 1 to 5 :
    if vi = 1 then do:
      def var ss as int.
      ss = 1.
      repeat:
        if (trim(substring(jl.rem[vi],ss,60)) ne "" ) then
        put "     " trim(substring(jl.rem[vi],ss,60)) format "x(60)" skip(0).
        else leave.
        ss = ss + 60.
      end.
    end.
    else
    if (trim(jl.rem[vi]) ne "" ) then
    put "     " trim(rem[vi]) format "x(70)" skip(0).
   end.
  end.
end.

if vcash = true then put skip(2).

else put "======================================"
         "================================================" skip(15).
output close.
unix silent prit -t vou.img.

if vcash = true then do:
   s-jh = jh.jh.
   run jl-prca.
end.
hide all.

pause 0.
