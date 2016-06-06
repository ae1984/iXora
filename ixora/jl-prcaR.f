/* jl-prcaR.f
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

/* printer from OFC */

def shared var v-point like point.point.

find point where point.point = v-point no-lock no-error.

find first cmp.
put skip(3)
"============================================================================="
skip
    cmp.name "    Кассовый Ордер     "
jh.jdt " " string(time,"HH:MM") "   * " jh.who skip
point.addr[1] skip.
if point.addr[2] <> " " then put point.addr[2] skip.
if point.addr[3] <> " " then put point.addr[3] skip.
put point.regno skip point.licno skip
" " jh.jh " " jh.cif " " jh.party  skip
"============================================================================="
.

find sysc where sysc.sysc = "CASHGL".

for each jl of jh use-index jhln where jl.gl = sysc.inval no-lock
        break by jl.crc :
find crc of jl.
if jl.dam gt 0 then do: xin = jl.dam. xout = 0. intot = intot + xin. end.
else do:
 xin = 0. xout = jl.cam.  outtot = outtot + xout. end.
 disp crc.des label "CURRENCY"
      xin (sub-total by jl.crc)
      xout(sub-total by jl.crc)
      with  no-box down frame inout .
end.
put
"============================================================================="
skip
"                  |                   |                   |                 "
skip
"=============================================================================".

/* by sasco */
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[2] = 1 then put skip(14).
else put skip(1).


