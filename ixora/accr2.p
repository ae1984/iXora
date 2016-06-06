/* accr2.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Начисленные %% по депозитам
        Выводит отчет по начисленным %% по заданному счету
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-13-3
 * AUTHOR
        15.09.2003 nataly 
 * CHANGES
        24/09/03 nataly был добавлен вывод проводок по заданному счету
                             при пересчете начисленных %% в тенге брался курс 
                             на дату записи остатка в accr.fdt , а на за 
                              фактический ОД = v-dat
        19/01/04 nataly был доработан алгоритм расчета данных
        20/01/04 nataly при выводе данных за каждый день выдается v-dat
        22/01/04 nataly был добавлен вывод доп. информации по перносу счета с ГК на ГК, с одной lgr1 -> lgr2
        02.02.10 marinav - расширение поля счета до 20 знаков
*/

def var sum1 as decimal.
def var sum2 as decimal.
def var sum2lib as decimal.

def stream rpt.
def var v-dat as date.
def var dt1 as date.
def var dt2 as date.
def var v-aaa like aaa.aaa.
def var v-tek as decimal.
def var v-tekten as decimal.
def var v-tektenlib as decimal.
def var v-crc as char.
def var v-day as integer.
def var v-bal as decimal.

def temp-table temp2  
    field acc like aaa.aaa
    field jh as integer
    field crc as integer
    field jdt as date
    field dam  as decimal
    field cam  as decimal
    index iacc is primary acc.

update v-aaa  label 'Введите счет'  
       dt1 label  'Задайте период. С ...'
       dt2 label  'По' .
       find aaa where aaa.aaa = v-aaa no-lock no-error.
       if not avail aaa then do:
         message 'Счет ' v-aaa 'не найден!!!'. 
          undo,retry.
       end.         

find crc where crc.crc = aaa.crc no-lock no-error.          
v-crc = crc.code.
output  stream rpt to rpt1.img.
put stream rpt skip 'История переноса депозитного счета ' v-aaa  skip  'за период с ' at 10 dt1  ' по '  dt2.
         put stream rpt skip fill ('-',110) format 'x(100)'.
         put stream rpt skip 'Счет      Старый ГК  Новый ГК  Дата   Старая гр   Новая гр  '.

        find aan where aan.aaa = v-aaa no-lock no-error.
        if avail aan then 
        put stream rpt skip  v-aaa  '   '  aan.glold  '    ' aan.glnew  '  '  aan.fdt  '   ' aan.lgrold '     ' aan.lgrnew.
        put stream rpt skip fill ('-',110) format 'x(100)' skip(1).

 
 put stream rpt skip 'История начисления %% по депозитному счету '  v-aaa skip  'за период с ' at 10 dt1  ' по '  dt2.
 put stream rpt skip fill ('-',110) format 'x(100)'.
 put stream rpt skip 'Счет              Вал  Сумма осн долга  %% ставка  Дата      Нач %%(вал)      Нач %% (тенге)  Нач %% по либор'.
 put stream rpt skip fill ('-',110) format 'x(100)'.
