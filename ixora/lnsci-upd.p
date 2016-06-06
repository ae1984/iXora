/* lnsci-upd.p
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
def var kk like lnsci.paid-iv.
for each lnsci where lnsci.lni = vlon and lnsci.flp = 0 
                                      and lnsci.f0 > -1 and lnsci.fpn = 0:
       lnsci.paid-iv = lnsci.iv.
end.
    find first lnsci where lnsci.lni = vlon and lnsci.flp = -1
                                           and lnsci.fpn = 0 no-error.
      if available lnsci then kk = lnsci.paid-iv.
      else if not available lnsci then kk = 0.
    for each lnsci where lnsci.lni = vlon and lnsci.flp = 0 and 
                         lnsci.fpn = 0 and lnsci.f0 > -1:
         if lnsci.iv <= kk then do:
            lnsci.paid-iv = 0.
            kk = kk - lnsci.iv.
         end.
         else if lnsci.iv > kk then do:       
            lnsci.paid-iv = lnsci.iv - kk.
            kk = 0.
         end.
     end.

