/* com-prcd.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Формирование и печать приходного кассового ордера при импорте и зачислении коммунальных, налоговых, пенсионных и АЛМА ТВ платежей
 * RUN

 * CALLER
        import.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        12/12/2003 kanat
 * CHANGES
        13/12/2003 kanat - добавил вывод в ордер ФИО кассира
        30/03/2004 kanat - добавил проверку по обменным операциям в формирование временной таблицы по коммунальным платежам
        16/04/2004 kanat - добавил вывод платежей за сотовую связь по квитанциям.
        23/04/2004 kanat - добавил сумму комиссии по АЛМА ТВ.
        24/05/2004 kanat - добавил проверки при выводе сумм по типам платежей в конце ордера,
                           чтобы суммы по реестрам платежей совпадали с суммами документов банка.
        01/10/2004 kanat - добавил недостачи в тенге
        05/10/2004 kanat - отделил недостачи и коммунальные платежи
        18/01/2005 kanat - добавил соц. отчисления
        20/01/2005 kanat - добавил проверки по логинам офицера в поиске документов по пенсионкам
        26/04/2005 kanat - убрал вывод ошибок если нет совпадений по референсам и суммам
        14/09/2005 kanat - добавил дополнительные индексирования временных таблиц и использование индексов по талицам tax, almatv, p_f_payment
        10/10/2005 suchkov - переделал слегка поиск документов
        30/01/2006 MARINAV - учет POS проводок
        18/11/2011 evseev  - переход на ИИН/БИН
*/

{global.i}
{comm-txb.i}
{chbin.i}


def input parameter v-date as date.
def input parameter v-ksofc as char.
def input parameter v-type as char.

def shared var v-pen-jh as integer.
def shared var v-atv-jh as integer.

def var seltxb as int.
seltxb = comm-cod ().


   def var v-com-count as integer init 0.
   def var v-com-sum as decimal init 0.
   def var v-com-comsum as decimal init 0.
   def var v-cell-sum as decimal init 0.

   def var v-pmp-sum as decimal init 0.

   def var v-tax-count as integer init 0.
   def var v-tax-sum as decimal init 0.
   def var v-tax-comsum as decimal init 0.
   def var v-tax-arp as char.

   def var v-pos-sum as decimal init 0.

   def var v-pen-count as integer init 0.
   def var v-pen-sum as decimal init 0.
   def var v-pen-comsum as decimal init 0.
   def var v-pen-arp as char.

   def var v-atv-count as integer init 0.
   def var v-atv-sum as decimal init 0.
   def var v-atv-comsum as decimal init 0.
   def var v-atv-arp as char.

   def var v-whole-sum as decimal init 0.

   def var v-count as integer init 0.
   def var v-sum as decimal init 0.
   def var v-comsum as decimal init 0.

   def var v-com-doc as char.
   def var v-tax-doc as char.

   def var v-temp-sum as decimal.
   def var v-pmp-sum1 as decimal.
   def var v-pmp-doc1 as char.

   define temp-table tprcd
          field arp as char
          field sum as decimal
          field comsum as decimal
          field count as integer
          field doc as char.

   define temp-table pmrcd
          field arp as char
          field sum as decimal
          field comsum as decimal
          field count as integer
          field doc as char.

   define temp-table cellprcd
          field dnum as integer
          field sum as decimal
          field comsum as decimal
          field count as integer
          field doc as char
          index dnum_idx is primary unique dnum.


   def var temp as char.
   def var StrTemp as char.
   def var StrAmount as char.
   def var str1 as char.
   def var str2 as char.


   if v-type = "COM" or v-type = "ALL" then do:
   for each commonpl where commonpl.txb = seltxb and commonpl.date = v-date and commonpl.uid = v-ksofc and
                           commonpl.deluid = ? and
                           commonpl.joudoc <> ? and
                           commonpl.grp <> 0 and
                           commonpl.grp <> 4 and
                           commonpl.grp <> 10 and
                           commonpl.grp <> 16 and
                           commonpl.grp <> 15 no-lock break by arp.

   v-com-count = v-com-count + 1.
   v-com-sum = v-com-sum + commonpl.sum.
   v-com-comsum = v-com-comsum + commonpl.comsum.

   if last-of(commonpl.arp) then do:

   create tprcd.
   assign tprcd.arp = commonpl.arp
          tprcd.sum = v-com-sum
          tprcd.comsum = v-com-comsum
          tprcd.count = v-com-count
          tprcd.doc = commonpl.joudoc.

   v-com-count = 0.
   v-com-sum = 0.
   v-com-comsum = 0.
   end.
   end.
   end.


