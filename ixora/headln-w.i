/* headln-w.i
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

/* headln-w.i fron -a missing who whn*/
/* 03/12/89 by Rim
   to accomodate head entry progrm with scrolling features
   where key value is character
*/
/* note
   1. need head no. unique as prime key
   2. need &head ... head file name
	   &form ... Form contents
	   &frame ... Frame Phrase
	   = "row 4 col 1 scroll 1 12 down overlay
		   title "" Line Entry "" "
	   &predisp ... action before display
	   &flddisp ... line display field
	   &fldupdt
	   &posupdt ... action after display
	   &index
	   &updthead ... update head file from lines
   3.
	   &postminus &postplus
*/

def new shared var    s-{&head} like {&head}.{&head}.
def var disagain as log.
def var    vcnt as int.
def var    vans as log.
{&var}
form {&form}
     with frame xf {&frame}.
view frame xf.
pause 0.
{&start}
r0:
repeat:
  find first {&head} no-error.
  if available {&head} then leave.
  create {&head}.
  update {&head}.{&head} with frame xf.
  {&preupdt}
  update {&fldupdt} with frame xf.
  {&posupdt}
  {&predisp}
  {&postplus}
  display {&flddisp} with frame xf.
  pause 0.
end. /* r0 */
disagain = true.

r1:
repeat:
  if not available {&head} then leave.
  pause 0.
  if disagain then do:
  clear frame xf all.
  repeat vcnt = 1 to frame-down(xf):
    {&predisp}
    display {&flddisp} with frame xf.
    down with frame xf.
    find next {&head} no-error.
    if not available {&head}
    then leave.
  end.
  if lastkey eq keycode("cursor-up")
  then up frame-line(xf) - 1 with frame xf.
  else up with frame xf.

  end.
  disagain = true.
  r2:
  repeat on endkey undo r1, leave r1:
    {mesg.i 0963}.
    {mesg.i 0956}.
    choose row {&head}.{&head} no-error with frame xf.

    find {&head} where {&head}.{&head} = frame-value no-error.

    if lastkey eq keycode("cursor-up") and frame-line(xf) = 1
    then do:
	   repeat vcnt = 1 to frame-down(xf):
	     find prev {&head} no-error.
	     if not available {&head}
	     then do:
		    find first {&head}.
		    leave.
		  end.
	   end.
	   next r1.
	 end.

    else if lastkey eq keycode("cursor-down")  and
	    frame-line(xf) = frame-down(xf)
    then do:
	   find next {&head} no-error.
	   if not available {&head}
	   then find last {&head}.
	   next r1.
	 end.

    else if lastkey eq keycode("cursor-right")
    then do:
	   find last {&head}.
	   next r1.
	 end.

    else if lastkey eq keycode("cursor-left")
    then do:
	   find first {&head}.
	   next r1.
	 end.
    else leave.
    end. /* r2 */

    if keyfunction(lastkey) = "GO"
    then do:
		    {&startdel}
		    vans = no.
		    {mesg.i 0824} update vans.
		    if vans
		    then do:
			   {&predisp}
			   {{&postminus}}
			   delete {&head}.
			   scroll from-current up with frame xf.
			   find first {&head}
				no-error.
			 end.
		    else {mesg.i 0212}.
		    {&enddel}
	end.

    else if frame-value = " "
    then do:
		  {&startadd}
		  {mesg.i 0404}.
		  create {&head}.
		  update {&head}.{&head} with frame xf.
		  {&preupdt}
		  update {&fldupdt} with frame xf.
		  {&posupdt}
		  {&predisp}
		  {&postplus}
		  display {&flddisp} with frame xf.
		  disagain = false.
		  {&endadd}
		end.

    else if frame-value ne " "
	     then do:
		    {&startedit}
		    {mesg.i 0807}.
		    {&predisp}
		    {&postminus}
		    {&preupdt}
		    update {&fldupdt} with frame xf.

		    {&posupdt}
		    {&predisp}
		    {&postplus}
		    display {&flddisp} with frame xf.
		    disagain = false.
		    {&endedit}
		  end.
end.
{&end}
