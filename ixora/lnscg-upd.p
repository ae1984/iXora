/* lnscg-upd.p
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
def var kk like lnscg.paid.
for each lnscg where lnscg.lng = vlon 
            and lnscg.flp = 0 and lnscg.fpn = 0 and lnscg.f0 > -1:
       lnscg.paid = lnscg.stval.
end.
    find first lnscg where lnscg.lng = vlon and lnscg.flp = -1 
                                             and lnscg.fpn = 0 no-error.
       if available lnscg then kk = lnscg.paid.
       else if not available lnscg then kk = 0.
    for each lnscg where lnscg.lng = vlon 
             and lnscg.flp = 0 and lnscg.fpn = 0 and lnscg.f0 > -1:
         if lnscg.stval <= kk then do:
            lnscg.paid = 0.
            kk = kk - lnscg.stval.
         end.
         else if lnscg.stval > kk then do:       
            lnscg.paid = lnscg.stval - kk.
            kk = 0.
         end.
     end.


