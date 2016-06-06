/* listedit.i
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

/* listedit.i
most updated version of line program
only 4 keys will be used:  F1 - go, run
			   F2 - help
			   F3 - insert-probably not used
			   F4 - end-error, quit
010593 by janet
*/

define new shared variable s-{&headkey} like {&head}.{&headkey}.

define variable v-newhead as logical.
define variable v-newline as logical.
define variable v-cnt as integer.
define variable v-down as integer.
define variable v-tmpline as integer.
define variable v-ans as logical.

{&variable}

{&start}

form {&form} with frame {&prefix}{&head}{&suffix} {&frame}.
view frame {&prefix}{&head}{&suffix}. pause 0.

find first {&head} where {&where} use-index {&index} no-error.
if not available {&head} then do:
  if {&addcon} then v-newhead = true.
	       else return.
end.

v-tmpline = 1.

outer:
repeat:

  if v-tmpline = 1 then do:
    clear frame {&prefix}{&head}{&suffix} all.
    v-down = 0.
  end.

  if available {&head} then do:
    repeat v-cnt = v-tmpline to frame-down({&prefix}{&head}{&suffix}):
      {&predisplay}
      display {&display} with frame {&prefix}{&head}{&suffix}.
      {&postdisplay}
      if v-cnt ge frame-down({&prefix}{&head}{&suffix}) then leave.
      find next {&head} where {&where} use-index {&index} no-error.
      if not available {&head} then do:
	find last {&head} where {&where} use-index {&index} no-error.
	leave.
      end.
      down with frame {&prefix}{&head}{&suffix}.
      v-down = v-down + 1.
    end.
  end.

  v-tmpline = 1.

  inner:
  repeat on endkey undo, leave outer:

    hide message.

    if v-newhead eq false then do:
      choose row {&head}.{&headkey}
      no-error with frame {&prefix}{&head}{&suffix}.
    end.

    if keyfunction(lastkey) eq "CURSOR-UP" and
      frame-line({&prefix}{&head}{&suffix}) eq 1 then do:
      repeat v-cnt = 1 to frame-down({&prefix}{&head}{&suffix}) + v-down:
	find prev {&head} where {&where} use-index {&index} no-error.
	if not available {&head} then do:
	  find first {&head} where {&where} use-index {&index} no-error.
	  leave.
	end.
      end.
      next outer.
    end.

    else
    if keyfunction(lastkey) eq "CURSOR-DOWN" and
      frame-line({&prefix}{&head}{&suffix}) eq
      frame-down({&prefix}{&head}{&suffix})
      then do:
      find next {&head} where {&where} use-index {&index} no-error.
      next outer.
    end.

    else
    if keyfunction(lastkey) eq "CURSOR-LEFT" then do:
      find first {&head} where {&where} use-index {&index} no-error.
      next outer.
    end.

    else
    if keyfunction(lastkey) eq "CURSOR-RIGHT" then do:
      find last {&head} where {&where} use-index {&index} no-error.
      next outer.
    end.

    else
    if keyfunction(lastkey) eq "DELETE-LINE" then do:

      find {&head} where {&where} and
	{&head}.{&headkey} eq {&type}(frame-value) use-index {&index} no-error.

      if not available {&head} then do:
	{mesg.i 0211}.
	bell. next inner.
      end.

      else
      if {&deletecon} then do:
	v-ans = false.
	{mesg.i 0882} update v-ans.
	if v-ans eq false then undo, retry.
	{&startdelete}
	{&postminus}
	{&predelete}
	delete {&head}.
	{&postdelete}
	v-tmpline = frame-line({&prefix}{&head}{&suffix}).

	repeat v-cnt = v-tmpline to frame-down({&prefix}{&head}{&suffix}):
	  clear frame {&prefix}{&head}{&suffix}.
	  down with frame {&prefix}{&head}{&suffix}.
	end.

	repeat v-cnt = v-tmpline to frame-down({&prefix}{&head}{&suffix}):
	  up 1 with frame {&prefix}{&head}{&suffix}.
	end.

	if "{&type}" eq "integer" then do:
	  find next {&head} where {&where} use-index {&index} no-error.
	  v-tmpline = frame-line({&prefix}{&head}{&suffix}).
	end.
	else
	if "{&type}" eq "string" then do:
	  find first {&head} where {&where} use-index {&index} no-error.
	  v-tmpline = 1.
	end.

	{&enddelete}
	next outer.
      end.

      else do:
	{mesg.i 0231}.
	bell.
      end.
    end.

    else do:
      if v-newhead eq false then
	find {&head} where {&where} and
	  {&head}.{&headkey}
	  eq {&type}(frame-value) use-index {&index} no-error.
      if not available {&head} then v-newline = true.
			       else v-newline = false.

      if v-newline eq true then do:
	if {&addcon} then do:
	  {&startadd}
	  {mesg.i 0403}.
	  {&preadd}
	  create {&head}.
	  if "{&type}" eq "integer" then do:
	    run n-{&head}.
	    {&head}.{&headkey} = s-{&headkey}.
	  end.
	  else update {&head}.{&headkey} with frame {&prefix}{&head}{&suffix}.
	  {&postadd}
	end.

	else do:
	  bell. {mesg.i 0733}.
	end.
      end.

      else
      if v-newline eq false then do:
	if {&updatecon} then do:
	  {&startupdate}
	  {mesg.i 0807}.
	end.
	else do:
	  bell. {mesg.i 0734}.
	end.
      end.

      if {&updatecon} then do on error undo, retry:
	if v-newline eq true then do: {&newpredisplay} end.
	{&predisplay}
	display {&display} with frame {&prefix}{&head}{&suffix}.
	{&postdisplay}
	if v-newline eq true then do: {&newpostdisplay} end.
	if v-newline eq true then do: {&newpreupdate} end.
	{&preupdate}
	update {&update} with frame {&prefix}{&head}{&suffix}.
	{&postupdate}
	if v-newline eq true then do: {&newpostupdate} end.
	if v-newline eq true then do: {&newpredisplay} end.
	{&predisplay}
	display {&display} with frame {&prefix}{&head}{&suffix}.
	{&postdisplay}
	if v-newline eq true then do: {&newpostdisplay} end.
      end.

      if v-newline eq false and {&updatecon} then do: {&endupdate} end.
					     else do: {&endadd} end.

      if v-newline eq true then down 1 with frame {&prefix}{&head}{&suffix}.
      v-newhead = false.

    end. /* add or edit */
  end. /* inner */
end. /* outer */

{&end}
