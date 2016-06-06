/* pkgrf2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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

/** 03.03.03 KOVAL Аннутивная схема **/
{global.i}
{pk.i}
{lonlev.i}

def var vduedt like lon.duedt.
def var vregdt like lon.rdt.
def var vopnamt like lon.opnamt.
def var vprem like lon.prem.
def var vbasedy like lon.basedy.
def var vdat like lnsch.stdat.
def var vdat0 like lnsch.stdat.
def var vdat1 like lnsch.stdat.
def var vopn like lnsch.stval.
def var vopn0 like lnsch.stval.
def var vopn1 like lnsch.stval.
def var vyear as inte.
def var vmonth as inte.
def var vday as inte.
def var vvday as inte.
def var mdays as inte.
def var vint like lnsch.stval.

def var iMonth as integer.
def var iPlan  like lon.plan.
def var iSumO  like lon.dam[1] init 0.     /* общая сумма долга */
def var iSumP  like lon.Dam[1] init 0.     /* общая сумма долга по процентам */
def var iperc  like lon.prem init 0.
def var iDate1 like lon.rdt.             /* Дата начала кредита */
def var iDate2 like lon.duedt.           /* Дата окончания кредита */
def var iBaseDay as integer format "99" init 30.
def var iDays1   as integer format "99".     /* Кол-во дней пользования кредитом в первый период */
def var i as integer. /* Просто счетчик */
def var iNN as integer. /* НЕ Просто счетчик определяет с какого месяца делать пересчет */
def var SumDebt  like lon.dam[1]  init 0.     /* Основная сумма долга */
def var SumVz    like lon.dam[1]  init 0.     /* Сумма Вознаграждения */
def var SumVzP   like lon.dam[1]  init 0.     /* Сумма Вознаграждения в первый месяц */
def var SumAvO   like lon.dam[1]  init 0.     /* Сумма основного долга, ежемесячная */
def var SSumO    like lon.dam[1]  init 0.     /* итоговая сумма долга, для коррекции погрешности */
def var SSumV    like lon.dam[1]  init 0.     /* итоговая сумма вознаграждения */
def var SSumEvrM like lon.dam[1]  init 0.    /* итоговая сумма Ежемесячного платежа */
def var AtlSum   like lon.dam[1]  init 0.     /* Фактическая Сумма кредита с учетом проплат */
def var tmpYear as integer.
def var tmpMonth as integer.
def var SumFault as decimal.
def var NextMonth as logical init false.
def var NextDays  as integer init 0.
                           
def stream lgg.
output stream lgg to log.txt.

def temp-table cxema
 field nn as integer format ">>>9"
 field Dp as date format "99.99.9999"
 field days as integer format "99"
 field AmtBase as decimal format "->>>,>>>,>>>,>>9.99"
 field AmtDebt as decimal format "->>>,>>>,>>>,>>9.99"
 field AmtPerC as decimal format "->>>,>>>,>>>,>>9.99"
 field AmtEvrM as decimal format "->>>,>>>,>>>,>>9.99"
 field AmtEnd  as decimal format "->>>,>>>,>>>,>>9.99"
 index nn is primary nn.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
find lon where lon.lon = pkanketa.lon no-lock.

assign
 iDate1 = lon.rdt
 iDate2 = lon.duedt.

Assign
 iSump  = lon.dam[2] - lon.cam[2] /* общая сумма долга по процентам */
 iPerc  = lon.prem 		                  /* процентная ставка */
 iMonth = round((iDate2 - iDate1) * 12 / 365, 0)  /* Кол-во месяцев */
 iPlan  = lon.plan.

run lon2hand(input lon.lon, output iSumO).
/* Выясним, надо ли пересчитать весь график или до даты последней оплаты */

run atl-dat1(input lon.lon, input g-today, input 3, output AtlSum).

 if iSumO <> AtlSum then do: 
 /* Старый график */
      for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > -1
      and stdat > g-today:
         delete lnsch.
      end.
      for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > -1 
      and idat > g-today:
         delete lnsci.
      end.
      /* Увеличим число на кол-во оставшихся линий */
      iNN = 1.
      for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > -1:
         iNN = iNN + 1.
      end.
      iSumO = AtlSum.
 end.
 /* Новый график */
 else do: 
      for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > -1:
         delete lnsch.
      end.
      for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > -1:
         delete lnsci.
      end.
      iNN = 1.
 end.

 tmpMonth =  month(lon.rdt).
 tmpYear  =  year (lon.rdt).

 /* Будет ли выплата производится во второй месяц */
 if (day(iDate1) - lon.day + 1) >= 25 
 then do:
     assign iMonth    = iMonth - 1 
            NextMonth = true
            iDays1    = 2 * iBaseDay - day(iDate1) + lon.day. 
     if tmpMonth + 1 > 12 then assign tmpMonth = 1 
                                      tmpYear  = tmpYear + 1.
                          else tmpMonth = tmpMonth + 1.
 end.
 else iDays1 = (iBaseDay - day(iDate1) + lon.day).

