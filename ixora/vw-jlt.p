/* vw-jlt.p
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
        15/08/2006 u00600 - оптимизация
*/

def shared var g-today as date.
def var i1 as cha format "x(1)".
def var i as int.
def var lh like jl.jh.
def var v-ofc like ofc.ofc.
def var v-crc like crc.crc.


def var v-gl like gl.gl.
def var datn as date.
def var datk as date.
def var amtn like jl.dam.
def var amtk like jl.dam.

def shared var g-ofc like ofc.ofc.
def var bbb like jl.dam.
def var nobal as cha format "x(3)".
def buffer b-jl for jl.

v-ofc = g-ofc.
v-crc = 0.
v-gl = 0.

datn = g-today.
datk = g-today.
amtn = -9999999999999.99.
amtk =  9999999999999.99.

repeat:
message " Press F2 for Help " .
update v-ofc label "Officer ? "
       v-gl label " (0-all)  G/L ? " v-crc label "(0-all) Curr ? "
      datn label "BegDat ? " datk label "EndDat ? "
      amtn label "BegAmt ? " amtk label "EndAmt ? "
  with 1 column centered row 6 frame eee.

hide frame eee.
if trim(v-ofc) = "" then v-ofc = "".
repeat :
 i = 0.
/*for each jl where jl.jdt >= datn and jl.jdt <= datk and jl.dam - jl.cam
   >= amtn and jl.dam - jl.cam  <= amtk
 and (jl.gl = v-gl or v-gl = 0 ) and ( jl.crc = v-crc or v-crc = 0)
 and (v-ofc = jl.who or v-ofc = "") no-lock
 by jh.   */

 for each jl where (jl.jdt >= datn and jl.jdt <= datk) and (jl.gl = v-gl or v-gl = 0 ) no-lock by jl.jh.
 if (jl.dam - jl.cam) >= amtn and (jl.dam - jl.cam) <= amtk then do: 
 if (jl.crc = v-crc or v-crc = 0) and (jl.who = v-ofc or v-ofc = "") then do: 

 find crc of jl no-lock.
 if lh <> jl.jh then do:
  find jh of jl.
  bbb = 0.
  if i1 = " " then i1 = chr(171).
  else i1 = " ".
  lh = jl.jh.
  for each b-jl of jh no-lock:
     bbb = bbb + b-jl.dam - b-jl.cam.
  end.
 end.
 i = i + 1.
if bbb <> 0 then nobal = "***" .
else nobal = "   ".
display i1 label " " jl.jh jl.who label "Teller" jl.sts label "STS"
 dam - cam format "z,zzz,zzz,zzz,zzz.99-" label "  Debit/Credit  " nobal
label "BAL"
jl.gl label " G/L " crc.cod
label "CRC" jl.acc skip .
 if i = 17 then do:
   i = 0.
   pause .
  end.

 end.
 end. /*if jl*/
 end. /*for each jl*/

if i = 0 and keyfunction(lastkey) <> "end-error" then
 display " No transaction today !!! " with centered row 12 frame aaa.
  pause .
 end.
end.
