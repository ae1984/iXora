/* kdkrvew.i
 * MODULE
        Кредитный  Модуль
 * DESCRIPTION
        Решение кред комитета
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-7
 * AUTHOR
        17.03.2004 marinav
 * CHANGES
        30/04/2004 madiar - изменил can-find для kdlon.resume.
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
define var v-num as inte format ">>>>9".
define var v-krkom as char format "x(25)".

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
  kdlon.resume  label  "РЕШЕНИЕ       " colon 15 help " F2 - справочник" 
  validate (kdlon.resume <> "msc" and can-find (bookcod where (bookcod.bookcod = "kdresum" or bookcod.bookcod = "kdresgo" or
                     bookcod.bookcod = "kdmres" or bookcod.bookcod = "kdmresgo") and 
              bookcod.code = kdlon.resume no-lock), " Неверный код ! Выберите из справочника")
  v-resdescr no-label format "x(40)" colon 19 

  kdlon.datkk label    "ДАТА          " colon 15 
  v-num label          "ВОПРОС N " colon 38 
  v-krkom no-label colon 45 skip 

  "УСЛОВИЯ КРЕДИТА" colon 30 skip
  "ЗАПРАШИВАЕМЫЕ                       ОДОБРЕННЫЕ" colon 15 SKIP
  kdlon.type_lnz label 
  "Инстр-т фин-я" format "x(3)" help " F2 - справочник" colon 14  
  validate (kdlon.type_lnz <> "msc" and can-find (bookcod where bookcod.bookcod = "kdfintyp" and 
              bookcod.code = kdlon.type_lnz no-lock), " Неверный код ! Выберите из справочника")
  v-insdescr no-label colon 19 
  kdlon.type_ln format "x(3)" help " F2 - справочник" no-label colon 44 
  validate (kdlon.type_ln <> "msc" and can-find (bookcod where bookcod.bookcod = "kdfintyp" and 
              bookcod.code = kdlon.type_ln no-lock), " Неверный код ! Выберите из справочника")
  v-insdescr1 no-label colon 49 skip

  kdlon.amountz label 
  "Сумма        " colon 14 kdlon.amount no-label colon 44 skip

  kdlon.crcz format ">9" label 
  "Валюта кред  " colon 14 help " F2 - поиск" v-crcdescr no-label colon 19 
   kdlon.crc format ">9" no-label colon 44 v-crcdescr1 no-label colon 49 skip

  kdlon.ratez format ">9.99%" label 
  "Ставка %     "  colon 14 kdlon.rate format ">9.99%" no-label colon 44 skip

  kdlon.srokz format ">>9" label 
  "Период (мес) "   colon 14 kdlon.srok format ">>9" no-label colon 44 skip

  kdlon.goalz format "x(3)" help " F2 - справочник" label 
  "Цель кредита " colon 14  v-tgtdescr no-label colon 19 
  kdlon.goal format "x(3)" no-label help " F2 - справочник" colon 44 v-tgtdescr1 no-label colon 49 skip

  kdlon.repayz  format "x(30)" label 
  "Погашение ОД " colon 14  
  kdlon.repay format "x(30)" no-label colon 44 

  kdlon.repay%z format "x(30)" label 
  "Выплата %    " colon 14 help " F2 - справочник"  
  kdlon.repay% format "x(30)" no-label colon 44 
  kdlon.rescha[1] format "x(30)" label 
  "Период доступности                         "    


  with centered row 3 width 80 side-labels frame kdkrkom.

