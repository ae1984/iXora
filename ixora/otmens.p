/* otmens.p
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

/* optmenus.p
values of : s-menu[1-7]

*/

{global.i}
{menuvar.i}

define var v-max as int initial 7.

s-menu = "".

if s-page eq 1 then do:
  s-sign[1] = "".
  s-sign[2] = "".
  find optmenu where optmenu.optmenu eq s-main no-lock.
  for each optitem where optitem.optmenu eq optmenu.optmenu
    no-lock by optitem.ln:
    find optlang where optlang.optmenu eq optmenu.optmenu
      and optlang.ln eq optitem.ln and optlang.lang eq g-lang no-lock no-error.
    /* s-proc[optitem.ln] = optitem.proc. */
    if available optlang then s-menu[optlang.ln] = optlang.menu.
  end.
  if s-hideone then s-menu[1] = "".
  if s-hidetwo then s-menu[2] = "".
  find optmenu where optmenu.optmenu eq s-opt no-lock.
  for each optitem where optitem.optmenu eq optmenu.optmenu
    no-lock by optitem.ln:
    if optitem.ln  gt v-max then do:
      s-sign[2] = ">".
      leave.
    end.
    find optlang where optlang.optmenu eq optmenu.optmenu
      and optlang.ln eq optitem.ln and optlang.lang eq g-lang no-lock no-error.
    /* s-proc[optitem.ln + 2] = optitem.proc. */
    if available optlang then s-menu[optlang.ln] = optlang.menu.
  end.

end. /* s-page eq 1 */

else do:
  s-sign[1] = "<".
  s-sign[2] = "".
  for each optitem where optitem.optmenu eq s-opt and
    optitem.ln gt (s-page - 1) * v-max - 2 no-lock:
    if optitem.ln - ((s-page - 1) * v-max - 2) gt v-max then do:
      s-sign[2] = ">".
      leave.
    end.
    find optlang where optlang.optmenu eq s-opt and
      optlang.ln eq optitem.ln and optlang.lang eq g-lang no-lock no-error.
    if available optlang then
      s-menu[optitem.ln - ((s-page - 1) * v-max - 2)] = optlang.menu.
  end.
end. /* s-page gt 1 */
