/* lnreal-iclc.p
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

def input parameter vlon like lon.lon.
def var vprem like lon.prem.
def var vbasedy like lon.basedy.
def var vduedt like lnsch.stdat.
def var vregdt like lnsch.stdat.
/*def shared var s-vint like lnsci.iv.*/
def var vint like lnsci.iv.
def var vnrr like lnsci.f0.
def var tau like lnsci.idat.
def var vrest like lnsci.iv.
def var intrat like ln%his.intrate.
def var basrate like rate.rate.
def var coe as deci format "zz9.99999999999".
def var cas as inte.

find lon where lon.lon = vlon no-lock.
if lon.gua = "LK"
then return.
vprem = lon.prem. vbasedy = lon.basedy. vduedt = lon.duedt. vregdt = lon.rdt.
find last rate where rate.base = lon.base 
                                 and rate.cdt <= lon.rdt no-lock no-error.
if available rate then basrate = rate.rate.

coe = 1 / (vbasedy * 100).
find first lnscg where lnscg.lng = vlon and lnscg.flp > 0
                                     and lnscg.fpn = 0 no-error.
if not available lnscg then do:
  for each lnsci where lnsci.lni = vlon and lnsci.flp = 0 and lnsci.fpn = 0:
     lnsci.iv = 0. lnsci.paid-iv = 0.
  end.
  return.
end.
tau = lnscg.stdat - 1.
intrat = vprem.

{lnreal-iclc.i
 &where-h = "lnsch.lnn = vlon and lnsch.flp > 0 and lnsch.fpn = 0"
 &where-i = "lnsci.lni = vlon and lnsci.flp = 0 and lnsci.fpn = 0"
 &where-g = "lnscg.lng = vlon and lnscg.flp > 0 and lnscg.fpn = 0"
}
/*s-vint = vint.*/

