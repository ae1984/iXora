/* lnsci-ren.p
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
        15/04/2009 madiyar - убрал zero-control
*/

def input parameter vlon like lnsci.lni.
def var vn like lnsci.f0.
def buffer b for lnsci.
/*Renumbering*/
     vn = 0.
for each lnsci use-index lni where lnsci.lni = vlon and lnsci.flp = 0
                       and lnsci.fpn = 0 and lnsci.f0 > -1:
    vn = vn + 1.
    find first b where b.lni = vlon and b.f0 = lnsci.f0 and b.fpn = 1 no-error.
      if available b then do:
        b.f0 = vn. b.schn = string(vn,"zzz.") + "1.    ".
      end.
    lnsci.f0 = vn. lnsci.schn = string(vn,"zzz.") + " .    ".
end.

vn = 0. release b. release lnsci.
for each lnsci use-index lni where lnsci.lni = vlon and lnsci.flp > 0
                        and lnsci.f0 = 0 and lnsci.fpn = 0:
    vn = vn + 1.
    lnsci.flp = vn. lnsci.schn = "   . ." + string(vn,"zzzz").
end.

    vn = 0. release lnsci.
for each lnsci use-index lni where lnsci.lni = vlon and lnsci.flp > 0
                       and lnsci.f0 = 0 and lnsci.fpn = 1:
    vn = vn + 1.
    lnsci.flp = vn. lnsci.schn = "   .1." + string(vn,"zzz.").
end.