/* 01/10/04 - kanat добавил недостачи в тенге */

   if v-type = "COM" or v-type = "ALL" then do:
   for each commonpl where commonpl.txb = seltxb and commonpl.date = v-date and commonpl.uid = v-ksofc and
                           commonpl.deluid = ? and commonpl.joudoc <> ? and commonpl.grp = 10 and commonpl.typegrp = 1 no-lock break by arp.

   v-com-count = v-com-count + 1.
   v-com-sum = v-com-sum + commonpl.sum.
   v-com-comsum = v-com-comsum + commonpl.comsum.

   if last-of(commonpl.arp) then do:

   create tprcd.
   assign tprcd.arp = commonpl.arp
          tprcd.sum = v-com-sum
          tprcd.comsum = v-com-comsum
          tprcd.count = v-com-count
          tprcd.doc = commonpl.joudoc.

   v-com-count = 0.
   v-com-sum = 0.
   v-com-comsum = 0.
   end.
   end.
   end.

/* 30/01/2006 marinav - POS */
   if v-type = "COM" or v-type = "ALL" then do:
   for each commonpl where commonpl.txb = seltxb and commonpl.date = v-date and commonpl.uid = v-ksofc and
                           commonpl.deluid = ? and commonpl.joudoc <> ? and commonpl.grp = 16 and commonpl.typegrp = 1 no-lock break by arp.

   v-pos-sum = v-pos-sum + commonpl.sum.

   end.
   end.


/* 01/17/05 - kanat добавил соц. отчисления в тенге */

   if v-type = "COM" or v-type = "ALL" then do:
   for each commonpl where commonpl.txb = seltxb and commonpl.date = v-date and commonpl.uid = v-ksofc and
                           commonpl.deluid = ? and commonpl.joudoc <> ? and commonpl.grp = 15 no-lock break by dnum.

   v-com-count = v-com-count + 1.
   v-com-sum = v-com-sum + commonpl.sum.
   v-com-comsum = v-com-comsum + commonpl.comsum.

   if last-of(commonpl.dnum) then do:

   create pmrcd.
   assign pmrcd.arp = commonpl.arp
          pmrcd.sum = v-com-sum
          pmrcd.comsum = v-com-comsum
          pmrcd.count = v-com-count
          pmrcd.doc = commonpl.joudoc.

   v-com-count = 0.
   v-com-sum = 0.
   v-com-comsum = 0.
   end.
   end.
   end.



/* ---------------------- kanat - специально для KCell и KMobile ------------------------------- */

   v-cell-sum = 0.

   if v-type = "COM" or v-type = "ALL" then do:
   for each commonpl where commonpl.txb = seltxb and commonpl.date = v-date and commonpl.uid = v-ksofc and
                           commonpl.deluid = ? and commonpl.joudoc <> ? and commonpl.grp = 4 no-lock break by dnum.

   v-whole-sum = v-whole-sum + commonpl.sum + commonpl.comsum.

   if first-of(commonpl.dnum) then do:
   create cellprcd.
   assign cellprcd.dnum = commonpl.dnum
          cellprcd.sum = commonpl.sum
          cellprcd.comsum = commonpl.comsum
          cellprcd.count = 1                   /* ? :)) ... */
          cellprcd.doc = commonpl.joudoc.
   end.
   end.
   end.

