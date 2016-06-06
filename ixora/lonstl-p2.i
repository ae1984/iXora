/* lonstl-p2.i
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
if lnsch.jh > 0 then do:  
           s-jh = lnsch.jh.
      if clin = 1 then do:
           if trec = frec then do:
                find next lnsch where lnsch.lnn = s-lon and lnsch.flp > 0
                                and lnsch.fpn = 0 and lnsch.f0 > -1 no-error.
                  if available lnsch then nrec = recid(lnsch).
                  else if not available lnsch then clin = 0. 
           end.
           else if trec <> frec then do:
                find prev lnsch where lnsch.lnn = s-lon and lnsch.flp > 0 
                                         and lnsch.fpn = 0 and lnsch.f0 > -1.
                nrec = recid(lnsch).
          end.
    end.  
             run lnx-jls.
            find first lnsch where recid(lnsch) = crec no-error.
            if not available lnsch then do:
              if clin = 1 then trec = nrec.
              clear frame lonstl-p2 all.
              next upper.
            end.
            else if available lnsch then do:
              disp lnsch.paid with frame lonstl-p2.
              next inner.
            end.
end.
else bell.

