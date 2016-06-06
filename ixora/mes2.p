/* mes2.p
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

/* 06/06/03 отчет по доходам за  внешние переводы в валюте за период 
            (комиссия 204,205,208,209) */
def stream rpt.
def buffer b-jl for jl. 

def var dt1 as date.
def var dt2 as date.
def var v-dat as date.
def var v-name as char.

def temp-table temp
  field dgl like gl.gl 
  field cgl like gl.gl 
  field acc like dfb.dfb
  field amt as decimal format 'zzz,zzz,zzz,zz9.99' 
  field crc like crc.code
  field bank as char.

output stream rpt to rpt.img.

update dt1 label 'Задайте период. С '
       dt2 label ' ПО ' 
      with row 8 centered  side-label frame opt.
hide  frame opt.

 find first cmp no-lock no-error.

 display '   ЖДИТЕ...   '  with row 5 frame ww centered .
  put stream rpt skip
  string( today, '99/99/9999' ) + ', ' +
  string( time, 'HH:MM:SS' ) + ', ' +
  trim( cmp.name ) format 'x(79)' at 02 skip(1).

do v-dat = dt1 to dt2:
for each jl no-lock  where jl.jdt = v-dat use-index  jdt.
  if not (jl.gl = 460111 or jl.gl = 460122) then next.
 if ( jl.dc <> 'c' ) then next.
  find jh where jh.jh = jl.jh no-lock no-error.

  if jh.sub = 'cif' or jh.sub = 'jou' 
  then do:
  find joudoc where joudoc.whn = jl.jdt and joudoc.jh = jl.jh no-lock no-error.
  if avail joudoc and (joudoc.comcode = '204' or joudoc.comcode = '205' or
    joudoc.comcode = '208' or joudoc.comcode = '209') 
  then do:
    find crc where crc.crc = jl.crc no-lock.

    create temp. 
    temp.cgl = jl.gl. temp.amt = jl.cam.
    temp.crc = crc.code.                

  end.
  end. /*jou/cif*/

  if jh.sub = 'rmz' then do: 
  find remtrz where remtrz.rdt = jl.jdt and  remtrz.jh1 = jl.jh no-lock no-error.
  if avail remtrz and (string(remtrz.svccgr) = '204' or  string(remtrz.svccgr) = '205' or
    string(remtrz.svccgr) = '208' or string(remtrz.svccgr) = '209') 
  then do:

    find crc where crc.crc = jl.crc no-lock.

    create temp. 
    temp.cgl = jl.gl. temp.amt = jl.cam.
    temp.crc = crc.code.                

  end.  
 end. /*rmz*/
end.  /*jl*/
end.   /*v-dat*/

put stream rpt  skip 'Доходы , полученные от зарубежных переводов' at 10 skip 
        ' (комиссия 204, 205, 208, 209) ' at 15 skip 
                     'за период с ' at 15 dt1  ' по ' dt2  skip.
put stream rpt  ' ' fill ('=',99) format 'x(99)' at 1.
put stream rpt skip 
'ГК          Валюта      '.
   put stream rpt  ' ' fill ('=',99) format 'x(99)' at 1.


 for each temp break by temp.acc by temp.cgl by temp.crc   .
   ACCUMULATE temp.amt (total by  temp.crc by  temp.cgl) .


   if first-of(temp.cgl) then 
   put stream rpt   skip "ГК " temp.cgl.
 
  if last-of(temp.crc) then do: 
   put stream rpt skip  temp.crc at 15 ACCUMulate 
     total  by (temp.cgl ) temp.amt format 'zzz,zz9.99'  at 27 + 12.
   end.

/*   if last-of(temp.cgl) then 
   put stream rpt  ACCUMulate 
     total  by (temp.cgl ) temp.amt format 'zzz,zz9.99'  at 37 + 12.
  */

 end.

output stream rpt close.

hide frame ww no-pause.
run menu-prt('rpt.img').