/* r-cltdoc.p
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

{mainhead.i}
def var v-text as char format "x(50)".
def var ddat as date label "ДАТА    ".
def new shared var s-datt as date.
def var vvans as logi initial false format "да/нет".
def var otv as log init false.
def var sumo as int format "zzz,zzz,zzz,zzz,zzz.99".
def var sumi as int format "zzz,zzz,zzz,zzz,zzz.99".
def var comprt as cha initial "prit  " format "x(10)" .
def var v-new as log  format "создать/продожить"  initial "Создать".

def new shared temp-table roree
    field remtrz as char format "x(10)"
    field cwho as char format "x(8)"
    field racc as char format "x(10)"
    field jh1 like remtrz.jh1
    field jh2 like remtrz.jh2
    field amt as deci index iroree amt.

def var lbnstr as char.    
def var n-ofc as char format "x(30)".
    
 update ddat skip
       comprt label  "Команда " skip
       v-new label "Создать(с)/продожить(п)"
 with side-label row 5 centered frame ans.


find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if not avail sysc then
do:
   v-text  =  " Нет LBNSTR записи в sysc файле ! ".
   message v-text. pause.
   return.
end.
lbnstr = trim(sysc.chval) .

for each clrdoc where clrdoc.rdt = ddat no-lock :
  find first remtrz where remtrz.remtrz = clrdoc.rem no-lock no-error.
  if avail remtrz then do :
    create roree.
    roree.remtrz = remtrz.remtrz.
    roree.cwho = remtrz.cwho.
    roree.amt = remtrz.payment.
    roree.jh1 = remtrz.jh1.
    roree.jh2 = remtrz.jh2.
  end.
end.

output to rpt.img.
  put space(10) 
  '  Ведомость платежных документов по контролерам' skip
     space(30) 'за ' ddat skip(1)
     ' Платеж         Сумма      1Проводка    2Проводка   ' skip
     "_____________________________________________________" skip(1).
  
  for each roree break by roree.cwho by roree.amt .
   if first-of(roree.cwho) then do  :   
     find first ofc where ofc.ofc = roree.cwho no-lock no-error.
     if avail ofc then n-ofc = trim(ofc.name).
     else n-ofc = ''.
     put "Пользователь   " roree.cwho space(2) n-ofc skip(1).
   end.   
     put roree.remtrz space(4) 
         roree.amt space(4) roree.jh1 space(4) roree.jh2 space(4) skip.
     accum roree.amt (total by roree.cwho).
     accum roree.amt (total ).
     if last-of(roree.cwho) then do :
       put 'Итого по пользователю  ' accum total by roree.cwho roree.amt 
        format "zzz,zzz,zzz,zzz.99" skip(1).
     end.
  end.
  put 'Итого  ' accum total roree.amt format "zzz,zzz,zzz,zzz.99" skip(2).
  output close.
  unix silent value(comprt) rpt.img.
  pause 0.

