/* corrtg.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет по ностро счету - 900161014
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
        10.01.2005 saltanat
 * CHANGES
*/

{mainhead.i}

 def buffer bdfb for bank.dfb.
 def var vdam like jl.dam.
 def var vcam like jl.cam.
 def var bbal like jl.cam.
 def var vdfb like rem.tdfb init "400161670".
 def var sdate as date.
 def var podate as date.
 def buffer bjl for bank.jl.
 def var c1 as char format "x(24)".
 def var c2 as char format "x(16)".
 def var c3 as char.
 def var c4 as char format "x(11)".
 def var c5 as char.
 def var c6 as char.
 def var c7 as char format "x(11)".
 def var c8 as char.

 {sdf.f}.
 {dfc.f}.

{image1.i rpt.img}
{image2.i }

{report1.i 59}

put chr(15).

put space(5) "ОБЩИЙ ОБЪЕМ ИСХОДЯЩИХ ПЛАТЕЖЕЙ ПО НОСТРО СЧЕТУ " vdfb skip(1).
put space(20) c2 sdate c3 podate.
put skip(1) "--------------------------------------------------------------------------------" skip.

for each bank.gl where bank.gl.subled = "DFB" and bank.gl.lev = 1 no-lock:

for each bjl where bjl.jdt >= sdate and bjl.jdt <= podate
               and bjl.acc = vdfb and bjl.gl = bank.gl.gl
         break by bjl.jdt.
find jh where jh.jh = bjl.jh no-lock.
 accumulate bjl.cam  ( total by bjl.jdt ) .

if last-of(bjl.jdt) then  do:

find bdfb where bdfb.dfb = bjl.acc no-lock.

  vcam =  accum total by bjl.jdt bjl.cam .
  bbal = bbal + vcam .

  put bjl.jdt vcam format "z,zzz,zzz,zzz,zz9.99" skip.
end.
end.
end.
put skip(1) "------------------------ ИТОГО: " bbal
            "------------------------------" skip.
{report2.i 132}
{report3.i}
{image3.i}
