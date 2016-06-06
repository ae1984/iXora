/* s-lonnd21.p
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

/*-----------------------------------------------------------------------------
  #3.
     1.izmai‡a - izmainЁts ±Ёlu skaits no 5 uz 25
------------------------------------------------------------------------------*/
{s-lonnd21a.f}.
find loncon where loncon.lon = s-lon.
readkey pause 0.
run s-secchs.
if lastkey = keycode("PF4")
then return.
do transaction:
   find first lonsec1 where lonsec1.lon = s-lon and lonsec1.ln = m-ln[1].
   {s-lonnd21b.f}.
   clear frame pielik all.
   i = 0.
   repeat:
      if lastkey <> keycode("CURSOR-UP") and lastkey <>
         keycode("CURSOR-DOWN")
      then do:
           i = i + 1.
           if i > 10
           then i = 10.
           if length(lonsec1.pielikums[i]) = 0
           then do:
                i = i - 1.
                if i = 0
                then i = 1.
            end.
            do j = 1 to 10:
               display lonsec1.pielikums[j] with frame pielik.
            end.
            pause 0.
            update  lonsec1.pielikums[i] go-on("CURSOR-UP" "CURSOR-DOWN" "U8"
                    "F10") with frame pielik.
            down with frame pielik.
      end.
      if lastkey = keycode("CURSOR-UP")
      then do:
           i = i - 1.
           if i = 0
           then i = 1.
           else up with frame pielik.
           do j = 1 to 10:
              display lonsec1.pielikums[j] with frame pielik.
           end.
           pause 0.
           update  lonsec1.pielikums[i] go-on("CURSOR-UP" "CURSOR-DOWN" "U8"
                   "F10") with frame pielik.
      end.
      if lastkey = keycode("CURSOR-DOWN")
      then do:
           i = i + 1.
           if i > 10
           then i = 10.
           else down with frame pielik.
           do j = 1 to 10:
              display lonsec1.pielikums[j] with frame pielik.
           end.
           pause 0.
           update  lonsec1.pielikums[i] go-on("CURSOR-UP" "CURSOR-DOWN" "U8"
                   "F10") with frame pielik.
      end.
      if lastkey = keycode("U8") or lastkey = keycode("F10")
      then do:
           readkey pause 0.
           do i = i to 9:
              lonsec1.pielikums[i] = lonsec1.pielikums[i + 1].
              if length(lonsec1.pielikums[i + 1]) = 0
              then leave.
           end.
           lonsec1.pielikums[10] = "".
           i = 0.
           clear frame pielik all.
      end.
      if lastkey = keycode("PF1") or lastkey = keycode("PF4")
      then leave.
   end.
   hide frame pielik.
end.