/* нахождение ставки либор или рефинансирования  - не менять */
def buffer d-aab  for aab.
def var z123 as decimal.
def var coef as decimal init 2.0.
def var v-prd as integer.
def buffer d-aaa for aaa.

  find first d-aab where d-aab.aaa = aaa.aaa  and d-aab.bal > 0 no-lock no-error.
  if available d-aab then do:

       if aaa.crc =  1   then do:
        find  last taxrate where taxrate.taxrate = 'rfn' and  
          taxrate.regdt <= d-aab.fdt  no-lock no-error.
         z123 = taxrate.val[12].
       end.  /*aaa.crc =  1*/
       else do:
        if aaa.gl = 221130 
        then do:
         find d-aaa where d-aaa.aaa = aaa.cracc no-lock no-error.
         v-prd = truncate((d-aaa.expdt - d-aaa.regdt ) / 30,0) . 
        end.
        else do:  
         v-prd = truncate((aaa.expdt - aaa.regdt ) / 30,0) .
        end.
         if v-prd > 12 or v-prd = ? then v-prd = 12.  
         if v-prd <= 0  then v-prd = 1.
         
         find  last taxrate where taxrate.taxrate = 'lbr' and  
         taxrate.regdt <= d-aab.fdt  no-lock no-error.
        if available taxrate  and v-prd <> ? then  z123 = taxrate.val[v-prd].
                                             else  z123 = 0.
         
       end. /*aaa.crc <> 1 */   

       if z123 = 0 then  do:
        message 'Не задана ставка либор для счета ' aaa.aaa  'дата открытия '  d-aab.fdt ' период ' v-prd .   pause 200.
        end.
  end.  /*if avail d-aab*/

   coef = 2.
   do v-dat = dt1 to dt2.
      find last aab where aab.aaa = aaa.aaa and aab.fdt <= v-dat  no-lock no-error.
      if available aab then do: 
          v-bal = aab.bal.
          find last crchis where crchis.crc = aaa.crc and crchis.rdt  <= v-dat no-lock.

          find cls where cls.whn = v-dat no-lock no-error.
          if available cls then do:
             find last accr where accr.aaa = v-aaa and accr.fdt = cls.whn  use-index aaa  no-lock no-error. 
             if available accr then  do: 
                v-tek = accr.accrued.
                v-tekten = v-tek * crchis.rate[1].
             end.
             else do: v-tek = 0.  v-tekten = 0. v-tektenlib = 0. end.
          end.
          else do: v-tek = 0 . v-tekten = 0. /* v-tektenlib = 0 .*/ end.

          v-tektenlib =  v-bal * coef * z123 / aaa.base / 100 * crchis.rate[1] .

          put stream rpt skip  aaa.aaa v-crc format 'x(3)'  v-bal format 'z,zzz,zzz,zz9.99' aab.rate format 'zzzz9.99' ' ' v-dat 
                               v-tek format 'zzz,zzz,zz9.99' at 60  v-tekten format 'zzz,zzz,zzz,zz9.99' v-tektenlib  format 'zzz,zzz,zzz,zz9.99'.
          sum1 = sum1 + v-tek. sum2 = sum2  + v-tekten.

          /*вычисление суммы по либор*/
          sum2lib = sum2lib + v-tektenlib.
      end. /*if avail aab*/
   end. /*v-dat*/                              

   put stream rpt skip fill ('-',110) format 'x(110)'.               
   put stream rpt skip 'ИТОГО ' at 40  sum1 format 'zzz,zzz,zz9.99' at 60 sum2  format 'zzz,zzz,zzz,zz9.99'  sum2lib  format 'zzz,zzz,zzz,zz9.99' skip(1).

/*учет всех проводок 24/09/03 nataly*/
def var v-dam as decimal.
def var v-cam as decimal.
def var v-jl as decimal.

   find gl where gl.gl = aaa.gl no-lock no-error.
  find trxlevgl where trxlevgl.gl = gl.gl and 
   trxlevgl.subled = 'cif' and trxlevgl.lev = 11 no-lock no-error. 

   for each jl where jl.acc = v-aaa 
    and jl.jdt >= dt1 and jl.jdt <= dt2 
    and jl.gl = trxlevgl.glr no-lock.
  if   jl.who <> 'bankadm' and jl.jdt <> 11/01/02  
  then do:
    create  temp2. 
     temp2.acc = aaa.aaa. temp2.jh = jl.jh.  temp2.crc = jl.crc.
     temp2.jdt = jl.jdt.
    if jl.crc <> 1 
    then do: 
      find last crchis where crchis.crc = jl.crc 
      and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.
      temp2.dam = jl.dam * crchis.rate[1].  
      temp2.cam = jl.cam * crchis.rate[1].
    end.
    else do:
     temp2.dam = jl.dam.  temp2.cam = jl.cam.  
    end.
   end.
   end. /*jl*/

put stream rpt skip 'N проводки     Дата      Счет                     Дебет           Кредит           Сальдо  '.
   for each temp2 where temp2.acc = aaa.aaa break by temp2.acc.
     accum temp2.dam  (total by temp2.acc ).
     accum temp2.cam  (total by temp2.acc ).
  put stream rpt skip temp2.jh  format 'zzzzzzzz' '    ' temp2.jdt '   '  temp2.acc 
       temp2.dam format 'zzz,zzz,zz9.99' at 43 
       temp2.cam format 'zzz,zzz,zz9.99' at  61.
    if last-of(temp2.acc) then  do: 
     v-dam = ACCUMulate total  by (temp2.acc) temp2.dam.   
     v-cam = ACCUMulate total  by (temp2.acc) temp2.cam.   
    end.
   end.
       v-jl = v-dam - v-cam. /*итоговая сумма проводок, тк счет активный */

/* 15.01.04 nataly корректировка суммы по либор по пропорции*/
   if v-jl  + sum2 <> 0 then
   sum2lib = (sum2 + v-jl) * sum2lib / sum2.


put stream rpt skip fill ('-',110) format 'x(110)'.
put stream rpt skip 'ИТОГО ' at 40 v-jl format 'zzz,zzz,zz9.99-' at 65.
put stream rpt skip 'ИТОГО начислено в тенге ' at 40 v-jl + sum2 format 'zzz,zzz,zz9.99-' at 65  
                                                        sum2lib  format 'zzz,zzz,zzz,zz9.99' skip(1).

/*24/09/03 nataly*/
  output stream rpt close .
  hide all.
  run menu-prt('rpt1.img').

