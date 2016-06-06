/* s-lonnd.p
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
        24/07/2010 madiyar - закомментировал содержимое пп. 2 и 4 (все равно в библиотеке нет такой программы)
*/

{s-lonnd.f}.
repeat:
   do i = 1 to 5:
      display ko[i] with frame ko.
   end.
   choose field ko go-on ("PF1" "PF4") with frame ko.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
   if frame-index = 1
   then do:
        hide frame ko.
        run s-lonnd1.
   end.
   if frame-index = 2
   then do:
        /*
        hide frame ko.
        run s-lonlg3("kl-novert").
        */
   end.
   if frame-index = 3
   then do:
        hide frame ko.
        run s-lonnd2.
   end.
   if frame-index = 4
   then do:
        /*
        hide frame ko.
        run s-lonchs.
        */
   end.
   if frame-index = 5
   then do:
        hide frame ko.
        leave.
   end.
end.
clear frame ko all.
hide  frame ko.