/* --------------------------------------------------------------------------------------------- */

   if v-type = "TAX" or v-type = "ALL" then do:
   for each tax where tax.txb = seltxb and tax.date = v-date and tax.uid = v-ksofc and tax.duid = ? and
                      tax.taxdoc <> ? no-lock use-index datenum.
   accumulate tax.sum (total).
   accumulate tax.comsum (total).
   accumulate tax.sum (count).
   v-tax-doc = tax.taxdoc.
   end.

   v-tax-count = (accum count tax.sum).
   v-tax-sum = (accum total tax.sum).
   v-tax-comsum = (accum total tax.comsum).

   v-whole-sum = v-whole-sum + v-tax-sum + v-tax-comsum.
   end.


   if v-type = "PEN" or v-type = "ALL" then do:
   for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = v-date and p_f_payment.uid = v-ksofc and
                              p_f_payment.deluid = ? and p_f_payment.stcif = 1 no-lock use-index datenum.
   accumulate p_f_payment.amt (total).
   accumulate p_f_payment.comiss (total).
   accumulate p_f_payment.amt (count).
   end.

   v-pen-count = (accum count p_f_payment.amt).
   v-pen-sum = (accum total p_f_payment.amt).
   v-pen-comsum = (accum total p_f_payment.comiss).

   v-whole-sum = v-whole-sum + v-pen-sum + v-pen-comsum.
   end.


   if v-type = "ATV" or v-type = "ALL" then do:
   for each almatv where almatv.dtfk = v-date and almatv.txb = seltxb and almatv.uid = v-ksofc and almatv.summfk <> 0 and
                         almatv.Dtfk <> ? and almatv.deluid = ? and almatv.state = 1 no-lock use-index dtfk.
   accumulate almatv.summfk (total).
   accumulate almatv.summfk (count).
   accumulate almatv.cursfk (total).
   end.

   v-atv-count = (accum count almatv.summfk).
   v-atv-sum = (accum total almatv.summfk).
   v-atv-comsum = (accum total almatv.cursfk).

   v-whole-sum = v-whole-sum + v-atv-sum + v-atv-comsum.
   end.


   if v-type = "COM" or v-type = "ALL" then do:
   v-com-sum = 0.
   for each tprcd no-lock.
   v-com-sum = v-com-sum + tprcd.sum + tprcd.comsum.
   v-whole-sum = v-whole-sum + tprcd.sum + tprcd.comsum.
   end.
   end.


   if v-type = "COM" or v-type = "ALL" then do:
   v-pmp-sum = 0.
   for each pmrcd no-lock.
   v-pmp-sum = v-pmp-sum + (pmrcd.sum + pmrcd.comsum).
   v-whole-sum = v-whole-sum + (pmrcd.sum + pmrcd.comsum).
   end.
   end.


   output to prihod.img.
   put unformatted " " skip.
   put unformatted "                         ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР " skip(2).

   find first ofc where ofc.ofc = g-ofc no-lock no-error.
   if avail ofc then
   put unformatted ofc.name "/" ofc.ofc + "                         " + string(g-today,"99/99/9999") skip.

   put unformatted fill ("=", 77) skip.
   put unformatted "ВАЛЮТА                                      ПРИХОД                РАСХОД" skip.
   put unformatted fill ("-", 77) skip.
   put unformatted "Тенге                             " v-whole-sum format ">>>,>>>,>>>,>>9.99" "              0.00"  skip(1).
   put unformatted "                   ИТОГО          " v-whole-sum format ">>>,>>>,>>>,>>9.99" skip(3).

   put 'Сумма прописью :' skip(1).

   temp = string (v-whole-sum).

   if num-entries(temp,".") = 2 then do:
      temp = substring(temp, length(temp) - 1, 2) + " тенге ".
      if num-entries(temp,".") = 2 then
      temp = " " + substring(temp,2,1) + "0" + " тиын".
   end.
   else temp = " тенге 00" + " тиын".

   strTemp = string(truncate(v-whole-sum,0)).

   run Sm-vrd(input v-whole-sum, output strAmount).
   strAmount = strAmount + temp.

   if length(strAmount) > 80 then do:
          str1 = substring(strAmount,1,80).
          str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
          put unformatted str1 skip str2 skip(0).
     end.
   else  put unformatted strAmount skip(0).


   put unformatted "Менеджер:                  Контролер:                       Кассир:" skip(2).
   put unformatted "Внес" skip.
   put unformatted "Паспорт" skip.
   if v-bin then put unformatted "ИИН" skip.
   else put unformatted "РНН" skip.
   put unformatted "Подпись" skip(1).


   put unformatted fill ("=", 77) skip(1).
   find first ofc where ofc.ofc = v-ksofc no-lock no-error.
   if avail ofc then
   put unformatted "Примеч. - Зачисление на транзитные счета по кассиру: " ofc.name " / " + ofc.ofc + " за " string(v-date) skip.
   put unformatted fill ("=", 77) skip(1).


   v-temp-sum = v-tax-sum + v-tax-comsum.
   if (v-type = "TAX" or v-type = "ALL") and v-temp-sum <> 0 then do:
   find first joudoc where joudoc.docnum = v-tax-doc and joudoc.who = g-ofc no-lock no-error.
   if avail joudoc then do:
   put unformatted " - Налоговые платежи: -----------------------------" skip.
   if v-temp-sum = joudoc.cramt then
   put unformatted v-temp-sum format ">>>,>>>,>>>,>>9.99" " /" joudoc.docnum "/" joudoc.jh skip.
