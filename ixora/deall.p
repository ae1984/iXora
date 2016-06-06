/* deall.p
 * MODULE
        Межбанковские кредиты и депозиты
 * DESCRIPTION
        Отчет по доходам и расходам по операциям РЕПО
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        {deall.i}
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK 
 * AUTHOR
        3/10/2003 marinav
 * CHANGES
       24.02.2004 tsoy Добавил 3 поля
*/

{global.i}

define temp-table wrk
  field gl like gl.gl
  field mom like deal.rem[3]
  field fun like deal.deal
  field sum1 like trxbal.dam
  field sum11 like trxbal.dam 
  field summa like trxbal.dam 
  field parval      as deci
  field open_price  like deal.prn 
  field close_price like deal.prn 
  field intrate like deal.intrate
  index fun fun.

define var summa1 as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99' init 0.
define var summa11 as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'  init 0.

define var v-open_price  as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'  init 0.
define var v-close_price as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'  init 0.
define var v-parval as deci format '>>>,>>>,>>>,>>>,>>>,>>>,>>9.99'  init 0.

define var lista as char.
define var listp as char.
define var dat1 as  date.
define var dat2 as  date.

define var v-IsOld as logical.

define stream m-out.
output stream m-out to rpt.html.

dat1 = g-today.
dat2 = g-today.
update dat1 label ' Укажите дату c: ' format '99/99/9999' 
       dat2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

find sysc where sysc eq "funa" no-error.
if available sysc then lista = sysc.chval.

for each fun no-lock.

  if lookup(string(fun.gl), lista) = 0 then 
          next. 

/* 
   Для того чтобы попали только те репо периоды которых
   которых пересекаются с отчетным периодом.
*/

  if  (fun.regdt>= dat1 and fun.regdt<= dat2) or
      (fun.duedt>= dat1 and fun.duedt<= dat2) or
      (fun.regdt>= dat1 and fun.duedt<= dat2) then do:

  find first deal where deal.deal = fun.fun no-lock no-error.
  if not avail deal then next.
  summa1 = 0. summa11 = 0.


  find first trxbal where trxbal.sub = 'fun' and trxbal.acc = deal.deal and trxbal.lev = 1 no-lock no-error.
  if avail trxbal then summa1 = trxbal.dam .

/*
  tsoy вместо текущих остатков берём, сумму по проводкам
  find first trxbal where trxbal.sub = 'fun' and trxbal.acc = deal.deal and trxbal.lev = 11 no-lock no-error.
  if avail trxbal then summa11 = abs(trxbal.cam - trxbal.dam).
*/
   for each jl where  jl.acc = deal.deal 
                      and jl.jdt >=dat1
                      and jl.jdt <=dat2
                      no-lock. 
         if jl.lev = 11 then do:

           find first gl where gl.gl = jl.gl no-lock no-error.           
           if avail  gl then do:
                if (caps(gl.type) = "a" or caps(gl.type) = "e") then
                   summa11 = summa11 + (jl.dam - jl.cam).
                else
                   summa11 = summa11 + (jl.cam - jl.dam).
           end.

         end.
   end.

      v-parval = deci(deal.ncrc[1]) * deci(deal.ncrc[2]).
  
/*
  Для старых счетов не умножаем на количество, тк как deal.prn уже содержит 
  Сумму а не Цену
*/

  find first fungrp where fungrp.fungrp = deal.grp no-lock no-error.
  if avail fungrp then do:
     if index(caps(fungrp.des[1]), 'N/A') > 0 then
        v-IsOld = true.
     else
        v-IsOld = false.
  end.

  if  v-IsOld then do:
      v-open_price  = (deal.prn).
      v-close_price = round((((deal.prn * deal.intrate / 100 / 365 * deal.trm) + deal.prn)),4).
  end.
  else do:
      v-open_price  = (deal.prn / 100) * deci(deal.ncrc[2]).
      v-close_price = round(((deal.prn / 100) * deci(deal.ncrc[2]) * deal.intrate / 100 / 365 * deal.trm + (deal.prn / 100) * deci(deal.ncrc[2])),4).
  end.

  find first trxlevgl where trxlevgl.sub = 'fun' and trxlevgl.level = 11 
         and trxlevgl.gl = deal.gl no-lock no-error.
  if not avail trxlevgl then displ deal.gl.
  find first wrk where wrk.fun = deal.deal no-lock no-error.
  if not avail wrk then do:
     create wrk.
     wrk.gl = trxlevgl.glr.
     wrk.mom = deal.rem[3].
     wrk.fun = deal.deal.
     wrk.parval      = v-parval.
     wrk.open_price  = v-open_price .
/*     wrk.close_price = v-close_price. */
     wrk.close_price = v-open_price + summa11 . 
     wrk.intrate     = deal.intrate.
  end.
  wrk.sum1 = summa1.
  wrk.sum11 = summa11.   
  wrk.summa = summa1 * deal.intrate.
/*  put stream m-out summa1 summa11 deal.intrate summa1 * deal.intrate format '>>>,>>>,>>>,>>9.99' skip.*/

end.
end.


put stream m-out "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">" skip.

put stream m-out "<tr align=""center""><td><h3> Доходы по операциям обратное РЕПО за период с " dat1
                 " по " dat2 "</h3></td></tr><br><br>" skip.
put stream m-out "<br><br><tr></tr>".
       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">ГК</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид ценных бумаг</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма ОД </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисленное вознаграждение </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Средняя %%</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Номинальная стоимость </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Стоимость приобретения </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Стоимость реализации</td>"

                  "</tr>".
for each wrk where wrk.gl < 500000 break by wrk.gl by wrk.mom.
 {deall.i}.
end.
put stream m-out "</table><br><br>".

put stream m-out "<tr align=""center""><td><h3> Расходы по операциям прямое РЕПО за период с " dat1
                 " по " dat2 "</h3></td></tr><br><br>" skip.
put stream m-out "<br><br><tr></tr>".
       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">ГК</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид ценных бумаг</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма ОД </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисленное вознаграждение </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Средняя %%</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Номинальная стоимость </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Стоимость приобретения </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Стоимость реализации</td>"
                  "</tr>".

for each wrk where wrk.gl > 500000 break by wrk.gl by wrk.mom.
 {deall.i}.
end.
put stream m-out "</table>".

output stream m-out close.
unix silent cptwin rpt.html excel.



