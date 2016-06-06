/* l-jm.p
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

/* l-jm.p
*/

{mainhead.i "STBA"}

def var vamt like jl.dam.

repeat:
  view frame jl.
  {mesg.i 8803} update vamt.
  for each jl where jl.jdt eq g-today and (jl.dam eq vamt or jl.cam eq vamt)
               and  (jl.who eq g-ofc   or g-ofc eq "root") no-lock:
    find gl where gl.gl eq jl.gl.
    find jh where jh.jh eq jl.jh.
    display jl.jh jl.gl gl.sname
            jh.cif jh.party
            jl.dam jl.cam
            jl.jdt jl.acc jl.who
         with frame jl centered row 3 down.
    if jh.cif ne ""
      then do:
        find cif where cif.cif eq jh.cif.
        display trim(trim(cif.prefix) + " " + trim(cif.sname)) @ jh.party
          with frame jl.
      end.
    down 1 with frame jl.
  end.
  clear frame jl all.
end.
