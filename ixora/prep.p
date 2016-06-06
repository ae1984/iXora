/* kztcreg.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Отчет по видам платежей
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
        31/12/99 pragma
 * CHANGES
*/


{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{comm-chk.i}
{global.i}

def temp-table tcommpl like commonpl.
def var dat as date.
def var files as char initial "".
def var outf as char.
def var subj as char.
def var selgrp  as integer init 9.
def var selarp  as char.
def var ourbank as char.
def var p-parameter as integer init 100 no-undo.
def var p-count as integer init 0 no-undo.
def var p-patch as integer init 1 no-undo.
def var p-patch-sum as decimal init 0 no-undo.
def var p-patch-comsum as decimal init 0 no-undo.  /* сумма комиссии по пачке*/
def var tcnt as integer init 0 no-undo.
def var tsum as decimal init 0 no-undo.            /* общая сумма комиссии*/
def var ttsum as decimal init 0 no-undo.           /* общая сумма + комиссия*/


def var ksum as decimal init 0 no-undo.           
def var kcom as decimal init 0 no-undo.           
def var kproc as decimal init 0 no-undo.           
def var kkol as integer init 0 no-undo.           
DEFINE STREAM s1.

dat = g-today.

update dat label ' Укажите дату ' format '99/99/99' skip
with side-label row 5 centered frame dataa .




  OUTPUT STREAM s1 TO kztcreg.txt.

  put STREAM s1 unformatted
  "                                             РЕЕСТР" skip
  "                               по учету платежей  за " + string(dat,'99/99/9999') + " г." skip(1).



/*кар тел*/
  ksum  = 0.  kcom  = 0.  kproc = 0. kkol = 0. 
  for each commonpl no-lock where commonpl.txb = 0 and date = dat and commonpl.arp = "003904699" and commonpl.grp = 4 and commonpl.type = 2 and deluid = ?:
      ksum = ksum + commonpl.sum. 
      kcom = kcom + commonpl.comsum.
      kkol = kkol + 1.
  end.
  kproc = truncate(ksum * 0.004, 2).


  put STREAM s1 unformatted
  fill("=", 104) format "x(104)" skip                                                
  "Платежи ТОО Кар-тел "          skip
  "Количество "    kkol    skip
  "Сумма "    ksum    skip
  "Комиссия " kcom    skip
  "Проценты " kproc   skip(2).


/*ИВЦ*/
  ksum  = 0.  kcom  = 0.  kproc = 0. kkol = 0.
  for each commonpl no-lock where commonpl.txb = 0 and date = dat and commonpl.arp = "000904883" and commonpl.grp = 5 and commonpl.type = 1 and deluid = ?:
      ksum = ksum + commonpl.sum. 
      kcom = kcom + commonpl.comsum.
      kkol = kkol + 1.
  end.
  kproc = truncate(ksum * 0.003, 2).

  put STREAM s1 unformatted
  fill("=", 104) format "x(104)" skip                                                
  "Платежи ИВЦ "          skip
  "Количество "    kkol    skip
  "Сумма "    ksum    skip
  "Комиссия " kcom    skip
  "Проценты " kproc   skip(2).

/*Водоканал*/
  ksum  = 0.  kcom  = 0.  kproc = 0. kkol = 0.
  for each commonpl no-lock where commonpl.txb = 0 and date = dat and commonpl.arp = "000904074" and commonpl.grp = 7 and commonpl.type = 1 and deluid = ?:
      ksum = ksum + commonpl.sum. 
      kcom = kcom + commonpl.comsum.
      kkol = kkol + 1.
  end.
  kproc = truncate(ksum * 0.005, 2).


  put STREAM s1 unformatted
  fill("=", 104) format "x(104)" skip                                                
  "Платежи ВОДОКАНАЛ "          skip
  "Количество "    kkol    skip
  "Сумма "    ksum    skip
  "Комиссия " kcom    skip
  "Проценты " kproc   skip(2).

/*Базис*/
  ksum  = 0.  kcom  = 0.  kproc = 0. kkol = 0.
  for each commonpl no-lock where commonpl.txb = 0 and date = dat and commonpl.arp = "003904301" and commonpl.grp = 9 and commonpl.type = 18 and deluid = ?:
      ksum = ksum + commonpl.sum. 
      kcom = kcom + commonpl.comsum.
      kkol = kkol + 1.
  end.
  kproc = truncate(ksum * 0.000, 2).


  put STREAM s1 unformatted
  fill("=", 104) format "x(104)" skip                                                
  "Платежи Базис-телеком "          skip
  "Количество "    kkol    skip
  "Сумма "    ksum    skip
  "Комиссия " kcom    skip
  "Проценты " kproc   skip(2).

/*Налоговые платежи*/
  ksum  = 0.  kcom  = 0.  kproc = 0. kkol = 0.
  for each tax no-lock where tax.txb = 0 and tax.date = dat  and tax.duid = ?:
      ksum = ksum + tax.sum. 
      kcom = kcom + tax.comsum.
      kkol = kkol + 1.
  end.

  put STREAM s1 unformatted
  fill("=", 104) format "x(104)" skip                                                
  "Налоговые платежи "          skip
  "Количество "    kkol    skip
  "Сумма "    ksum    skip
  "Комиссия " kcom    skip
  "Проценты " kproc   skip.




    OUTPUT STREAM s1 CLOSE.

  run menu-prt ("kztcreg.txt").
/*
  unix silent value ( ' cp kztcreg.txt ' + outf ).

  files = files + ";" + outf.
  display "Сформирован файл " outf format "x(9)" " на сумму "
     (ACCUM TOTAL tcommpl.sum) with no-labels.
  pause.
  */

