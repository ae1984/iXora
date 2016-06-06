/* nbal+r.i
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


/*       increase   nbal correction    */



find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if avail sysc and  sysc.chval ne  "" then do:

 if remtrz.sbank ne sysc.chval  and  remtrz.jh1 eq ? and remtrz.dracc ne ""
  then do:
  find first nbal where nbal.dfb = remtrz.dracc and
    nbal.plus = remtrz.valdt1 - g-today exclusive-lock no-error .
  if not avail nbal then
   do:
    create nbal .
    nbal.dfb = remtrz.dracc .
    nbal.plus = remtrz.valdt1 - g-today .
    nbal.inwbal = 0 .
    nbal.outbal = 0 .
   end .
  nbal.inwbal = nbal.inwbal + remtrz.amt .
 end.

 if remtrz.rbank ne sysc.chval  and remtrz.jh2 eq ? and remtrz.cracc
  ne "" then do:
  find first nbal where nbal.dfb = remtrz.cracc and
    nbal.plus = remtrz.valdt2 - g-today exclusive-lock no-error .
  if not avail nbal then
   do:
    create nbal .
    nbal.dfb = remtrz.cracc .
    nbal.plus = remtrz.valdt2 - g-today .
    nbal.inwbal = 0 .
    nbal.outbal = 0 .
   end .
  nbal.outbal = nbal.outbal + remtrz.payment .
 end.

end.
/*        end nbal                */
