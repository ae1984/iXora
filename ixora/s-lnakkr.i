/* s-lnakkr.i
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

repeat:
   m-ln = lnakkred.ln.
   display lnakkred.uno
           lnakkred.regdt
           lnakkred.duedt
           lnakkred.crc
           lnakkred.amount
           with frame akkr.  

   update  lnakkred.uno
           lnakkred.regdt
           lnakkred.duedt
           lnakkred.crc
           lnakkred.amount
           go-on("CURSOR-UP" "CURSOR-DOWN" "U8" "PF4" "PF3" "F10" )
           with frame akkr.


   if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("U8") and
   lastkey <> keycode("PF4") and lastkey <> keycode("F10")
   then do:
   if lnakkred.crc ne lon.crc then  do:  
       if lon.crc = 1 then do:
          find last crc where crc.crc = lnakkred.crc no-lock no-error.
          s1 = lnakkred.amount * crc.rate[1].
       end.
       if lon.crc ne 1 then do:
          find last crc where crc.crc = lnakkred.crc no-lock no-error.
          v-sum = lnakkred.amount * crc.rate[1].

          find last crc where crc.crc = lon.crc no-lock no-error.
          s1 = v-sum / crc.rate[1].
       end.
   end.
   else s1 = lnakkred.amount.


      if s1 > lon.opnamt - (lon.dam[1] - lon.cam[1]) or lnakkred.amount < 0 or
           not can-find(uno where uno.uno = lnakkred.uno and uno.grupa = grp) 
           or not can-find(crc where crc.crc = lnakkred.crc)
        then undo,next.
   end.

   if frame akkr lnakkred.uno        entered
      or frame akkr lnakkred.regdt   entered
      or frame akkr lnakkred.duedt   entered
      or frame akkr lnakkred.amount  entered
      or frame akkr lnakkred.crc     entered
   then do:
        lnakkred.who = userid("bank").
        lnakkred.whn = g-today.
   end.
   display lnakkred.uno
           lnakkred.regdt
           lnakkred.duedt
           lnakkred.crc
           lnakkred.amount
           with frame akkr.  
   leave.
end.
pause 0.
