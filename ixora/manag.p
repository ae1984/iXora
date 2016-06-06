/* manag.p
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

def var ys as log .
def var y as int.
def var iss as int.
def var cur as int.
def var curold as int.
def var vvv as cha.
def shared var v-log as cha .
def var idle  as cha .
def shared var h as int .
def shared frame pid .
 find first dproc no-lock.
 if avail dproc then
 cur = recid(dproc).
 else cur =  0 .

{global.i}
{ps-prmt.i}
def var v-dproc as cha format "x(1)" . 
{lgps.i}
{mpid.f}


repeat:
 clear frame pid all.

 if cur ne 0 then do:
 find dproc where recid(dproc) = cur no-lock .

 pause 0.
 repeat with frame pid:
  display dproc.pid copy tout dproc.u_pid with frame pid .
  pause 0 .
  find next dproc no-lock no-error  .
  if not avail dproc then leave.
  if frame-line = h then leave .
  down with frame pid.
  pause 0.
 end.
 /*
 display frame-down(pid) frame-line(pid).
*/
 up frame-line(pid) - 1  with frame pid.

 end .



repeat:
 if cur ne 0 then do:
 find dproc where recid(dproc) = cur no-lock .
  display dproc.pid copy tout dproc.u_pid with frame pid .
  color display message dproc.pid copy with frame pid.
  pause 0 .
 end .


 readkey. /* !!!!!!!!!!!!! */



 color display normal dproc.pid copy  with frame pid.
 pause 0 .


 if keyfunction(lastkey) = "cursor-up" then
     do:
      find prev dproc no-lock no-error .
      if avail dproc then do:
      cur = recid(dproc).
      if frame-line(pid) = 1 then
       scroll down with frame pid .
       else do:
         up 1 with frame pid.
        end .
      end.
     end.

 if keyfunction(lastkey) = "cursor-down" then
     do:
      find next dproc no-lock no-error.
      if avail dproc then do:
      cur = recid(dproc).
      if frame-line(pid) = frame-down(pid)  then
       scroll up with frame pid .
       else
       down 1 with frame pid.
      end.
     end.

 if keyfunction(lastkey) = "home" then
     do:
      find first dproc no-lock .
      cur = recid(dproc).
      leave .
     end.

 if keyfunction(lastkey) = "right-end" then
     do:
      find last dproc no-lock .
      iss = h .
      repeat :
      iss = iss - 1.
      find prev dproc no-lock .
      if iss = 1 then leave .
      end.
       cur = recid(dproc).
       leave .
     end.
  /*
 if keyfunction(lastkey) = "delete-line" then
     do:
      find last dproc no-lock .
      iss = h .
      repeat :
      iss = iss - 1.
      find prev dproc no-lock .
      if iss = 1 then leave .
      end.
       cur = recid(dproc).
       leave .
     end.
    */

 if keyfunction(lastkey) matches  "*goto*" then
     do:
      run vpsman.
     end.

 if keyfunction(lastkey) = "delete-line" then do on error undo , leave :

   if dproc.tout ne 1000 then
   do:
    message " There is working process , stop it before ! " .
    pause .
    undo , leave .
   end.

  ys = false .
  message " Are you realy sure ? " update ys .
  if not ys then do: undo , leave . end .

  curold = cur .
  find next dproc no-lock no-error.
  if not avail dproc then do:
   find dproc where recid(dproc) = curold no-lock .
   find prev dproc no-lock no-error .
    if not avail dproc then do:
     cur = 0  .
     leave .
    end.
  end.
  cur = recid(dproc) .

   find dproc where recid(dproc) = curold exclusive-lock .
   delete dproc .
   clear frame pid all .
   leave .

 end.



  /*
 if keyfunction(lastkey) = "new-line" then
     do:
      create dproc  .
      scroll from-current down with frame pid.

      do on endkey undo,leave :
       update dproc.pid dproc.copy  with frame pid.
       tout = 1000.
      end.

     if keyfunction(lastkey) = "end-error" then do:
        delete dproc.
        find dproc where recid(dproc) = cur no-lock .
        scroll from-current up with frame pid.
       end.
     cur = recid(dproc).
     leave.
    end.
    */
 if keyfunction(lastkey) = "return" then do:
     do transaction :
      find dproc where recid(dproc) = cur exclusive-lock .
      update dproc.tout with frame pid.
      unix silent value("kill -SIGALRM " + string(dproc.u_pid)) .
      unix silent value("kill -SIGALRM " + string(dproc.u_pid)) .
      pause 0. 
/*      leave .     */
     end .
     release dproc .
    end.

 if keyfunction(lastkey) = "page-down" then
     do:
      iss = h .
      repeat :
      iss = iss - 1.
      find next dproc no-lock no-error  .
      if not avail dproc then
      do:
       find last dproc no-lock .
       find prev dproc no-lock .
       find prev dproc no-lock .
       leave .
      end.
      if iss = 1 then leave .
      end.
       cur = recid(dproc).
       leave .
     end.
 if keyfunction(lastkey) = "page-up" then
     do:
      iss = h .
      repeat :
      iss = iss - 1.
      find prev dproc no-lock no-error .
      if not avail dproc then
      do:
       find first dproc no-lock .
       leave .
      end.
      if iss = 1 then leave .
      end.
       cur = recid(dproc).
       leave .
     end.

 if keylabel(lastkey) = "h" then do:
  unix value("ps_less " + trim(v-log) + "/" + trim(m_hst) + "_" +
    dproc.pid + "_" + string(dproc.copy,"99") +
  "_ps.lg  " ).
 end.


 if keyfunction(lastkey) = "end-error" then leave.


end.
 if keyfunction(lastkey) = "end-error" then do:
 clear frame pid all .
 leave.
 end.
pause 0.

end.
