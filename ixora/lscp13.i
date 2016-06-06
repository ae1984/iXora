/* lscp13.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Изменение 1 строчки графика погашения ОД
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
        16.03.2004 marinav - при изменении графика пишется дата и логин польз-ля
*/
def var st as inte.
def var nrec as recid.
def new shared var s-com like lnsch.comment.
def new shared var s-fund like lnsch.paid.
                 s-com = lnsch.comment.
                 s-fund = lnsch.stval - lnsch.paid.
                 update lnsch.stdat lnsch.stval lnsch.comment with frame lonscp.
                 lnsch.who = g-ofc. lnsch.whn = g-today.
                  if trec = frec then do:
                     if crec = trec then do:
                       find lnsch where recid(lnsch) = trec.
                       find next lnsch where {&where} no-error.
                       if available lnsch then nrec = recid(lnsch).
                       find lnsch where recid(lnsch) = crec.
                     end.
                     else nrec = trec.
                  end.
                  else if crec <> frec then do:
                     find lnsch where recid(lnsch) = trec.
                     find prev lnsch where {&where}.             
                     nrec = recid(lnsch).
                     find lnsch where recid(lnsch) = crec.
                  end.
                  run lscp-up(lnsch.f0, vregdt, vduedt, vopnamt, output st).
                  if st < 0 then do:
                  undo, next upper.
                  end.
                  else if st = 1 then next upper.
                  else if st = 2 then do:
                     if clin = dlin then do:
                        find lnsch where recid(lnsch) = trec.
                        find next lnsch where {&where} no-error.
                        if available lnsch then trec = recid(lnsch).
                     end.
                        clin = dlin.
                  end.
                  else if st = 3 then trec = nrec.
                  next upper.

