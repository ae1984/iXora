/* ocksp.p
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

/* ocksp.p
   Official Check Stop Payment
*/

{mainhead.i "OCSTOP"}

define var ans as log.
define var fv as char.
define var inc as int.

repeat:
  prompt-for ock.ock with row 3 centered 1 col frame ock.
  find ock using ock.ock no-error.
  if not available ock
  then do:
	 bell.
	 {mesg.i 0230}.
	 undo, retry.
       end.

  {ocksp.f}

  if ock.cam[1] - ock.dam[1] eq 0
    then do:
      bell.
      {mesg.i 0888}.
      undo, retry.
    end.
  {mesg.i 6802} update ans.
  if ans eq false then undo, retry.
  if spflag eq true
    then spflag = false.
    else spflag = true.
  ock.spdt = g-today.
  ock.spby = g-ofc.
  display ock.spflag ock.spdt ock.spby
    with frame ock.
  update ock.reason with frame ock.
end.
