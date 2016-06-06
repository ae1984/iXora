/* psprt1.p
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

{global.i}
{ps-prmt.i}
{lgps.i new }
def var
wait as cha initial " Ж д и т е ... " format "X(13)" .
def var brnch as log initial false .
def var v-tout like dproc.tout .
def var yn as log format "да/нет" initial false .
def var v-n as int .
def var v-chval as cha .
define var v-fields    as cha initial "gl,bank,cif,base,lon,lcr,bill,code".
define var v-addprog   as cha.
def var sview as cha format "x(16)" .
def var shost as cha format "x(16)" .
define var v-slct    as int format "99".
define var position  as int.
define var support   as log.
define var procedure as cha.
define var v-fldname as cha.
def var ourbank as cha . 
form wait with centered row v-n + 9 no-label frame www .

 find first sysc where sysc.sysc = "PR-DIR" no-lock no-error .
 if not avail sysc then do:
  Message  " Нет  PR-DIR записи в sysc файле  " .  pause .
  return .
 end.
 v-chval = trim(sysc.chval) .

 find first sysc where sysc.sysc = "ps1hst" no-lock no-error .
 if not avail sysc then do:
  Message  " Нет ps1hst записи в sysc файле  " .  pause .
  return .
 end.
 shost = trim(sysc.chval) .

 sview = "joe -rdonly " .
 v-n = 9 .


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет OURBNK записи в sysc файле ! ".
 run lgps.
 return .
end.
ourbank = sysc.chval.

find sysc where sysc.sysc = "clcen" no-lock no-error .
if avail sysc and trim(sysc.chval) ne trim(ourbank) then  brnch = true . 

 {psprt1.f}

 repeat  on error undo,retry:
    view frame heading.
     display sview label "Viewer "
      shost label "Host для печати" with side-label
      column 40  1 column row 10 overlay no-hide frame vw.

    set v-slct validate(v-slct ge 0 and v-slct le 16 ,"Enter 1 to 16 " )
        with frame menu.
    if v-slct = 1 then do :
     if
     search(v-chval + "/PDPR1.log" ) = v-chval + "/PDPR1.log"
     then  do:
     yn = false .
     Message
     " Старый файл будет удален ! Вы уверены , что он распечатан ? "
      update yn .
     if not yn then next .
     Display wait with centered row v-n + 9 frame www .
     do transaction :
     find first dproc where dproc.pid = "PD1"  exclusive-lock no-error .
     if avail dproc then
     do:
      v-tout = dproc.tout .
      dproc.tout  = 10000 .
     end .
     else v-tout = 5.

     pause 5 no-message .
     unix  silent value ( "echo " +
     "=################## Архив =========================================== >>"
     + v-chval + "/PDPR1.arc " ) .
     pause 0 .
     unix  silent value ( "date  >> "  +
      v-chval + "/PDPR1.arc " ) .
     pause 0 .
     unix  silent value ( "cat " + v-chval + "/PDPR1.prt >> "  +
      v-chval + "/PDPR1.arc " ) .
     pause 0 .
     if brnch then do:
      unix  silent value ( "/bin/mv  "
       + v-chval + "/PDPR1.log  "
       + v-chval + "/PDPR1.prt  " ) .
     end.
     else 
     do:
     output to esc.tmp.
     put unformatted chr(27) + "(1L" +  chr(27) + "(s0p12.00h10.0v0s0b0T" .
     output close .
     unix  silent value ( "/bin/cat esc.tmp "
        + v-chval + "/PDPR1.log  >  "
        + v-chval + "/PDPR1.prt  " ) .
     output to value(v-chval + "/PDPR1.prt" ) append . 
     put unformatted chr(12) .
     output close .
     unix  silent value ( "/bin/rm " + v-chval + "/PDPR1.log  " ) .  
    end.
     find first dproc where dproc.pid = "PD1"  exclusive-lock no-error .
     if avail dproc then
      dproc.tout  = v-tout .
     v-text = " PDPR1.prt сформирован ... " .
     run lgps .
     release dproc .
     end. /* trans */
     message " Выполнено " . pause .
     hide frame www  .
     pause 0 .
     end .
     else do: message " PDPR1.log не найден ! " .  pause .
     end.
    end.
    else
    if v-slct = 2 then  do:
     if
     search(v-chval + "/PDPR1.prt" ) = v-chval + "/PDPR1.prt"
     then do:
      unix  value ( sview + " " + v-chval + "/PDPR1.prt" ) .
      pause 0 .
     end.
     else
     do:
      message " PDPR1.prt не найден ! " . pause .
     end.
    end.
    else
    if v-slct = 3 then  do:
     if
     search(v-chval + "/PDPR1.prt" ) = v-chval + "/PDPR1.prt"
     then do:
     Display wait with centered row v-n + 9 frame www .
     if shost = "" then
     unix  silent value ( "prit "  + " " + v-chval + "/PDPR1.prt" ) .
     else
     unix  silent value ( "prit -h"  + shost
      + " " + v-chval + "/PDPR1.prt" ) .
     pause 0 .
     hide frame www  .
      v-text = " PDPR1.prt распечатан  ... " .
     run lgps .
     message " Выполнено " . pause .
     pause 0 .
     end.
     else do: message " PDPR1.prt не найден  ! " . pause .
     end.
    end.
    else
    if v-slct = 4 then  do:
     if
     search(v-chval + "/PDPR1.arc" ) = v-chval + "/PDPR1.arc"
     then do:
      unix  value ( sview + " " + v-chval + "/PDPR1.arc" ) .
      pause 0 .
     end.
     else
     do:
      message " Архив не найден ! " . pause .
     end.
    end.
    else
    if v-slct = 5 then  do:
     update  sview with frame vw.
     pause 0 .
    end.
    else
    if v-slct = 6 then  do:
     update  shost with frame vw.
     pause 0 .
    end.
    else
    if v-slct = 7 then  do:
     unix  value ( sview + " " +  "./tmp" ) .
     pause 0 .
    end.
    else
    if v-slct = 8 then  do:
     if
     search("tmp" ) = "tmp"
     then do:
     Display wait with centered row v-n + 9 frame www .
     if shost = "" then
     unix  silent value ( "prit "  + " " + "./tmp" ) .
     else
     unix  silent value ( "prit -h"  + shost
      + " " +  "./tmp" ) .
     pause 0 .
     hide frame www  .
     message " Выполнено " . pause .
     pause 0 .
     end.
     else do: message " tmp файл не найден ! " . pause .
     end.
    end.
    else
    if v-slct = 9 then  do:
     if
     search(v-chval + "/PDPR1.log" ) = v-chval + "/PDPR1.log"
     then do:
      unix  value ( sview + " " + v-chval + "/PDPR1.log" ) .
      pause 0 .
     end.
     else
     do:
      message " PDPR1.log не найден ! " . pause .
     end.
    end.
    /*
    procedure = entry(v-slct,v-listprog).
    run value(procedure). */
  end.
