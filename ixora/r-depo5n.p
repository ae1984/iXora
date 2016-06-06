/* r-depo5n.p
 * MODULE
        Отчет по начисленному вознаграждению в разрезе резидентов-нерезидентов
 * DESCRIPTION
        Отчет по начисленному вознаграждению  в разрезе резидентов-нерезидентов (аналог отчету 8-13-2)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        depo5n.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        r-depfun2,r-depaaa5n 
 * MENU
        8-13-7 
 * AUTHOR
        04.04.05 nataly
 * CHANGES
*/

define var g-batch  as log initial false.
def  new shared var vgl as integer format 'zzzzzz' /*init 221520*/ .
def  new shared var dt1 as date  .
def  new shared var dt2 as date  .
def  new shared  var v-brate as decimal.
def  new shared var lastday as date.
def  new shared var vval as char.
def new shared var vval_text as char init " ".
def new shared var prz as integer.
def new shared var prz1 as integer.

def new shared temp-table  taxtemp
   field taxrate as char format 'x(8)'
   field regdt as date 
   field val as decimal extent 15 format 'zzzzz.99-'
   field who as char format 'x(8)'
   index itaxrate is primary taxrate regdt.

def new  shared temp-table  taaa
   field aaa as char format 'x(9)'
   field crc as integer format 'zz'
   field lgr as char format 'x(5)'
   field base as integer format 'zzz'
   field bal as decimal
   field days as integer
   field jl as decimal 
   field rate as decimal 
   field regdt as date
   field expdt as date
   field sta as char
   field libor as decimal 
   field v-acrrl as decimal
   field v-acrr as decimal
   field prib-aaa as decimal
   field v-aaamin as decimal
   field v-acrrlv as decimal
   field v-acrrv as decimal
   field prib-aaav as decimal
   field v-aaaminv as decimal
   index iaaa is primary aaa .

def new shared temp-table temp2  
    field acc as char format 'x(9)'
    field jh as integer
    field crc as integer
    field jdt as date
    field dam  as decimal
    field cam  as decimal
    index iacc is primary acc.
 
def  stream nur.
def var i as date .

def var  sum1 as decimal.
def var  sum2 as decimal.
def var  sum3 as decimal.
def var  sum4 as decimal.

def var  sum1v as decimal.
def var  sum2v as decimal.
def var  sum3v as decimal.
def var  sum4v as decimal.
def var dt as date extent 3.

def var dt11 as date.
def var dt22 as date.

/* dt2 не должен превышать последний закрытый ОД!!!! */ 
 find first cmp no-lock no-error.

find sysc "bsrate" no-lock no-error.
if available sysc then v-brate = sysc.deval. else v-brate = 6.
find last cls no-lock no-error. 
lastday = cls.cls.

if not g-batch then do:
     update vgl label 'ВВЕДИТЕ СЧЕТ ГК' 
     validate(substr(string(vgl), 1,1)  = '2' and 
     can-find(gl where gl.gl eq vgl),
             "Счет ГК не найден... или Счет ГК не 2..... ")
              help "Введите счет ГК."
              dt1 label 'С' validate (01/01/02 le dt1, 
                " В базе информация с  " + string(01/01/02) )
              dt2 label 'ПО' 
              with row 8 centered  side-label frame opt.
end. 
   hide frame  opt.
dt11 = dt1.
dt22 = dt2. 
      
def button  btn1  label "Сокращенная форма отчета".
   def button  btn2  label "Расширенная форма отчета ".
   def button  btn3  label "Выход".
   def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете вариант отчета:" row 5 .

  on choose of btn1,btn2,btn3 do:
    if self:label = "Сокращенная форма отчета" then prz = 1.
    else
    if self:label = "Расширенная форма отчета  " then prz=2.
    else prz = 3.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if prz = 3 then return.
    if prz = 2 then do: 
              message 'Данный режим недоступен !' view-as alert-box.
              return.
           end.
 hide  frame frame1.

def new shared var vlgr as char init "".
if prz = 2 then  update vlgr format 'x(3)' label 'Задайте группу ' 
         validate(can-find(lgr where lgr.lgr eq vlgr) or can-find(fungrp where  string(fungrp.fungrp) eq vlgr),"Группа " + vlgr + " не найдена!")
         help "Задайте группу."
              with row 8 centered  side-label frame opt2.
 hide frame opt2.
