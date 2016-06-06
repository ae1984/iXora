/* ockedt.p
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

/* ockedt.p
*/
{global.i}
define var ans as log.
define var fv as char.
define var inc as int.

repeat:
  ans = false.
  prompt-for ock.ock format "x(10)"
    with no-validate row 3 title " Official Check "
	 centered 1 col frame ock editing: {gethelp.i} end.
  find ock using ock.ock no-error.
  if not available ock
  then do:
	 {mesg.i 1808} update ans.
	 if ans eq false then next.
	 create ock.
	 assign ock.ock.
	 update ock.payee ock.rdt ock.ref with frame ock.
       end.
  else display ock.payee ock.rdt ock.ref with frame ock.
  update ock.dam[1] ock.cam[1] with frame ock.
end.
