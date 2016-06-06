/* x-jlvouPl.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

/* x-jlvou.p
*/

{global.i}

def var vi as int.
define  shared   var s-jh like jh.jh .
define  shared   var s-remtrz like remtrz.remtrz.
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
def var svc5 like rem.svc.

def var xamt like fun.amt.
def var xdam like jl.dam.
def var xcam like jl.cam.
def var xco as char format "x(2)" label "".
def var vcha2 as cha format "x(50)".
def var vcha3 as cha format "x(50)".
def var vcha1 as cha format "x(65)".
def var vcha4 as cha format "x(65)".
def new shared var v-point like point.point.
def var v-pakal like tarif2.pakal.
{x-jlvou1.f}

find jh where jh.jh eq s-jh.
find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
if available remtrz then do:
svc5 = remtrz.svca.

find crc where crc.crc = remtrz.svcrc no-lock no-error.
if not available crc then 
   find crc where crc.crc = 1 no-lock no-error.

find tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error.
if available tarif2 then v-pakal = tarif2.pakalp.
end.
/*
else  do :
find brem where brem.rem = s-rem no-lock no-error.
if available brem then do:
svc5 = brem.svc.
find crc where crc.crc = brem.crc1 no-lock no-error.

find tarif2 where tarif2.str5 = substring(brem.tcby,1,4) no-lock no-error.
if available tarif2 then v-pakal = tarif2.pakalp.

 end.
end.
*/
find sysc where sysc.sysc = "CASHGL" no-lock.

find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

output to vou.img page-size 0.
put skip(10)
vcha4 skip(1) .
put
"=============================================================================="
skip vcha1 skip .
put  jh.jdt " " string(time,"HH:MM") "     "
jh.party " * " jh.who skip(1).
/*
put "Комиссия: "   svc5 " " crc.code "     " v-pakal format "x(33)" skip(1).
*/
put
"------------------------------------------------------------------------------"
skip.
put skip(5).
output close.
unix silent prit /* -t */ vou.img.

hide all.

pause 0.