if prz = 2 then  update vval format 'x(1)' label 'Задайте валюту: 1) ВАЛЮТА, 2) ТЕНГЕ' 
         validate((vval = '1' or vval = '2'), "Наберите 1 или 2")
              with row 8 centered  side-label frame opt3.
 if vval = '1' then vval_text = " В ВАЛЮТЕ". 
 if vval = '2' then  vval_text = " В ТЕНГЕ".
    if vval = '1' then  do:
        message 'Данный режим пока недоступен !' view-as alert-box.
        return.
     end.
hide frame opt3.
   def button  btn4  label "Средневзвешанный курс".
   def button  btn5  label "Курс Нац Банка ".
   def button  btn6  label "Выход".
   def frame   frame2
   skip(1) btn4 btn5 btn6 with centered title "Задайте курс расчета суммы по либору/рефинанс:" row 5 .

  on choose of btn4,btn5,btn6 do:
    if self:label = "Средневзвешанный курс" then prz1 = 1.
    else
    if self:label = "Курс Нац Банка  " then prz1 = 2.
    else prz1 = 3.
   end.
   enable all with frame frame2.
    wait-for choose of btn4, btn5, btn6.
    if prz1 = 3 then return.
 hide  frame frame2.



 display '   ЖДИТЕ...   '  with row 5 frame ww centered .

 for each taxrate no-lock.
   create taxtemp.
   buffer-copy taxrate to taxtemp no-error.
 end.

if dt1 < 11/28/03 and dt2 >= 11/28/03 then  do: 
  dt[1] = dt1. dt[2] = 11/28/03.    dt[3] = dt2. 
/*   dt3 = dt2. 
   dt2 = 11/28/03. */
end.
else if dt1 > 11/28/03 then do:
  dt[1] = ?. dt[2] = dt1.    dt[3] = dt2. 
/*   dt3 = dt2. 
   dt2 = dt1. 
   dt1 = ?.*/
end. 
else if dt2 < 11/28/03 then do:
  dt[1] = dt1. dt[2] = dt2.    dt[3] = ?. 
/*   dt3 = ?. */
end. 
find gl where gl.gl = vgl no-lock no-error.
case gl.subled:
 when   'fun' then  do:
if dt[1] <> ? then do: 
       if dt[3] <> ? then do:   
          dt1 = dt[1]. 
          dt2 = dt[2].  
        {r-branch-arx2.i &proc = "r-depfun2n"} 
          dt1 = dt[2] + 1. 
          dt2 = dt[3].  
        {r-branch-arx.i &proc = "r-depfun2n"} 
      end.
      else do: /*dt[3] = ?*/
          dt1 = dt[1]. 
          dt2 = dt[2].  
        {r-branch-arx2.i &proc = "r-depfun2n"} 
      end.
    end. /*dt[1] <> ?*/
    else do:  /*dt[1] = ?*/
       dt1 = dt[2]. 
       dt2 = dt[3].  
      {r-branch-arx.i &proc = "r-depfun2n"} 
   end.
  end. /*fun*/
 otherwise  do: 
    if dt[1] <> ? then do: 
       if dt[3] <> ? then do:   
          dt1 = dt[1]. 
          dt2 = dt[2].  
        {r-branch-arx2.i &proc = "r-depaaa5n"} 
          dt1 = dt[2] + 1. 
          dt2 = dt[3].  
        {r-branch-arx.i &proc = "r-depaaa5n"} 
      end.
      else do: /*dt[3] = ?*/
          dt1 = dt[1]. 
          dt2 = dt[2].  
        {r-branch-arx2.i &proc = "r-depaaa5n"} 
      end.
     end. /*dt[1] <> ?*/
     else do:  /*dt[1] = ?*/
       dt1 = dt[2]. 
       dt2 = dt[3].  
      {r-branch-arx.i &proc = "r-depaaa5n"} 
    end.
    end.  /*otherwise*/
end case.
  

if connected ("comm") then disconnect "comm".

/*----------- печать результатов ------------ */
output stream nur to rpt.img.
  put stream nur skip
  string( today, '99/99/9999' ) + ', ' +
  string( time, 'HH:MM:SS' ) + ', ' +
  trim( cmp.name ) format 'x(79)' at 02 skip(1).

