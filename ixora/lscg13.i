/* lscg13.i
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

def var st as inte.
def var nrec as recid.
                 update lnscg.stdat lnscg.stval with frame lonscg.
                  if trec = frec then do:
                     if crec = trec then do:
                       find lnscg where recid(lnscg) = trec.
                       find next lnscg where {&where} no-error.
                       if available lnscg then nrec = recid(lnscg).
                       find lnscg where recid(lnscg) = crec.
                     end.
                     else nrec = trec.
                  end.
                  else if crec <> frec then do:
                     find lnscg where recid(lnscg) = trec.
                     find prev lnscg where {&where}.             
                     nrec = recid(lnscg).
                     find lnscg where recid(lnscg) = crec.
                  end.
                  run lscg-up(lnscg.f0, vregdt, vduedt, vopnamt, output st).
                  if st < 0 then do:
                  undo, next upper.
                  end.
                  else if st = 1 then next upper.
                  else if st = 2 then do:
                     if clin = dlin then do:
                        find lnscg where recid(lnscg) = trec.
                        find next lnscg where {&where} no-error.
                        if available lnscg then trec = recid(lnscg).
                     end.
                        clin = dlin.
                  end.
                  else if st = 3 then trec = nrec.
                  next upper.

