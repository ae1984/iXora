/* c-lon10.p
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

{c-lon1.f}.
define variable dzest as logical.
define variable i as integer.
{mainhead.i CLC1}.
readkey pause 0.

clear frame sec all.
i = 0.
m-ln = 0.
repeat with frame sec:
   if lastkey <> keycode("CURSOR-UP") and lastkey <>
      keycode("CURSOR-DOWN") and i < 14
   then do:
        i = i + 1.
        find next lonsec use-index lonsec no-error.
        if not available lonsec
        then do:
             find last lonsec use-index lonsec no-error.
             if not available lonsec
             then do:
                  i = 15.
                  create lonsec.
                  lonsec.ln = m-ln + 1.
                  /* find last lonsec . */
             end.
             {c-lon1.i}.
        end.
        else do:
             down with frame sec.
             display lonsec.apz
                     lonsec.lonsec
                     lonsec.des
                     lonsec.des1
                     lonsec.risk
                     with frame sec.
        end.
        if lonsec.ln > m-ln
        then m-ln = lonsec.ln.
   end.
   if lastkey = keycode("CURSOR-UP")
   then do:
        find prev lonsec use-index lonsec no-error.
        if not available lonsec
        then find first lonsec use-index lonsec.
        else up with frame sec.
        {c-lon1.i}.
        if lonsec.ln > m-ln
        then m-ln = lonsec.ln.
   end.
   if lastkey = keycode("CURSOR-DOWN") or i >= 14 and 
      lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("PF1") and
      lastkey <> keycode("PF4") and lastkey <> keycode("F10") and
      lastkey <> keycode("U8")
   then do:
        find next lonsec use-index lonsec  no-error.
        if not available lonsec
        then do:
             create lonsec.
             lonsec.ln = m-ln + 1.
             down with frame sec.
             {c-lon1.i}.
             if lonsec.lonsec = 0
             then delete lonsec.
             i = 0.
             clear frame sec all.
             readkey pause 0.
             for each lonsec use-index lonsec no-lock:
                 if i < 14
                 then do:
                      i = i + 1.
                      display lonsec.apz
                              lonsec.lonsec
                              lonsec.des
                              lonsec.des1
                              lonsec.risk
                              with frame sec.
                      down with frame sec.
                      pause 0.
                 end.
                 else leave.
             end.
             find prev lonsec use-index lonsec no-lock.
             if frame-line(sec) > 1
             then up with frame sec.
           /*   find last lonsec. */
        end.
        else do:
             down with frame sec.
             {c-lon1.i}.
             if lonsec.ln > m-ln
             then m-ln = lonsec.ln.
        end.
   end.
   if lastkey = keycode("U8") or lastkey = keycode("F10")
   then do:
        readkey pause 0.
        dzest = no.
        message "Nodzёst rindi‡u" lonsec.lonsec lonsec.des "?" update dzest.
        if dzest
        then do:
             i = 0.
             delete lonsec.
             clear frame sec all.
             for each lonsec use-index lonsec no-lock:
                 if i < 14
                 then do:
                      i = i + 1.
                      display lonsec.apz
                              lonsec.lonsec
                              lonsec.des
                              lonsec.des1
                              lonsec.risk
                              with frame sec.
                      down with frame sec.
                      pause 0.
                 end.
                 else leave.
             end.
             if frame-line(sec) > 1
             then up with frame sec.
        end.
   end.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
end.
find lonsec where lonsec.lonsec = 0 no-error.
if available lonsec
then delete lonsec.
hide frame sec.
