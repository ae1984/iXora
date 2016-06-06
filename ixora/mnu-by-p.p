/* mnu-by-p.p
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
        01/07/2004 madiar
 * CHANGES
*/

def var mnu_nmbr as char.
def var notupper as logi.
def var bb as char.
def var myproc as char.
def var myfunc as char.

def buffer b-nmenu for nmenu.

form skip(1)
     myproc label " Mask for procedure name " skip
     myfunc label " Mask for function name  " skip
     skip(1)
     with side-label centered row 7 frame fr.

repeat:

update myproc go-on (F4) with frame fr.
update myfunc go-on (F4) with frame fr.

hide message no-pause.

if keyfunction(lastkey) = "end-error" then leave.

hide frame fr.

if myproc = '' then myproc = "*".
if myfunc = '' then myfunc = "*".
find first nmenu where nmenu.proc matches myproc and nmenu.fname matches myfunc no-lock no-error.
if avail nmenu then
   for each nmenu where nmenu.proc matches myproc and nmenu.fname matches myfunc no-lock:
     
     if keyfunction(lastkey) = "end-error" then leave.
     
     mnu_nmbr = ''.
     notupper = yes.
     bb = nmenu.fname.
     
     repeat while notupper :
       find first b-nmenu where b-nmenu.fname = bb no-lock no-error.
       if avail b-nmenu then do:
         mnu_nmbr = string(b-nmenu.ln) + mnu_nmbr.
         bb = b-nmenu.father.
         if bb = 'MENU' then notupper = no.
         else mnu_nmbr = '-' + mnu_nmbr.
       end.
       else do:
         mnu_nmbr = "x" + mnu_nmbr.
         notupper = no.
       end.
     end. /* repeat */
     
     display nmenu.proc nmenu.fname mnu_nmbr format "x(50)" label "Menu".
   end.
else message " not found ".
end.
