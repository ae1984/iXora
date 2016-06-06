/* line-aax.i
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

/* line.i
   01/06/89 editlin3.i by Rim
   revide from editline.i for line item whose keys consist of
   three keys not one.

   note
   1. need head + line no. unique and prime key
   2. need &head ... head file name
	   &line ... line file name
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
	   &newline
   3.
	   &postminus &postplus
*/

def buffer x{&line} for  {&line}.

def shared var    s-{&head} like {&head}.{&head}.

def var disagain as log.
def var vcnt as int.
def var vans as log.

{&var}

form {&form}
     with frame xf {&frame}.

view frame xf.
pause 0.
find {&head} where {&head}.{&head} = s-{&head}.

{&start}

r0:
repeat:
  find first {&line}
       where {&line}.{&head} eq {&head}.{&head}
       use-index {&index}
       no-error.
  if available {&line} then leave.
  create {&line}.
  {&newline}
  {&line}.{&head} = {&head}.{&head}.
  update {&line}.ln with frame xf.
  display {&line}.ln with frame xf.
  {&preupdt}
  update {&fldupdt} with frame xf.
  {&line}.who = userid('bank').
  {&line}.whn = g-today.
  {&line}.tim = time.
  {&posupdt}
  {&predisp}
  {&postplus}
  display {&flddisp} with frame xf.
  {&endadd}
  pause 0.
end. /* r0 */

disagain = true.

r1:
repeat:
  if not available {&line} then leave.
  pause 0.
  if disagain
  then do:
	 pause 0.
	 view frame xf.
	 pause 0.
	 clear frame xf all.
	 repeat vcnt = 1 to frame-down(xf):
	   {&predisp}
	   display {&flddisp} with frame xf.
	   down with frame xf.
	   find next {&line}
		where {&line}.{&head} eq {&head}.{&head}
		use-index {&index}
		no-error.
	   if not available {&line}
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
    input clear.
    choose row {&line}.ln no-error with frame xf.
    find {&line} where {&line}.{&head} = {&head}.{&head} and
		       {&line}.ln = integer(frame-value)
		 use-index {&index} no-error.
    if lastkey eq keycode("cursor-up") and frame-line(xf) = 1
    then do:
	   repeat vcnt = 1 to frame-down(xf):
	     find prev {&line}
		  where {&line}.{&head} eq {&head}.{&head}
		  use-index {&index} no-error.
	     if not available {&line}
	     then do:
		    find first {&line}
			 where {&line}.{&head} eq {&head}.{&head}
			 use-index {&index}.
		    leave.
		  end.
	   end.
	   next r1.
	 end.

    else if lastkey eq keycode("cursor-down")  and
	    frame-line(xf) = frame-down(xf)
    then do:
	   find next {&line} where {&line}.{&head} eq {&head}.{&head}
		     use-index {&index} no-error.
	   if not available {&line}
	   then find last {&line}
		     where {&line}.{&head} eq {&head}.{&head}
		     use-index {&index} .
	   next r1.
	 end.

    else if lastkey eq keycode("cursor-right")
    then do:
	   find last {&line}
		where {&line}.{&head} eq {&head}.{&head}
		use-index {&index}.
	   next r1.
	 end.

    else if lastkey eq keycode("cursor-left")
    then do:
	   find first {&line}
		where {&line}.{&head} eq {&head}.{&head}
		use-index {&index}.
	   next r1.
	 end.
    else leave.
  end. /* r2 */

  if keyfunction(lastkey) = "GO"
  then do:
	 {&no-del}
	 {&startdel}
	 vans = no.
	 {mesg.i 0824} update vans.
	 if vans
	 then do:
		{&predisp}
		{&postminus}
		delete {&line}.
		scroll from-current up with frame xf.
		find first {&line} where
		     {&line}.{&head} = {&head}.{&head}
		     no-error.
	      end.
	 else {mesg.i 0212}.
	 {&enddel}
       end.
  else if frame-value = " "
  then do:
	 {&startadd}
	 {mesg.i 0839}.
	 find last x{&line}
	      where x{&line}.{&head} eq {&head}.{&head}
	      use-index {&index} no-error.
	 create {&line}.
	 {&newline}
	 {&line}.{&head} = {&head}.{&head}.
	 update {&line}.ln with frame xf.
	 display {&line}.ln with frame xf.
	 {&preupdt}
	 update {&fldupdt} with frame xf.
	 {&line}.who = userid('bank').
	 {&line}.whn = g-today.
	 {&line}.tim = time.
	 {&posupdt}
	 {&predisp}
	 {&postplus}
	 display {&flddisp} with frame xf.
	 disagain = false.
	 {&endadd}
       end.

  else if frame-value ne " "
  then do on endkey undo, next r1:
	 {&no-edit}
	 {&startedit}
	 {mesg.i 0807}.
	 {&predisp}
	 {&postminus}
	 {&preupdt}
	 update {&fldupdt} with frame xf.
	 {&line}.who = userid('bank').
	 {&line}.whn = g-today.
	 {&line}.tim = time.
	 {&posupdt}
	 {&predisp}
	 {&postplus}
	 display {&flddisp} with frame xf.
	 disagain = false.
	 {&endedit}
       end.
end.

{&end}
