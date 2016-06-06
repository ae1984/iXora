/* canbal.i
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




       /*    nbal cancel   */

 if entry(1,que.pvar) ne  "" and (
 string(remtrz.valdt1 - 01/01/01 ) ne entry(1,que.pvar) or
  remtrz.dracc ne entry(3,que.pvar) or
  string(remtrz.amt) ne entry(2,que.pvar) ) and
  remtrz.jh1 eq ?
  then
  do:
  find first nbal where nbal.dfb = entry(3,que.pvar) and
    nbal.plus = integer(entry(1,que.pvar)) + 01/01/01
     - g-today exclusive-lock no-error .

  if avail nbal then
   do:
   nbal.inwbal = nbal.inwbal - decimal(entry(2,que.pvar)) .
   if nbal.inwbal = 0 and nbal.outbal = 0 then delete nbal .
   end.
 end .

 if entry(4,que.pvar) ne  "" and (
 string(remtrz.valdt2 - 01/01/01 ) ne entry(4,que.pvar) or
  remtrz.cracc ne entry(6,que.pvar) or
  string(remtrz.payment)  ne entry(5,que.pvar) )
  and remtrz.jh2 eq ?
 then do:
  find first nbal where nbal.dfb = entry(6,que.pvar) and
    nbal.plus = integer(entry(4,que.pvar)) + 01/01/01
     - g-today exclusive-lock no-error .
  if avail nbal then
  do:
   nbal.outbal = nbal.outbal - decimal(entry(5,que.pvar)) .
   if nbal.inwbal = 0 and nbal.outbal = 0 then delete nbal .
  end.
 end .


       /*      end nbal    */
