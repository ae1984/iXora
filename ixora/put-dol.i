/* put-dol.i
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

do:
/* display stream stm i0 n0. */
   rinda = substring(raksts,index(raksts,"$") + 1).
   repeat:
      raksts = substring(raksts,1,index(raksts,"$")).
      rinda1 = rinda.
      do i = i0 to i0 + n0 - 1:
         j = minimum(index(rinda1,"$"),index(rinda1,":")).
         if j = 0
         then j = index(rinda1,"$").
         if j = 0
         then leave.
         run aile(input-output r[i],j,output p2).
         raksts = raksts + p2 + substring(rinda1,j,1).
         rinda1 = substring(rinda1,j + 1).
      end.
      raksts = raksts + rinda1.
      do i = i + 1 to n:
         r[i] = "".
      end.
      do i = i0 to i0 + n0 - 1:
         if length(r[i]) > 0
         then leave.
      end.
      if i > i0 + n0 - 1 and {&last} and r7 = ""
      then leave.
      export stream s2 raksts.
      if i > i0 + n0 - 1
      then leave.
   end.
   if r7 <> ""
   then repeat:
        i = index(r7,"!").
        if {&last} and substring(r7,i + 1) = ""
        then do:
             raksts = "!" + substring(r7,1,i - 1).
             r7 = "".
             leave.
        end.
        export stream s2 "!" + substring(r7,1,i - 1).
        r7 = substring(r7,i + 1).
        if r7 = ""
        then leave.
   end.
   do i = 1 to n:
      r[i] = r0[i].
   end.
end.
