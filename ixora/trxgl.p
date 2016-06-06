/* trxgl.p
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
        24.08.06 marinav - оптимизация
*/

{mainhead.i "STBM"}

def var famt like jl.dam.
def var tamt like jl.dam.
def var fdate as date.
def var tdate as date.
def var type as cha format "x(1)".
def var vgl like gl.gl.
def var vdes like gl.des.

form vgl   label "Счет ГК" skip
     type  label "Тип операции"  skip
     famt  label "Нач.сумма" skip
     tamt  label "Кон.сумма" skip
     fdate label "Нач. дата" skip
     tdate label "Кон. дата" skip
     with  frame opt.

fdate = g-today.
tdate = g-today.
type = "B".

  update vgl validate(can-find(gl where gl.gl = vgl),"RECORD NOT FOUND")
         type help "D - Дебетовые   C - Кредитовые   B - Все" skip
	 famt tamt skip
	 fdate tdate
	 with centered row 3 2 col side-label frame opt.

hide frame opt. pause 0.

  find gl where gl.gl = vgl.
  vdes = "  " + string(gl.gl) + " - " + gl.des + "   ".

  for each jl where jl.jdt ge fdate and jl.jdt le tdate and  jl.gl = vgl no-lock use-index jdt	.

     if type eq "D" or type eq "B" then do:
           if jl.dam ge famt  and jl.dam le tamt then 
		      
             display jl.jh jl.jdt jl.acc jl.who jl.dam format '>>>,>>>,>>9.99' jl.cam format '>>>,>>>,>>9.99' 
         	 with frame jl
         	 centered row 5 down title vdes.
     end.
     if type eq "C" or type eq "B" then do:
	   if jl.cam ge famt  and jl.cam le tamt then

             display jl.jh jl.jdt jl.acc jl.who jl.dam format '>>>,>>>,>>9.99'  jl.cam format '>>>,>>>,>>9.99' 
         	 with frame jl
         	 centered row 5 down title vdes.
     end.
  end.