/*
   else
   put unformatted "Суммы по реестру и транзакции не совпадают!!!" skip.
*/
   end.
   end.


   if (v-type = "COM" or v-type = "ALL") or v-com-sum <> 0 then do:
   put unformatted " - Платежи станций диагностик: --------------------" skip.
   for each tprcd no-lock.
   find first joudoc where joudoc.docnum = tprcd.doc and
                           joudoc.who = g-ofc no-lock no-error.
   if avail joudoc then do:
   if (tprcd.sum + tprcd.comsum) = joudoc.cramt then
   put unformatted tprcd.sum + tprcd.comsum format ">>>,>>>,>>>,>>9.99" " /" tprcd.doc "/" joudoc.jh skip.
/*
   else
   put unformatted "Суммы по реестру и транзакции не совпадают!!!" skip.
*/
   end.
   end.
   end.

   /* kanat - вывод платежей за сотовую связь по квитанциям */

   if (v-type = "COM" or v-type = "ALL") or v-cell-sum <> 0 then do:
   put unformatted " - Платежи за сотовую связь (KCell/KMobile) (по квитанциям): --------------------" skip.
   for each cellprcd no-lock use-index dnum_idx.
   find first joudoc where joudoc.docnum = cellprcd.doc and
                           joudoc.who = g-ofc no-lock no-error.
   if avail joudoc then do:
   if cellprcd.sum = joudoc.cramt then
   put unformatted cellprcd.sum format ">>>,>>>,>>>,>>9.99" " /" cellprcd.doc "/"
                   joudoc.jh " Общая сумма с комиссией: " cellprcd.sum + cellprcd.comsum format ">>>,>>>,>>>,>>9.99" skip.
/*
   else
   put unformatted "Суммы по реестру и транзакции не совпадают!!!" skip.
*/
   end.
   end.
   end.

  /* kanat - вывод платежей соц. отчислений */

   if (v-type = "COM" or v-type = "ALL") or v-pmp-sum <> 0 then do:
   put unformatted " - Платежи по соц. отчислениям : --------------------" skip.
   for each pmrcd no-lock break by pmrcd.doc.
   if first-of (pmrcd.doc) then
   v-pmp-doc1 = pmrcd.doc.
   v-pmp-sum1 = v-pmp-sum1 + pmrcd.sum + pmrcd.comsum.
   end.
   find first joudoc where joudoc.docnum = v-pmp-doc1 and joudoc.who = g-ofc no-lock no-error.
   if avail joudoc then do:
   if joudoc.cramt = v-pmp-sum1 then
   put unformatted joudoc.cramt format ">>>,>>>,>>>,>>9.99" " /" joudoc.docnum "/" joudoc.jh skip.
