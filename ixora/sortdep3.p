/* sortdep3.p
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
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/


def stream rpt.
def stream nur.
output stream rpt to rpt.img.
output  stream nur to rpt1.img.

def buffer bjl for jl.
def temp-table temp  /*workfile*/
    field aaa  like aaa.aaa
    field bal  as decimal
    field gl   as char 
    field prd as integer
    field crc like aaa.crc 
    field balrate as decimal 
    field rate  like aaa.rate.

def var v-prd as integer.
def var vgl as integer format 'zzzz'.
def var vdt as date.
def var vcrc as char.
def var strvgl as character.
def button  btn1  label "СУММА ОСНОВНОГО ДОЛГА".
   def button  btn2  label "СУММА ОСНОВНОГО ДОЛГА C %%".
   def button  btn3  label "Выход".
   def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете вариант отчета:" row 5 .

def var prz as integer.

vdt = today.

     update vgl label 'Введите ГРУППУ' 
    /* validate(substr(string(vgl), 1,1)  = '2' and 
        can-find(gl where gl.gl eq vgl) 
                */
     /* vdt label 'Введите отчтеную дату '  */
             with row 8 centered  side-label frame opt.
             hide frame opt.

  on choose of btn1,btn2,btn3 do:
    if self:label = "СУММА ОСНОВНОГО ДОЛГА" then prz = 1.
    else
    if self:label = "СУММА ОСНОВНОГО ДОЛГА C %%" then prz=2.
    else prz = 3.
   end.
   enable all with frame frame1.

    wait-for choose of btn1, btn2, btn3.
    if prz = 3 then return.
 hide  frame frame1.

IF prz = 1 then 
put stream rpt  'ОТЧЕТ ПО СУММЕ ОСН. ДОЛГА  ( В ТЕНГЕ) ПО ГРУППЕ ' 
at 5 vgl  SKIP 'ОТСОРТИРОВАННЫЙ ПО СРОКАМ И  %% СТАВКЕ НА ' AT 5 TODAY  skip.

IF prz = 2 then 
put stream rpt  'ОТЧЕТ ПО СУММЕ ОСН. ДОЛГА C %% (В ТЕНГЕ) ПО ГРУППЕ ' at 5 vgl SKIP 'ОТСОРТИРОВАННЫЙ ПО СРОКАМ И  %% СТАВКЕ НА ' AT 5 TODAY  skip.

 put stream rpt   ' ' fill ('-',70) format 'x(80)' at 1 .

strvgl = substring(string(vgl),1,2).

for each aaa where substr(string(aaa.gl),1,2) begins strvgl and 
 aaa.cr[1] - aaa.dr[1] > 0: 
  v-prd = aaa.expdt  - today. 
   if v-prd < 30 and v-prd >= 0 then v-prd = 1.
   if v-prd < 0 then  v-prd = 0.
   else  v-prd =  truncate(((aaa.expdt - today) / 30),0)  + 1. 
    
 create temp. 
     temp.aaa = aaa.aaa. temp.crc = aaa.crc.
     temp.gl  = strvgl . temp.rate = aaa.rate. temp.prd = v-prd.
    
     find last crchis where crchis.crc = aaa.crc 
      and crchis.rdt <= vdt  use-index crcrdt no-lock no-error.
  /*  find last aab where aab.aaa = aaa.aaa and aab.fdt <= vdt no-lock no-error.
   */
    IF prz = 1 then 
     temp.bal = (aaa.cr[1] - aaa.dr[1]) * crchis.rate[1].
   IF prz = 2 then 
     temp.bal = ((aaa.cr[1] - aaa.dr[1]) + (aaa.cr[2] - aaa.dr[2])) * crchis.rate[1].
   end.

for each arp where substr(string(arp.gl),1,2) begins strvgl and 
 arp.cam[1] - arp.dam[1] > 0: 
  v-prd = 0. 
 create temp. 
     temp.aaa = arp.arp.  temp.crc = arp.crc.
     temp.gl  = strvgl . temp.prd = v-prd.
     find last crchis where crchis.crc = arp.crc 
      and crchis.rdt <= vdt  use-index crcrdt no-lock no-error.
   IF prz = 1 then 
     temp.bal = (arp.cam[1] - arp.dam[1]) * crchis.rate[1].

   IF prz = 2 then 
     temp.bal = ((arp.cam[1] - arp.dam[1])+ (arp.cam[2] - arp.dam[2])) * crchis.rate[1].

