/* dcls_dr.p
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

{global.i}
def var vparam as char.
def var rcode as int.
def var rdes as char.
def new shared var s-jh like jh.jh.
define variable vdel as character initial "^".
def var v-sub like gl.subled.
def var v-dam like jl.dam init 0.
def var v-cam like jl.dam init 0.

s-jh = 0.
output to rpt1.img.

for each gl where gl.type eq "R" and gl.totlev = 1 and gl.totact = no:
   for each glbal where glbal.gl = gl.gl and glbal.bal ne 0 .
     displ glbal.gl gl.totact gl.subled gl.lev format "99" glbal.bal skip.
     v-sub = "".
     if gl.subled <> "" 
      then do: 
           v-sub = gl.subled.
           gl.subled = "".
      end. 
     if glbal.bal > 0 then vparam = string(glbal.bal) + vdel +
                                    string(glbal.gl) + vdel +
                                    '499970' + vdel +
                                    'Свертка доходов'.
     if glbal.bal < 0 then vparam = string(glbal.bal * (-1)) + vdel +
                                    '499970' + vdel +
                                    string(glbal.gl) + vdel +
                                    'Свертка доходов'.
     run trxgen("dcl0008", vdel, vparam,
         " ", "", output rcode, output rdes, input-output s-jh).
    gl.subled = v-sub.
    displ s-jh rcode rdes format "x(40)" skip.
   end.
end.

for each gl where gl.type eq "E" and gl.totlev = 1 and gl.totact = no:
   for each glbal where glbal.gl = gl.gl and glbal.bal ne 0 .
     displ glbal.gl gl.totact gl.subled gl.lev format "99" glbal.bal skip.
     v-sub = "".
     if gl.subled <> "" 
      then do: 
           v-sub = gl.subled.
           gl.subled = "".
      end. 
     if glbal.bal > 0 then vparam = string(glbal.bal) + vdel +
                                    '499970' + vdel +
                                    string(glbal.gl) + vdel +
                                    'Свертка расходов'.
     if glbal.bal < 0 then vparam = string(glbal.bal * (-1)) + vdel +
                                    string(glbal.gl) + vdel +
                                    '499970' + vdel +
                                    'Свертка расходов'.
     run trxgen("dcl0008", vdel, vparam,
         " ", "", output rcode, output rdes, input-output s-jh).
    gl.subled = v-sub.
    displ s-jh rcode rdes format "x(40)" skip.
   end.
end.

s-jh = 0.
find first glbal where glbal.gl = 499970 no-error.
for each jl where jl.jdt eq g-today and jl.crc eq 1 and jl.gl eq 499970 no-lock:
    v-dam = v-dam + jl.dam.
    v-cam = v-cam + jl.cam.
end.

if glbal.bal + v-cam - v-dam > 0 then do:
   vparam = string(glbal.bal + v-cam - v-dam) + vdel +
            '499970' + vdel +
            '359911' + vdel +
            'Перечисление доходов'.
   run trxgen("dcl0008", vdel, vparam,
         " ", "", output rcode, output rdes, input-output s-jh).
  displ s-jh rcode rdes format "x(40)" skip.
end.
if glbal.bal + v-cam - v-dam < 0 then do:
   vparam = string((glbal.bal + v-cam - v-dam) * (-1)) + vdel +
            '359911' + vdel +
            '499970' + vdel +
            'Перечисление доходов'.
   run trxgen("dcl0008", vdel, vparam,
         " ", "", output rcode, output rdes, input-output s-jh).
  displ s-jh rcode rdes format "x(40)" skip.
end.

output close.