put stream lgg
 'lon      ' lon.lon skip
 'g-today  ' g-today skip
 'pkanketa.ln ' pkanketa.ln skip
 'iDate1 ' iDate1 skip
 'iDate2 ' iDate2 skip
 'iSump  ' iSump  skip
 'iperc  ' iperc  skip
 'imonth ' imonth skip
 'iPlan  ' iPlan  skip
 'iSumO  ' iSumO  format "->>>,>>>,>>>,>>9.99" skip
 'SSumO  ' SSumO  format "->>>,>>>,>>>,>>9.99" skip
 'AtlSum ' AtlSum format "->>>,>>>,>>>,>>9.99" skip
 'iDays1 ' iDays1 skip
 'iNN    ' iNN    skip
 'iMonth ' iMonth skip
 'NextMonth ' NextMonth skip
 'tmpMonth ' tmpMonth skip
 'tmpYear  ' tmpYear skip.


/* Main cycle */
do i = 1 to iMonth:

   /* Счетчик дат */
   if tmpMonth + 1 > 12 then assign tmpMonth = 1 
                                    tmpYear  = tmpYear + 1.
                        else tmpMonth = tmpMonth + 1.
   if i < iNN then next. /* Проскочим оплаченные месяцы */

   create cxema.
   if i = 1 then cxema.days = iDays1 .
            else cxema.days = iBaseDay .

   assign
      cxema.nn = i
      cxema.Dp = date(string(lon.day,"99") + "." + String(tmpMonth,"99") + "." + String(tmpYear,"9999")).
   
      if i = 1 then do:
           /* Ежемесячный платеж */
           SumAvO = round((iSumO * iPerc / 100 / 12) / ( 1 - (1 / exp(1 + iPerc / 100 / 12, iMonth) ) ),2).
           SumVzP = round(iSumO * iPerc * iBaseDay / (lon.basedy * 100 ), 2).

           /* Сумма вознаграждения в первый месяц исходя из фактического времени пользования кредитом */
           SumVz = round(iSumO * iPerc * iDays1 / (lon.basedy * 100 ), 2).
           
           /* Сумма платежа по основному долгу */
           SumDebt = SumAvO - SumVzP.

           /* Первый платеж составит */
           cxema.AmtEvrM = SumDebt + SumVz.
      end.
      else do:
           /* проверим Если график пересчитывался, то получим среднемесячную сумму снова */
           if iNN <> 1 then 
           SumAvO = round((iSumO * iPerc / 100 / 12) / ( 1 - (1 / exp(1 + iPerc / 100 / 12, iMonth - iNN + 1) ) ),2). 

           /* Сумма вознаграждения в следующие месяцы */
           SumVz = round((iSumO - SSumO) * iPerc * iBaseDay / ( lon.basedy * 100 ),2).

           /* Сумма платежа по основному долгу */
           SumDebt = SumAvO - SumVz.

           cxema.AmtEvrM = SumAvO.
      end.

      cxema.AmtDebt = SumDebt.
      cxema.AmtBase = iSumO - SSumO.
      cxema.AmtPerC = SumVz.

      SSumO    = SSumO + SumDebt.
      SSumEvrM = SSumEvrM + cxema.AmtEvrM.
      SSumV    = SSumV + SumVz.

      cxema.AmtEnd = iSumO - SSumO.

      /* Коррекция погрешности расчета с добавлением ее в первую сумму */
      if i = iMonth and cxema.AmtEnd <> 0 then do:
           SumFault = cxema.AmtEnd.
           cxema.AmtEnd = 0.

           find first cxema where cxema.nn > 0 use-index nn no-error .
           assign 
                cxema.AmtDebt = cxema.AmtDebt + SumFault
                cxema.AmtEvrM = cxema.AmtEvrM + SumFault
                SSumO = SSumO + SumFault.

           put stream lgg skip 
           'SumFault = ' SumFault skip.

           /* итоговая строка */
           create cxema.
           assign
           cxema.nn=0
           cxema.AmtDebt = SSumO
           cxema.AmtEvrM = SSumEvrM
           cxema.AmtPerC = SSumV
           cxema.AmtEnd  = 0.
      end.

  end. /* Main cycle */

  /* Перенос схемы в LOAN's*/
  for each cxema where nn > 0 use-index nn .
      put stream lgg
             cxema.nn ' '
             cxema.Dp ' '
             cxema.days
             cxema.AmtBase
             cxema.AmtDebt
             cxema.AmtPerC
             cxema.AmtEvrM
             cxema.AmtEnd skip.

      create lnsch.
      create lnsci.
      assign
  	lnsch.lnn   = lon.lon
        lnsch.stdat = cxema.Dp
        lnsch.stval = cxema.AmtDebt
        lnsch.f0    = 1
  	lnsci.lni   = lon.lon
        lnsci.idat  = cxema.Dp
        lnsci.iv-sc = cxema.AmtPerC
        lnsci.f0    = 1.
  end.

  run lnsch-ren(s-lon).
  release lnsch.         

  run lnsci-ren(s-lon).
  release lnsci.