end.

 for each temp break by temp.gl  by temp.crc by  temp.prd   by temp.rate:
     ACCUMULATE temp.bal (total by  (temp.crc)).
     ACCUMULATE temp.bal (total by  (temp.rate)).
     ACCUMULATE temp.bal (total by  (temp.prd)).
     ACCUMULATE temp.bal (total by  (temp.gl)).


  if last-of(temp.rate) then do:  
    put stream nur skip ' %% СТ-КА: ' at 10  (temp.rate) format 'zz9.9' ' ' 
     ACCUMulate total  by (temp.rate) 
        temp.bal format '->>>,>>>,>>>,>>9.99' at 30 .
  temp.balrate = (aCCUMulate total  by (temp.rate) temp.bal) * temp.rate / 100.
  
  put stream nur temp.balrate format '->>>,>>>,>>>,>>9.99' at 65.
   end.
 
   end.            
   
 for each temp break by temp.gl  by temp.crc by  temp.prd          by temp.rate:
  
     ACCUMULATE temp.bal (total by  (temp.crc)).
     ACCUMULATE temp.bal (total by  (temp.rate)).
     ACCUMULATE temp.bal (total by  (temp.prd)).
     ACCUMULATE temp.bal (total by  (temp.gl)).
     ACCUMULATE temp.balrate (total by  (temp.crc)).
     ACCUMULATE temp.balrate (total by temp.prd ).
     ACCUMULATE temp.balrate (total by  (temp.gl)).

/* find aaa where aaa.aaa = temp.aaa no-lock no-error.
 if available aaa then  put stream rpt skip temp.aaa ' ' aaa.regdt ' ' 
 aaa.expdt  ' 'temp.prd ' ' temp.crc ' ' temp.bal format '->>,>>>,>>9.99'.     
  */
  if first-of(temp.crc) then  DO: 
   find crc where crc.crc = temp.crc no-lock no-error.
   vcrc = crc.code.
   if available crc then  put stream rpt skip  'ВАЛЮТА : ' vcrc ' '.
   else displ aaa.aaa aaa.crc.
  end.

  if first-of(temp.prd) then put stream rpt skip 
  'СРОК(МЕС): ' temp.prd  format 'zz9' at 15 ' ' .

  if last-of(temp.rate) then do:  
    put stream rpt skip ' %% СТ-КА: ' at 10  (temp.rate) format 'zz9.9' at 25 
     ' '  ACCUMulate total  by (temp.rate) 
        temp.bal format '->>>,>>>,>>>,>>9.99' at 40 .
 /* temp.balrate = (aCCUMulate total  by temp.rate temp.bal) * temp.rate / 100.
   */
   put stream rpt  temp.balrate format '->>>,>>>,>>>,>>9.99' at 75.
   end.

  if last-of(temp.prd) then do:  
    put stream rpt skip "ИТ. ПО СР-КУ " temp.prd format 'zz9'  at 15 ' '  
     ACCUMulate total  by (temp.prd) 
        temp.bal format '->>>,>>>,>>>,>>9.99' at 60.

    put stream rpt ACCUMULATE total by temp.prd  
                 temp.balrate format '->>>,>>>,>>>,>>9.99' at 95 skip  .
 
    put stream rpt  'СРЕДН % СТ-КА ' 
   ( ACCUMulate total  by (temp.prd) temp.balrate) / ( ACCUMulate total  by   (temp.prd) temp.bal) * 100 format 'zz9.9' at 25 skip(2).
  end.

 if last-of(temp.crc) then do:
  put stream rpt skip 'ИТОГО ПО ВАЛЮТЕ : ' 
    vcrc  ACCUMulate total  by (temp.crc) 
        temp.bal format '->>>,>>>,>>>,>>9.99' at 60 .  
  
  put stream rpt ACCUMULATE total by temp.crc
                   temp.balrate format '->>>,>>>,>>>,>>9.99' at 95  .
  
   put stream rpt  skip 'СРЕДН % СТ-КА '
      ( ACCUMulate total  by (temp.crc) temp.balrate) / ( ACCUMulate total  by
      (temp.crc) temp.bal) * 100 format 'zz9.99' at 25 skip(2).
      
  end.
 if last-of(temp.gl) then  
    put stream rpt skip  ' ИТОГО ПО ГРУППЕ ' vgl ' ' 
     ACCUMulate total  by (temp.gl) 
        temp.bal format '->>>,>>>,>>>,>>9.99' at 45.
       
 end.
output stream rpt close.
output stream nur close.

 run menu-prt('rpt.img'). 
