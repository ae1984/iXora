/* r-fun.p
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
        30/10/2008 madiyar - перекомпиляция
*/

def stream rpt.
output stream rpt to rpt.img.

def var dt1 as date.
def var dt2 as date.
def var v-dat as date.

def temp-table temp 
     field acc as char
     field crc like crc.crc
     field rem as char
     field dam as decimal
     field cam as decimal
     field gl as integer.
     
    update dt1 label 'Введите нач дату ' 
           dt2 label 'Введите кон дату' .
           
for each fun where substr(fun,4,3) = '593' or substr(fun,4,3) =  '693' break by fun.fun.
 find gl where gl.gl = fun.gl  no-lock no-error.
 find trxlevgl where trxlevgl.gl = gl.gl and trxlevgl.lev = 11 no-lock no-error.
 find deal where deal.deal = fun.fun no-lock no-error. 
   for each jl where  jl.acc = fun.fun  no-lock use-index acc.
       if jl.jdt > dt2 then next.
       if jl.jdt < dt1 then next.
       if jl.acc <> fun.fun then next .
       if jl.gl <>  trxlevgl.glr then next .
       create temp. temp.acc = fun.fun. temp.rem = deal.rem[3].
       temp.crc = jl.crc. temp.gl = jl.gl. 
       temp.dam =  temp.dam + jl.dam.
       temp.cam = temp.cam + jl.cam.
   end.
  end. 
  for each temp break by temp.rem. 
   put stream rpt skip temp.acc  ' ' temp.crc ' '  temp.dam ' ' temp.cam 
       ' ' temp.gl format '999999' ' '  temp.rem. 
  end.
  output stream rpt close.
run menu-prt('rpt.img').   
