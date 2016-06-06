/* lngrf-2.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
       Построение графика аннуитетной схемы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-1-2 Календари
 * AUTHOR
        04.09.2003 marinav
 * CHANGES
        30/07/2004 madiyar - добавил возможность выбора суммы для пересчета графика
        11/03/2005 madiyar - при нажатии F4 все же происходило удаление графиков, исправил
        12/08/2010 aigul - Исправила вычисление 2-ой схемы при изменении дат выдачи и погашения кредита
        11/10/2010 madiyar - перенос платежей с выходных дней
        12/10/2010 madiyar - перекомпиляция
        21/01/2011 madiyar - спрашиваем, двигать графики с выходных дней или нет
        11.03.2011 aigul - в связи сдвигами для праздников изменила вычисление последней даты
        21.04.2011 aigul - исправила подсчет процентов для произвольной суммы
        06.01.2012 aigul - вызов новой проги для расчета аннуитета
        10.01.2012 aigul - убрала старый код
*/

{global.i}
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
def shared var s-lon like lnsch.lnn.
/*s-lon = '009151543'.*/
def new shared var v-sum3 as decimal initial 0.
define variable dn1 as integer.
define variable dn2 as decimal.
define var prevdt as date.
def var iMonth as integer.
def var iPlan  like lon.plan.
def var iSumO  like lon.dam[1] init 0.     /* общая сумма долга */
def var iSumP  like lon.Dam[1] init 0.     /* общая сумма долга по процентам */
def var iperc  like lon.prem init 0.
def var iDate1 like lon.rdt.             /* Дата начала кредита */
def var iDate2 like lon.duedt.           /* Дата окончания кредита */
def var iBaseDay as integer format "99" init 30.
def new shared var iDays1   as integer format "9999".     /* Кол-во дней пользования кредитом в первый период */
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
def var tmpYear% as integer.
def var tmpMonth% as integer.
def var tmpDate% as date.
def var SumFault as decimal.
def var NextMonth as logical init false.
def var NextDays  as integer init 0.

def var v-ja as logi no-undo.
def new shared var v-pdt as date.
def stream lgg.

def temp-table cxema
 field nn as integer format ">>>9"
 field Dp as date format "99.99.9999"
 field days as integer format "9999"
 field AmtBase as decimal format "->>>,>>>,>>>,>>9.99"
 field AmtDebt as decimal format "->>>,>>>,>>>,>>9.99"
 field AmtPerC as decimal format "->>>,>>>,>>>,>>9.99"
 field AmtEvrM as decimal format "->>>,>>>,>>>,>>9.99"
 field AmtEnd  as decimal format "->>>,>>>,>>>,>>9.99"
 index nn is primary nn.

find first lon where lon.lon = s-lon no-lock no-error.
assign
 iDate1 = lon.rdt
 iDate2 = lon.duedt.

Assign
 iSump  = lon.dam[2] - lon.cam[2] /* общая сумма долга по процентам */
 iPerc  = lon.prem 		                  /* процентная ставка */
 iPlan  = lon.plan.

run lon2hand(input lon.lon, output iSumO).  /* сколько было выдано фактически*/

/* Выясним, надо ли пересчитать весь график или до даты последней оплаты */

run atl-dat1(input lon.lon, input g-today, input 3, output AtlSum).      /*сколько осталось*/

 tmpMonth =  month(lon.rdt).
 tmpYear  =  year (lon.rdt).

/* если еще не выдавался кредит  т.е. AtlSum = 0, то считать график исходя из одобренной суммы*/
if AtlSum = 0 then  AtlSum = lon.opnamt.

/* 30/07/2004 madiar - дать возможность выбора - пересчитывать график исходя из остатка долга или из одобренной суммы */
def var v-sel as char init ''.
run sel2 ("Выбор :", " 1. Пересчет от остатка ОД | 2. Пересчет от одобренной суммы | 3. Пересчет от произвольной суммы", output v-sel).
if v-sel = "1" then do:
    run lngrfanu(lon.opnamt,"1").
    leave.
end.
if v-sel = "2" then /*AtlSum = lon.opnamt.*/ do:
    run lngrfanu(lon.opnamt,"2").
    leave.
end.
if v-sel = "3" then do:
  update AtlSum label " Введите сумму" validate(AtlSum > 0, " Ошибка!") with centered row 5 side-label frame fr.
  v-sum3 = AtlSum.
  run lngrfanu(v-sum3,"3").
  leave.
end.
if not(v-sel = '1' or v-sel = '2' or v-sel = '3') then return.
/* 30/07/2004 madiar end */