put stream nur skip " КОНСОЛИДИРОВАННЫЙ ОТЧЕТ ПО ВОЗНАГРАЖДЕНИЮ  " at 15 skip  
"С " at 25 dt11 " ПО " dt22  vval_text format 'x(10)'  skip.

find gl where gl.gl  = vgl no-lock no-error.
   put stream nur  ' ' fill ('=',70) format 'x(80)' at 1.
   put stream nur skip 'Счет ГК ' gl.gl ' ' gl.des.
   put stream nur  ' ' fill ('=',70) format 'x(90)' at 1.


/*----------сокращенная форма----------*/
if prz = 1 then do:

put stream nur 
    "  ГРУППА " at 2 " Кол-во "  at 13 + 7 " Об. сумма "  at 21 + 7     " Об.Сумма " at 69 - 20 + 7    skip
                     " счетов" at 13 + 7 " долга "  at 21 + 7            " нач. %%"  at 69 - 20 + 7   .
   put stream nur  ' ' fill ('=',70) format 'x(112)' at 1.

for each taaa no-lock break by taaa.sta by taaa.lgr.
  ACCUMULATE taaa.aaa (count by taaa.sta by taaa.lgr ).
  ACCUMULATE taaa.bal (total by taaa.sta by  taaa.lgr).
 
  ACCUMULATE taaa.v-acrrv (total by taaa.sta by  taaa.lgr).

  ACCUMULATE taaa.v-acrr (total by taaa.sta by  taaa.lgr).


 if last-of(taaa.lgr) then  do:
 put stream nur skip  'ГРУППА ' at 1  taaa.lgr
   ACCUMulate count  by (taaa.lgr) taaa.aaa format 'zzzz9' at 13 + 7 
   ACCUMulate total  by (taaa.lgr) taaa.bal  format '->>>,>>>,>>9.99' at 21 + 7.


  sum2v = ACCUMulate total  by (taaa.lgr) taaa.v-acrrv.   


    put stream nur      
                sum2v format '->,>>>,>>9.99'  at 67 - 20 + 5.
 
  end. /*last-of taaa.lgr*/

 if last-of(taaa.sta) then  do:

 put stream nur  ' ' fill ('-',70) format 'x(112)' at 1.
 put stream nur skip  'ИТОГО ' at 1  if taaa.sta = '1' then 'РЕЗИДЕНТОВ' else 'НЕРЕЗИДЕНТОВ' format 'x(12)'
   ACCUMulate count  by (taaa.sta) taaa.aaa  format 'zzzz9' at 13 + 7
   ACCUMulate total  by (taaa.sta) taaa.bal format '->>>,>>>,>>9.99' at 21 + 7  .



  sum2v = ACCUMulate total  by (taaa.sta) taaa.v-acrrv.   


    put stream nur      
                sum2v format '->,>>>,>>9.99'  at 67 - 20 + 7 skip(2) .
 
  end. /*last-of taaa.crc*/

 end. /*taaa*/
   put stream nur  ' ' fill ('=',70) format 'x(112)' at 1.
    put stream nur skip 'ПО ' at 1 vgl  accum count taaa.aaa format 'zzzz9' at 13 + 7
                        ACCUMulate total  taaa.bal   format '->>,>>>,>>9.99'  at  22 + 7
                        ACCUMulate total  taaa.v-acrrv   format '->>,>>>,>>9.99'  at 67 - 20 + 7.

end. /*prz = 1*/

/*вывод корректирующих проводок*/
/*
find first temp2 no-lock no-error.
if available temp2 then do:
  put stream nur skip(2)  fill ('-',112) format 'x(112)' at 1.

  put stream nur skip ' Счет     Валюта     Дебет       Кредит    ї Транз    Дата '.
   for each temp2 no-lock break by temp2.acc.
/*    find crc where .crc.crc = temp2.crc no-lock.*/
    put stream nur skip   temp2.acc ' ' /*crc.code */ ' KZT '  
     temp2.dam    format '->,>>>,>>9.99'  temp2.cam   format '->,>>>,>>9.99'  ' ' 
     temp2.jh  format 'zzzzzzz99' ' '  temp2.jdt.
   end.
end.
  */

 put stream nur  skip(1) 
      " =====      КОНЕЦ ДОКУМЕНТА     ====="
    SKIP(1).
output stream nur close.
 hide  frame ww no-pause.

run menu-prt( 'rpt.img' ). 
pause 0.
