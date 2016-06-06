/* s-lonlg.p
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
        10.03.2011 ruslan добавил "Распоряжение"
*/

{s-lonlg.f}.
repeat:
   do i = 1 to 7:
      display ko[i] with frame ko.
   end.
   choose field ko go-on ("PF1" "PF4") with frame ko.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
   if frame-index = 1
   then do:
        hide frame ko.
        run pril.
   end.
   if frame-index = 2
   then do:
        hide frame ko.
        run raspr_lon.
   end.
   if frame-index = 3
   then do:
        hide frame ko.
        run s-lonlg3("frm-wrk").
   end.
   if frame-index = 4
   then do:
        hide frame ko.
        run s-lonlg3("papild").
   end.
   if frame-index = 5
   then do:
        hide frame ko.
        run s-lonlg3("liz-lig").
   end.
   if frame-index = 6
   then do:
        hide frame ko.
        run s-lonchs.
   end.
   if frame-index = 7
   then do:
        hide frame ko.
        leave.
   end.
end.
clear frame ko all.
hide  frame ko.
/*----------------------------------------------------------------------------
  #3.
     1.izmai‡a - pieslёgta programmas papild izsaukЅana.№Ё programma sa-
       v–c un druk– papildvienoЅan–s inform–ciju
-----------------------------------------------------------------------------*/
