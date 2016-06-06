/* mes.p
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
	24/08/06 - suchkov - оптимизация
*/

def stream rpt.
def buffer b-jl for jl. 

def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var v-name as char no-undo.

def temp-table temp no-undo
  field dgl like gl.gl 
  field cgl like gl.gl 
  field acc like dfb.dfb
  field amt as decimal format 'zzz,zzz,zzz,zz9.99' 
  field crc like crc.code
  field bank as char
  index acc as primary acc dgl.



update dt1 label 'Задайте период. С '
       dt2 label ' ПО ' 
      with row 8 centered  side-label frame opt.
hide  frame opt.

 find first cmp no-lock no-error.

 display '   ЖДИТЕ...   '  with row 5 frame ww centered .

for each jl where (jl.gl = 560100 or jl.gl = 560800) and jl.jdt >= dt1 and jl.jdt <= dt2 and jl.dc = "d" no-lock .
  find first b-jl where b-jl.jh = jl.jh and b-jl.dc = 'c' no-lock no-error.
  if not available b-jl then next.
  if not (b-jl.gl  = 105210 or b-jl.gl = 105220 ) then next.

  if available b-jl then do: 
    find crc where crc.crc = jl.crc no-lock.
    create temp. 
    temp.cgl = b-jl.gl. temp.dgl = jl.gl. temp.amt = jl.dam.
    temp.acc = b-jl.acc.  temp.crc = crc.code.


  end.
end. 

output stream rpt to rpt.img.

  put stream rpt skip
  string( today, '99/99/9999' ) + ', ' +
  string( time, 'HH:MM:SS' ) + ', ' +
  trim( cmp.name ) format 'x(79)' at 02 skip(1).

put stream rpt  skip 'Расходы по зарубежным банкам-корреспондентам ' at 10 skip 
                     'за период с ' at 20 dt1  ' по ' dt2  skip.
put stream rpt  ' ' fill ('=',99) format 'x(99)' at 1.
put stream rpt skip 
'Лиц. счета         Наимен Банка                  Валюта      560100           560800        ИТОГО'.
   put stream rpt  ' ' fill ('=',99) format 'x(99)' at 1.


 for each temp break by temp.acc by temp.dgl   .
   ACCUMULATE temp.amt (total by  temp.dgl) .
   ACCUMULATE temp.amt (total by  temp.acc) .


   if first-of(temp.acc) then 
    do: 
    find last bankt where bankt.acc = temp.acc no-lock no-error.
    if available bankt then 
    do:
    find bankl where bankl.bank = bankt.cbank no-lock no-error.
    if available bankl then v-name = bankl.name. else v-name = "".
    end.
    put stream rpt skip temp.acc  at 1 ' ' v-name  format 'x(38)' at 12 ' '  temp.crc at 40 + 12.

   end.
   if last-of(temp.dgl) then 
  do:
  if temp.dgl = 560100 then
   put stream rpt  ACCUMulate 
     total  by (temp.dgl ) temp.amt format 'zzz,zz9.99'  at 47 + 12.
  else 
   put stream rpt  ACCUMulate 
     total  by (temp.dgl ) temp.amt  format 'zzz,zz9.99' at 64 + 12.
  end.

   if last-of(temp.acc) then 
   put stream rpt   ACCUMulate 
     total  by (temp.acc) temp.amt  format 'zz,zzz,zz9.99' at 75  + 12.
 end.

output stream rpt close.

hide frame ww no-pause.
run menu-prt('rpt.img').