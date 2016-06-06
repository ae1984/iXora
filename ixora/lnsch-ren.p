/* lnsch-ren.p
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

def input parameter vlon like lnsch.lnn.
def var vn like lnsch.f0.
def buffer b for lnsch.
/*Renumbering*/
     vn = 0.
  for each lnsch use-index lnn where lnsch.lnn = vlon and lnsch.flp = 0
                       and lnsch.fpn = 0 and lnsch.f0 > 0:
     vn = vn + 1.
    find first b where b.lnn = vlon and b.f0 = lnsch.f0 and b.fpn = 1 no-error.
      if available b then do:
        b.f0 = vn. b.schn = string(vn,"zzz.") + "1.    ".
      end.
    lnsch.f0 = vn. lnsch.schn = string(vn,"zzz.") + " .    ".
  end.

    vn = 0. release b. release lnsch.
  for each lnsch use-index lnn where lnsch.lnn = vlon and lnsch.flp > 0
                        and lnsch.f0 = 0 and lnsch.fpn = 0:
    vn = vn + 1.
    lnsch.flp = vn. lnsch.schn = "   . ." + string(vn,"zzzz").
  end.

    vn = 0. release lnsch.
  for each lnsch use-index lnn where lnsch.lnn = vlon and lnsch.flp > 0
                       and lnsch.f0 = 0 and lnsch.fpn = 1:
    vn = vn + 1.
    lnsch.flp = vn. lnsch.schn = "   .1." + string(vn,"zzz.").
  end.


