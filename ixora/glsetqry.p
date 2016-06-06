/* glsetqry.p
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

/*
  glsetqry.p
*/
{global.i}
def shared var s-gl like gl.gl.
def var famt like jl.dam label "Сумма >=".
def var tamt like jl.dam label "Сумма <=".
def var fdate as date label "Дата >=".
def var tdate as date label "Дата <=".
def var type as cha format "x(1)" label "Актив/Пассив " initial "B".
def var vdes like gl.des.

fdate = g-today.
tdate = g-today.
tamt = 9999999999999.99.

repeat:
  update famt skip
         tamt skip
         fdate skip
         tdate skip
         type help "D>Дебет C>Кредит B>Все"
         with centered row 5 side-label frame opt.
  find gl where gl.gl = s-gl.
  vdes = "  " + string(gl.gl) + " - " + gl.des + "   ".
  for each jl where jl.gl = s-gl and
                  jl.jdt ge fdate and jl.jdt le tdate
                  and 
   (
   (jl.dam ge famt  and jl.dam le tamt and (type eq "D" or type eq "B")) 
   or
   (jl.cam ge famt  and jl.cam le tamt and (type eq "C" or type eq "B")
   )
                   ) use-index jdt no-lock:
    find jh where jh.jh eq jl.jh.
    display jl.jh jl.jdt jh.cif jl.acc jl.who skip
            jl.dam jl.cam
         with frame jl
         centered row 3 down .
  end.
end.
