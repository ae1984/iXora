/* s-garan.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        26.05.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
*/

{s-garan.f}.
repeat:
   do i = 1 to 2:
      display ko[i] with frame ko.
   end.
   choose field ko go-on ("PF1" "PF4") with frame ko.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
   if frame-index = 1
   then do:
        hide frame ko.
        run raspr_gar.
   end.
   if frame-index = 2
   then do:
        hide frame ko.
        leave.
   end.
end.
clear frame ko all.
hide  frame ko.



