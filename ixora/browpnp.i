/* browpnp.i
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

def var ys as log format "да/нет".
def var y as int.
def var iss as int.
def var cur as int.
def var curold as int.

 find first {&file} where {&where} no-lock no-error .
 if avail {&file} then
 cur = recid({&file}).
 else 
 do: cur =  0 .
  if not {&addcon} then return . 
 end .

form {&form} with {&frame-phrase} frame frm.
{&first}
view frame frm.
pause 0 .
repeat:
 clear frame frm all.

 if cur ne 0 then do:
 find {&file} where recid({&file}) = cur no-lock .

 pause 0.
 repeat :
  {&predisp}
  display {&disp} with frame frm .
  pause 0 .
  find next {&file} where {&where} no-lock no-error  .
  if not avail {&file} then leave.
  if frame-line(frm) = {&h} then leave .
  down  with frame frm.
  pause 0.
 end.
 up frame-line(frm) - 1  with frame frm.

end .

repeat:
 if cur ne 0 then do:
 find {&file} where recid({&file}) = cur no-lock .
  {&predisp}
  display {&disp} with frame frm .
  color display message {&seldisp} with frame frm.
  pause 0 .
 end .
 else clear frame frm all .
 readkey. /* !!!!!!!!!!!!! */

 color display normal {&seldisp} with frame frm.
 pause 0 .

 if keyfunction(lastkey) = "cursor-up" then
     do:
      find prev {&file} where {&where} no-lock no-error .
      if avail {&file} then do:
      cur = recid({&file}).
      if frame-line(frm) = 1 then
       scroll down with frame frm .
       else do:
         up 1 with frame frm.
        end .
      end.
     end.
 else
 if keyfunction(lastkey) = "cursor-down" then
     do:
      find next {&file} where {&where} no-lock no-error.
      if avail {&file} then do:
      cur = recid({&file}).
      if frame-line(frm) = frame-down(frm)  then
       scroll up with frame frm .
       else
       down 1 with frame frm.
      end.
     end.
 else
 if keyfunction(lastkey) = "home" then
     do:
      find first {&file} where {&where} no-lock .
       cur = recid({&file}).
      leave .
     end.
 else
 if keyfunction(lastkey) = "right-end" then
     do:
      find last {&file} where {&where} no-lock .
      iss = {&h} .
      repeat :
      iss = iss - 1.
      find prev {&file} where {&where} no-lock .
      if iss = 1 then leave .
      end.
       cur = recid({&file}).
       leave .
     end.
 else
 if keyfunction(lastkey) = "delete-line" and {&delcon} then

 do on error undo , leave :

  ys = false .
  {&predelete}
  message " Вы уверены ? " update ys .
  if not ys then do: undo , leave . end .

  curold = cur .
  find next {&file} where {&where} no-lock no-error.
  if not avail {&file} then do:
   find {&file} where recid({&file}) = curold no-lock .
   find prev {&file} where {&where} no-lock no-error .
    if not avail {&file} then do:
     cur = 0  .
    /*   leave .    */
    end.
   else
   cur = recid({&file}) .
  end.
  else
  cur = recid({&file}) .

   find {&file} where recid({&file}) = curold exclusive-lock .
   delete {&file} .
   {&posdelete}
   clear frame frm all .
   leave .

 end.


 else

 if keyfunction(lastkey) = "new-line" and {&addcon} then
     do:
       create {&file}  .
       {&poscreat}

      if frame-line(frm) = frame-down(frm)  then
       scroll up with frame frm .
       else do:
        scroll from-current down with frame frm.
       end.
     do on endkey undo , leave :
       update {&addupd}  with frame frm.
     end .

     if keyfunction(lastkey) = "end-error" then do:
        delete {&file}.
        find {&file} where recid({&file}) = cur no-lock no-error .
         up 1 with frame frm.
       end.
     {&postadd}
     cur = recid({&file}).
     /*
     find first {&file} no-lock .
     cur = recid({&file}).
     leave.               */
    end.
 else

 if keyfunction(lastkey) = "return" and {&updcon} then
     do:
      find {&file} where recid({&file}) = cur exclusive-lock no-error .
      if avail {&file} then do:
      update {&upd} with frame frm.
      {&postupd}
      leave .
      end.
     end .
     else
 if keyfunction(lastkey) = "return" and {&retcon} then
     do:
     {&befret}
     return.
     end .
 else
 if keyfunction(lastkey) = "page-down" then
     do:
      iss = {&h} .
      repeat :
      iss = iss - 1.
      find next {&file} where {&where} no-lock no-error  .
      if not avail {&file} then
      do:
       find last {&file} where {&where} no-lock .
       find prev {&file} where {&where} no-lock .
       find prev {&file} where {&where} no-lock .
       leave .
      end.
      if iss = 1 then leave .
      end.
       cur = recid({&file}).
       leave .
     end.
 else
 if keyfunction(lastkey) = "page-up" then
     do:
      iss = {&h} .
      repeat :
      iss = iss - 1.
      find prev {&file} where {&where} no-lock no-error .
      if not avail {&file} then
      do:
       find first {&file} where {&where} no-lock .
       leave .
      end.
      if iss = 1 then leave .
      end.
       cur = recid({&file}).
       leave .
     end.
 else
 if keyfunction(lastkey) = "end-error" then
  do:
  {&enderr}
/*   hide all .   */
   return .
  end.
 else do:
 {&action}
 end.
end.
pause 0.

end.
