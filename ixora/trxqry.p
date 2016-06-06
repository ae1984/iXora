/* trxqry.p
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

/* trxqry.p
*/

{mainhead.i "STBD"}

def var famt like jl.dam.
def var tamt like jl.dam.
def var fdate as date.
def var tdate as date.
def var type as cha format "x(1)".

{trxqry.f}
fdate = g-today.
tdate = g-today.
type = "B".

repeat:
  update famt tamt skip
         fdate tdate type {trxqry.h}
         with centered row 7 side-label frame opt.
  view frame jl.
  for each jl where jl.jdt ge fdate and jl.jdt le tdate
                  and (jl.dam ge famt  and jl.dam le tamt and
                      (type eq "D" or type eq "B") or
                    jl.cam ge famt  and jl.cam le tamt and
                      (type eq "C" or type eq "B")
                   ) no-lock:

    find gl where gl.gl eq jl.gl.
    find jh where jh.jh eq jl.jh.
    display jl.jh  jl.gl gl.sname jh.cif jh.party
            jl.jdt jl.acc jl.who jl.dam jl.cam skip(1)
         with frame jl centered row 5 down.
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
