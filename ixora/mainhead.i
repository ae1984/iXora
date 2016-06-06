/* mainhead.i
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
        12/12/03 sasco добавил no-lock
        21/02/2008 madiyar - подправил под новый размер терминала
        
*/

/* mainhead.i
   Program head
   05-21-87 created by yong k. yoon
   12-07-88 revised by Simon Y. Kim
   12-29-92 revised by Janet Shin
   {1} = procedure description
*/

{global.i "{2} "}

if "{2}" eq "new global" then run setglob.

if "{1}" ne "" then do:
  g-fname = "{1}".
  g-mdes = "".
  find nmenu where nmenu.fname eq "{1}" no-lock no-error.
  find nmdes where nmdes.fname eq "{1}"
              and  nmdes.lang  eq g-lang no-lock no-error.
  if available nmdes then g-mdes = nmdes.des.
end.

if g-batch eq false then
display
  g-fname format "x(16)" g-mdes format "x(65)" "iXora  " g-ofc /*to 71*/ g-today format "99/99/9999"  /*to 80*/
  with color messages /*centered*/ overlay no-box no-label row 2 width 110 /*col 1*/ frame mainhead.