/*
   else
   put unformatted "Суммы по реестру и транзакции не совпадают!!!" skip.
*/
   end.
   end.


   if (v-type = "PEN" or v-type = "ALL") and v-pen-sum <> 0 then do:
   find first jh where jh.jh = v-pen-jh no-lock no-error.
   find first joudoc where joudoc.docnum = jh.party no-lock no-error.
   if avail joudoc then do:
   put unformatted " - Пенсионные платежи: ----------------------------" skip.
   if (v-pen-sum + v-pen-comsum) = joudoc.cramt then
   put unformatted v-pen-sum + v-pen-comsum format ">>>,>>>,>>>,>>9.99" " /" joudoc.docnum "/" joudoc.jh skip.
/*
   else
   put unformatted "Суммы по реестру и транзакции не совпадают!!!" skip.
*/
   end.
   end.


   if (v-type = "ATV" or v-type = "ALL") and v-atv-sum <> 0 then do:
   find first jh where jh.jh = v-atv-jh no-lock no-error.
   find first joudoc where joudoc.docnum = jh.party no-lock no-error.
   if avail joudoc then do:
   put unformatted " - Платежи АЛМА TV: -------------------------------" skip.
   if (v-atv-sum + v-atv-comsum) = joudoc.cramt then
   put unformatted v-atv-sum + v-atv-comsum format ">>>,>>>,>>>,>>9.99" " /" joudoc.docnum "/" joudoc.jh skip.
/*
   else
   put unformatted "Суммы по реестру и транзакции не совпадают!!!" skip.
*/
   end.
   end.

if v-pos-sum > 0 then do:

   put unformatted " " skip.
   put unformatted "                         РАСХОДНЫЙ КАССОВЫЙ ОРДЕР " skip(2).

   find first ofc where ofc.ofc = g-ofc no-lock no-error.
   if avail ofc then
   put unformatted ofc.name "/" ofc.ofc + "                         " + string(g-today,"99/99/9999") skip.

   put unformatted fill ("=", 77) skip.
   put unformatted "ВАЛЮТА                                      ПРИХОД                РАСХОД" skip.
   put unformatted fill ("-", 77) skip.
   put unformatted "Тенге                                         0.00    " v-pos-sum format ">>>,>>>,>>>,>>9.99" skip(1).
   put unformatted "                   ИТОГО                      0.00    " v-pos-sum format ">>>,>>>,>>>,>>9.99" skip(2).

   put 'Сумма прописью :' skip(1).

   temp = string (v-pos-sum).

   if num-entries(temp,".") = 2 then do:
      temp = substring(temp, length(temp) - 1, 2) + " тенге ".
      if num-entries(temp,".") = 2 then
      temp = " " + substring(temp,2,1) + "0" + " тиын".
   end.
   else temp = " тенге 00" + " тиын".

   strTemp = string(truncate(v-pos-sum,0)).

   run Sm-vrd(input v-pos-sum, output strAmount).
   strAmount = strAmount + temp.

   if length(strAmount) > 80 then do:
          str1 = substring(strAmount,1,80).
          str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
          put unformatted str1 skip str2 skip(0).
     end.
   else  put unformatted strAmount skip(0).


   put unformatted "Менеджер:                  Контролер:                       Кассир:" skip(2).
   put unformatted "Паспорт" skip.
   if v-bin then put unformatted "ИИН" skip.
   else put unformatted "РНН" skip.
   put unformatted "Подпись" skip(1).


   put unformatted fill ("=", 77) skip(1).
   find first ofc where ofc.ofc = v-ksofc no-lock no-error.
   if avail ofc then
   put unformatted "Примеч. - Зачисление по кассиру: " ofc.name " / " + ofc.ofc + " за " string(v-date) skip.
   put unformatted fill ("=", 77) skip(1).
end.

   output close.

   unix silent prit prihod.img.




