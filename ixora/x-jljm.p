/* x-jljm.p
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

/* x-jljm.p
*/

def shared var g-today as date.

  /* Added by A.Panov for russian version 10.05.94 */

def var fxcash as log.
def buffer chs  for sysc.
find chs where chs.sysc = "CASHGL" no-lock.
find first sysc where sysc.sysc = "CASHFX" no-lock no-error.
if available sysc and sysc.loval then fxcash = true.
else fxcash = false.

/*  10.05.94 */

for each gl:
  for each crc where crc.sts ne 9:
    find glbal where glbal.gl eq gl.gl and glbal.crc eq crc.crc no-error.
    if not available glbal
    then do:
      create glbal.
      glbal.gl = gl.gl.
      glbal.crc = crc.crc.
    end. /* if not available glbal */
  end. /* for each crc */
end.  /* for each gl */

for each jh where jh.jdt eq g-today and jh.post eq false:
  for each jl of jh:
    if jl.dam = 0 and jl.cam = 0
      then do:
        delete jl.
        next.
      end.

      /* Added by A.Panov for russian version 10.05.94 */

 if jl.gl = chs.inval and jl.crc ne 1 and fxcash then do:

  jl.gl = sysc.inval.

 end.
 /* 10.05.94 */

    find gl of jl.
    /*********/
    find glbal where glbal.gl eq gl.gl and glbal.crc eq jl.crc.
    glbal.dam = glbal.dam + jl.dam.
    glbal.cam = glbal.cam + jl.cam.

    /********/

    if gl.subled ne "" then do:
           if gl.subled = "ast" then do: {jdtupdt.i ast} end.
      else if gl.subled = "bill" then do: {jdtupdt.i bill} end.
      /* else if gl.subled = "cif" then do: {jdtupdt.i aaa} end. */
      else if gl.subled eq "cif"
        then do:
          find aaa where aaa.aaa eq jl.acc no-error.
          if gl.level ge 1 and gl.level le 5 then do:
          if available aaa
            then do:
              if jl.dam ne 0
                then do:
                  aaa.ddt = jl.jdt.
                  aaa.lstdb = jl.dam.
                end.
                else do:
                  aaa.cdt = jl.jdt.
                  aaa.lstcr = jl.cam.
                end.
            end.
          end.
        end.
                                         /* BATCH PROCESSING FOR DFB */
      else if gl.subled = "dfb" then do: {jlupsub.i dfb} end.
      else if gl.subled = "eck" then do: {jdtupdt.i eck} end.
      else if gl.subled = "eps" then do: {jdtupdt.i eps} end.
      else if gl.subled = "fun" then do: {jdtupdt.i fun} end.
                                         /* BATCH PROCESSING FOR IOF */
      else if gl.subled = "iof" then do: {jlupsub.i iof} end.
      else if gl.subled = "lcr" then do: {jdtupdt.i lcr} end.
      else if gl.subled = "lon" and gl.level ne 2 then do: {jdtupdt.i lon} end.
      else if gl.subled = "ock" and gl.level <=5 then do: {jdtupdt.i ock} end.
     end.
  end.
  jh.post = true.
end.
