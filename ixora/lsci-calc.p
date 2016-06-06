/* lsci-calc.p
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

def input parameter vprem like lon.prem.
def input parameter vbasedy like lon.basedy.
def input parameter vduedt like lnsch.stdat.
def input parameter vregdt like lnsch.stdat.
def output parameter vint like lnsci.iv.
def shared var s-lon like lnsch.lnn.
def var vnrr like lnsci.f0.
def var tau like lnsci.idat.
def var vrest like lnsci.iv.
def var coe as deci format "zz9.99999999999".
def var cas as inte.

coe = vprem / vbasedy / 100.
tau = vregdt - 1.
find lon where lon.lon = s-lon no-lock.
if lon.gua = "LK"
then return.
{lsci-calc.i
 &where-h = "lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
             and lnsch.f0 > -1"
 &where-i = "lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
             and lnsci.f0 > -1"
 &where-g = "lnscg.lng = s-lon and lnscg.flp = 0 and lnscg.fpn = 0
             and lnscg.f0 > -1"
}

