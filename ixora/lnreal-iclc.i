/* lnreal-iclc.i
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

def var grec as recid.
def var hrec as recid.
def var datt as date.
define variable dn1 as integer.
define variable dn2 as decimal.
vrest = 0.
inter:
for each lnsci where {&where-i}:
 lnsci.iv = 0.
inner:
repeat:
/*disp lnsci.iv vrest intrat. pause.*/
 datt = lnsci.idat.
 cas = 0.
 find first ln%his where ln%his.lon = vlon and ln%his.stdat > tau
                                       and ln%his.stdat <= lnsci.idat no-error.
 find first rate where rate.base = lon.base and rate.cdt > tau
                                      and rate.cdt <= lnsci.idat no-error.
 find first lnscg where {&where-g} and lnscg.stdat > tau 
                                    and lnscg.stdat <= lnsci.idat no-error. 
 grec = recid(lnscg).
 find first lnsch where {&where-h} and lnsch.stdat > tau
                                    and lnsch.stdat <= lnsci.idat no-error.
 hrec = recid(lnsch).
 if available lnscg then do: datt = lnscg.stdat. cas = 1. end.
 if available lnsch then do:
    if lnsch.stdat < datt then do: datt = lnsch.stdat. cas = 2. end.
 end.
 if available rate then do:
    if rate.cdt < datt then do: datt = rate.cdt. cas = 3. end.
 end.
 if available ln%his then do:
   if ln%his.intrate <> intrat then do:
    if ln%his.stdat < datt then do: datt = ln%his.stdat. cas = 4. end.
   end.
 end. 
/*if available lnscg then cas = 1.
if available lnsch then do:
      if cas = 0 then cas = 2.
      if cas = 1 then do:
         if lnsch.stdat < lnscg.stdat then cas = 2.
         else if lnsch.stdat >= lnscg.stdat then cas = 1.
      end.
end.*/
   if cas = 0 then do:
      run day-360(tau,lnsci.idat - 1 ,lon.basedy,output dn1,output dn2).
      lnsci.iv = lnsci.iv + round(vrest * dn1
                                  * (basrate + intrat) * coe,2).
      tau = lnsci.idat.
      leave inner. end.
   else
   if cas = 1 then do:
      run day-360(tau,lnscg.stdat - 1 ,lon.basedy,output dn1,output dn2).
      lnsci.iv = lnsci.iv + round(vrest * dn1
                                  * (basrate + intrat) * coe,2).
      vrest = vrest + lnscg.paid.
      tau = lnscg.stdat.
      vnrr = lnscg.f0.
      for each lnscg where {&where-g} and lnscg.stdat = tau 
                                      and recid(lnscg) <> grec:
         vrest = vrest + lnscg.paid.
      end.
      for each lnsch where {&where-h} and lnsch.stdat = tau:
         vrest = vrest - lnsch.paid.
      end.
      for each ln%his where ln%his.lon = vlon and ln%his.stdat = tau:
         intrat = ln%his.intrate.
      end.
      for each rate where rate.base = lon.base and rate.cdt = tau:
         basrate = rate.rate.
      end.
      next inner. end.
   else
   if cas = 2 then do:
      run day-360(tau,lnsch.stdat - 1,lon.basedy,output dn1,output dn2).
      lnsci.iv = lnsci.iv + round(vrest * dn1
                                  * (basrate + intrat) * coe,2).
      vrest = vrest - lnsch.paid.
      tau = lnsch.stdat.
      vnrr = lnsch.f0.
      for each lnsch where {&where-h} and lnsch.stdat = tau
                                      and recid(lnsch) <> hrec:
         vrest = vrest - lnsch.paid.
      end.
      for each lnscg where {&where-g} and lnscg.stdat = tau:
         vrest = vrest + lnscg.paid.
      end.
      for each ln%his where ln%his.lon = vlon and ln%his.stdat = tau:
         intrat = ln%his.intrate.
      end.
      for each rate where rate.base = lon.base and rate.cdt = tau:
         basrate = rate.rate.
      end.
      next inner. end.
   else
   if cas = 3 then do:
      run day-360(tau,rate.cdt - 1,lon.basedy,output dn1,output dn2).
      lnsci.iv = lnsci.iv + round(vrest * dn1
                                  * (basrate + intrat) * coe,2).
      basrate = rate.rate.
      tau = rate.cdt.
      for each ln%his where ln%his.lon = vlon and ln%his.stdat = tau:
         intrat = ln%his.intrate.
      end.
      for each lnsch where {&where-h} and lnsch.stdat = tau:
         vrest = vrest - lnsch.stval.
      end.
      for each lnscg where {&where-g} and lnscg.stdat = tau:
         vrest = vrest + lnscg.paid.
      end.
      next inner. end.
   else
   if cas = 4 then do:
      run day-360(tau,ln%his.stdat - 1,lon.basedy,output dn1,output dn2).
      lnsci.iv = lnsci.iv + round(vrest * dn1
                                  * (basrate + intrat) * coe,2).
      intrat = ln%his.intrate.
      tau = ln%his.stdat.
      for each rate where rate.base = lon.base and rate.cdt = tau:
         basrate = rate.rate.
      end.
      for each lnsch where {&where-h} and lnsch.stdat = tau:
         vrest = vrest - lnsch.stval.
      end.
      for each lnscg where {&where-g} and lnscg.stdat = tau:
         vrest = vrest + lnscg.paid.
      end.
      next inner. end.
 end.
lnsci.paid-iv = lnsci.iv.
end. /*inter*/

/*vint = 0.
for each lnsci where {&where-i}:
 vint = vint + lnsci.iv.
end.*/

