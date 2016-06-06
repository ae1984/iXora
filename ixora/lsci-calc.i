/* lsci-calc.i
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
        11.03.2011 aigul - исправила расчет процентов
        31/08/2011 kapar - новый алгоритм исчисления 365/366 дней в году для (овердрафт и факторинг)
*/

def var grec as recid.
def var hrec as recid.
define variable dn1 as integer.
define variable dn2 as decimal.
def var v_dd      as int.
def var v_basedy  as int.
def var v_day     as int.
def var v_prnmos  as int.
def var v_rdt     as date.
def var v_iv-sc   as deci.

vrest = 0.
inter:
for each lnsci where {&where-i}:
 lnsci.iv-sc = 0.

v_prnmos = 0.
find first lon where lon.lon = lnsci.lni no-lock no-error.
if available lon then do:
 v_prnmos = lon.prnmos.
 v_rdt = lon.rdt.
end.

inner:
repeat:
 cas = 0.
 find first lnscg where {&where-g} and lnscg.stdat > tau
                                    and lnscg.stdat <= lnsci.idat no-error.
 grec = recid(lnscg).
 find first lnsch where {&where-h} and lnsch.stdat > tau
                                    and lnsch.stdat <= lnsci.idat no-error.
 hrec = recid(lnsch).
if available lnscg then cas = 1.
if available lnsch then do:
      if cas = 0 then cas = 2.
      if cas = 1 then do:
         if lnsch.stdat < lnscg.stdat then cas = 2.
         else if lnsch.stdat >= lnscg.stdat then cas = 1.
      end.
end.
   if cas = 0 then do:
      if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
        run mondays(2,year(lnsci.idat),output v_dd).
        if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
        v_day = day(lnsci.idat).
      end.
      else
        v_basedy = lon.basedy.

      run day-360(tau,lnsci.idat - 1,v_basedy,output dn1,output dn2).
      lnsci.iv-sc = lnsci.iv-sc + /*round(vrest * dn1 *  coe, 2)*/ round(vrest * dn1 *  vprem / v_basedy / 100, 2).

      tau = lnsci.idat.
      leave inner. end.
   else
   if cas = 1 then do:
      if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
        run mondays(2,year(lnscg.stdat),output v_dd).
        if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
        v_day = day(lnscg.stdat).
      end.
      else
        v_basedy = lon.basedy.

      run day-360(tau,lnscg.stdat - 1,v_basedy,output dn1,output dn2).
      lnsci.iv-sc = lnsci.iv-sc + /*round(vrest * dn1 *  coe, 2)*/ round(vrest * dn1 *  vprem / v_basedy / 100, 2).

      vrest = vrest + lnscg.stval.
      tau = lnscg.stdat.
      vnrr = lnscg.f0.
      for each lnscg where {&where-g} and lnscg.stdat = tau
                                      and recid(lnscg) <> grec:
         vrest = vrest + lnscg.stval.
      end.
      for each lnsch where {&where-h} and lnsch.stdat = tau:
         vrest = vrest - lnsch.stval.
      end.
      next inner. end.
   else
   if cas = 2 then do:
      if ((v_prnmos = 1) or (v_prnmos = 3)) and (v_rdt > date('01/09/2011')) then do:
        run mondays(2,year(lnsch.stdat),output v_dd).
        if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
        v_day = day(lnsch.stdat).
      end.
      else
        v_basedy = lon.basedy.

      run day-360(tau,lnsch.stdat - 1,v_basedy,output dn1,output dn2).

      if (month(lnsch.stdat) = 1) and (v_basedy = 366) then do:
        v_iv-sc = round(vrest * v_day *  vprem / v_basedy / 100, 2).
        v_iv-sc = v_iv-sc + round(vrest * (dn1 - v_day) *  vprem / (v_basedy - 1) / 100, 2).
        lnsci.iv-sc = lnsci.iv-sc + v_iv-sc.
      end.
      else
        lnsci.iv-sc = lnsci.iv-sc + /*round(vrest * dn1 *  coe, 2)*/ round(vrest * dn1 *  vprem / v_basedy / 100, 2).

      vrest = vrest - lnsch.stval.
      tau = lnsch.stdat.
      vnrr = lnsch.f0.
      for each lnsch where {&where-h} and lnsch.stdat = tau
                                      and recid(lnsch) <> hrec:
         vrest = vrest - lnsch.stval.
      end.
      for each lnscg where {&where-g} and lnscg.stdat = tau:
         vrest = vrest + lnscg.stval.
      end.
      next inner. end.
 end.
end. /*inter*/

vint = 0.
for each lnsci where {&where-i}:
 vint = vint + lnsci.iv-sc.
end.

