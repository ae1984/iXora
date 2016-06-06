/* oborot.p
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
 * BASES
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
   	01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
        15/08/06 u00600 - оптимизация
   	21/08/06 suchkov - исправлена ошибка

*/

{global.i new}
def stream m-out.
def var fdat as date format '99/99/9999' .
def var tdat as date format '99/99/9999'.
def var flg as int init 0.
def var ost_dam as deci decimals 2 format '->>>,>>>,>>9.99'.
def var ost_cam as deci decimals 2 format '->>>,>>>,>>9.99'.

def var v-crc like crc.code.

find last  cls no-lock no-error.
find first cmp no-lock no-error.
find first ofc where ofc.ofc = userid('bank') no-lock no-error.

g-today = if available cls then cls.cls + 1 else today.
fdat = g-today.
tdat = g-today.
/*
    update fdat label 'С ' 
           tdat label 'по ' 
           with side-label row 8 centered frame dat title 'Введите период: '.
*/           
    update fdat label 'С '
    validate(fdat <= g-today,"Должно быть: начало <= текущей даты ")                                  with frame dat.
    update tdat label 'по '
    validate(tdat >= fdat and tdat <= g-today,
        "Должно быть: начало периода <= конец периода <= текущей даты")
   with side-label row 8 centered frame dat title 'Введите период: '.          .
    hide frame dat.

display '   Ждите...   '  with row 5 frame ww centered .

output stream m-out to rpt.img.
put stream m-out skip
string( today, '99/99/9999' ) + ', ' +
string( time, 'HH:MM:SS' ) + ', ' +
trim( cmp.name )                  format 'x(79)' at 02 skip(1)
'ДВИЖЕНИЕ ПО СЧЕТАМ КЛИЕНТОВ'      format 'x(30)' at 29 skip
'                          '
'за период с ' string(fdat) ' по ' string(tdat) skip(1)
'Исполнитель: ' + trim( ofc.name )             format 'x(79)' at 02 skip.
put stream m-out ' ' fill( '-', 77 )           format 'x(77)'       skip.
put stream m-out
'Клиент'       at 02
'Счет'         at 35
'Дебет' at 50
'Кредит' at 65
'Валюта'       at 72

skip.
put stream m-out ' ' fill( '-', 77 ) format 'x(77)' skip(1).

for each cif no-lock :

  for each aaa where aaa.cif = cif.cif use-index cif no-lock.
     if aaa.sta = 'C' then next.
     if substring(string(aaa.gl),1,2) = '22' then do:

       ost_dam = 0.
       ost_cam = 0.  
       
   find first crc where crc.crc eq aaa.crc no-lock no-error.
   if avail crc then v-crc = crc.code.
   else v-crc = ''.

   for each jl where jl.acc = aaa.aaa and jl.gl = aaa.gl and (jl.jdt >= fdat and jl.jdt <= tdat) no-lock:
      ost_dam = ost_dam + dam.
      ost_cam = ost_cam + cam.
   end.
    
  if ost_dam = 0 and ost_cam = 0 then next .
  put stream m-out trim(trim(cif.prefix) + " " + trim(cif.name)) format 'x(30)' ' ' aaa.aaa ost_dam ost_cam '  ' v-crc skip.
   end.   
  
  end.
    
end. 
put stream m-out ' ' fill( '-', 77 ) format 'x(77)' skip(1).

output stream m-out close.
if not g-batch then do:
    pause 0 before-hide.
    run menu-prt( 'rpt.img' ).
    pause 0 no-message.
    pause before-hide.
end.              

