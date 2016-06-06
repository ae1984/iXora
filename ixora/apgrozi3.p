/* apgrozi3.p
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


{deftrial3.f}

define var drr as dec format "->>,>>>,>>>,>>9.99".
define var crr as dec format "->>,>>>,>>>,>>9.99".

vasof = g-today - 1.
bsof  = g-today - 1.

{image1.i rpt.img}
if g-batch eq false then
  update vasof bsof with centered row 9 no-box frame opt.

vpost = false.
if g-batch eq false and vasof = g-today
 then do:
  bell.
/*  {mesg.i 0906} update vpost. */
 end.


{image2.i}



/* if vpost eq true then run rbpost. */

{report1.i 59}


for each jl where jl.jdt ge vasof and jl.jdt le bsof no-lock
            break by jl.crc by jl.gl :

  if first-of(jl.crc) then do:
  find crc where crc.crc = jl.crc no-lock.
  page.

{shtrial3.f}

 end.
  {report2.i 132}

  if jl.dam gt 0 and jl.cam = 0 then dcnt = dcnt + 1.
  else if jl.dam = 0 and jl.cam gt 0 then ccnt = ccnt + 1.
  else do: dcnt = dcnt + 1. ccnt = ccnt + 1. end.
  accumulate jl.dam (total by jl.gl).
  accumulate jl.cam (total by jl.gl).
  if last-of(jl.gl)
    then do:
    dr = accum total by jl.gl jl.dam.
    cr = accum total by jl.gl jl.cam.
    find gl where gl.gl = jl.gl no-lock .
    find last cls where cls.whn < vasof no-lock no-error.
    if available cls then do:

    find last glday where glday.gdt le cls.whn and glday.gl = jl.gl and
       glday.crc = jl.crc no-lock no-error.
       if available glday then
        vglbal = glday.dam - glday.cam.
    end.
    else    do:
     find glbal where glbal.gl eq gl.gl and glbal.crc eq jl.crc no-lock.
     vglbal = glbal.dam - glbal.cam.
    end.
     vsubbal = vglbal + dr - cr.
     if gl.type eq "L" or gl.type eq "O" or gl.type eq "R"
       then do:
       vglbal = - vglbal.
       vsubbal = - vsubbal.
     end.

     find crc where crc.crc = jl.crc no-lock.
     unitls = crc.rate[9].
     find last crchis where crchis.crc = jl.crc no-lock.
     ratels = crchis.rate[1].
     debls  = dr * ratels / unitls.
     credls = cr * ratels / unitls.

     accumulate debls  ( total by jl.gl ).
     accumulate credls ( total by jl.gl ).

     drr = accum total by jl.gl  debls.
     crr = accum total by jl.gl  credls.

{trialout3.f}

        end.
end.
{report3.i}
{image3.i}
