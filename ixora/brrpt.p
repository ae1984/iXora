/* brrpt.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

def var lll as log .
def var ttt as int .
def var x as int.
def var y as int.
def var h as int.
def var iss as int.
def var cur as int.
def var vvv as cha.
def var v-crc like crc.crc .
def shared var tout as int label " Период ( сек ) " .
def temp-table remtrz field dfb as cha format "x(74)".
x = 0 . y = 3 .  h = 17 .
input from rpt.img.
repeat :
 create remtrz.
 import remtrz.dfb .
end.
input close .
find last remtrz where remtrz.dfb ne "".
vvv = remtrz.dfb .
delete remtrz.
form " " remtrz.dfb " " with column x row y h down overlay
 no-hide title vvv no-label frame ddd .

 find first remtrz .
 cur = recid(remtrz).
repeat:
 clear frame ddd all.
 find remtrz where recid(remtrz) = cur .

 pause 0.
 repeat with frame ddd:
  display remtrz.dfb .
  find next remtrz no-error.
  if not avail remtrz then leave.
  if frame-line = h then leave .
  down with frame ddd.
  pause 0.
 end.
 /*
 display frame-down(ddd) frame-line(ddd).
 */
 up frame-line(ddd) - 1  with frame ddd.

repeat:

 find remtrz where recid(remtrz) = cur .
 display remtrz.dfb  with frame ddd.
 color display message remtrz.dfb  with frame ddd.
 lll = false .
 ttt = time .
 message 
 "<t> - установ.период <F4> - переустановить НОСТРО     <F1> - рассчитать    ".
 message " П е р е с ч е т   через... " + string(tout) + 
 " сек   Ж Д И Т Е........" .
 readkey pause tout. /* !!!!!!!!!!!!! */

 ttt = time - ttt .
 if ttt >= tout then do: lll = true . leave . end .
    /*
     find que of remtrz no-error. if avail que then
     display que.pid with column 10 row 5 frame aaa .
    */
 color display normal remtrz.dfb with frame ddd.

 if keyfunction(lastkey) = "cursor-up" then
     do:
      find prev remtrz no-error.
      if avail remtrz then do:
      cur = recid(remtrz).
      if frame-line(ddd) = 1 then
       scroll down with frame ddd .
       else
       up 1 with frame ddd.
      end.
     end.

 if keyfunction(lastkey) = "cursor-down" then
     do:
      find next remtrz no-error.
      if avail remtrz then do:
      cur = recid(remtrz).
      if frame-line(ddd) = frame-down(ddd)  then
       scroll up with frame ddd .
       else
       down 1 with frame ddd.
      end.
     end.
 if keyfunction(lastkey) = "home" then
     do:
      find first remtrz .
      cur = recid(remtrz).
      leave .
     end.

 if keyfunction(lastkey) = "right-end" then
     do:
      find last remtrz .
      iss = h .
      repeat :
      iss = iss - 1.
      find prev remtrz .
      if iss = 1 then leave .
      end.
       cur = recid(remtrz).
       leave .
     end.

 if keyfunction(lastkey) = "t" then
  do on endkey undo:
   message " Timeout (sec) " update tout .
  end.

 if keyfunction(lastkey) = "page-down" then
     do:
      iss = h .
      repeat :
      iss = iss - 1.
      find next remtrz no-error .
      if not avail remtrz then
      do:
       find last remtrz .
       find prev remtrz .
       find prev remtrz .
       leave .
      end.
      if iss = 1 then leave .
      end.
       cur = recid(remtrz).
       leave .
     end.
 if keyfunction(lastkey) = "page-up" then
     do:
      iss = h .
      repeat :
      iss = iss - 1.
      find prev remtrz no-error .
      if not avail remtrz then
      do:
       find first remtrz .
       leave .
      end.
      if iss = 1 then leave .
      end.
       cur = recid(remtrz).
       leave .
     end.


 if keyfunction(lastkey) = "End-Error" then leave .
 if keyfunction(lastkey) = "Go" then leave .
 else
  do:
      find first remtrz where remtrz.dfb begins keyfunction(lastkey) no-error.
      if avail remtrz then do:
       cur = recid(remtrz).
       leave .
      end.
      else find remtrz where recid(remtrz) = cur .
  end.

end.
 if keyfunction(lastkey) = "End-Error" then leave .
 if keyfunction(lastkey) = "Go" then leave .
 if lll then  leave .
pause 0.

end.
