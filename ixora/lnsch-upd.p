/* lnsch-upd.p
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
def var kk like lnsch.paid.
for each lnsch where lnsch.lnn = vlon 
            and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > -1:
       lnsch.paid = lnsch.stval.
end.
    find first lnsch where lnsch.lnn = vlon and lnsch.flp = -1 
                                             and lnsch.fpn = 0 no-error.
       if available lnsch then kk = lnsch.paid.
       else if not available lnsch then kk = 0.
    for each lnsch where lnsch.lnn = vlon 
             and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > -1:
         if lnsch.stval <= kk then do:
            lnsch.paid = 0.
            kk = kk - lnsch.stval.
         end.
         else if lnsch.stval > kk then do:       
            lnsch.paid = lnsch.stval - kk.
            kk = 0.
         end.
     end.


