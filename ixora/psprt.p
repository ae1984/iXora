/* psprt.p
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
def var
wait as cha initial " Ж д и т е .." format "X(13)" .
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

form wait with centered row v-n + 9 no-label frame www .

 find first sysc where sysc.sysc = "PR-DIR" no-lock no-error .
 if not avail sysc then do:
  Message  " Нет PR-DIR записи в sysc  " .  pause .
  return .
 end.
 v-chval = trim(sysc.chval) .

 find first sysc where sysc.sysc = "psphst" no-lock no-error .
 if not avail sysc then do:
  Message  " Нет psphst записи в sysc  " .  pause .
  return .
 end.
 shost = trim(sysc.chval) .

 sview = "joe -rdonly " .
 v-n = 9 .

 {psprt.f}

 repeat  on error undo,retry:
    view frame heading.
    display 

    " Просмотр SWIFT документов    17" skip
    " Печать   SWIFT документов    18" skip
    " Архивация SWIFT документов   19" skip
    " Просмотр архива SWIFT док-ов 20" skip
    with row 1 column 44 1 column overlay no-hide no-label frame menu1.

     
     display sview label "Viewer "
      shost label "HOST для печати" with side-label
      column 44  1 column row 10 overlay no-hide frame vw.

    set v-slct validate(v-slct gt 0 and v-slct le 20 ,"Введите от 1 до 20" )
        with frame menu.
    if v-slct = 1 then  do:
     if
     search(v-chval + "/1TRXprot.log" ) = v-chval + "/1TRXprot.log"
     then do:
      unix  value ( sview + " " + v-chval + "/1TRXprot.log" ) .
      pause 0 .
     end.
     else
     do:
      message " Протокол не найден      ! " . pause .
      /*
      display search(v-chval + "/1TRXprot.log" ) format "x(60)" .
      display v-chval + "/1TRXprot.log"  format "x(60)" .
      */
     end.
    end.
    else
    if v-slct = 2 then  do:
     if
     search(v-chval + "/1TRXprot.log" ) = v-chval + "/1TRXprot.log"
     then do:

     Display wait with centered row v-n + 9 frame www .
     if shost = "" then
     unix  silent value ( "prit "  + " " + v-chval + "/1TRXprot.log" ) .
     else
     unix  silent value ( "prit -h"  + shost
      + " " + v-chval + "/1TRXprot.log" ) .
     pause 0 .
     hide frame www  .
     message " OK " . pause .
     pause 0 .
     end.
     else do: message " Протокол не найден      ! " . pause .
     end.
    end.
    if v-slct = 3 then do :
     if
     search(v-chval + "/1TRXprot.log" ) = v-chval + "/1TRXprot.log"
     then  do:
     yn = false . Message " Вы уверены   ? " update yn .
     if not yn then next .
     Display wait with centered row v-n + 9 frame www .
     unix  silent value ( "echo " +
     "==================================================================== >>"
     + v-chval + "/1TRXprot.arc " ) .
     pause 0 .
     unix  silent value ( "date  >> "  +
      v-chval + "/1TRXprot.arc " ) .
     pause 0 .
     unix  silent value ( "cat " + v-chval + "/1TRXprot.log >> "  +
      v-chval + "/1TRXprot.arc " ) .
     pause 0 .
     unix  silent value ( "/bin/rm  " + v-chval + "/1TRXprot.log  " ) .
     message " OK " . pause .
     hide frame www  .
     pause 0 .
     end .
     else do: message " Protocol does not EXIST ! " .  pause .
     end.
    end.
    else
    if v-slct = 4 then  do:
     unix  value ( sview + " " + v-chval + "/1TRXprot.arc" ) .
     pause 0 .
    end.
    else
    if v-slct = 5 then  do:
     if
     search(v-chval + "/2TRXprot.log" ) = v-chval + "/2TRXprot.log"
     then do:
      unix  value ( sview + " " + v-chval + "/2TRXprot.log" ) .
      pause 0 .
     end.
     else
     do:
      message " Протокол не найден      ! " . pause .
      /*
      display search(v-chval + "/2TRXprot.log" ) format "x(60)" .
      display v-chval + "/2TRXprot.log"  format "x(60)" .
      */
     end.
    end.
    else
    if v-slct = 6 then  do:
     if
     search(v-chval + "/2TRXprot.log" ) = v-chval + "/2TRXprot.log"
     then do:
     Display wait with centered row v-n + 9 frame www .
     if shost = "" then
     unix  silent value ( "prit "  + " " + v-chval + "/2TRXprot.log" ) .
     else
     unix  silent value ( "prit -h"  + shost
      + " " + v-chval + "/2TRXprot.log" ) .
     pause 0 .
     hide frame www  .
     message " Выполнено " . pause .
     pause 0 .
     end.
     else do: message " Протокол не найден      !" . pause .
     end.
    end.
    if v-slct = 7 then do :
     if
     search(v-chval + "/2TRXprot.log" ) = v-chval + "/2TRXprot.log"
     then  do:
     yn = false . Message " Вы уверены ? " update yn .
     if not yn then next .
     Display wait with centered row v-n + 9 frame www .
     unix  silent value ( "echo " +
     "==================================================================== >>"
     + v-chval + "/2TRXprot.arc " ) .
     pause 0 .
     unix  silent value ( "date  >> "  +
      v-chval + "/2TRXprot.arc " ) .
     pause 0 .
     unix  silent value ( "cat " + v-chval + "/2TRXprot.log >> "  +
      v-chval + "/2TRXprot.arc " ) .
     pause 0 .
     unix  silent value ( "/bin/rm  " + v-chval + "/2TRXprot.log  " ) .
     message " OK " . pause .
     hide frame www  .
     pause 0 .
     end .
     else do: message " Протокол не найден      ! " .  pause .
     end.
    end.
    else
    if v-slct = 8 then  do:
     unix  value ( sview + " " + v-chval + "/2TRXprot.arc" ) .
     pause 0 .
    end.
    else
    if v-slct = 9 then  do:
     if
     search(v-chval + "/PDPR.log" ) = v-chval + "/PDPR.log"
     then do:
      unix  value ( sview + " " + v-chval + "/PDPR.log" ) .
      pause 0 .
     end.
     else
     do:
      message " Протокол не найден      ! " . pause .
      /*
      display search(v-chval + "/PDPR.log" ) format "x(60)" .
      display v-chval + "/PDPR.log"  format "x(60)" .
      */
     end.
    end.
    else
    if v-slct = 10 then  do:
     if
     search(v-chval + "/PDPR.log" ) = v-chval + "/PDPR.log"
     then do:
     Display wait with centered row v-n + 9 frame www .
     if shost = "" then
     unix  silent value ( "prit "  + " " + v-chval + "/PDPR.log" ) .
     else
     unix  silent value ( "prit -h"  + shost
      + " " + v-chval + "/PDPR.log" ) .
     pause 0 .
     hide frame www  .
     message " Выполнено " . pause .
     pause 0 .
     end.
     else do: message " Протокол не найден      ! " . pause .
     end.
    end.
    if v-slct = 11 then do :
     if
     search(v-chval + "/PDPR.log" ) = v-chval + "/PDPR.log"
     then  do:
     yn = false . 
     Message " Вы уверены ? " update yn .
     if not yn then next .
     Display wait with centered row v-n + 9 frame www .
     unix  silent value ( "echo " +
     "=################## Архив =========================================== >>"
     + v-chval + "/PDPR.arc " ) .
     pause 0 .
     unix  silent value ( "date  >> "  +
      v-chval + "/PDPR.arc " ) .
     pause 0 .
     unix  silent value ( "cat " + v-chval + "/PDPR.log >> "  +
      v-chval + "/PDPR.arc " ) .
     pause 0 .
     unix  silent value ( "/bin/rm  " + v-chval + "/PDPR.log  " ) .
     message " Выполнено " . pause .
     hide frame www  .
     pause 0 .
     end .
     else do: message " Протокол не найден      ! " .  pause .
     end.
    end.
    else
    if v-slct = 12 then  do:
     unix  value ( sview + " " + v-chval + "/PDPR.arc" ) .
     pause 0 .
    end.
    else
    if v-slct = 13 then  do:
     update  sview with frame vw.
     pause 0 .
    end.
    else
    if v-slct = 14 then  do:
     update  shost with frame vw.
     pause 0 .
    end.
    else
    if v-slct = 15 then  do:
     unix  value ( sview + " " +  "./tmp" ) .
     pause 0 .
    end.
    else
    if v-slct = 16 then  do:
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
     else do: message " tmp файл не найден    ! " . pause .
     end.
    end.

    /*
    procedure = entry(v-slct,v-listprog).
    run value(procedure). 
    */

  if v-slct = 17 then  do:
   if
   search(v-chval + "/SW.log" ) = v-chval + "/SW.log"
   then do:
      unix  value ( sview + " " + v-chval + "/SW.log" ) .
      pause 0 .
   end.
   else
   do:
    message " Протокол не найден      ! " . pause .
   end.
  end.
  if v-slct = 18 then  do:
   if
   search(v-chval + "/SW.log" ) = v-chval + "/SW.log"
   then do:
      Display wait with centered row v-n + 9 frame www .
      if shost = "" then
      unix  silent value ( "prit "  + " " + v-chval + "/SW.log" ) .
      else
      unix  silent value ( "prit -h"  + shost
                + " " + v-chval + "/SW.log" ) .
      pause 0 .
      hide frame www  .
      message " Выполнено " . pause .
      pause 0 .
   end.
   else do: 
     message " Протокол не найден      ! " . pause .
   end.
  end.
  if v-slct = 19 then do :
   if
   search(v-chval + "/SW.log" ) = v-chval + "/SW.log"
   then  do:
    yn = false . 
    Message " Вы уверены ? " update yn .
    if not yn then next .
    Display wait with centered row v-n + 9 frame www .
    unix  silent value ( "echo " +
    "=################## Архив ========================================= >>"
     + v-chval + "/SW.log " ) .
    pause 0 .
    unix  silent value ( "date  >> "  + v-chval + "/SW.arc " ) .
    pause 0 .
    unix  silent value ( "cat " + v-chval + "/SW.log >> "  +
      v-chval + "/SW.arc " ) .
    pause 0 .
    unix  silent value ( "/bin/rm  " + v-chval + "/SW.log  " ) .
    message " Выполнено " . pause .
    hide frame www  .
    pause 0 .
   end .
    else do: 
      message " Протокол не найден      ! " .
      pause .
    end.
  end.
  else
   if v-slct = 20 then  do:
   unix  value ( sview + " " + v-chval + "/SW.arc" ) .
   pause 0 .
  end.
 end.
