/* crdpaygen2.p
 * MODULE
        Пластиковые Карточки
 * DESCRIPTION
        формирование файла перечислений на пласт.
        карточки в формате для BWX на основе
        данных их таблицы cpay
        ТОЛЬКО ДЛЯ SECURE DEPOSIT !!!!!!!!!!!!!!!
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
        09.07.2003 sasco
 * CHANGES
        01.03.2004 sasco Изменение регистра на заглавные для номера карточки/контракта
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
	15.12.2005 u00121 увеличил формат для counters.counter до "999" - со старым параметром "99" нельзя было отправить больше 99 файлов, что привело к ошибке при отправке 15/12/05 пополнения на 10000$ менеджером u00443 (TRX # 19329143)
	17.12.2005 u00121 вернул все назад, так как это число по формату не должно быть больше двух символов
        02.11.2006 Natalya D. - в связи с переходом в процессинг Казкома изменила bankid на 0038
*/

def shared temp-table cpay
           field card as char format "x(18)" /* N карт */
           field sum like jl.dam             /* Сумма к зачисл */
           field crc as char format "x(3)"   /* валюта */
           field trxdes as char              /* описание транзакции */
           field batchdes as char            /* описание батча */
           field messtype as char.           /* тип зачисления */

define output parameter f-name as char. 

define var g-today as date init today.
define var bankid as char init "0038".

define var total_sum as decimal.
define var batch_sum as decimal.
define var trxcnt as integer.

define var linenum as integer.
define var batchsnum as integer.
define var file-cntr as char.

define var idays as integer.
define var sstr as char.
define var i as integer.


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* подготовка рабочей таблицы */

total_sum = 0.0.

for each cpay:
   if cpay.sum = 0.0 then delete cpay.
end.


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* счетчик файлов типа 'payments' */

find counters where counters.type = "payments" exclusive-lock no-error.
if not avail counters then
   do:
      create counters.
      assign counters.type = "payments"
             counters.dat = g-today
             counters.counter = 1.
  end.
else do:
  if counters.dat <> g-today then
  do:
      assign counters.dat = g-today
             counters.counter = 1.
  end.
  else counters.counter = counters.counter + 1.
end.


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

 file-cntr = string(counters.counter, "99").
 linenum = 1.
 batchsnum = 0.
 idays = g-today - date(01,01, year(g-today)).

 /*название файла*/
 f-name = "P" + bankid + '_' + string(file-cntr, "99") + "." + string (idays + 1, "999").
 output to value (f-name).


 /*хидер файла*/  
 put unformatted "FH" + "000001" + "PAYMENT  " + " 10 " + "0038  "
       + string(year(g-today),"9999") 
       + string (month(g-today),"99")
       + string (day(g-today),"99"). 
 sstr = string(time,"hh:mm:ss").
 put unformatted substr(sstr,1,2)  substr(sstr,4,2) substr(sstr,7,2) "00" string(file-cntr, "99")
              "9997  " "F" "C" "N" "m" "D" " " fill(" ",146) "*" chr(13) chr(10).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* формирование батчей и проводок */

for each cpay break by cpay.crc:

  if first-of (cpay.crc) then
  do:
     /* батчи делаем по валютам */

     i = 0.
     batchsnum = batchsnum + 1.
     linenum = linenum + 1.
     batch_sum = 0.0.
     trxcnt = 0.

     /*хидер батча*/ 
     put unformatted "BH" linenum format("999999") 
                     string(batchsnum) format 'x(10)' 
                     "PAYCARDSEC" format 'x(12)'
                     "s" format 'x(5)' "C".

     if cpay.crc = 'KZT' or cpay.crc = '398' then
                           put unformatted '398'.
     if cpay.crc = 'USD' or cpay.crc = '840' then
                           put unformatted '840'.
     if cpay.crc = 'EUR' or cpay.crc = '978' then
                           put unformatted '978'.

     put unformatted 
                  string(year(g-today),"9999")   /* transaction date */
                + string (month(g-today),"99")
                + string (day(g-today),"99")
                  string (substring (cpay.batchdes, 1, 32), "x(32)")
                  fill(" ", 124) "*" chr(13) chr(10).

  end. /* batch header */

  i = i + 1.

  /*транзакция*/
  linenum = linenum + 1.
  trxcnt = trxcnt + 1.
  put unformatted "RD"
                  linenum format("999999")
                  i format ("999999")
                  cpay.sum * 100 format ("999999999999999") 
                  CAPS (cpay.card) format 'x(32)'
                  fill(' ', 60) /* shortname */
                  string (substring (cpay.trxdes, 1, 32), "x(32)")
                  " "
                  " "
                  fill(" ", 48)
                  "*"
                  chr(13) chr(10).

 total_sum = total_sum + cpay.sum.
 batch_sum = batch_sum + cpay.sum.


 if last-of (cpay.crc) then
 do:
     /*футер батча*/
     linenum = linenum + 1.
     put unformatted "BT" linenum format("999999")
                 trxcnt format("999999")
                 batch_sum * 100 format ("999999999999999999")
                 fill(" ", 171) "*" chr(13) chr(10).
 end.

end. /* конец обработки батчей */


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*футер файла*/
 
 linenum = linenum + 1.   
 put unformatted "FT" linenum format ("999999")
                      batchsnum format ("999999")  /* количество батчей */
                      total_sum * 100 format ("999999999999999999") /* hash file total */
                                                        /* не смотрим на валюту и знак */
                      fill(" ", 171) "*" chr(13) chr(10).
 output close.


