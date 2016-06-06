/* lonstl-i3.i
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
if lnsci.jh > 0 then do:  
           s-jh = lnsci.jh.
      if clin = 1 then do:
           if trec = frec then do:
                find next lnsci where lnsci.lni = s-lon and lnsci.flp >= 0
                                and lnsci.fpn = 0 and lnsci.f0 > -1 no-error.
                  if available lnsci then nrec = recid(lnsci).
                  else if not available lnsci then clin = 0. 
           end.
           else if trec <> frec then do:
                find prev lnsci where lnsci.lni = s-lon and lnsci.flp >= 0 
                                         and lnsci.fpn = 0 and lnsci.f0 > -1.
                nrec = recid(lnsci).
          end.
    end.  
             run lnx-jls.
            find first lnsci where recid(lnsci) = crec no-error.
            if not available lnsci then do:
              if clin = 1 then trec = nrec.
              clear frame loniss-i3 all.
              next upper.
            end.
            else if available lnsci then do:
              disp lnsci.paid-iv with frame loniss-i3.
              next inner.
            end.
end.

