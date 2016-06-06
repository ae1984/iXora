/* r-chek.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Доходы по чекам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6-3-8 
 * AUTHOR
        13/02/04 nataly 
 * CHANGES
*/

def var v-dat as date.
def var dt1 as date.
def var dt2 as date.

def var v-dam1 as decimal.
def var v-cam1 as decimal.
def var v-dam2 as decimal.
def var v-cam2 as decimal.
def var v-dam11 as decimal.
def var v-cam11 as decimal.
def new shared var prz as integer.


def button  btn1  label "Доходы по чекам(кроме дорожных)".
   def button  btn2  label "Доходы по дорожным чекам".
   def button  btn3  label "Выход".
   def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете вариант отчета:" row 5 .

  on choose of btn1,btn2,btn3 do:
    if self:label = "Доходы по чекам(кроме дорожных)" then prz = 1.
    else
    if self:label = "Доходы по дорожным чекам" then prz=2.
    else prz = 3.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if prz = 3 then return.
 hide  frame frame1.


update dt1 label 'Введите начальную дату'
       dt2 label 'Введите конечную дату'
            with frame opt.


if dt2 < dt1  then do:
    message "Неверно задана вторая дата".
    undo,retry.    
end.
hide frame opt.

message 'ЖДИТЕ ...' .

def stream rpt.
output stream rpt to rpt.img.

if prz = 1 then put stream rpt skip 'Отчет по доходам от продажи чеков (кроме дорожных) за период'  skip 
   ' с ' + string(dt1) +  ' по ' + string(dt2)  at 10 format 'x(80)'. 
 else if prz = 2 then put stream rpt skip 'Отчет по доходам от продажи ДОРОЖНЫХ чеков за период'  skip 
   ' с ' + string(dt1) +  ' по ' + string(dt2)  at 10 format 'x(80)'. 
put stream rpt skip fill('-',50) format 'x(50)'.

do v-dat = dt1 to dt2.
for each jl where jdt = v-dat.
 /*чеки, кроме дорожных*/
if prz = 1 and  jl.trx <> 'ock0002' and jl.trx <> 'ock0009' and jl.trx <> 'ock0043' and jl.trx <> 'ock0041' then next.

 /*чеки дорожные*/
if prz = 2 and  jl.trx <> 'ock0006' and jl.trx <> 'ock0017' then next.

  if string(jl.gl) begins '4' then do:
/*  message jl.trx jl.gl prz.*/
   
   if jl.crc = 1 then do: 
      v-dam1 = v-dam1 + jl.dam.
      v-cam1 = v-cam1 + jl.cam.
    end.
   else if jl.crc =2 then do:
      v-dam2 = v-dam2 + jl.dam.
      v-cam2 = v-cam2 + jl.cam.
   end.
   else if jl.crc = 11 then do:
         v-dam11 = v-dam11 + jl.dam.
         v-cam11 = v-cam11 + jl.cam.
   end.             
 end.  /*'4'*/
end. /*jl*/
end. /*v-dat*/
  if  v-cam1 <> 0 then
   put stream rpt skip 'KZT '  v-cam1 format 'zz,zzz,zzz,zz9.99'.
  if  v-cam2 <> 0 then
   put stream rpt skip 'USD '  v-cam2 format 'zz,zzz,zzz,zz9.99'.
  if v-cam11 <> 0 then
   put stream rpt skip 'EUR '  v-cam11 format 'zz,zzz,zzz,zz9.99'.

output stream rpt close.
run menu-prt('rpt.img').
