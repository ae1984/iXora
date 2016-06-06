/* c-lon.i
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

{&vecais} = {&jaunais}.
if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("CURSOR-DOWN") and
   lastkey <> keycode("PREV-PAGE") and lastkey <> keycode("NEXT-PAGE") and
   lastkey <> keycode("PF1") and lastkey <> keycode("U8") and
   lastkey <> keycode("F10") and lastkey <> keycode("PF4")
then
repeat:
   update {&jaunais} go-on("CURSOR-UP" "CURSOR-DOWN" "PREV-PAGE" "NEXT-PAGE"
                           "U8" "F10" "PF1")
          with frame {&frame}.
   if frame {&frame} {&jaunais} entered and {&vecais} <> {&no-ctr}
   then do:
        ja-ne = no.
        message m3 {&vecais} m4 {&jaunais} "?" update ja-ne.
        if not ja-ne
        then do:
             bell.
             {&jaunais} = {&vecais}.
             display {&jaunais} with frame {&frame}.
        end.
        else leave.
   end.
   else leave.
end.
