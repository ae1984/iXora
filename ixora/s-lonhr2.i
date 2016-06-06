/* s-lonhr2.i
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

/*------------------------
  #3.Statuss
------------------------*/
repeat:
   m-ln = lonhar.ln.
   if lonhar.rez-log[1]
   then z = "*".
   else z = "".
   display lonhar.fdt
           lonhar.lonstat
           z
           lonhar.who
           lonhar.whn
           with frame har.
   update  lonhar.fdt
           lonhar.lonstat
           go-on("CURSOR-UP" "CURSOR-DOWN" "U8" "F10" "PF4")
           with frame har.
   if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("U8") and
   lastkey <> keycode("PF4") and lastkey <> keycode("F10")
   then if not can-find(lonstat where lonstat.lonstat = lonhar.lonstat)
        then undo,next.
   if    frame har lonhar.fdt        entered
      or frame har lonhar.lonstat    entered
   then do:
        if lonhar.rez-log[1]
        then do:
             bell.
             message "После ввода накоплений редактировать нельзя".
             pause.
             undo,retry.
        end.
        if lonhar.lonstat > 0
        then do:
             find lonstat where lonstat.lonstat = lonhar.lonstat no-lock.
             display lonstat.apz with frame har.
        end.
        lonhar.who = userid("bank").
        lonhar.whn = today.
        display lonhar.who
                lonhar.whn with frame har.
   end.
   leave.
end.
pause 0.
