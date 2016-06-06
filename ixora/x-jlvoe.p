/* x-jlvoe.p
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

/* x-jlvou.p
*/

{global.i}

def var vi as int.
define  shared   var s-jh like jh.jh .
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
def var vcha1 as cha format "x(50)".
{x-jlvou.f}

find jh where jh.jh eq s-jh.
find sysc where sysc.sysc = "CASHGL".

output to vou.img page-size 0.
put skip(3)
"=============================================================================="
skip vcha1 skip .
put jh.jh " " jh.jdt " " string(time,"HH:MM") " "
jh.cif " " jh.party " * " jh.who skip.
put
"------------------------------------------------------------------------------"
skip.
vcash = false.
xdam = 0. xcam = 0.
for each jl of jh use-index jhln break by jl.crc by jl.ln:
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
for each jl of jh where jl.ln = 1 break by jl.crc by jl.ln:
  if trim(jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5]) ne "" then
/*   put jl.ln " " jl.gl " " gl.sname skip(0). */
   do vi = 1 to 5 :
    if (trim(jl.rem[vi]) ne "" ) then
    put "     " trim(rem[vi]) format "x(70)" skip(0).
   end.
  end.
end.

if vcash = true then put skip.

else put "======================================"
	 "================================================" skip(15).
output close.

unix silent prit vou.img.


/*
if vcash = true then do:
   s-jh = jh.jh.
   run jl-prca.
end.
*/
/*hide all.

pause 0.   */
