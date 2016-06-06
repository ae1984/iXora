/* s-lonhr1.i
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

/*------------------------------
  #3.Bilance
------------------------------*/
repeat:
   m-ln = lonhar.ln.
   display lonhar.fdt
           lonhar.finrez
           lonhar.akc
           lonhar.who
           lonhar.whn
           with frame har.
   update  lonhar.fdt
           lonhar.finrez
           lonhar.akc
           go-on("CURSOR-UP" "CURSOR-DOWN" "U8" "F10" "PF4" "PF3")
           with frame har.
   if lastkey = keycode("PF3")
   then do:
        lonhar.finrez = 999999999999.99.
        next.
   end.
   if    frame har lonhar.fdt     entered
      or frame har lonhar.akc     entered
      or frame har lonhar.finrez  entered
   then do:
        lonhar.cif = lon.cif.
        lonhar.who = userid("bank").
        lonhar.whn = today.
        display lonhar.who
                lonhar.whn with frame har.
   end.
   leave.
end.
pause 0.
