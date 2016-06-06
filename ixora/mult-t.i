/* mult-t.i
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

/* mult.i
most updated version of line program
only 6 keys will be used:  F1 - go
			   F2 - help
			   F3 - insert-probably not used
			   F4 - end-error, quit
			   F5 - get
			   F6 - put
*/
define buffer b-{&head} for {&head}.

define new shared variable s-{&headkey} like {&head}.{&headkey}.
define new shared variable s-newrec as logical.
define new shared frame menu.

define variable v-newhead as logical.
define variable v-newline as logical.
define variable v-cnt as integer.
define variable v-down as integer.
define variable v-tmpline as integer.
define variable v-ans as logical.
define variable v-top as int initial -1.
def var prof-prefix as char.

{{&formname}.f}

{&start}

view frame {&framename}. pause 0.
{&viewframe}

find first {&head} where {&where}  no-error.
if not available {&head} then do:
  if {&addcon} then v-newhead = true.
	       else return.
end.

v-tmpline = 1.

outer:
repeat:

  if v-tmpline = 1 then do:
    clear frame {&framename} all.
    v-down = 0.
  end.

  if available {&head} then do:
    repeat v-cnt = v-tmpline to frame-down({&framename}):
      {&predisplay}
      display {&display} with frame {&framename}.
      {&postdisplay}
      if v-cnt ge frame-down({&framename}) then leave.
      find next {&head} where {&where} no-error.
      if not available {&head} then do:
	find last {&head} where {&where}  no-error.
	leave.
      end.
      down with frame {&framename}.
      v-down = v-down + 1.
     end.
  end.

  v-tmpline = 1.

  inner:
  repeat on endkey undo, leave outer:

    hide message.

    if v-newhead eq false then do:
      choose row {&head}.{&headkey} go-on("home")
      no-error with frame {&framename}.
    end.

    if keyfunction(lastkey) eq "CURSOR-UP" and
      frame-line({&framename}) eq 1 then do:
      repeat v-cnt = 1 to frame-down({&framename}) + v-down:
	find prev {&head} where {&where}  no-error.
	if not available {&head} then do:
	  find first {&head} where {&where}  no-error.
	  leave.
	end.
      end.
      next outer.
    end.

    else
    if keyfunction(lastkey) eq "CURSOR-DOWN" and
      frame-line({&framename}) eq
      frame-down({&framename})
      then do:
      find next {&head} where {&where}  no-error.
      next outer.
    end.

    else
    if keyfunction(lastkey) eq "HOME" then do:
      if v-top eq 1 then
	find first {&head} where {&where}  no-error.
      else if v-top eq -1 then
	find last {&head} where {&where}  no-error.
      v-top = v-top * -1.
      next outer.
    end.

    else if v-newhead eq true or
	    keyfunction(lastkey) eq "GO" or
	    keyfunction(lastkey) eq "RETURN" then do:
      if v-newhead eq false then
	find first {&head} where {&where} and
	  {&datetype}({&head}.{&headkey}) eq {&type}(frame-value)
	   no-error.
      if not available {&head} then v-newline = true.
			       else v-newline = false.

      if v-newline eq true then do:
	if {&addcon} then do:
	  {mesg.i 0403}.
	  {&preadd}
	  if "{&numprg}" eq "prompt" then do:
	    prompt {&head}.{&headkey} with frame {&framename}.
	    find first {&head} where {&where}
			       using input {&head}.{&headkey} no-error.
	    if available {&head} then do:

	      {mesg.i 0238}.
	      find first {&head} where {&where} .
	      bell.  next outer.
	    end.
	    s-{&headkey} = input {&head}.{&headkey}.
	    hide message.
	    create {&head}.
	    {&head}.{&headkey} = s-{&headkey}.
	  end. /* prompt */
	  else do:
	    run {&numprg}.
	    create {&head}.
	    {&head}.{&headkey} = s-{&headkey}.
	  end.
	  {&postadd}
	  display {&head}.{&headkey} with frame {&framename}.
	  s-newrec = true.

	end.

	else do:
	  bell.
	  {mesg.i 0233}.
	  next inner.
	end.
      end. /* v-newline eq true */

      else
      if v-newline eq false then do:
	if {&updatecon} then do:
	  {mesg.i 0807}.
	end.
	else do:
	  bell. {mesg.i 0201}.
	end.
      end.

      if {&updatecon} then do on error undo, retry:
	if v-newline eq true then do: {&newpreupdate} end.
	{&preupdate}
	update {&update} with frame {&framename}.
	{&postupdate}
      end.

      if v-newline eq true and {&addcon} then do: {&newpostupdate} end.

      if v-newline eq true then down 1 with frame {&framename}.
      v-newhead = false.

    end. /* v-newhead eq true or GO or RETURN - add or edit */

    else
    if keyfunction(lastkey) eq "DELETE-LINE" then do:

      find first {&head} where {&where} and
	{&datetype}({&head}.{&headkey}) eq {&type}(frame-value)
	 no-error.

      if not available {&head} then do:
	bell. {mesg.i 0230}. next inner.
      end.

      else
      if {&deletecon} then do:
	v-ans = false.
	{mesg.i 0882} update v-ans.
	if v-ans eq false then undo, retry.
	{&predelete}
	delete {&head}.
	{&postdelete}
	v-tmpline = frame-line({&framename}).

	repeat v-cnt = v-tmpline to frame-down({&framename}):
	  clear frame {&framename}.
	  down with frame {&framename}.
	end.

	repeat v-cnt = v-tmpline to frame-down({&framename}):
	  up 1 with frame {&framename}.
	end.

	find next {&head} where {&where}  no-error.
	v-tmpline = frame-line({&framename}).

	next outer.
      end.

      else do:
	bell. {mesg.i 0231}.
      end.
    end.

    else
    if keyfunction(lastkey) eq "GET" then do:
      find first {&head} where {&where} and
	{&datetype}({&head}.{&headkey}) eq {&type}(frame-value)
	 no-error.
      if available {&head} then do:
	s-{&headkey} = {&head}.{&headkey}.
	{&get}
      end. /* vail line */
      else do:
	bell. {mesg.i 0955}.
      end.
    end.

    else
    if keyfunction(lastkey) eq "PUT" then do:
      find first {&head} where {&where} and
	{&datetype}({&head}.{&headkey}) eq {&type}(frame-value)
	 no-error.
      if available {&head} then do:
	s-{&headkey} = {&head}.{&headkey}.
	{&put}
      end. /* vail line */
      else do:
	bell. {mesg.i 0955}.
      end.
    end.

    else do: /* other key has been pressed */
      bell.
    end.

  end. /* inner */
end. /* outer */

{&end}
