/* loniss-p2.i
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

      def var nrec as recid.
if lnscg.jh > 0 then do:  
           s-jh = lnscg.jh.
      if clin = 1 then do:
           if trec = frec then do:
                find next lnscg where lnscg.lng = s-lon and lnscg.flp > 0
                                and lnscg.fpn = 0 and lnscg.f0 > -1 no-error.
                  if available lnscg then nrec = recid(lnscg).
                  else if not available lnscg then clin = 0. 
           end.
           else if trec <> frec then do:
                find prev lnscg where lnscg.lng = s-lon and lnscg.flp > 0 
                                         and lnscg.fpn = 0 and lnscg.f0 > -1.
                nrec = recid(lnscg).
          end.
    end.  
             run lnx-jls.
            find first lnscg where recid(lnscg) = crec no-error.
            if not available lnscg then do:
              if clin = 1 then trec = nrec.
              clear frame loniss-p2 all.
              next upper.
            end.
            else if available lnscg then do:
              disp lnscg.paid with frame loniss-p2.
              next inner.
            end.
end.
else bell.

