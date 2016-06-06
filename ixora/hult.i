/* hult.i
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

/* hult.i  10.05.94 A.Panov
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

{{&formname}.f}

{&start}

view frame {&framename}. pause 0.
{&viewframe}

find first {&head} where {&where} use-index {&index} no-error.
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
      find next {&head} where {&where} use-index {&index} no-error.
      if not available {&head} then do:
	find last {&head} where {&where} use-index {&index} no-error.
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
      frame-line({&framename}) eq
      frame-down({&framename})
      then do:
      find next {&head} where {&where} use-index {&index} no-error.
      next outer.
    end.

    else
    if keyfunction(lastkey) eq "HOME" then do:
      if v-top eq 1 then
	find first {&head} where {&where} use-index {&index} no-error.
      else if v-top eq -1 then
	find last {&head} where {&where} use-index {&index} no-error.
      v-top = v-top * -1.
      next outer.
    end.
    else
    if keyfunction(lastkey) eq "GO" or
     keyfunction(lastkey) eq "RETURN" then do:
     frame-value = frame-value.
     hide frame {&framename}.
     leave outer.
     end.

    else do: /* other key has been pressed */
      bell.
    end.

  end. /* inner */
end. /* outer */

{&end}
