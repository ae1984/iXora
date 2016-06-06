/* dfbjdtn.p
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
        07.12.09 marinav расширен формат поля счета до 20 знаков
*/


{mainhead.i}



 def buffer bdfb for bank.dfb.
 def var vdam like jl.dam.
 def var vcam like jl.cam.
 def var bbal like jl.cam.
 def var vdfb like dfb.dfb init "ALL".
 def var vgl like jl.gl init 132100.
 def var sdate as date.
 def var podate as date.
 def buffer bjl for bank.jl.
 def var c1 as char format "x(24)".
 def var c2 as char format "x(16)".
 def var c3 as char.
 def var c4 as char format "x(16)".
 def var c5 as char.
 def var c6 as char.
 def var c7 as char format "x(11)".
 def var c8 as char format "x(11)".
 def var c9 as char format "x(11)".
 def var c10 as char format "x(12)".
 def var c11 as char format "x(11)".

 {sdfn.f}.
 {dfn.f}.

/*output to dfbjl.txt .*/
{image1.i rpt.img}
{image2.i }

{report1.i 59}

put chr(15).
put space(22) c1 skip(1).
put space(20) c2 sdate c3 podate skip(2).

for each bank.gl where bank.gl.subled = "DFB" and  bank.gl.lev = 1
and bank.gl.gl = vgl no-lock:

for each bjl where bjl.gl = bank.gl.gl and ( bjl.acc = vdfb or vdfb = "ALL" )
    break by bjl.acc by bjl.jdt descending by bjl.cam by bjl.dam  .
find jh where jh.jh = bjl.jh no-lock.

if true then do:

 accumulate bjl.dam  ( total by bjl.jdt ) .
 accumulate bjl.cam  ( total by bjl.jdt ) .

 if first-of(bjl.acc) then do:
   find bdfb where bdfb.dfb = bjl.acc no-lock no-error.
    if not available bdfb then do :
     vdam = 0.
     vcam = 0.
   end.
 end.

 if (first-of(bjl.jdt) or first-of(bjl.acc)) and
     bjl.jdt >= sdate and bjl.jdt <= podate then do:
   put skip(2) "---------------------------------------------------" bjl.acc format "x(20)"
       "-------------------------------------------------" skip
   c4 space(16) c5 space(14) c6 space(6) c7 skip
   "---------------------------------------------------------------------"
   "---------------------------------------------------" skip.
 end.


if bjl.jdt >= sdate and bjl.jdt <= podate then do:
      put  bjl.jdt space(1) bjl.jh space(1) bjl.dam
      format "z,zzz,zzz,zzz,zz9.99-"
      bjl.cam format "z,zzz,zzz,zzz,zz9.99-" space(1) bjl.rem[1]
      skip.
end.

if last-of(bjl.jdt) then  do:

find bdfb where bdfb.dfb = bjl.acc no-lock no-error.


   if not available bdfb then do :
/*
     put bjl.acc " not found ." jh.jh skip.
*/
     vdam = 0.
     vcam = 0.
   end.

  vdam =  accum total by bjl.jdt  bjl.dam .
  vcam =  accum total by bjl.jdt  bjl.cam .

  bbal = bbal + vdam - vcam .

  if bjl.jdt >= sdate and bjl.jdt <= podate then do:

  put "-------------------------------------------------------------"
  "-----------------------------------------------------------" skip
  space(8) c8 space(12) c9 space(10) c10 space(10) c11 skip
  "-------------------------------------------------------------------------------------------------------------------------"skip.

   if  available bdfb then do :
    put bdfb.dam[1] - bdfb.cam[1] - bbal
    format "z,zzz,zzz,zzz,zz9.99-"
     vdam vcam
    format "z,zzz,zzz,zzz,zz9.99-"
    bdfb.dam[1] - bdfb.cam[1] - bbal + vdam - vcam
    format "z,zzz,zzz,zzz,zz9.99-"
    skip(10).
   end.
  end.
 end.
 end.
 if last-of(bjl.acc) then do :
     bbal = 0.
     vdam = 0.
     vcam = 0.
 end.
end.
end.
{report2.i 132}
{report3.i}
{image3.i}
