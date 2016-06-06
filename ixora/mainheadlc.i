/* mainheadlc.i
 * MODULE
        Trade Finance
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
        18/02/2011 id00810 (на основе mainhead.i -  в качестве параметра передается значение переменной)
 * BASES
        BANK
 * CHANGES
*/

{global.i}

if {&nm} ne "" then do:
  g-fname = {&nm}.
  g-mdes = "".
  find nmenu where nmenu.fname eq {&nm} no-lock no-error.
  find nmdes where nmdes.fname eq {&nm}
              and  nmdes.lang  eq g-lang no-lock no-error.
  if available nmdes then g-mdes = nmdes.des.
end.

if g-batch eq false then
display
  g-fname format "x(16)" g-mdes format "x(65)" "iXora  " g-ofc /*to 71*/ g-today format "99/99/9999"  /*to 80*/
  with color messages /*centered*/ overlay no-box no-label row 2 width 110 /*col 1*/ frame mainhead.
