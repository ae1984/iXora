/* dfbjdts.p
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
        10.01.2005 saltanat - Оптимизировала.
        10.08.2006 ten - Оптимизировал.
         07.12.09 marinav расширен формат поля счета до 20 знаков
*/

/* Отчет по ностро счетам
  С.Шинкарова    */

{mainhead.i}


 def var vdam like jl.dam no-undo.
 def var vcam like jl.cam no-undo.
 def var bbal like jl.cam no-undo.
 def var vdfb like dfb.dfb init "ALL" no-undo.
 def var sdate as date no-undo.
 def var podate as date no-undo.
 def var c1 as char format "x(24)" no-undo.
 def var c2 as char format "x(16)" no-undo.
 def var c3 as char no-undo.
 def var c4 as char format "x(11)" no-undo.
 def var c5 as char no-undo.
 def var c6 as char no-undo.
 def var c7 as char format "x(11)" no-undo.
 def var c8 as char no-undo.
 def var v-dt as date no-undo.




{sdf.f}.
{df.f}.
{image1.i rpt.img}
{image2.i }
{report1.i 59}
put chr(15).

put space(22) c1 skip(1).
put space(20) c2 sdate c3 podate.

if vdfb = "ALL" then do:
   for each gl where gl.subled = "DFB" and gl.lev = 1 no-lock:
       for each jl where jl.jdt >= sdate and jl.jdt <= podate and jl.gl = gl.gl use-index jdt no-lock break by jl.acc by jl.jdt .
              find jh where jh.jh = jl.jh no-lock.
              if true then do:
                 accumulate jl.dam  ( total by jl.jdt ) .
                 accumulate jl.cam  ( total by jl.jdt ) .
                 if first-of(jl.acc) then do:
                    bbal = 0.
                    find first dfb where dfb.dfb = jl.acc no-lock no-error.
                    if avail dfb then do:
                       put skip(2) "-------------------------------------------" dfb.dfb
                                   "-------------------------------------" skip
                                   space(18) c4 space(12) c5 space(14) c6 space(14) c7 skip
                                   "----------------------------------------------------------------------------------------------------"skip
                                   c8 string (time,"HH:MM:SS")
                                   dfb.dam[1] - dfb.cam[1] format "zzz,zzz,zzz,zz9.99-"
                                   dfb.dam[1] dfb.cam[1] skip.
                       put "----------------------------------------------------------------------------------------------------"skip.
                    end.
                 end.
                 if last-of(jl.jdt) then  do:
                    find dfb where dfb.dfb = jl.acc no-lock no-error.
                    if avail dfb then do:
                       vdam =  accum total by jl.jdt  jl.dam .
                       vcam =  accum total by jl.jdt  jl.cam .
                       bbal = bbal + vdam - vcam .

                       put jl.jdt dfb.dam[1] - dfb.cam[1] - bbal format "z,zzz,zzz,zzz,zz9.99-"
                       vdam vcam format "z,zzz,zzz,zzz,zz9.99-"
                       dfb.dam[1] - dfb.cam[1] - bbal + vdam - vcam format "z,zzz,zzz,zzz,zz9.99-" 
                       skip.
                    end.
                 end.
              end.
          end.
   end.
end.
else do:
     for each bank.gl where bank.gl.subled = "DFB" and bank.gl.lev = 1 no-lock:
         for each jl where jl.jdt >= sdate and jl.jdt <= podate and jl.acc = vdfb  and jl.gl = bank.gl.gl use-index jdt no-lock
                           break by jl.acc by jl.jdt.
             find jh where jh.jh = jl.jh no-lock no-error.
             if avail jh then do:
                accumulate jl.dam  ( total by jl.jdt ) .
                accumulate jl.cam  ( total by jl.jdt ) .
                if first-of(jl.acc) then do:
                   bbal = 0.
                   find dfb where dfb.dfb = jl.acc no-lock no-error.
                   if avail dfb then do:
                      put skip(2) "-------------------------------------------" dfb.dfb
                                  "-------------------------------------" skip
                                  space(18) c4 space(12) c5 space(14) c6 space(14) c7 skip
                                  "----------------------------------------------------------------------------------------------------"skip
                                  c8 string (time,"HH:MM:SS")
                                  dfb.dam[1] - dfb.cam[1] format "zzz,zzz,zzz,zz9.99-"
	                                  dfb.dam[1] dfb.cam[1] skip.
                      put "----------------------------------------------------------------------------------------------------"skip.
                   end.
                end.
 
                if last-of(jl.jdt) then  do:
                   find dfb where dfb.dfb = jl.acc no-lock no-error.
                   if avail dfb then do:
 
                      vdam =  accum total by jl.jdt  jl.dam .
                      vcam =  accum total by jl.jdt  jl.cam .
                      bbal = bbal + vdam - vcam .
 
                      put jl.jdt dfb.dam[1] - dfb.cam[1] - bbal format "z,zzz,zzz,zzz,zz9.99-"
                      vdam vcam format "z,zzz,zzz,zzz,zz9.99-"
                      dfb.dam[1] - dfb.cam[1] - bbal + vdam - vcam format "z,zzz,zzz,zzz,zz9.99-" 
                      skip.
                   end.
                end.
             end.
         end.
     end.
end.

{report2.i 132}
{report3.i}
{image3.i}
