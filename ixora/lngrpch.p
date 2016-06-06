/* lngrpch.p
 * MODULE
        Изменение группы кредита
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
        11/11/2004 madiar
 * CHANGES
        19.04.2005 nataly добавлено автоматическое проставление кодов расходов/доходов {cods.i}
        22/04/2005 madiar создание записи в таблице aan
        10/03/2006 madiar мелкие изменения
*/

def var acc like lon.lon.
def var new_grp as int.

def var old_grp as int.
def var old_gl as int.
def var new_gl as int.

def new shared var s-jh  like jh.jh.
def shared var g-today as date.
def var v-ln as int.

define var v-code as char.
define var v-dep as char format 'x(3)'.

def temp-table mktrx
  field from_gl like gl.gl
  field to_gl like gl.gl
  field crc like crc.crc
  field level as int
  field amt as deci.

update acc label " Ссудный счет " validate (can-find(lon no-lock where lon.lon = acc), " Ссудный счет не найден ") skip
       new_grp label " Новая группа " validate (can-find(longrp no-lock where longrp.longrp = new_grp), " Некорректная группа ") skip
       with side-label row 5 centered frame fr.

find lon where lon.lon = acc no-lock no-error.
if not avail lon then return.
find longrp where longrp.longrp = new_grp no-lock no-error.
if not avail longrp then return.

if lon.grp = new_grp then do:
  message " Кредит уже имеет указанную группу ".
  pause. return.
end.

old_grp = lon.grp.
old_gl = lon.gl.
new_gl = longrp.gl.

for each trxbal where trxbal.subled = 'lon' and trxbal.acc = acc no-lock:
    
    if trxbal.dam - trxbal.cam <> 0 then do:
      create mktrx.
      
      find trxlevgl where trxlevgl.gl = old_gl and trxlevgl.subled = 'lon' and trxlevgl.level = trxbal.level no-lock no-error.
      if not avail trxlevgl then do:
        message " gl-account for " old_gl ", lon level " trxbal.level ", is not set ".
        pause. return.
      end.
      else if trxlevgl.glr = 0 then do:
        message " gl-account for " old_gl ", lon level " trxbal.level ", is not set ".
        pause. return.
      end.
      mktrx.from_gl = trxlevgl.glr.
      
      find trxlevgl where trxlevgl.gl = new_gl and trxlevgl.subled = 'lon' and trxlevgl.level = trxbal.level no-lock no-error.
      if not avail trxlevgl then do:
        message " gl-account for " new_gl ", lon level " trxbal.level ", is not set ".
        pause. return.
      end.
      else if trxlevgl.glr = 0 then do:
        message " gl-account for " new_gl ", lon level " trxbal.level ", is not set ".
        pause. return.
      end.
      mktrx.to_gl = trxlevgl.glr.
      
      mktrx.crc = trxbal.crc.
      mktrx.level = trxbal.level.
      mktrx.amt = trxbal.dam - trxbal.cam.
      
    end.
    
end. /* for each trxbal */

def stream rep.
output stream rep to rpt.txt.
for each mktrx no-lock:
  find crc where crc.crc = mktrx.crc no-lock no-error.
  if not avail crc then return.
  put stream rep unformatted mktrx.from_gl " " mktrx.to_gl " " crc.code " " mktrx.level format ">9" mktrx.amt format "->>>,>>>,>>>,>>>,>>9.99" skip.
end.
output stream rep close.
run menu-prt("rpt.txt").
pause.

for each mktrx:
  if mktrx.from_gl = mktrx.to_gl then delete mktrx. /* удалить запись если счета ГК одни и те же */
end.

do transaction on error undo,leave:

  run x-jhnew.
  pause 0.
  find jh  exclusive-lock where jh.jh = s-jh no-error.
  if not avail jh then return. 
  jh.crc = 0.
  jh.party = "GL CORRECTION TRANSACTION".
  jh.jdt = g-today.
  
  find current lon exclusive-lock.
  lon.grp = new_grp.
  lon.gl = new_gl.
  find current lon no-lock.
  
  v-ln = 1.
  for each mktrx no-lock:
    
         create jl.
         jl.jh = jh.jh.
         jl.ln = v-ln.
         jl.crc = mktrx.crc.
         jl.who = jh.who.
         jl.jdt = jh.jdt.
         jl.whn = jh.whn.   
         jl.dc = "D".
         jl.sub = "LON".
/*         jl.lev = 16. 	*/
         jl.acc = "".
         jl.rem[1] = "GL CORRECTION TRANSACTION".
         if mktrx.amt > 0 then do:
           jl.dam = mktrx.amt.
           jl.gl = mktrx.to_gl.
         end.
         else do:
           jl.dam = - mktrx.amt.
           jl.gl = mktrx.from_gl.
         end.
         jl.cam = 0.
         
        {cods.i}
         v-ln = v-ln + 1.

         create jl.
         jl.jh = jh.jh.
         jl.ln = v-ln.
         jl.crc = mktrx.crc.
         jl.who = jh.who.
         jl.jdt = jh.jdt.
         jl.whn = jh.whn.
         jl.dc = "C".
         jl.acc = "".
         jl.rem = "GL CORRECTION TRANSACTION".
         if mktrx.amt > 0 then do:
           jl.cam = mktrx.amt.
           jl.gl = mktrx.from_gl.
         end.
         else do:
           jl.cam = - mktrx.amt.
           jl.gl = mktrx.to_gl.
         end.
         jl.dam = 0.
         
        {cods.i}
         v-ln = v-ln + 1.
         
  end. /* for each mktrx */
  
  create aan.
  aan.sub = 'lon'.
  aan.aaa = lon.lon.
  aan.crc = lon.crc.
  aan.fdt = g-today.
  aan.glold = old_gl.
  aan.glnew = new_gl.
  aan.lgrold = string(old_grp).
  aan.lgrnew = string(new_grp).
  aan.rem = 'Сс счет ' + lon.lon + ', перенос из группы ' + string(old_grp) + ' в группу ' + string(new_grp).
  
end. /* do transaction */

displ s-jh.

