/* lnscg-ren.p
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

def input parameter vlon like lnscg.lng.
def var vn like lnscg.f0.
def buffer b for lnscg.
/*Zero control*/
  for each lnscg where lnscg.lng = vlon and lnscg.stval = 0 
                                                 and lnscg.paid = 0:
     delete lnscg.
  end.
/*Renumbering*/
     vn = 0. 
  for each lnscg use-index lng where lnscg.lng = vlon and lnscg.flp = 0
                       and lnscg.fpn = 0 and lnscg.f0 > 0:
     vn = vn + 1.  
    find first b where b.lng = vlon and b.f0 = lnscg.f0 and b.fpn = 1 no-error.
      if available b then do: 
        b.f0 = vn. b.schn = string(vn,"zzz.") + "1.    ".
      end.
    lnscg.f0 = vn. lnscg.schn = string(vn,"zzz.") + " .    ".
  end.
    
    vn = 0. release b. release lnscg.
  for each lnscg use-index lng where lnscg.lng = vlon and lnscg.flp > 0
                        and lnscg.f0 = 0 and lnscg.fpn = 0 by lnscg.stdat:
    vn = vn + 1. 
    lnscg.flp = vn. lnscg.schn = "   . ." + string(vn,"zzzz").
  end.

    vn = 0. release lnscg.
  for each lnscg use-index lng where lnscg.lng = vlon and lnscg.flp > 0
                       and lnscg.f0 = 0 and lnscg.fpn = 1 by lnscg.stdat:
    vn = vn + 1.
    lnscg.flp = vn. lnscg.schn = "   .1." + string(vn,"zzz.").
  end.



