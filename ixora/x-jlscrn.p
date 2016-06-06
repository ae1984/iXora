/* x-jlscrn.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* x-jlscrn.p

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
*/

{global.i}

define input parameter kuda_vivodim as character.
define input parameter doc_num      as character.

define variable ss as integer.

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
def var vcha1 as cha format "x(65)".
def new shared var v-point like point.point.
{x-jlvou.f}

define new shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

find jh where jh.jh eq s-jh.
find sysc where sysc.sysc = "CASHGL".

find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

output to vou1.img page-size 0.
put skip(3)
"=============================================================================="
skip vcha1 skip .
put point.addr[1] skip.
if point.addr[2] <> " " then put point.addr[2] skip.
if point.addr[3] <> " " then put point.addr[3] skip.
put point.regno skip point.licno space(14) "Документ N " doc_num skip.
put jh.jh " " jh.jdt " " string(time,"HH:MM") " "
jh.cif " " jh.party " * " jh.who skip.
put
"------------------------------------------------------------------------------"
skip.
vcash = false.
xdam = 0. xcam = 0.

for each jl of jh use-index jhln break by jl.crc by jl.ln:
   find crc where crc.crc eq jl.crc no-lock.
   find gl of jl no-lock.
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
   
   disp jl.ln jl.gl gl.sname jl.acc crc.code xamt xco
         with down width 132 frame jlprt no-label no-box.
   
   if last-of(jl.crc) then do:
      put vcha2 xdam crc.code skip vcha3 xcam crc.code skip.
      xcam = 0. xdam = 0. 
   end.
   
   if jl.subled eq "arp" then do:
      find first wf where wf.wsub eq "arp" and wf.wacc eq jl.acc no-error. 
      if not available wf then do:
         create wf.
         wf.wsub = "arp".
         wf.wacc = jl.acc.
      end.
   end.
   else if jl.subled eq "cif" then do:
      find first wf where wf.wsub eq "cif" and wf.wacc eq jl.acc no-error.
      if not available wf then do:
         find aaa where aaa.aaa eq jl.acc no-lock.
         create wf.
         wf.wsub = "cif".
         wf.wacc = jl.acc.
         wf.wcif = aaa.cif.
      end.
   end.
end.

 
DO:

put "--------------------------------------"
    "----------------------------------------" skip(0).

for each jl of jh where jl.ln = 1 use-index jhln break by jl.crc by jl.ln:
   if trim(jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5]) ne "" then
      do vi = 1 to 5 :
    
      if vi = 1 then do:
         ss = 1.
         repeat:
            if (trim(substring(jl.rem[vi],ss,60)) ne "" ) then
              put "     " trim(substring(jl.rem[vi],ss,60)) format "x(60)"                                                                  skip(0).
            else leave.
            ss = ss + 60.
         end.       
      
         /* arp ili cif */
         for each wf:
            if wf.wsub eq "cif" then do:
               find cif where cif.cif eq wf.wcif no-lock.
               put unformatted "     " wf.wacc " " 
                  trim(trim(cif.prefix) + " " + trim(cif.name)) " " cif.jss skip.
            end.
            else if wf.wsub eq "arp" then do:
               find arp where arp.arp eq wf.wacc no-lock.
               find sub-cod where sub-cod.d-cod eq "arprnn" and
                              sub-cod.acc eq wf.wacc no-lock no-error.
               if available sub-cod then put unformatted
                  "     " wf.wacc " " arp.des " " sub-cod.rcode skip.
               else put unformatted "     " wf.wacc " " arp.des skip.
            end.
         end.
      end.
      else if (trim(jl.rem[vi]) ne "" ) then
                   put "     " trim(jl.rem[vi]) format "x(70)" skip(0).
   end.
   else do:
      /* arp ili cif */
      for each wf:
         if wf.wsub eq "cif" then do:
            find cif where cif.cif eq wf.wcif no-lock.
            put unformatted "     " wf.wacc " " 
               trim(trim(cif.prefix) + " " + trim(cif.name)) " " cif.jss skip.
         end.
         else if wf.wsub eq "arp" then do:
            find arp where arp.arp eq wf.wacc no-lock.
            find sub-cod where sub-cod.d-cod eq "arprnn" and
                                 sub-cod.acc eq wf.wacc no-lock no-error.
            if available sub-cod then put unformatted
               "     " wf.wacc " " arp.des " " sub-cod.rcode skip.
            else put unformatted "     " wf.wacc " " arp.des skip.
         end.
      end.
   end.
end.

END.

if vcash = true then put skip(2).

else put "======================================"
         "================================================" skip(2).
pause 0.
output close.

/*unix silent value ( kuda_vivodim + " vou.img").
pause 0.*/

if vcash = true then do:
   s-jh = jh.jh.
   run jl-screen (input kuda_vivodim, doc_num).
end.
/*hide all.*/


output to vou3.img page-size 0.

put 
"Клиент ................ Менеджер ................ Контролер ................"
skip(1).

put 
"Кассир ................" skip(1).

output close.


if vcash = true then do:
   unix silent cat vou1.img vou2.img vou3.img >vou.img.  end.
else do:
   unix silent cat vou1.img vou3.img >vou.img.   end.
   
if kuda_vivodim eq "prit" then do:
   unix silent value (kuda_vivodim + " vou.img").   end.
else do:
   unix value (kuda_vivodim + " vou.img").   end.


