/* kdlon.f Электронное кредитное досье
     Форма для ведения Досье клиента
 * MODULE
     Электронное кредитное досье
 * DESCRIPTION
      Форма для заведения нового клиента в ЭКД
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


   20.05.2003 marinav
*CHANGES
   30/04/2004 madiar - изменил can-find для kdlon.resume.
   12/05/2004 madiar - изменил заголовок "ПРЕДЛОЖЕННЫЕ / ОДОБРЕННЫЕ" на "РЕКОМЕНДУЕМЫЕ"
   30.09.2005 marinav - изменения для бизнес-кредитов
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


form
  kdcif.kdcif label "КОД КЛИЕНТА   " 
    help " F2 - поиск"
    colon 15

  kdlon.manager format "x(2)" colon 40 label "ТИП"
          help " Корпоративный, Бизнес (F2 - справочник)"
  validate (kdlon.manager <> "msc" and can-find (bookcod where bookcod.bookcod = "kdbk" and 
              bookcod.code = kdlon.manager no-lock), " Неверный код ! Выберите из справочника")

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
  validate (kdlon.resume <> "msc" and can-find (bookcod where (bookcod.bookcod = "kdresum" or bookcod.bookcod = "kdresgo" or
                 bookcod.bookcod = "kdmres" or bookcod.bookcod = "kdmresgo") and 
              bookcod.code = kdlon.resume no-lock), " Неверный код ! Выберите из справочника")
  v-resdescr no-label format "x(40)" colon 19 
  "УСЛОВИЯ КРЕДИТА" colon 30 skip
  "ЗАПРАШИВАЕМЫЕ                 РЕКОМЕНДУЕМЫЕ" colon 15 SKIP(1)
  kdlon.type_lnz label 
  "Инстр-т фин-я" format "x(3)" help " F2 - справочник" colon 14  
  validate (kdlon.type_lnz <> "msc" and can-find (bookcod where bookcod.bookcod = "kdfintyp" and 
              bookcod.code = kdlon.type_lnz no-lock), " Неверный код ! Выберите из справочника")
  v-insdescr no-label colon 19 
  kdlon.type_ln format "x(3)" help " F2 - справочник" no-label colon 45 
  validate (kdlon.type_ln <> "msc" and can-find (bookcod where bookcod.bookcod = "kdfintyp" and 
              bookcod.code = kdlon.type_ln no-lock), " Неверный код ! Выберите из справочника")
  v-insdescr1 no-label colon 50 skip

  kdlon.amountz label 
  "Сумма        " colon 14 kdlon.amount no-label colon 45 skip

  kdlon.crcz format ">9" label 
  "Валюта кред  " colon 14 help " F2 - поиск" v-crcdescr no-label colon 19 
   kdlon.crc format ">9" no-label colon 45 v-crcdescr1 no-label colon 49 skip

  kdlon.ratez format ">9.99%" label 
  "Ставка %     "  colon 14 kdlon.rate format ">9.99%" no-label colon 45 skip

  kdlon.srokz format ">>9" label 
  "Период (мес) "   colon 14 kdlon.srok format ">>9" no-label colon 45 skip

  kdlon.goalz format "x(3)" help " F2 - справочник" label 
  "Цель кредита " colon 14  v-tgtdescr no-label colon 19 
  kdlon.goal format "x(3)" no-label help " F2 - справочник" colon 45 v-tgtdescr1 no-label colon 50 skip

  kdlon.repayz  format "x(30)" label 
  "Погашение ОД " colon 14  
  kdlon.repay format "x(30)" no-label colon 45 

  kdlon.repay%z format "x(30)" label 
  "Выплата %    " colon 14 help " F2 - справочник"  
  kdlon.repay% format "x(30)" no-label colon 45 

/*
  kdlon.repayz  format "x(3)" label 
  "Погашение ОД " colon 14 help " F2 - справочник"  
  validate (kdlon.repayz <> "msc" and can-find (bookcod where bookcod.bookcod = "kdrepay" and 
              bookcod.code = kdlon.repayz no-lock), " Неверный код ! Выберите из справочника")
  v-repdescr no-label colon 19 
  kdlon.repay format "x(3)" no-label colon 44 
  validate (kdlon.repay <> "msc" and can-find (bookcod where bookcod.bookcod = "kdrepay" and 
              bookcod.code = kdlon.repay no-lock), " Неверный код ! Выберите из справочника")
  v-repdescr1 no-label colon 49 skip

  kdlon.repay%z format "x(3)" label 
  "Выплата %    " colon 14 help " F2 - справочник"  
  validate (kdlon.repay%z <> "msc" and can-find (bookcod where bookcod.bookcod = "kdrepay" and 
              bookcod.code = kdlon.repay%z no-lock), " Неверный код ! Выберите из справочника")
  v-rep%descr no-label colon 19 
  kdlon.repay% format "x(3)" no-label colon 44 
  validate (kdlon.repay% <> "msc" and can-find (bookcod where bookcod.bookcod = "kdrepay" and 
              bookcod.code = kdlon.repay% no-lock), " Неверный код ! Выберите из справочника")
  v-rep%descr1 no-label colon 49 skip
*/


  with centered row 3 width 80 side-labels frame kdlon.

