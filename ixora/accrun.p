/* accrun.p
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

/* accrun.p */
def var vans as log init false.
def var vmonth as int.
def var vyear as int.
def var vaint like invsec.aintrec.
def var vinv like invsec.invsec init "ALL".

{proghead.i}

loop1: do transaction.
display "1. Do you want to run the Accrued Interest Calculation till Today ?"
  with no-box row 6 centered frame kk.
update vans with no-label no-box frame kk.
down 1 with frame kk.
if vans eq false then leave loop1.
else do:
  update vinv with side-label row 6 centered frame mk.
  for each invsec where invsec.lacrdt lt g-today
   and (invsec.invsec eq vinv or vinv eq "ALL"):
   if invsec.rtype eq false then do:
      if invsec.rchgdt + invsec.rintval le g-today then
	 invsec.rchgdt = invsec.rchgdt + invsec.rintval.
      find last rate where rate.base eq invsec.base
	and rate.cdt le invsec.rchgdt.
      invsec.coupon = rate.rate + invsec.prem.
   end.

   {aintrec.i g-today invsec.lacrdt}
   invsec.lacrdt = g-today.
   invsec.aintrec = invsec.aintrec + vaint.
   invsec.dam[2] = invsec.dam[2] + vaint.
  end.
end.
end.
pause.

loop2: do transaction.
display "2. Do you want to run Amortization/Accretion, also ?"
  with no-box centered frame ll.
update vans with no-label frame ll.
if vans eq false then leave loop2.
else do:
update vinv with side-label row 6 centered frame mk.
for each invsec where invsec.laadt lt g-today
  and (invsec.invsec eq vinv or vinv eq "ALL"):
  if invsec.acalm eq "1" then do:
     invsec.accumaa = invsec.accumaa +
     (invsec.purpr - invsec.accumaa - invsec.par) /
       ((year(invsec.mdt) * 12 + month(invsec.mdt)) -
       (year(invsec.laadt) * 12 + month(invsec.laadt))).
     /*
     invsec.laadt = date(month(g-today),1,year(g-today)) - 1.
     */
     vmonth = month(invsec.laadt) + 2.
     vyear = year(invsec.laadt).
    if vmonth + 2 gt 12 then do:
       vmonth = vmonth - 12.
       vyear = vyear + 1.
    end.
   invsec.laadt = date(vmonth,1,vyear) - 1.
  end.
end.
end.
end.
