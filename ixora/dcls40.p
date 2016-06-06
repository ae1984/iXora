/* dcls40.p
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

/* x-gltot.p
*/

{global.i}

define shared var s-target as date.
define shared var s-bday as log.
define shared var s-intday as int.

define var vmonth as int.

vmonth = month(g-today).

for each gl where gl.type eq "A" or gl.type eq "L" or gl.type eq "O":
  for each crc where crc.sts ne 9:
  find gltot where gltot.gl eq gl.gl and gltot.crc eq crc.crc no-error.
  find glbal where glbal.gl eq gl.gl and glbal.crc eq crc.crc.
  if not available gltot
    then do:
      create gltot.
      gltot.gl = gl.gl.
      gltot.crc = crc.crc.
    end.
  gltot.cnt[vmonth] = gltot.cnt[vmonth] + 1.

  if gl.type eq "A"
    then do:
      gltot.dam[vmonth] = gltot.dam[vmonth] + glbal.bal * s-intday.
    end.
    else do:
      gltot.cam[vmonth] = gltot.cam[vmonth] + glbal.bal * s-intday.
    end.
  end. /* for each crc */
end. /* for each gl */

/*
for each dfb:
    dfb.dam[3] = dfb.dam[1].
    dfb.cam[3] = dfb.cam[1].
    dfb.dam[5] = dfb.dam[5] + (dfb.dam[1] - dfb.cam[1]) * s-intday.
end.
*/

for each iof:
    iof.dam[3] = iof.dam[1].
    iof.cam[3] = iof.cam[1].
    iof.dam[5] = iof.dam[5] + (iof.dam[1] - iof.cam[1]) * s-intday.
end.
