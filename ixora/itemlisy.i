/* itemlisy.i
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

/* itemlist.i
*/
/*def shared var vitm like itm.itm.*/
/*def shared var vven like itm.ven.*/
/*def shared var vdes like itm.des.*/
/*def shared var vprc like itm.listp.*/
{&var}
{&start}
form {&form} with {&frame} top-only frame xf.
view frame xf.
pause 0.
{&updvar}
find first {&file} where {&where} use-index {&index} no-lock no-error.
if not available {&file}
then do:
       {mesg.i 0211}.
       pause 2.
       hide message.
       return.
     end.
{&findaddr}
outer:
repeat:
  clear frame xf all.
  repeat vcnt = 1 to frame-down(xf):
    {&predisp}
    display {&flddisp}
	    with frame xf.
    {&dispadd}
    down with frame xf.
    find next {&file} where {&where}
		      use-index {&index}
		      no-lock no-error.
    if not available {&file} then leave.
    {&findaddr}
  end.
  if lastkey eq keycode("cursor-up")
  then up frame-line(xf) - 1 with frame xf.
  else up with frame xf.

  inner:
  repeat on endkey undo, leave outer:

    choose row {&file}.{&chkey} no-error with frame xf.
    find first {&file} where {&where} and
		       {&file}.{&chkey} eq {&chtype}(frame-value)
		 use-index {&index}
		 no-lock no-error.
    if lastkey eq keycode("cursor-up") and frame-line(xf) = 1
    then do:
	   repeat vcnt = 1 to frame-down(xf):
	     find prev {&file} where {&where} use-index {&index}
			       no-lock no-error.
	     if not available {&file}
	     then do:
		    find first {&file} where  {&where}
				       use-index {&index}
				       no-lock.
		    {&findaddr}
		    leave.
		  end.
	     {&findaddr}
	   end.
	   leave inner.
	 end.
    else if lastkey eq keycode("cursor-down")  and
	    frame-line(xf) = frame-down(xf)
    then do:
	   find next {&file} where {&where} use-index {&index}
			     no-lock no-error.
	   if not available {&file}
	   then find last {&file} where {&where} use-index {&index}
				  no-lock.
	   {&findaddr}
	   leave inner.
	 end.

    else if lastkey eq keycode("cursor-right")
    then do:
	   find last {&file} where {&where} use-index {&index}
			     no-lock.
	   {&findaddr}
	   leave inner.
	 end.
    else if lastkey eq keycode("cursor-left")
    then do:
	   find first {&file} where {&where} use-index {&index}
			      no-lock.
	   {&findaddr}
	   leave inner.
	 end.

    else do:
	      if frame-value = " " then do: {&funaddr} end.
				   else do: {&prereturn} leave outer. end.
	 end.

  end. /* inner */
end. /* outer */
if keyfunction(lastkey) eq "GO" or
   keyfunction(lastkey) eq "RETURN" then frame-value = frame-value.
hide frame xf.
{&end}
