/* t-chgdel.p
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

trigger procedure for delete of que.
def var ttt as int . 
do transaction:
 ttt = time . 
 find first sts where sts.pid = que.pid exclusive-lock no-error .
 if avail sts and (sts.nw + sts.nf < 1) then 
  do:
  /*
  delete sts .
  */
  end. 
 else
 if avail sts then do: 
   sts.nwt =  sts.nwt + (ttt - sts.upd + (today - sts.dupd) * 86400)
   * (sts.nw + sts.nf) - (ttt - que.tf + (today - que.df) * 86400) .  
   sts.upd = ttt .
   sts.dupd = today .
   if que.con ne "F" then 
   sts.nw = sts.nw - 1 . 
   else 
   sts.nf = sts.nf - 1 . 
 end.
end.
