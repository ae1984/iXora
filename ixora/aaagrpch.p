/* aaagrpch.p
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
        05/09/2006 suchkov сделал новую прогу на основе lngrpch для текущих и депозитных счетов
*/

def var acc like aaa.aaa no-undo.
def var new_lgr as character no-undo.

def var old_lgr as character no-undo.
def var old_gl as int no-undo.
def var new_gl as integer no-undo.

def new shared var s-jh  like jh.jh .
def shared var g-today as date .
def var v-ln as int no-undo.

define var v-code as char no-undo.
define var v-dep as char format 'x(3)' no-undo.

def temp-table mktrx no-undo 
  field from_gl like gl.gl
  field to_gl like gl.gl
  field crc like crc.crc
  field level as int
  field amt as deci.

update acc label " Номер счета " validate (can-find(aaa no-lock where aaa.aaa = acc), " Cчет не найден ") skip
       new_lgr label " Новая группа " validate (can-find(lgr no-lock where lgr.lgr = new_lgr), " Некорректная группа ") skip
       with side-label row 5 centered frame fr.

find aaa where aaa.aaa = acc no-lock no-error.
if not avail aaa then return.
find lgr where lgr.lgr = new_lgr no-lock no-error.
if not avail lgr then return.

if aaa.lgr = new_lgr then do:
  message " Счет уже имеет указанную группу ".
  pause. return.
end.

old_lgr = aaa.lgr.
old_gl = aaa.gl.
new_gl = lgr.gl.

for each trxbal where trxbal.subled = 'cif' and trxbal.acc = acc no-lock:
    
    if trxbal.dam - trxbal.cam <> 0 then do:
      create mktrx.
      
      find trxlevgl where trxlevgl.gl = old_gl and trxlevgl.subled = 'cif' and trxlevgl.level = trxbal.level no-lock no-error.
      if not avail trxlevgl then do:
        message " gl-account for " old_gl ", cif level " trxbal.level ", is not set ".
        pause. return.
      end.
      else if trxlevgl.glr = 0 then do:
        message " gl-account for " old_gl ", cif level " trxbal.level ", is not set ".
        pause. return.
      end.
      mktrx.from_gl = trxlevgl.glr.
      
      find trxlevgl where trxlevgl.gl = new_gl and trxlevgl.subled = 'cif' and trxlevgl.level = trxbal.level no-lock no-error.
      if not avail trxlevgl then do:
        message " gl-account for " new_gl ", cif level " trxbal.level ", is not set ".
        pause. return.
      end.
      else if trxlevgl.glr = 0 then do:
        message " gl-account for " new_gl ", cif level " trxbal.level ", is not set ".
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
  
  find current aaa exclusive-lock.
  aaa.lgr = new_lgr.
  aaa.gl = new_gl.
  find current aaa no-lock.
  
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
         jl.sub = "CIF".
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
  aan.sub = 'cif'.
  aan.aaa = aaa.aaa.
  aan.crc = aaa.crc.
  aan.fdt = g-today.
  aan.glold = old_gl.
  aan.glnew = new_gl.
  aan.lgrold = string(old_lgr).
  aan.lgrnew = string(new_lgr).
  aan.rem = 'Со счет ' + aaa.aaa + ', перенос из группы ' + string(old_lgr) + ' в группу ' + string(new_lgr).
  
end. /* do transaction */

displ s-jh.

