/* x-jlam.p
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

/* x-jlam.p
*/
{global.i}.
def var vamt like jl.dam.

repeat:
  {mesg.i 8802} update vamt.
  if vamt = 0 then leave.
  for each jl where jl.dam = vamt or jl.cam = vamt:
    display jl.jh jl.jdt jl.who jl.dam jl.cam with frame amt
	    down centered title "Search by Amount".
  end.
end.
