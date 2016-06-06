/* t-chgwrt.p
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

trigger procedure for write of  que new buffer newque old buffer oldque.
/*{lgps.i new }*/

/**/

def new shared var m_hst as char.
def new shared var m_copy as char.
def new shared var m_pid like que.pid.
def new shared var u_pid as cha.
def new shared var v-text as cha.

/**/

m_pid = "TRG".
u_pid = "Trigger" . 
def var ttt as int . 
def var nxt like  route.npc.
do transaction:
 ttt = time . 
 if oldque.pid = newque.pid and newque.con ne "f" then 
 do:
  find first  sts where 
    sts.pid = newque.pid exclusive-lock no-error  .
  if avail  sts then do:
   if oldque.con ne "F" then  sts.nw =  sts.nw - 1 .
   else  sts.nf =  sts.nf - 1 .
   if newque.con ne "F" then  sts.nw =  sts.nw + 1 .
   else  sts.nf =  sts.nf + 1 .
   if (newque.df ne oldque.df ) or (newque.tf ne oldque.tf ) then 
    do:
       sts.nwt =  
        sts.nwt + (ttt -  sts.upd + (today - 
        sts.dupd) * 86400)
       * ( sts.nw +  sts.nf) - (ttt - oldque.tf + 
       (today - oldque.df) *  86400) .
       sts.upd = ttt .
       sts.dupd = today.     
      newque.df = today .
      newque.tf = ttt . 
    end.
  end.
  return .
 end.
 else if newque.con eq "f"  then 
  do:
  find first  route where   route.ptype = newque.ptype and 
   route.pid = newque.pid and 
   route.rcod = newque.rcod no-lock no-error .
   if not available  route then 
      do:
/*
        v-text = "Ошибка маршрута для: Тип= " + newque.ptype + " Код= " +
        newque.pid + " " + newque.rcod + " " + newque.remtrz + " -> E " .
        run lgps.
*/
        nxt = "E" .
      end.
      else nxt =  route.npc .
   newque.pid = nxt .
   newque.df = today.
   newque.tf = time.
   newque.con = "W".
   if substr(oldque.npar,1,9)  = " Last PRI" then newque.npar = "" .
    newque.npar  = " Last PRI = " + string(oldque.pri,"zzzz9") +
    " Last PID = " + string(oldque.pid) + newque.npar .
    newque.pvar = "".
 end.
 if oldque.pid > newque.pid then 
 find first  sts where
     sts.pid = newque.pid exclusive-lock no-error .
 find first  sts where 
   sts.pid = oldque.pid exclusive-lock no-error .
 if avail  sts and ( sts.nw +  sts.nf < 1) then 
 do:
   /*
    delete sts .
   */
 end.
 else
 if avail  sts then do: 
    sts.nwt =   sts.nwt + (ttt -  sts.upd + 
   (today -  sts.dupd)
      * 86400)    * 
      ( sts.nw +  sts.nf) - 
      (ttt - oldque.tf + (today - oldque.df) * 86400) .  
    sts.upd = ttt .
    sts.dupd = today .
   if oldque.con ne "F" then 
    sts.nw =  sts.nw - 1 . 
   else 
    sts.nf =  sts.nf - 1 . 
 end.
 if newque.pid ne "ARC" then do:
 find first  sts where 
   sts.pid = newque.pid exclusive-lock no-error .
  if not avail  sts then do:
     create  sts . 
      sts.pid = newque.pid . 
      sts.dupd = today . 
    end.
     sts.nwt =  
       sts.nwt + (ttt -  sts.upd + (today - 
       sts.dupd ) * 86400)
      * ( sts.nw +  sts.nf).
     sts.upd = ttt .
     sts.dupd = today . 
    if newque.con ne "F" then
      sts.nw =  sts.nw + 1 . 
    else 
      sts.nf =  sts.nf + 1 . 
    newque.df = today .
    newque.tf = time . 
 end.
end.

