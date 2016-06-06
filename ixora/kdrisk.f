/* kdlon.f Электронное кредитное досье
     Форма для ведения Досье клиента


   20.05.2003 marinav
*/


def var v-stsdescr as char .
def var v-insdescr as char format "x(20)".
def var v-statdescr as char format "x(30)".
def var v-resdescr as char format "x(20)".
def var v-crcdescr as char format "x(3)".
def var v-tgtdescr as char format "x(20)".
def var v-repdescr as char format "x(20)".
def var v-rep%descr as char format "x(20)".
def var v-insdescr1 as char format "x(20)".
def var v-crcdescr1 as char format "x(3)".
def var v-tgtdescr1 as char format "x(20)".
def var v-repdescr1 as char format "x(20)".
def var v-rep%descr1 as char format "x(20)".

/*предложенные риск-менеджером*/
def var r-type_ln like kdlon.type_ln.
def var r-amount like kdlon.amount.
def var v-crc like kdlon.crc.
def var r-rate like kdlon.rate.
def var r-srok like kdlon.srok.
def var r-goal like kdlon.goal.
def var r-repay   like kdlon.repay.
def var r-repay%  like kdlon.repay%.


form
  kdcif.kdcif label "КОД КЛИЕНТА   " 
    help " F2 - поиск"
    colon 15

  kdlon.bank format "x(6)" label "БАНК" colon 57 skip

  kdlon.kdlon label "КОД ДОСЬЕ     " 
    help " F2 - поиск"
    colon 15

  kdlon.regdt label "РЕГИСТ" colon 57 
  kdlon.who no-label colon 69 skip  

  kdlon.sts label   "СТАТУС ДОСЬЕ  " colon 15 
    help " F2 - справочник"
    validate (kdlon.sts <> "msc" and can-find (bookcod where bookcod.bookcod = "kdsts" and 
              bookcod.code = kdlon.sts no-lock), " Неверный статус !")
  v-stsdescr no-label format "x(40)" colon 20 skip

  kdcif.name    label  "ПОЛНОЕ НАИМ   " colon 15 skip
  kdlon.lonstat label  "КЛАССИФИКАЦИЯ " colon 15 help " F2 - справочник" 
  validate (kdlon.lonstat <> "msc" and can-find (bookcod where bookcod.bookcod = "kdstat" and 
              bookcod.code = kdlon.lonstat no-lock), " Неверный код ! Выберите из справочника")
  v-statdescr no-label colon 19 skip
  kdlon.resume  label  "РЕШЕНИЕ       " colon 15 help " F2 - справочник" 
  validate (kdlon.resume <> "msc" and can-find (bookcod where bookcod.bookcod = "kdresum" and 
              bookcod.code = kdlon.resume no-lock), " Неверный код ! Выберите из справочника")
  v-resdescr no-label format "x(40)" colon 19 
  "УСЛОВИЯ КРЕДИТА" colon 30 skip
  "ПРЕДЛОЖЕННЫЕ                ПРЕДЛОЖЕННЫЕ РИСК-МЕНЕДЖЕРОМ" colon 15 SKIP(1)
  kdlon.type_ln label 
  "Инстр-т фин-я" format "x(3)" help " F2 - справочник" colon 14  
  v-insdescr no-label colon 19 
  r-type_ln format "x(3)" help " F2 - справочник" no-label colon 44 
  validate (r-type_ln <> "msc" and can-find (bookcod where bookcod.bookcod = "kdfintyp" and 
              bookcod.code = r-type_ln no-lock), " Неверный код ! Выберите из справочника")
  v-insdescr1 no-label colon 49 skip

  kdlon.amount label 
  "Сумма        " colon 14 r-amount no-label colon 44 skip

  kdlon.crc format ">9" label 
  "Валюта кред  " colon 14 help " F2 - поиск" v-crcdescr no-label colon 19 
   v-crc format ">9" no-label colon 44 v-crcdescr1 no-label colon 49 skip

  kdlon.rate format ">9.99%" label 
  "Ставка %     "  colon 14 r-rate format ">9.99%" no-label colon 44 skip

  kdlon.srok format ">>9" label 
  "Период (мес) "   colon 14 r-srok format ">>9" no-label colon 44 skip

  kdlon.goal format "x(3)" help " F2 - справочник" label 
  "Цель кредита " colon 14  v-tgtdescr no-label colon 19 
  r-goal format "x(3)" no-label help " F2 - справочник" colon 44 v-tgtdescr1 no-label colon 49 skip

  kdlon.repay  format "x(30)" label 
  "Погашение ОД " colon 14  
  r-repay format "x(30)" no-label colon 44 

  kdlon.repay% format "x(30)" label 
  "Выплата %    " colon 14 help " F2 - справочник"  
  r-repay% format "x(30)" no-label colon 44 

  with centered row 3 width 80 side-labels frame kdrisk.

