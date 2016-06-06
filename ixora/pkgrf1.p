/* pkgrf1.p
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
        31/08/2011 kapar - новый алгоритм исчисления 365/366 дней в году для (овердрафт и факторинг) в lsci-calc.i
*/

{global.i}
{pk.i}

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

  find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
           pkanketa.ln = s-pkankln no-lock no-error.

  find lon where lon.lon = s-lon no-lock.

  vduedt = lon.duedt.
  vregdt = pkanketa.cdt.
  vbasedy = lon.basedy.
  vprem = lon.prem.
  vopnamt = lon.opnamt.

  vyear = year(vregdt).
  vmonth = month(vregdt) + 1.
  vday = day(vregdt).
  if vmonth = 13 then do:
     vmonth = 1. vyear = vyear + 1.
  end.
  vvday = vday.
  run mondays(vmonth,vyear,output mdays).
  if vday > mdays then vvday = mdays.
  vdat0 = date(vmonth,vvday,vyear).
  vopn0 = decimal (truncate (pkanketa.summa / pkanketa.srok, 0)).
  vopn = 0.
  vdat = vduedt.


  for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0
            and lnsch.fpn = 0 and lnsch.f0 > -1:
      delete lnsch.
  end.
  vyear = year(vdat0).
  vmonth = month(vdat0).
  vday = day(vdat0).
  /*month*/
  mon:
  repeat:
      if vmonth = 13 then do:
          vmonth = 1. vyear = vyear + 1.
      end.
      vvday = vday.
      run mondays(vmonth,vyear,output mdays).
      if vday > mdays then vvday = mdays.
      vdat1 = date(vmonth,vvday,vyear).

      if vdat1 < vdat0 then do:
          vmonth = vmonth + 1.
          next mon.
      end.
      if vdat1 > vdat then do:
          find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
                         and lnsch.f0 > -1 no-error.
          if not available lnsch then do:
              create lnsch.
              lnsch.lnn = s-lon.
              lnsch.stdat = vdat.
              lnsch.stval = vopnamt.
              leave mon.
          end.
          else
          if available lnsch then do:
              leave mon.
          end.
      end.

      create lnsch.
      lnsch.lnn = s-lon.
      lnsch.stdat = vdat1.
      lnsch.f0 = 1.
      if vopnamt - vopn >= vopn0 then do:
         lnsch.stval = vopn0.
         vopn = vopn + vopn0.
      end.
      else do:
         lnsch.stval = vopnamt - vopn.
         vopn = vopnamt.
      end.
      vmonth = vmonth + 1.
  end.

  find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
                         and lnsch.f0 > -1 and lnsch.stdat = vduedt no-error.
  if not available lnsch then do:
      create lnsch.
      lnn = s-lon.
      lnsch.stdat = vduedt.
      lnsch.stval = vopnamt - vopn.
      lnsch.f0 = 1.
  end.
  else lnsch.stval = vopnamt - vopn + vopn0.

  run lnsch-ren(s-lon).
  release lnsch.

  /* График процентов  */

  find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0
         and lnsch.fpn = 0 and lnsch.f0 > -1 no-error.
  vdat0 = lnsch.stdat.

  vdat = vduedt.

  for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
                         and lnsci.f0 > -1 :
      delete lnsci.
  end.
  vyear = year(vdat0).
  vmonth = month(vdat0).
  vday = day(vdat0).
  /*month*/
  mon:
  repeat:
      if vmonth = 13 then do:
          vmonth = 1. vyear = vyear + 1.
      end.
      vvday = vday.
      run mondays(vmonth,vyear,output mdays).
      if vday > mdays then vvday = mdays.
      vdat1 = date(vmonth,vvday,vyear).
      if vdat1 < vdat0 then do:
          vmonth = vmonth + 1.
          next mon.
      end.
      if vdat1 > vdat then do:
          find first lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
                         and lnsci.f0 > -1  no-error.
          if not available lnsci then do:
              create lnsci.
              lnsci.lni = s-lon.
              lnsci.idat = vdat.
              leave mon.
          end.
          else
          if available lnsci then do:
              leave mon.
          end.
      end.
      create lnsci.
      lnsci.lni = s-lon.
      lnsci.idat = vdat1.
      vmonth = vmonth + 1.
  end.

  find first lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
                         and lnsci.f0 > -1  and lnsci.idat = vduedt no-error.
  if not available lnsci then do:
      create lnsci.
      lni = s-lon.
      lnsci.idat = vduedt.
  end.
  release lnsci.


   run lnsci-ren(s-lon).

  def var vnrr like lnsci.f0.
  def var tau like lnsci.idat.
  def var vrest like lnsci.iv.
  def var coe as deci format "zz9.99999999999".
  def var cas as inte.

  coe = vprem / vbasedy / 100.
  tau = vregdt - 1.
  find lon where lon.lon = s-lon no-lock.
  {lsci-calc.i
   &where-h = "lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
               and lnsch.f0 > -1"
   &where-i = "lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
               and lnsci.f0 > -1"
   &where-g = "lnscg.lng = s-lon and lnscg.flp = 0 and lnscg.fpn = 0
               and lnscg.f0 > -1"
  }

