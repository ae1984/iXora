/* kdzal.f
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Форма для Работы с обеспечением
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-6
 * AUTHOR
        13.01.2004 marinav
 * CHANGES
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
  kdcif.kdcif label "КОД КЛИЕНТА   "     help " F2 - поиск"    colon 15

  kdlon.bank format "x(6)" label "БАНК" colon 57 skip

  kdlon.kdlon label "КОД ДОСЬЕ     "     help " F2 - поиск"    colon 15

  kdlon.regdt label "РЕГИСТ" colon 57 
  kdlon.who no-label colon 69 skip  

  kdlon.sts label   "СТАТУС ДОСЬЕ  " colon 15 
  v-stsdescr no-label format "x(40)" colon 20 skip

  kdlon.lonstat label  "КЛАССИФИКАЦИЯ " colon 15  
  v-statdescr no-label colon 19 skip

  kdlon.resume  label  "РЕШЕНИЕ       " colon 15
  v-resdescr no-label format "x(40)" colon 19 

  kdcif.name label     "ПОЛН НАИМ     " colon 15 skip

  kdcif.urdt LABEL     "ДАТА РЕГИСТ   " colon 15 kdcif.urdt1 LABEL "ДАТА ПЕРВ РЕГИСТ" colon 57 skip
  kdcif.regnom LABEL   "РЕГ НОМЕР     " colon 15 skip
  kdcif.addr[1] LABEL  "ЮРИД АДРЕС    " colon 15 skip
  kdcif.addr[2] LABEL  "ФАКТ АДРЕС    " colon 15 skip
  kdcif.tel LABEL      "ТЕЛЕФОНЫ      " colon 15 
  kdcif.sotr LABEL "КОЛ-ВО СОТР" colon 57 skip

  kdcif.chief[1] LABEL "РУКОВОДИТЕЛЬ  " format "x(50)" colon 15 skip
  kdcif.job[1]   LABEL "ДОЛЖНОСТЬ     " format "x(50)" colon 15 skip
  kdcif.docs[1]  LABEL "НОМЕР ДОК     " format "x(50)" colon 15 skip
  kdcif.rnn_chief[1] LABEL "РНН РУК-ЛЯ    "colon 15 skip
  kdcif.chief[2] LABEL "ГЛ. БУХГАЛТЕР " format "x(50)" colon 15 skip

  with centered row 3 width 80 side-labels frame kdzal.

