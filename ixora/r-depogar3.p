/* r-depogar1.p
 * MODULE
        Отчет по фонду гарантирования вкладов
 * DESCRIPTION
        Отчет по фонду гарантирования вкладов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        r-depogar1.p 
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM TXB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        07/10/03 nataly отчет доработан в связи с изменениями, высланными НБ РК от 04.07.04
        12/01/04 nataly были внесены изменения в соот-вии с новым ПС
        14/01/04 nataly был доработан отчет по %% ставкам по депозитам
        29/03/08 marinav - изменения отчетности
        27/04/09 marinav - изменения суммы до 5 млн  
*/

def  shared temp-table vdepo2
    field nm as char 
    field srok as int
    field crc as integer
    field rate as decimal
    field garant as logical
    field sum1 as decimal format 'zz9.99'
    field sum2 as decimal format 'zz9.99'.

def  shared var m-kvar as integer.
def  shared var m-year as integer.
def buffer b-crchis for txb.crchis.
def var sum as decimal.

def var dt1 as date.
def var dt2 as date.
def var v-dat as date.
/*v-dat = date(month(g-today),1,year(g-today)).
  */
if m-kvar = 1       then do: dt1 = date(1,1,m-year). dt2 = date(1,31,m-year). end.
else if m-kvar = 2  then do: dt1 = date(2,1,m-year). dt2 = date(2,28,m-year). end.
else if m-kvar = 3  then do: dt1 = date(3,1,m-year). dt2 = date(3,31,m-year). end.
else if m-kvar = 4  then do: dt1 = date(4,1,m-year). dt2 = date(4,30,m-year). end.
else if m-kvar = 5  then do: dt1 = date(5,1,m-year). dt2 = date(5,31,m-year). end.
else if m-kvar = 6  then do: dt1 = date(6,1,m-year). dt2 = date(6,30,m-year). end.
else if m-kvar = 7  then do: dt1 = date(7,1,m-year). dt2 = date(7,31,m-year). end.
else if m-kvar = 8  then do: dt1 = date(8,1,m-year). dt2 = date(8,31,m-year). end.
else if m-kvar = 9  then do: dt1 = date(9,1,m-year). dt2 = date(9,30,m-year). end.
else if m-kvar = 10 then do: dt1 = date(10,1,m-year). dt2 = date(10,31,m-year). end.
else if m-kvar = 11 then do: dt1 = date(11,1,m-year). dt2 = date(11,30,m-year). end.
else if m-kvar = 12 then do: dt1 = date(12,1,m-year). dt2 = date(12,31,m-year). end.

do v-dat = dt1 to dt2:

for each txb.jl  no-lock where txb.jl.jdt = v-dat. 
  if dc = 'd' then next.
  if txb.jl.acc = "" then next.
  find txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
  if not avail txb.aaa then next.

   if txb.jl.gl = 220620 or txb.jl.gl = 220720      then do:
      create vdepo2. 
      if txb.jl.crc = 1 then vdepo2.crc = 1. else vdepo2.crc = 2.
      vdepo2.rate = txb.aaa.rate. 
      if truncate((txb.aaa.expdt  - txb.aaa.regdt) / 30,0) <= 6 then vdepo2.srok = 1.
        else if truncate((txb.aaa.expdt  - txb.aaa.regdt) / 30,0) <= 12 then vdepo2.srok = 2.
         else  if truncate((txb.aaa.expdt  - txb.aaa.regdt) / 30,0) <= 36 then vdepo2.srok = 3.
          else if truncate((txb.aaa.expdt  - txb.aaa.regdt) / 30,0) > 36 then vdepo2.srok = 4.
       vdepo2.garant = true.
       vdepo2.sum1 = txb.jl.cam.
   end.
   else if txb.jl.gl = 220820 then do:
      create vdepo2. 
        if  txb.jl.crc = 1 then vdepo2.crc = 1. else vdepo2.crc = 2.
        vdepo2.rate = txb.aaa.rate. 
        vdepo2.srok = 5.
        vdepo2.garant = true.
        vdepo2.sum1 = txb.jl.cam.
   end.
   else if txb.jl.gl = 220520  then do:
      create vdepo2. 
        if txb.jl.crc = 1 then vdepo2.crc = 1. else vdepo2.crc = 2.
        vdepo2.rate = txb.aaa.rate. 
        vdepo2.srok = 6.
        vdepo2.garant = true. 
        vdepo2.sum1 = txb.jl.cam.
   end.
   else if txb.jl.gl = 220420 then do:
      create vdepo2. 
        if txb.jl.crc = 1 then vdepo2.crc = 1. else vdepo2.crc = 2.
        vdepo2.rate = txb.aaa.rate. 
        vdepo2.srok = 7.
        vdepo2.garant = true. 
        vdepo2.sum1 = txb.jl.cam.
   end.
   else if txb.jl.gl = 220920  then do:
      create vdepo2. 
        if txb.jl.crc = 1 then vdepo2.crc = 1. else vdepo2.crc = 2.
        vdepo2.rate = txb.aaa.rate. 
        vdepo2.srok = 8.
        vdepo2.garant = true. 
        vdepo2.sum1 = txb.jl.cam.
   end.

end.  /*jl*/

end.  /*v-dat*/
