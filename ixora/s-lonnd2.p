/* s-lonnd2.p
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
        24/07/2010 madiyar - закомментировал содержимое п. 2 (все равно в библиотеке нет такой программы)
*/

{s-lonnd2.f}.
repeat:
   do i = 1 to 3:
      display ko1[i] with frame ko1.
   end.
   choose field ko1 go-on ("PF1" "PF4") with frame ko1.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
   if frame-index = 1
   then do:
        hide frame ko1.
        run s-lonnd21.
   end.
   if frame-index = 2
   then do:
        /*
        hide frame ko1.
        run s-lonlg3("kl-lgm").
        */
   end.
   if frame-index = 3
   then do:
        hide frame ko1.
        leave.
   end.
end.
clear frame ko1 all.
