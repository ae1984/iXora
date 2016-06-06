/* lsch-ini.i
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

find first lnscg where lnscg.lng = s-lon and lnscg.flp = 0
                       and lnscg.fpn = 0 and lnscg.f0 > -1 no-error.
 if not available lnscg then do:
   create lnscg. lnscg.f0 = 1. lnscg.lng = s-lon.
                 lnscg.schn = "  1. .   ". lnscg.stdat = vregdt.
                 lnscg.stval = vopnamt.
end.
find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0
                       and lnsch.fpn = 0 and lnsch.f0 > -1 no-error.
 if not available lnsch then do:
   create lnsch. lnsch.f0 = 1. lnsch.lnn = s-lon.
                 lnsch.schn = "  1. .   ".
                 lnsch.stdat = vduedt. lnsch.stval = vopnamt.
end.
find first lnsci where lnsci.lni = s-lon and lnsci.flp = 0
                       and lnsci.fpn = 0 and lnsci.f0 > -1 no-error.
 if not available lnsci then do:
   create lnsci. lnsci.f0 = 1. lnsci.lni = s-lon.
                 lnsci.idat = vduedt. lnsci.schn = "  1. .   ". 
 end.


