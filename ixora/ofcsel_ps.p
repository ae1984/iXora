/* ofcsel_ps.p
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

{global.i} 
def var te as char format "x(480)" .
def var err as log format "да/нет" .
def var ys1 as log format "да/нет" .
def var iss1 as int.
def var cur1 as int.
def var curold1 as int.
def var n as int.
def var n1 as int.
def var h as int initial 15 .
def var d as int initial 60 .
def frame frm1 .
def shared var p like pssec.proc .
def var v-ofc like ofc.ofc .
def temp-table ofct
 field ofc like ofc.ofc label 'Исполнитель'
 field name like ofc.name label 'Имя' .

 /*
  g-lang = "RS" .
 */

do transaction :
 find first pssec where pssec.proc = p exclusive-lock .

 n1 = 0 .
 n = 1 .
 do while n <> n1 :
  n1 = n .
  n = index(substring(pssec.ofcs, n + 1), ",") + n .
  do while substring(pssec.ofcs, n + 1, 1) = "," :
   pssec.ofcs = substring(pssec.ofcs, 1, n) + substring(pssec.ofcs, n + 2) .
  end .
 end .
 pssec.ofcs = pssec.ofcs + ',' .

 n = 1 .
 do while entry(n, pssec.ofcs) <> '' :
  te = entry(n, pssec.ofcs) .
  find first ofc where ofc.ofc = te no-lock no-error .
  if avail(ofc) then
   err = false .
  else do :
   err = false .
   message 'Неизвестный исполнитель ' + te + 
   '. Удалить ? ' update err .
  end .
  if not err then do :
   create ofct .
   ofct.ofc = te .
   if avail(ofc) then
    ofct.name = ofc.name .
   else
    ofct.name = 'UNKNOW OFFICER' .
  end .
  n = n + 1 .
 end .


 find first ofct no-lock no-error .
 if avail ofct then
  cur1 = recid(ofct).
 else 
  cur1 =  0 .

form with title p row 2 column 36 scroll 1 h down overlay frame frm.
form v-ofc label 'Исполнитель' 
 with row 5 column 65 overlay frame frm1 .
pause 0 .
repeat:
 clear frame frm all.
 display '                                   F9 - Добавить  F10 - Удалить'
  with column 15 row 21 no-box overlay frame frm2.

 if cur1 ne 0 then do:
 find ofct where recid(ofct) = cur1 no-lock .

 pause 0.
 repeat :
  display ofct.ofc ofct.name with frame frm .
  pause 0 .
  find next ofct no-lock no-error  .
  if not avail ofct then leave.
  if frame-line(frm) = h then leave .
  down  with frame frm.
  pause 0.
 end.
 up frame-line(frm) - 1  with frame frm.

end .

repeat:
 if cur1 ne 0 then do:
  find ofct where recid(ofct) = cur1 no-lock .
  display ofct.ofc ofct.name with frame frm .
  color display message ofct.ofc with frame frm.
  pause 0 .
 end .
 else do : clear frame frm all . display with frame frm . end .
 readkey. /* !!!!!!!!!!!!! */

 color display normal ofct.ofc with frame frm.
 pause 0 .

 if keyfunction(lastkey) = 'cursor-up' then
     do:
      find prev ofct  no-lock no-error .
      if avail ofct then do:
      cur1 = recid(ofct).
      if frame-line(frm) = 1 then
       scroll down with frame frm .
       else do:
         up 1 with frame frm.
        end .
      end.
     end.
 else
 if keyfunction(lastkey) = 'cursor-down' then
     do:
      find next ofct  no-lock no-error.
      if avail ofct then do:
      cur1 = recid(ofct).
      if frame-line(frm) = frame-down(frm)  then
       scroll up with frame frm .
       else
       down 1 with frame frm.
      end.
     end.
 else
 if keyfunction(lastkey) = 'delete-line' then

 do on error undo , leave :

  ys1 = false .
  message ' Вы уверены    ? ' update ys1 .
  if not ys1 then do: undo , leave . end .

  curold1 = cur1 .
  find next ofct  no-lock no-error.
  if not avail ofct then do:
   find ofct where recid(ofct) = curold1 no-lock .
   find prev ofct  no-lock no-error .
    if not avail ofct then do:
     cur1 = 0  .
    /*   leave .    */
    end.
   else
   cur1 = recid(ofct) .
  end.
  else
  cur1 = recid(ofct) .

   find ofct where recid(ofct) = curold1 exclusive-lock .
   delete ofct .
   clear frame frm all .
   leave .

 end.


 else

 if keyfunction(lastkey) = 'new-line' then
     do:
      if cur1 <> 0 then do :
       down 1 with frame frm .
       scroll from-current down with frame frm .
      end .

      do on endkey undo , leave :
       v-ofc = '' .
       hide frame frm2 .
       display fill(' ',79) format 'x(79)' with row 21 no-box .
       update v-ofc  with frame frm1.
       find first ofct where ofct.ofc = v-ofc no-lock no-error .
       find first ofc where ofc.ofc = v-ofc no-lock no-error .
       if avail(ofct) then do :
        err = true .
        message color message 'Исполнитель уже введен !' .
        repeat :
         pause .
         leave .
        end .
       end .
       else
        if avail(ofc) then do :
         err = false .
        end .
        else do :
         err = true .
         message color messages 'Некорректный исполнитель !' .
         repeat :
          pause .
          leave .
         end .
        end .
      end .
      find first ofct where recid(ofct) = cur1 no-lock no-error .
      if keyfunction(lastkey) = 'end-error' or err then do:
        scroll from-current with frame frm .
        up 1 with frame frm.
        pause 0 .
       end.
       else do :
        create ofct .
        ofct.ofc = v-ofc .
        ofct.name = ofc.name .
       end .
      cur1 = recid(ofct) .
      view frame frm2 .
    end.
 else

 if keyfunction(lastkey) = 'page-down' then
     do:
      iss1 = h .
      repeat :
      iss1 = iss1 - 1.
      find next ofct  no-lock no-error  .
      if not avail ofct then
      do:
       find last ofct  no-lock no-error .
       find prev ofct  no-lock no-error .
       find prev ofct  no-lock no-error .
       leave .
      end.
      if iss1 = 1 then leave .
      end.
       cur1 = recid(ofct).
       leave .
     end.
 else
 if keyfunction(lastkey) = 'page-up' then
     do:
      iss1 = h .
      repeat :
      iss1 = iss1 - 1.
      find prev ofct  no-lock no-error .
      if not avail ofct then
      do:
       find first ofct  no-lock no-error .
       leave .
      end.
      if iss1 = 1 then leave .
      end.
       cur1 = recid(ofct).
       leave .
     end.
 else
 if keyfunction(lastkey) = 'end-error' then do :
   te = '' .
   for each ofct no-lock break by ofct.ofc .
    if first-of(ofct.ofc) then
     te = te + ofct.ofc + ',' .
   end .
   pssec.ofcs = te .
   return .
  end.
 else do:
 end.
end.
pause 0.

end.
end .
